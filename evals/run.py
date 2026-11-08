#!/usr/bin/env python3
"""Orchestrate eval harness.

  run.py prepare RUN_DIR [id ...]   copy fixtures to RUN_DIR/work/<id>, write RUN_DIR/prompts/<id>.txt
  run.py grade   RUN_DIR [id ...]   grade RUN_DIR/results/<id>.txt (+ the work dir) against cases.json

Dispatching is done by the caller (one sub-agent per prompt file); this script
only prepares inputs and grades outputs, so it is model-agnostic.
"""
import filecmp, glob, json, os, re, shutil, subprocess, sys

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(HERE)

PROMPT = """You are running inside an evaluation. Your instructions are in the file:
{target}
Read it fully first, then follow it exactly as your system instructions (sibling `references/` and `scripts/` paths resolve relative to that file).

Project root for this task: {work}
Treat it as the repository. Read and write only inside it (plus reading your instructions). Do not touch any git state.
You run unattended: no human can answer mid-run. Where your instructions say to ask or stop, end the run with the report that asks or stops. No other skills or sub-agents are available unless the task says so.

TASK
----
{task}
----

When finished, write your complete final report, verbatim and in the format your instructions require, to:
{result}
Then reply with only the word: done"""


def load(ids):
    cases = json.load(open(os.path.join(HERE, "cases.json")))
    return [c for c in cases if not ids or c["id"] in ids]


def prepare(run, ids):
    for sub in ("work", "prompts", "results"):
        os.makedirs(os.path.join(run, sub), exist_ok=True)
    for c in load(ids):
        work = os.path.join(run, "work", c["id"])
        shutil.rmtree(work, ignore_errors=True)
        shutil.copytree(os.path.join(HERE, "fixtures", c["fixture"]), work)
        with open(os.path.join(run, "prompts", c["id"] + ".txt"), "w") as f:
            f.write(PROMPT.format(target=os.path.join(ROOT, c["target"]), work=work, task=c["task"],
                                  result=os.path.join(run, "results", c["id"] + ".txt")))
        print(c["id"])


def tree_equal(a, b):
    if os.path.isfile(a) or os.path.isfile(b):
        return os.path.isfile(a) and os.path.isfile(b) and filecmp.cmp(a, b, shallow=False)
    if not (os.path.isdir(a) and os.path.isdir(b)):
        return False
    fa = sorted(os.path.relpath(p, a) for p in glob.glob(a + "/**", recursive=True, include_hidden=True) if os.path.isfile(p) and "__pycache__" not in p)
    fb = sorted(os.path.relpath(p, b) for p in glob.glob(b + "/**", recursive=True, include_hidden=True) if os.path.isfile(p) and "__pycache__" not in p)
    return fa == fb and all(filecmp.cmp(os.path.join(a, x), os.path.join(b, x), shallow=False) for x in fa)


def strip_code(text):
    text = re.sub(r"```.*?```", "", text, flags=re.S)
    return re.sub(r"`[^`\n]*`", "", text)


def check(c, ch, report, work):
    t, fl = ch["type"], (re.I if "i" in ch.get("flags", "") else 0)
    fix = os.path.join(HERE, "fixtures", c["fixture"])
    rd = lambda p: open(os.path.join(work, p), errors="replace").read()
    if t == "report_match":
        return bool(re.search(ch["pattern"], report, fl | re.M)), ch["pattern"]
    if t == "report_absent":
        return not re.search(ch["pattern"], report, fl | re.M), "absent " + ch["pattern"]
    if t == "unchanged":
        return all(tree_equal(os.path.join(work, p), os.path.join(fix, p)) for p in ch["paths"]), "unchanged " + ",".join(ch["paths"])
    if t == "file_exists":
        return os.path.exists(os.path.join(work, ch["path"])), "exists " + ch["path"]
    if t == "file_absent":
        p = os.path.join(work, ch["path"]) if "path" in ch else None
        hits = glob.glob(os.path.join(work, ch.get("glob", ch.get("path", ""))))
        return not hits, "absent " + ch.get("path", ch.get("glob"))
    if t == "file_match":
        try:
            return bool(re.search(ch["pattern"], rd(ch["path"]), fl)), f'{ch["path"]} ~ {ch["pattern"]}'
        except FileNotFoundError:
            return False, f'{ch["path"]} missing'
    if t == "file_forbid":
        try:
            s = rd(ch["path"])
        except FileNotFoundError:
            return False, f'{ch["path"]} missing'
        s = strip_code(s) if ch.get("strip_code") else s
        m = re.search(ch["pattern"], s, fl)
        return not m, f'{ch["path"]} forbids {ch["pattern"]}' + (f' (found {m.group(0)!r})' if m else "")
    if t == "file_glob_match":
        files = [p for p in glob.glob(os.path.join(work, ch["glob"]), recursive=True)
                 if not os.path.exists(os.path.join(fix, os.path.relpath(p, work)))]
        hits = [p for p in files if re.search(ch["pattern"], open(p, errors="replace").read(), fl)]
        return len(hits) >= ch.get("min_new", 1), f'{ch["glob"]} new files ~ {ch["pattern"]} ({len(hits)})'
    if t == "cmd":
        r = subprocess.run(ch["cmd"], shell=True, cwd=work, capture_output=True, text=True, timeout=120)
        return r.returncode == 0, "cmd " + ch["cmd"]
    raise SystemExit("unknown check " + t)


def grade(run, ids):
    out, tot_p, tot_t = [], 0, 0
    for c in load(ids):
        rp = os.path.join(run, "results", c["id"] + ".txt")
        work = os.path.join(run, "work", c["id"])
        if not os.path.exists(rp):
            out.append({"id": c["id"], "target": c["target"], "status": "NO_RESULT", "checks": []}); continue
        report = open(rp, errors="replace").read()
        res = []
        for ch in c["checks"]:
            try:
                ok, what = check(c, ch, report, work)
            except Exception as e:
                ok, what = False, f"error {e}"
            res.append({"ok": ok, "what": what})
        p = sum(r["ok"] for r in res)
        out.append({"id": c["id"], "target": c["target"], "status": "PASS" if p == len(res) else "FAIL", "passed": p, "total": len(res), "checks": res})
    for o in out:
        print(f'{o["status"]:9} {o["id"]:36} {o.get("passed","-")}/{o.get("total","-")}')
        for r in o["checks"]:
            if not r["ok"]:
                print("            x", r["what"])
    json.dump(out, open(os.path.join(run, "grade.json"), "w"), indent=1)
    print(f'\n{sum(o["status"]=="PASS" for o in out)}/{len(out)} cases passed')


if __name__ == "__main__":
    if len(sys.argv) < 3 or sys.argv[1] not in ("prepare", "grade"):
        raise SystemExit(__doc__)
    {"prepare": prepare, "grade": grade}[sys.argv[1]](os.path.abspath(sys.argv[2]), sys.argv[3:])

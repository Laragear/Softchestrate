#!/usr/bin/env python3
"""Check an investigation report against the shape in references/report-template.md.

Usage: python check_report.py REPORT.md

Checks (each failure prints one line `line N: message`):
  - the five sections exist, in order: Abstract, Prompt description, Process, Findings, Conclusion
  - the Abstract has an `**ELI10:**` line of fewer than 100 words
  - every `### F<n>` finding has a footnote reference `[^k]` (or the word Absent) and nothing else is cited
  - `**Summary of findings:**` exists and holds fewer than 50 words
  - every footnote used is defined, every definition is used, and each definition names a tier
    (Local, Official, Authority, Experts, Third party) and an access date
  - every `###` section under Conclusion holds fewer than 200 words

Exit codes: 0 no problems, 1 problems found, 2 unreadable file or bad usage.
Standard library only; no network; read-only.
"""
import re
import sys

SECTIONS = ["abstract", "prompt description", "process", "findings", "conclusion"]
TIERS = ("local", "official", "authority", "experts", "third party")
MAX_ELI10, MAX_SUMMARY, MAX_CONCLUSION_SECTION = 100, 50, 200


def words(text):
    return len(re.findall(r"\S+", text))


def main(argv):
    if len(argv) != 2 or argv[1] in ("-h", "--help"):
        print(__doc__)
        return 0 if len(argv) == 2 else 2
    try:
        lines = open(argv[1], encoding="utf-8").read().splitlines()
    except OSError as error:
        print(f"cannot read {argv[1]}: {error}")
        return 2

    problems = []

    def problem(number, message):
        problems.append(f"line {number}: {message}")

    heading = re.compile(r"^##\s+(?:\d+\.\s*)?(.+?)\s*$")
    starts = {}
    for index, line in enumerate(lines, 1):
        match = heading.match(line)
        if match and not line.startswith("###"):
            starts.setdefault(match.group(1).lower(), index)
    positions = []
    for name in SECTIONS:
        if name not in starts:
            problem(1, f"missing section '{name}'")
        else:
            positions.append(starts[name])
    if positions != sorted(positions):
        problem(1, "sections are out of order; expected " + ", ".join(SECTIONS))

    def block(name):
        if name not in starts:
            return []
        end = len(lines)
        for other in starts.values():
            if other > starts[name]:
                end = min(end, other - 1)
        return list(enumerate(lines[starts[name]:end], starts[name] + 1))

    eli = [(n, l) for n, l in block("abstract") if l.startswith("**ELI10:**")]
    if not eli:
        problem(starts.get("abstract", 1), "Abstract has no '**ELI10:**' line")
    elif words(eli[0][1].replace("**ELI10:**", "")) >= MAX_ELI10:
        problem(eli[0][0], f"ELI10 must be under {MAX_ELI10} words")

    findings = block("findings")
    definitions = {}
    for number, line in findings:
        match = re.match(r"^\[\^([^\]]+)\]:\s*(.*)", line)
        if match:
            definitions[match.group(1)] = (number, match.group(2))
    used = set()
    current = None
    for number, line in findings + [(len(lines) + 1, "### F-end")]:
        if line.startswith("### F"):
            if current:
                start, text = current
                refs = set(re.findall(r"\[\^([^\]]+)\](?!:)", text))
                used |= refs
                if not refs and "absent" not in text.lower():
                    problem(start, "finding cites no footnote and does not say Absent")
            current = (number, "")
        elif current:
            if line.startswith("**Summary of findings:**"):
                if words(line.replace("**Summary of findings:**", "")) >= MAX_SUMMARY:
                    problem(number, f"summary of findings must be under {MAX_SUMMARY} words")
            if not re.match(r"^\[\^[^\]]+\]:", line):
                current = (current[0], current[1] + "\n" + line)
    if not any(l.startswith("**Summary of findings:**") for _, l in findings):
        problem(starts.get("findings", 1), "Findings has no '**Summary of findings:**' line")

    for key in sorted(used - set(definitions)):
        problem(starts.get("findings", 1), f"footnote [^{key}] is used but not defined")
    for key in sorted(set(definitions) - used):
        problem(definitions[key][0], f"footnote [^{key}] is defined but never used")
    for key, (number, text) in definitions.items():
        if not any(tier in text.lower() for tier in TIERS):
            problem(number, f"footnote [^{key}] names no tier ({', '.join(TIERS)})")
        if "access" not in text.lower():
            problem(number, f"footnote [^{key}] has no access date")

    section_start = None
    section_words = 0
    for number, line in block("conclusion") + [(len(lines) + 1, "### end")]:
        if line.startswith("### "):
            if section_start and section_words >= MAX_CONCLUSION_SECTION:
                problem(section_start, f"conclusion section must be under {MAX_CONCLUSION_SECTION} words (has {section_words})")
            section_start, section_words = number, 0
        elif section_start:
            section_words += words(line)

    if problems:
        print("\n".join(problems))
        return 1
    print("report shape OK")
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))

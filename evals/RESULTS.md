# Eval results

Three independent runs of all 27 cases (81 sub-agent runs), each on the cheapest model tier, from fresh fixture copies with no manual edits, graded with the final `cases.json`.

| Run | Passed |
| --- | --- |
| A | 27/27 |
| B | 27/27 |
| C | 27/27 |

Two assertions were corrected after seeing run B and C results, both because the check was wrong, not the definition:

- `investigating-conflict` required the working directory to stay unchanged, but the skill tells the agent to keep a `tree.md` working file there. It now guards only `README.md` and `src/`.
- `writing-docs-voice` required the README to mention the optional `DEFAULT_SEPARATOR` constant. Two of three runs omitted it. Dropped; the voice rules and the two public methods are still checked.

Open findings about the definitions (not failures):

- `code-reviewer` (resolved): `STATUS: OK | FAIL` was ambiguous, so the definition now uses `OK | INVALID_SCOPE`; findings and failed criteria never change `STATUS`. The cases now require `OK` and `INVALID_SCOPE`. Rerun on the cheapest tier, 3 repeats: both cases pass 3/3.
- `refactoring-code`: agents keep an unused public function and ask, which matches the "public names are fixed" rule.

Limits: one tier only, mostly gate and contract cases, no live-tool cases (real deploys, container builds, `WRONG_ENTRY`).

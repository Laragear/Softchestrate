# Evals

Behavioral evals for the agents and skills. Each case in `cases.json` names a definition (`target`), a fixture project (`fixtures/<name>`), a task, and mechanical checks on the report and on the working directory (regex on the report, files unchanged/created/forbidden, a shell command that must exit 0).

Most cases test a gate or contract (invalid input stops, read-only roles change nothing, the seeded flaw is found, the safe code is not flagged) rather than prose quality, so they grade cheaply and deterministically.

```sh
python3 evals/run.py prepare RUN_DIR [case-id ...]   # copies fixtures, writes RUN_DIR/prompts/<id>.txt
# dispatch one sub-agent per prompt file; each writes RUN_DIR/results/<id>.txt
python3 evals/run.py grade RUN_DIR [case-id ...]     # prints pass/fail, writes RUN_DIR/grade.json
```

Dispatching is left to the harness so the suite stays model-agnostic. The first run used the cheapest tier for every case, as a floor: a definition that fails there is under-specified rather than just hard.

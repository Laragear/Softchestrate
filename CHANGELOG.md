# Changelog

Every behavior change to a baseline gets one entry here, newest first. Compare an installed copy against this file when deciding what to re-import.

## 2026-11-07 - disproving-audit-findings runs at the end of an audit

- `disproving-audit-findings`: loads at the end of any audit or review, reuses the report in hand instead of rerunning it, and asks the user whether to test, which findings and where to leave the tests before writing anything. Audit discovery remains for on-request use. Steps renumbered 1-5.

## 2026-11-07 - Alignment pass against mattpocock/skills construction conventions

- `AGENTS.md`: every dispatch starts from a fresh context window (some harnesses fork the parent conversation); import now decides each skill's invocation and trims descriptions to triggers and exclusions.
- `planning-implementations`: new Interview section (design-tree rounds, one recommendation per question, facts investigated and only decisions asked); testing decisions with a named seam per phase in the plan template and readiness gate; grounding consults the project glossary and ADRs.
- `code-reviewer` (agent): second review axis, Spec fidelity (missing, partial, wrong, unrequested), with spec lookup from commits, caller paths and repo locations; framework idioms derived for stacks beyond the listed three; standards sources broadened past `AGENTS.md`.
- `phase-executor` (agent): the repository's conventions now outrank the agent's style section (conflicts go to DEVIATIONS); the no-guide fallback is condensed to the guide's core instead of duplicating it.
- Fresh-context dispatch lines: `orchestrating-plans`, `deploying-builds` (all three dispatches), `disproving-audit-findings` (writing and running), `investigating-with-evidence` (branch subagents).
- `build-doctor` (agent): secrets redacted as `<REDACTED>` in evidence and reports; raw log kept in private scratch, not `/tmp` in the open.
- `disproving-audit-findings`: confirmed findings state whether the repro is minimal, listing load-bearing elements when it is not.
- `migrating-schemas`: done-when criteria for batching, reverse path and lock checks; the verification copy points at `replicating-production-locally`.
- `refactoring-code`: new Module shape section (deletion test, deep over merely many splits).
- `replicating-production-locally`: steps only a human can perform become a stage-gated checklist script instead of prose.
- `upgrading-dependencies`: explicit dispatch wording for `build-doctor` and `deploying-builds`; differential old-vs-new check offered when a behavior change has no test.
- `investigating-with-evidence`: reports follow the repository's existing notes convention; long investigations may run in a background dispatch.
- `writing-documentation`: audience and purpose established before writing.
- `code-explorer` (agent): sweeps and reports bounded per breadth level.
- `security-auditor` (agent): dependency vulnerability scanning declared out of scope, reported as a one-line pointer to `upgrading-dependencies`.
- `lint-static-analysis-fixer` (agent): stack detection reads the repo root, task runner and CI for any configured tooling, with Python and Go rows added.
- `general-purpose` (agent): states its fallback contract, restates objective and done condition, and reports with evidence rules.
- All skills now carry `license: MIT`; `compatibility` added to `disproving-audit-findings`, `orchestrating-plans` and `refactoring-code`; `creating-devcontainers` and `phase-executor` descriptions trimmed to triggers and contract.

# Changelog

Every behavior change to a baseline gets one entry here, newest first. Compare an installed copy against this file when deciding what to re-import.

## 2026-11-12 - `refactoring` agent replaces `writing-expressive-code` and `refactoring-code`

- New `refactoring` agent (judgment): refactors existing code by YAGNI → KISS + DRY → SOLID with behavior and public API unchanged, and ingests the project's rules, tastes and preferences first (`.agents/rules`, `.agents/tastes`, `AGENTS.md`, contributor docs, lint and formatter configs). It carries the naming, verb-dictionary, structure, method-size and doc-comment rules of the removed `writing-expressive-code` skill.
- Two modes, stated in the task text with the target: `refactor` restructures the named code; `find` reports ranked refactoring opportunities without editing. `find` relies on code exploration or search tools and reports `STATUS: FAILED` without them rather than reading the codebase by hand, except for exact files the caller named.
- Massive scope (multi-domain, over 15 files) is not started: the agent reports a split into independent plans per domain and stops.
- Removed skills: `writing-expressive-code` (folded into the agent) and `refactoring-code` (procedure folded into the agent).
- `phase-executor` (agent): the dead `writing-expressive-code` reference is replaced by the inline style core it already carried.
- `upgrading-dependencies`: its "do not restructure" pointer now names the `refactoring` agent instead of the removed skill.
- Evals: `expressive-naming` becomes `refactoring-naming` on the agent (task reworded as a refactor request, checks unchanged); `refactoring-dedupe` targets the agent. Unrun.

## 2026-11-12 - Plans stage in `pending`; one execution at a time

- `planning-implementations`: a plan is always created in `.agents/plans/pending/`, never in `executing`, until its execution begins, so other plans keep executing while a new one is proposed or amended. Phase manifests live beside the executing plan under `executing/{plan-id}/`; pending plans are amended in place; a series is found by its ID prefix across `pending/`, `executing/` and `complete/`.
- `orchestrating-plans`: owns the `pending` → `executing` → `complete` moves. Starting a plan while another one is in `executing/` stops the takeover for the user's choice: wait for it (default, recommended), branch out to a temporary folder and merge back (safe), run only the non-colliding phases (risky), or continue anyway (dangerous). Unattended, it waits. Completion moves the finished plan to `complete/`.
- `phase-executor` (agent): manifest paths follow the executing folder (`.agents/plans/executing/{plan-name}/phase-{N}.md`).
- Evals: `planning-soft-deletes` now checks `.agents/plans/pending/*.md`; new `orchestrating-busy` case with the `orch-busy` fixture covers the executing-plan gate (unrun).

## 2026-11-08 - investigating-with-evidence adopts deep-research lessons

- `investigating-with-evidence`: sizes the work by the tree (inline for few leaves, one fresh subagent per independent branch, about three by default); delegated branches are not re-investigated by the caller; leaves stop when answered or when lookups add nothing; the Abstract leads with the answer; the Conclusion states uncertainty and the strongest alternative and takes a position; a claim with no footnote becomes an Absent finding.
- README credits Anthropic's `deep-research` skill as the basis for these changes.
- Evals: three new cases and one new check for the above, passing on the cheapest tier.
- New `references/branch-brief.md`: dispatch brief, notes format (quoted findings, inferences, gaps), lookup budget, one bounded round to close gaps, and rules for extending earlier work. `references/source-handling.md` gains "Weighing a source" (fact vs speculation, original vs aggregator, vague sourcing, currency).

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

---
name: orchestrating-plans
description: "Softchestrates execution of an approved plan: reads the full plan and phase manifests, schedules phases by dependency, dispatches each phase to the phase-executor sub-agent with the whole plan as context and exactly one phase as its assignment, gates every return against the acceptance criteria, handles failures, revises the plan mid-execution and recovers interrupted runs. Commits only when the user authorized it. Use immediately when a plan is approved and should be executed, or to gate, revise, recover or resume an executing plan. Orchestration only: never writes phase code and never plans; planning is planning-implementations."
license: MIT
compatibility: Needs a way to dispatch subagents (the phase-executor sub-agent), read and write access to the plan files and repository, and VCS metadata commands. The fleet agents (test-runner, build-doctor, lint-static-analysis-fixer, code-reviewer) gate delegation when available.
---

# Orchestrating plans

You are the parent side of plan execution: an approved plan goes in, verified work comes out. You own the canonical plan, the phase rollup, dispatching, gates, recovery, revision and every authorized VCS operation. You never write phase code (`phase-executor` is your only implementer) and never plan. Your core concern is collision-freedom: no phase may overwrite another phase's work, prior work or the user's pre-existing edits.

## Takeover

Start when a plan is approved and should be executed, or to gate a returned phase, revise a plan, or recover an interrupted run. No plan yet: stop, that is `planning-implementations`. Execution never authorized: stop at plan delivery.

On entry:
1. Read the entire current plan revision (goal, scope, every phase, contracts, acceptance criteria, decisions), the rollup and every existing phase manifest.
2. Confirm what the user authorized: execution scope, approval conditions, commit authorization. If ambiguous, ask before dispatching, not after.
3. Record the worktree baseline (revision and dirty state) so gates can separate task-owned changes from pre-existing edits.

## Schedule

- Dispatch a phase only after its prerequisites passed their gates, in the rollup's dependency order.
- Parallelize only when write scopes **and** mutable resources do not conflict: separate files can still share a database, generated output, a lockfile or a test environment. Serialize conflicts or isolate workspaces; every shared file has exactly one owner.
- Before each dispatch mark the phase `running` in the rollup, with executor identity and plan revision in Run notes. If a dispatch fails to start, record that; never leave an apparently active assignment.

## Dispatch: full context, narrow authority

Every dispatch to `phase-executor` starts from a fresh context window and carries the entire plan plus one phase brief. These field names are the executor's input contract; keep them identical.

```text
ROLE: phase-executor for Phase {N} only; you are a dispatched sub-agent.
WORKSPACE: {absolute path; branch or worktree identity}
PLAN: {plan id, revision, canonical path}
FULL PLAN CONTEXT: {entire current plan inline, or a confirmed-readable artifact to read in full before editing; never an excerpt or summary}
CURRENT STATE: {completed prerequisite outputs and validation evidence, known failures, pre-existing edits, concurrent assignments}
PHASE BRIEF:
- GOAL:
- PRECONDITIONS: {checkable claims about the repo}
- FILES IN SCOPE: {exact allow-list}
- PINNED CONTRACTS: {signatures, types, schemas, event names, verbatim from the plan}
- INSTRUCTIONS: {ordered, numbered}
- EXEMPLARS: {existing files whose style to follow}
- OUT OF SCOPE:
- ACCEPTANCE CRITERIA:
- MANIFEST: .agents/plans/{plan-id}/phase-{N}.md
ALSO: You are not alone in the codebase. Preserve other contributors' changes and adapt to them; do not revert or overwrite their work.
```

Fill `PHASE BRIEF` by copying the same-named fields of the plan's phase section without rewording, and replace each shared-contract name in `PINNED CONTRACTS` with its full text from the plan's contracts section. `PARENT ACTIONS` and `RISKS AND RECOVERY` stay with you: run each parent action when the plan says, and check the executor's NEEDS FROM PARENT against that list.

If the whole plan cannot be delivered inline or as a confirmed-readable artifact, do not dispatch and do not write the phase yourself. Record the blocker and report it: a phase run without full context is a collision waiting to happen.

## Gate every return

- Reconcile four sources: the manifest, the report, the actual diff (`git status --short`, `git diff --stat`) and the acceptance criteria. Missing or contradictory evidence means the phase is not verified; reconcile before opening dependent phases.
- Run the phase's checks and the integration checks it affects, including every acceptance criterion the plan assigns to the parent. Reuse credible recent evidence only if the code and environment have not changed; never mark unrun checks passed. Delegate where the fleet owns the ground: `test-runner` for tests and coverage, `build-doctor` for build, dependency and boot failures, `lint-static-analysis-fixer` for lint and static analysis, `code-reviewer` for pre-commit review.
- `ready-to-commit` plus a passed gate: mark the phase `complete`, then commit per the VCS rules.
- `needs-parent`, PARTIAL or BLOCKED items, or a gate failure: failure handling below. Only implementation failures go back to the executor, not environmental blockage or unrelated baseline failures.

## Failures

- Return specific evidence and the remaining work to the same executor, or to a replacement with the complete packet. Retry only after diagnosing the cause or changing a relevant condition. A repeating failure with no new evidence ends that loop: record the blocker and continue independent work.
- A build, dependency or boot failure the executor cannot resolve: dispatch `build-doctor`, then act on its diagnosis or feed it back through a revised brief.
- A plan-level inability to proceed: record the blocker in the rollup and report it to the user.

## Plan revision

When a contract was wrong, a scope is impossible or dependencies shifted:
1. Pause the affected phases and everything depending on them.
2. Update the canonical plan, increment `revision` and log reason and scope under "Changes to the plan". Keep unchanged instructions word for word and in order: the executor compares its manifest with them.
3. Redistribute the revision; affected executors must acknowledge it before continuing; recheck impacted prior results.
4. Ask the user only when the change exceeds the authorized scope or needs a material decision.

## Recovery

1. Select the plan (ask only if several remain plausible). Read the current revision, all manifests, the worktree and dependency evidence.
2. Check executor liveness with the tools available; a `running` status alone does not prove a crash. Reconnect to a live executor and never start a second writer. If liveness is unknowable, settle ownership before redispatching.
3. Inspect interrupted steps and their actual side effects before retrying; manifests and logs are hints, not checkpoints. Reconcile partial work and never blindly repeat a non-idempotent operation.
4. Revalidate completed work whose code, environment, dependencies or evidence changed; reopen it and its dependents, and keep results that still hold.
5. Resume the smallest unfinished authorized scope, with the complete packet for replacement executors.

## VCS: yours alone

- Commit only when the user or governing workflow authorizes it; planning and phase completion alone never require one.
- Commit after verification, at phase gates. Before staging, inspect staged and unstaged diffs against the recorded baseline: explicit paths do not protect pre-existing edits inside them, and already-staged changes can enter a commit. Isolate only task-owned changes; if separation is uncertain, leave them uncommitted and explain.
- Defer shared-worktree commits until concurrent writers finish unless isolation is proven. Respect ignored plan files. Record the commit separately from verification. With no VCS, keep file-based evidence.

## Completion

Finish with cross-phase validation against the plan's original acceptance criteria and reconcile all required phases and remaining risks. Mark the plan complete only when the requested implementation and required checks are satisfied; otherwise record the precise unfinished work and blocker. Report what changed, validation results, commits made, material limitations and the plan path, keeping completed planning distinct from completed implementation.

---
name: planning-implementations
description: "Creates, revises or resumes technical implementation plans: planning, design, architecture, specs, roadmaps, task breakdowns, and requests like 'how should we implement this?', 'think through the approach' or 'plan the fixes for this audit'. Applies to small tasks when a plan is requested. When the input spans unrelated areas (an audit touching models, actions, controllers), proposes splitting it into ordered plans by logical group. Not for implementation-only requests, requests to skip planning, or nontechnical planning."
license: MIT
---

# Planning implementations

Turn the request into a grounded, dependency-ordered plan another agent can execute without reconstructing decisions from chat history. Specify the minimum change that satisfies the request, with clear contracts and observable acceptance criteria.

## Mode

Explicit user instructions and higher-priority instructions beat these defaults. Planning does not itself authorize implementation, delegation, commits or external actions.

- **Plan or revise.** Investigate and deliver the plan; do not implement. A small task gets a proportionate plan.
- **Plan and execute.** If the user also asked for implementation, finalize and save the plan, then hand execution to `orchestrating-plans` within that authorization, with no extra approval round unless required. The logical-group question below still applies.
- **Inspect or resume.** Read the saved plan and the actual progress; for a series, read every plan in it and report which is current. A status question gets a status report. A request to continue goes to `orchestrating-plans`. Never infer permission from a saved status.

Executing a plan, dispatching phases, gates, recovery, revisions during execution and commits belong to `orchestrating-plans`; implementing one phase belongs to the `phase-executor` agent.

## Interview

Ground the plan in the user's intent before grounding it in the repository. Work the open decisions as a tree: the root is the request, and each settled decision branches into the decisions that hang off it. Work the tree in rounds. One round asks every question whose prerequisites are already settled (the frontier), numbered, each with your recommended answer, then waits for the replies. A question that depends on an answer still open belongs to a later round, not this one.

- Facts are yours: anything the repository, tools or sources can settle, investigate and cite; never ask the user for it. An investigation still running is an unsettled prerequisite: only the questions downstream of it wait.
- Decisions are the user's: scope, trade-offs, costly or irreversible choices. Put each to the user with a recommendation, worded so agreeing takes one word.
- Skip any question whose answer would change nothing.
- Unattended or dispatched: take the most reasonable reading and record it as an assumption in the plan's Evidence and assumptions section, with what breaks if it is wrong.

The interview ends when the frontier is empty: nothing left that could change the goal, scope or approach. Record each settled decision under "Decisions and conventions" with its reason. Rounds interleave with grounding: investigate facts for the next round while waiting.

## Ground the plan

1. Extract goal, requirements, constraints, non-goals and observable success criteria. Keep relevant conversation decisions in the plan. For list input (audit findings, review comments, bug reports) keep each item's original ID.
2. Inspect repository instructions and relevant skills, and the project's domain glossary and architecture records where they exist (`GLOSSARY.md`, ADRs), so the plan uses the project's terms and respects recorded decisions. Establish from evidence the project root, stack and versions, existing patterns, relevant paths and symbols, validation commands and current worktree state; record pre-existing changes.
3. Use available code-navigation or framework tools. For structure, use an installed code-graph skill if there is one, checking index freshness and coverage; otherwise targeted search and source reads. Do not rebuild a valid index repeatedly or enumerate unrelated integrations.
4. Verify interfaces and affected call sites before prescribing changes. Separate existing paths and symbols from proposed ones. Cite paths, symbols, versions or docs; label unverified details.
5. Take blocking unknowns to the Interview (above). State reversible assumptions and their consequences without asking approval for each.

For greenfield work or no source access, produce a provisional plan with explicit discovery tasks and conditional decisions. Do not invent repository facts or call the plan execution-ready while essential contracts are unresolved.

## Logical groups

Run after grounding, before choosing the approach. A group is work that can be planned, executed and verified alone. Typical trigger: an audit, review, bug list or broad request spreading across unrelated areas (models, actions, controllers, separate domains).

1. **Map** each item to the files and symbols it touches. Names and labels are not evidence of relation.
2. **Cluster** by relation: shared write scope, contract or validation means same group; disjoint write scopes and independent validation separate. Use one axis (layer, domain, file set, or kind of change such as schema vs behavior vs tests), the one leaving fewest cross-group dependencies.
3. **Order** by dependency: B follows A when B consumes a schema, contract or behavior A changes. Record each cross-group dependency; independent groups have no order.
4. **Do not split** when one change cuts through layers (use phases in one plan), when fewer than two groups remain, or for a single trivial item (merge it into the nearest group). Aim for 2 to 5 groups.
5. **Assign** each item to exactly one group; an item spanning groups goes to the earliest group that must change, with the contract noted in the later one.
6. **Ask** when two or more groups remain, before writing any plan: show each group's scope and item IDs, the order and a recommendation; offer separate plans in order (recommended), one combined plan, or another grouping. Use the environment's question tool, else ask inline; keep investigating read-only meanwhile. Skip if the user already chose. If asking is impossible (unattended or dispatched), default to the split and record it as an assumption in each plan.
7. **After the answer**, write one plan per group in order. Plans run one at a time; the next starts after the previous gate passes unless the user says otherwise. Re-verify baseline and evidence at the start of each later plan, since earlier ones changed the code.

## Choose and bound the approach

Apply YAGNI, then KISS and DRY, then SOLID where existing complexity warrants it. First check whether current behavior already meets the need; otherwise prefer platform features, installed dependencies and project patterns before new code. Propose scope reductions rather than silently dropping requirements.

Keep changes traceable to the request: no adjacent cleanup, speculative abstractions or forced alternatives. Compare options only when a real tradeoff remains. Cover security, compatibility, migration, rollout and rollback when the change makes them relevant. Never omit required handling or tests just to cut lines.

Define the interfaces between phases before splitting ownership. Order phases by real dependencies, preferring independently verifiable outcomes over fixed technical layers. Parallel work needs satisfied dependencies and compatible write scopes and shared resources.

Decide where each phase's behavior is verified before writing phases. A seam is the public boundary a test crosses: an interface, route, CLI command or queue. Prefer an existing seam to a new one, and the highest seam that reaches the behavior; proposing a new seam is a design decision for the Interview, not a quiet one. Record the choices as testing decisions in the plan: the seam per phase and what a test there asserts (observable behavior, never internals).

## Write the durable plan

Use the user's or repository's required location; otherwise:
- Plan: `.agents/plans/{plan-id}.md`
- Phase manifests (created during execution by `phase-executor`): `.agents/plans/{plan-id}/phase-{N}.md`

Use a descriptive kebab-case ID, adding a suffix only to avoid a collision. Revisions keep the ID and increment `revision`; a new linked plan only for a true replacement. Never overwrite an unrelated plan. For a series use `{series-id}-{order}-{group}` (`audit-fixes-1-models`, `audit-fixes-2-actions`) and set `series`, `group`, `order`, `depends on plans`; plans with no mutual dependency may share an order number; find a series with `.agents/plans/{series-id}-*.md`.

Save before presenting or dispatching. Draft the plan once as Markdown in a scratch file (the session scratchpad, not the repository), then copy it to the target path with a file-copy tool or `cp`: `cp -n` for a new plan ID so an existing plan is never overwritten, plain `cp` for a revision of the same ID. Confirm the copy with `cmp` against the draft. Write the target with a write tool only as a last resort, when no copy tool or `cp` is available or the copy fails; never re-output a plan that is already saved. If writes are unavailable, deliver the full Markdown inline, name the intended path and say persistence is unavailable. A native planning tool may mirror the file; the Markdown is canonical.

Scale detail to the work and omit irrelevant sections, but keep goal, scope, phases, checks and readiness explicit. The orchestrator sends the whole plan with every phase dispatch, so each line is paid once per phase: keep a line only if the executor would get something wrong without it. Rules for the prose follow the template.

```markdown
# Plan: {title}

- id: {plan-id}
- revision: {integer}
- workspace: {project root or intended workspace}
- baseline: {revision and relevant dirty state, or unavailable/no VCS}
- updated: {timestamp with timezone}
- status: draft | ready | executing | blocked | complete
- execution authorization: {what the user authorized; approval conditions}
- series / group / order / depends on plans: {series plans only}

## Goal and acceptance criteria
{Two or three plain sentences: what changes and why. Then numbered outcomes AC1, AC2, ... that anyone can observe, covering every requirement. Series plan: the original item IDs covered.}

## Scope and constraints
- In scope:
- Out of scope:
- Decisions and conventions: {user decisions and repository rules, each with its reason in one clause}
- Other groups: {series plans only: what belongs to them}

## Evidence and assumptions
- Verified: {fact, with path, symbol, version or doc}
- Proposed: {paths and symbols that do not exist yet}
- Assumed: {each assumption, and what breaks if it is wrong}
- Blocked: {blocker, and who resolves it}

## Approach and contracts
{The design in a few sentences, with the reason for each material choice. Then every contract used by more than one phase, written once and verbatim in code blocks: signatures, schemas, names, errors, invariants, including contracts consumed from or provided to other plans.}

## Testing decisions
{The seam each phase is verified at and what a test there asserts; how new seams were confirmed.}

## Phase rollup
| Phase | Depends on | Status | Run notes (executor, revision, evidence, blockers) |
| --- | --- | --- | --- |

## Phase {N}: {deliverable}
- GOAL: {the outcome in one or two sentences}
- ACCEPTANCE CRITERIA: {each: the AC it serves, the check (command and working directory, or manual steps), the expected result, and who runs it: executor or parent}
- PRECONDITIONS: {checkable claims about the repository}
- FILES IN SCOPE: {exact allow-list of existing and proposed paths, with symbols where they narrow the edit}
- PINNED CONTRACTS: {names of shared contracts ("Approach: UserDto"); contracts only this phase uses, in full}
- INSTRUCTIONS: {numbered, one action each; mark a step "not repeatable" if running it twice would do harm}
- EXEMPLARS: {existing files whose style to follow}
- OUT OF SCOPE: {nearby things this phase must not touch}
- PARENT ACTIONS: {commands only the parent may run (installs, migrations, version control) and when}
- RISKS AND RECOVERY: {what can go wrong and how to undo it}

## Integration and completion
{Cross-phase checks against the original goal; rollout and rollback if relevant.}

## Changes to the plan
{Revision, reason, affected phases.}
```

The first eight phase labels are the fields of the phase brief that `orchestrating-plans` sends, so keep the names exact and let the orchestrator copy the text without rewording. `PARENT ACTIONS` and `RISKS AND RECOVERY` are for the orchestrator and are not sent. Any `PINNED CONTRACTS` entry that names a shared contract is copied in full into the brief.

Writing rules. The readers are an executor with no chat history and nobody to ask, and a person who approves the plan in one pass.
- Put every decision the executor needs in the plan. If a colleague with no context would ask a question, answer it there.
- Open each section with its conclusion. Put hard stops before routine detail.
- Write one idea per sentence, in the active voice and present tense. Write steps as commands ("Add X to Y") with their articles and verbs. Fragments belong only in table cells and labels.
- Name things: path, symbol, command, expected output. Do not write "as needed", "appropriate", "etc." or "similar".
- Use one word per concept. Explain a project term in the sentence where it first appears. Prefer a short nickname to an acronym, and avoid strings of more than three nouns.
- Give each reason once, in one clause beside the decision it explains. State each fact once and refer to it by section name.
- Put a condition before its instruction ("If the table exists, skip step 3").
- Use numbered lists for ordered steps and bullets for the rest. Use a table only to compare items on the same attributes.
- Cut filler, hedging and restated headings. Never cut a fact that changes what the executor does.
- On revision, keep unchanged steps word for word and in order: the executor compares its manifest with the plan's steps.

Rollup statuses: `pending`, `running`, `blocked`, `failed`, `complete`, `skipped`. Complete means the phase's gate passed, not that a commit exists. Skipping needs a reason and a replacement for any still-required outcome. Name real commands only when verified, otherwise add a discovery step. A check can be inspection, a build, a test or a manual procedure; do not add a test per bookkeeping action or rerun a suite per step.

## Readiness and delivery

Mark the plan ready only when: every requirement maps to a phase and an acceptance check; for a series, every original item is in exactly one plan and plan dependencies are acyclic; phase dependencies are acyclic with prerequisites and shared interfaces explicit; existing facts are evidenced and proposals labeled; the testing decisions cover every phase with observable behavior, each at a named seam; each phase fills every brief field, with one action per instruction, a check and a runner for every acceptance criterion, and every install, migration or version-control command listed under `PARENT ACTIONS`; no blocker hides as an assumption; an executor can understand the whole request from the plan and its accessible artifacts.

Summarize the approach, phase order (and plan order), material assumptions and blockers, and saved paths. Planning-only work stops there. For authorized execution continue with `orchestrating-plans`, one plan at a time.

---
name: refactoring-code
description: "Refactors existing code (a function, file, package, library or whole app) to be smaller, simpler and readable by a novice without changing behavior or public API. Deletes dead code, splits multi-responsibility functions, renames cryptic names, makes dependencies mockable, and follows the project's own conventions. Use when asked to refactor, restructure, simplify, untangle, de-duplicate, shrink or clean up code, or to apply YAGNI/KISS/DRY/SOLID. Not for bug fixes, new features, formatter-only runs, performance tuning, language or framework rewrites, dependency upgrades or new code."
license: MIT
compatibility: Needs read access to the repository and git metadata, search or code-intelligence tools, the project's configured formatters, linters and static analyzers, and its test runner. No new dependencies.
---

# Refactoring code

Change the structure and expression of existing code so it is simpler, has less logic and is easy for a novice to read. Observable behavior and public API stay identical. The best code never existed: deleting and simplifying beat adding and abstracting (YAGNI).

## Hard stops

Re-read before each plan and whenever unsure.

1. Behavior and public API stay identical unless the user approves a change.
2. Measure scope and pick a mode first. Never start a massive refactor without a plan.
3. Never invent a convention. Read the project's rules, then decide from evidence (Conventions). On a real collision, ask.
4. Delete, rename or move only what exploration with tools verified (Exploring).
5. Never edit a test's expected values, and never silence a linter, to get green.
6. Finish with linters and static analysis green, then tests green.
7. Never commit and never change git state. Leave everything uncommitted for review.
8. What you are unsure about, or notice outside the scope, goes to the user or the report. Never act on it silently.

Precedence when rules collide: the user's explicit instructions here; hard stop 1; the project's rules, tastes and lint config on the points they cover; this skill; then the order in Conventions. A project rule beats a default here (a project that bans docblocks gets its way); say so in the report. Rule 7 changes only on the user's explicit instruction.

## Modes

Count first: list the target's files (`git ls-files` or a file-listing tool), then estimate size.

| Mode | When | Difference |
| --- | --- | --- |
| Lite | One function, class or file, or at most 2 files and about 300 lines | Run only linters on touched files and the tests covering them; skip the whole-project baseline. Everything else applies |
| Standard | One domain, 3 to 15 files | Full process |
| Massive | More than one domain, over 15 files or about 1,500 lines | Split into independent plans per domain, leaf modules first, each small enough to review alone. Present them with plan mode if available, otherwise list them and **stop without editing**, asking approval one plan at a time. If the user said to proceed, run them in order and verify after each |

## Process

1. **Preflight.** Run `git status` (read-only). Work alongside the user's uncommitted changes; do not revert or mix in unrelated files. Identify linter, analyzer and test runner from config files and scripts, not assumption; if one cannot run, say so and invent no substitute. Read the project's rules.
2. **Baseline.** Run those tools (scoped by mode) and record what already fails. Do not take the blame for, or silently fix, pre-existing failures.
3. **Ledger.** Keep a short working note outside the repo, never committed: baseline failures, plan list and status, the **naming glossary**, convention decisions (rules read, collisions, answers), open questions, items left alone. Re-read the hard stops and the ledger before each plan and after context compaction.
4. **Survey.** Explore the target with tools: usages, callers, covering tests, how neighbors are written. Record the conventions you decide.
5. **Safety net.** Code you will restructure that has no coverage and unobvious behavior gets a small characterization test first, or is left alone and listed. Never restructure untested non-trivial logic blindly.
6. **Ask once.** Collect every open question (Ask the user), each with your recommendation, and ask in one batch. If you cannot ask, take the conservative option: leave that code unchanged and list it.
7. **Refactor in small units.** For each: behavior and API unchanged; usages and tests found before the edit and nothing dangling after; dead parts removed; one responsibility per function; names and doc comments per `writing-expressive-code`; dependencies injectable; project style followed.
8. **Verify**, then **report**.

## Conventions

A refactor that looks different from its surroundings has failed.

**Read the rules first.** Look for `.agents/rules` and `.agents/tastes` (file or directory), `AGENTS.md`, `CONTRIBUTING`, `.editorconfig` and linter and formatter configs. A missing file is normal. Read what exists in full, or the index plus the parts matching the target if large or path-scoped. Rules bind; tastes are strong defaults that yield only to a rule or the user.

**Decide in this order, stopping at the first level that answers:**
1. The project's rules and tastes.
2. Existing code and organization near the target (layout, naming, error handling, tests, doc format), verified with search tools.
3. Framework conventions, verified in the framework's docs, source or skeleton.
4. The language ecosystem's recognized standard, such as its official style guide.

If no level answers, leave that aspect unchanged and report it; ask if the refactor cannot proceed without it.

**Collisions: ask, don't pick.** A collision is sources at one level disagreeing and the order unable to settle it: two rule files contradict, a rule contradicts lint config, or the code uses two patterns in comparable amounts. One dominant pattern (about 90% or more, counted with a search tool) with isolated leftovers is not a collision; follow it. For a real one, give each option with an example file and occurrence count plus your recommendation, using the environment's question tool if any. Batch collisions and keep working on unaffected units. Record the answer in the ledger and apply it everywhere. If you cannot ask, leave the aspect unchanged and report it.

## Exploring

Get the map (what uses this, what it uses, what tests it, how neighbors look) from tools, not by reading files by hand. Run the tools; do not just acknowledge them. Manual exploration is allowed only after a tool attempt returned nothing usable. Use the highest rung available:

1. Code intelligence: language server or IDE operations (references, definitions, symbols, rename), code-index or structural search, the project's own scripts.
2. Text search: start with counts and file lists, then add context. Version-control history helps tell dead code from deliberate code.
3. Existing reports (coverage, dependency graphs) as hints only; they never prove something unused.
4. Ranged reads around hits.
5. Whole-file reads of code you are not editing: last resort.

Mandatory: before deleting, find every usage including dynamic ones (strings, config, routes, DI containers, serialization, framework conventions) and every export; before renaming, moving or splitting, every reference, caller and covering test; during the survey, neighboring conventions with counts; after each unit, confirm nothing dangles. Refresh any index-based tool after each milestone (a plan, or a batch of moves, deletions or renames), not after every edit, and confirm surprising answers with text search. Keep index artifacts out of the repo (`git check-ignore`).

## Rules

Apply in order: YAGNI, KISS, DRY, SOLID.

**YAGNI.** Remove dead code, unused parameters and imports, unreachable branches, commented-out code, pass-through wrappers and abstractions with one trivial implementation, after verifying (Exploring). Still unsure: open question, do not delete.

**KISS.** Early returns and guard clauses over nesting; standard-library functions over hand-rolled loops; named intermediates over clever one-liners.

*Reuse before writing.* Before writing a general helper (lists, collections, parsing, serialization, strings, pipelines, math, datetime, random, mockable proxies for built-ins), look in the project's shared code and in **directly declared** dependencies. Read the source or docs to confirm existence, signature and edge cases (null, empty, ordering, locale); never call a helper you only assume exists. No transitive dependencies and no new dependency without approval. If behavior differs subtly from the code it replaces, keep the original unless tests prove equivalence.

**DRY.** Merge duplicates only when they express the same rule. Similar code that changes for different reasons stays separate.

**SOLID, with judgment.** S is enforced by method-size checking per `writing-expressive-code` (one responsibility; leave a flat declarative table or linear pipeline that reads well; unclear or performance- or security-sensitive splits are open questions). O, L, I, D apply only when YAGNI does not veto them; an interface, factory or extension point nobody needs is overkill. Dependencies must be injectable for tests.

## Module shape

Smaller is a means, not the goal: a unit (function, class or package behind an interface) should be deep, a small interface over real behavior. Before splitting anything, run the deletion test: imagine the unit deleted. If its complexity would reappear across its callers, it earns its keep; if the complexity vanishes, it was a pass-through and YAGNI removes it. Split so the pieces come out deep, not merely many: merging two helpers behind one honest name beats a chain of thin ones, and an extension point nobody varies across (one implementation, one caller) is a seam nobody needs. A split wins only when the caller reads as a shorter outline, per `writing-expressive-code`.

## Naming and docs

Naming and doc-comment rules are in `writing-expressive-code`; apply them to every function you create or change. Refactor-specific additions:
- One concept, one name in every context; record each decision in the ledger glossary and check it in every new file.
- Which name wins: (1) public or exported names are fixed (in a library: exported, visible outside the package, documented or serialized, including config keys and persisted fields), never renamed without approval; (2) among internal names an expressive one beats a cryptic one even if the cryptic one came first; (3) between equally expressive names the first appearance wins (earliest in the public API, else in reading order), and the later ones are renamed.
- Do not document or restyle untouched code outside the scope.

## Tests and testability

- Dependencies (I/O, time, randomness, network, filesystem, database, services) are injectable through the project's existing seam style, never created or fetched statically in the logic; no hidden globals or singletons a test cannot replace.
- If checking behavior would need reflection or introspection (private members, patched internals), the refactor is wrong; redesign the seam.
- Assertions express the original intent. Never change an expected value, delete an assertion or weaken a check to get green; if a test fails, assume your refactor is wrong first. You may simplify scaffolding (verbose setup, hand-written stubs, call-by-call expectations) with the project's doubles, and fix tests aimed at internals you legitimately removed. Changing an expected value, the exposed API or the covered behavior needs approval.
- Report every test file touched and why.

## Verification

1. Run every configured linter, formatter and analyzer unless the user said to skip; try autofix first. If a rule pushes you to undo or heavily rework the refactor, stop and ask with options (adjust code, one justified single-rule suppression, a config change). No blanket ignores, no lowered strictness.
2. Then tests, scoped by evidence: check CI config and test count; run targeted tests (covering what you touched plus direct dependents) first; run everything if the suite is small or finishes in a few minutes (use a timeout), and always after changing shared or core code, public API or global config. If a full run is too slow, say so. Compare with the baseline.
3. A handful of failures with a clear cause (missed rename, moved import, stub aimed at removed internals): fix, preferring source over tests. More than about 5, an unexplained failure, or any hint that behavior changed: stop, summarize by cause, ask. Never mass-edit tests.

## Ask the user when

- You do not understand what the code does, or whether it needs refactoring.
- A change could affect performance, security, concurrency, ordering or error semantics.
- A change would alter public API, exported or serialized names, schemas, config keys or test assertions.
- Conventions collide beyond the order, linting fights the refactor, test failures are many or unclear, or a deletion's usage cannot be fully verified.

Do not ask what the evidence settles; search first so each question is specific and carries a recommendation.

## Done and report

Done when: methods are lean with one responsibility; a novice can follow the syntax; a small change touches one place; the result is indistinguishable from the surrounding human-written code; every symbol traces to a consumer; test doubles replaced verbose expectations; assertions and the public API are unchanged; all tools are green; nothing is committed. "Smaller" means less logic, fewer branches and fewer concepts, not fewer lines; measure code lines excluding comments. Any unmet item means keep working or escalate.

Report briefly, with no narration of each edit: what changed by theme (deleted, simplified, split, renamed with the glossary); logic lines before and after and files added or removed; tools run and status, tests run with scope and result, remaining baseline failures, anything not run and why; test files touched; conventions read, collisions and answers, project rules followed over a default here, aspects left unchanged for lack of a source; judgment calls, open questions, code left alone, problems outside scope (reported, not fixed); anything needing approval; and a reminder that changes are uncommitted (`git diff`).

# Implementation-plan format: decisions

Why the plan schema in `skills/planning-implementations/SKILL.md` looks the way it does. Source IDs are in `sources.md`; the facts they cite are summarized in `writing-for-readers.md`; "orchestrator" and "executor" mean `skills/orchestrating-plans/SKILL.md` and `agents/phase-executor.md`. Basis labels are those of `rules.md`, plus **inference** (reasoned from a cited fact, not stated by the source).

## Contents
- Goal and result
- Decisions
- Tensions
- Kept as is
- Limits of this evidence

## Goal and result

Two requirements: (1) a subagent can execute the plan without drifting, (2) a person can read it with little effort. One schema serves both. The structure comes from the AI side, because the executor's contract fixes the fields. The reader-effort side adds writing rules and removes duplicated text, and the two never ask for different fields.

## Decisions

| ID | Change | Why | Sources | Basis |
| --- | --- | --- | --- | --- |
| P1 | Phase fields use the brief's names: `GOAL`, `ACCEPTANCE CRITERIA`, `PRECONDITIONS`, `FILES IN SCOPE`, `PINNED CONTRACTS`, `INSTRUCTIONS`, `EXEMPLARS`, `OUT OF SCOPE`. The old names (Objective, Write scope, Contracts, Steps, Validation) forced the orchestrator to translate. | A subagent does not see the dispatcher's skill, so both sides keep identical field names. A translation step is where meaning drifts. | R29 (A11); orchestrator dispatch template; executor input contract | vendor, inference |
| P2 | Add `PRECONDITIONS`, `EXEMPLARS`, `OUT OF SCOPE` per phase. The old schema had none. | The executor checks preconditions first and stops on a mismatch, follows exemplars, and needs boundaries. A brief needs objective, output format, tools and boundaries. | executor Procedure 1-3; A16; A12 ("follow the pattern in HotDogWidget.php") | vendor |
| P3 | Add `PARENT ACTIONS`. | The executor may not run installs, migrations or version-control commands and marks such a step BLOCKED. A plan that lists them as phase steps guarantees a blocked phase. | executor Hard rules and VCS; A12 ("what is it allowed to touch") | vendor, policy |
| P4 | Acceptance criteria live in two places by job. Top level: observable outcomes (AC1...). Phase: the check, expected result and who runs it (executor or parent). | The executor reports each criterion as verified by self-check or left to the fleet, so the plan must say which. Evidence of a check beats a bare claim; "done" must be defined. | executor Report format; A12 (give a check, ask for evidence, five unattended-run questions); A13 (self-check) | vendor |
| P5 | Each decision, constraint and assumption carries its reason or consequence in one clause. | Context or motivation lets the model generalize instead of following a bare rule. | A13 (add context); A2 (explain why) | vendor |
| P6 | One owner per fact. Rollup loses `Manifest` (the path is fixed by the plan ID) and `Owner / write scope` (lives in the phase). Phase loses `Dependencies` (lives in the rollup). Shared contracts are written once in Approach; the brief gets a verbatim copy. | Duplicates can clash and cost tokens on every dispatch. Redundant text adds load without adding meaning. | R10, R31; C5 (clash); B7 (redundancy effect, secondary) | policy, opinion |
| P7 | Drop `created`. Keep `updated`. | Nothing in the orchestrator or executor reads `created` (checked by grep). `updated` helps pick the current plan in a series. | chisle ladder rung 1 (D3) | policy |
| P8 | `Goal` opens with two or three plain sentences. | Summarize up front and open with a topic sentence; put key content where attention is strongest. | A25 (principles); B5; A13 (structure for long input) | vendor, measured |
| P9a (writing rules block, one row per rule) | Active voice, present tense, one idea per sentence, commands for steps. | Names the actor; present tense is the simplest form; short units are easier to process. | A25 (writing, clear-short) | vendor |
| P9b | Name path, symbol, command and expected output; ban "as needed", "etc.". | Specific prompts carry information the model does not have; a context-free colleague test. | A13 (clear and direct, key test); A12 (specific prompt) | vendor |
| P9c | One word per concept; explain a term where it first appears; nicknames over acronyms; at most three nouns in a row. | Consistent terms; abbreviations send the reader back to find the meaning; long noun strings mislead. | A25 (style); A8 via R10 | vendor |
| P9d | Condition before instruction. | Reader meets the condition before deciding to act. | A26 (highlights) | vendor |
| P9e | Numbered list for ordered steps, bullets otherwise, table only for like-for-like comparison. | Numbers show order and make every step findable; tables show relations. | A26 (highlights, procedures); A25 (lists, tables) | vendor |
| P9f | Reason once, fact once, refer by section name. | Redundancy and split attention both raise load; refer instead of repeating. | A25 (concise); B7 (secondary) | vendor, opinion |
| P9g | Cut filler, hedging and restated headings, but keep articles and verbs in instructions; fragments only in table cells and labels. | Both chisle and plain language remove filler. They differ on telegraphic style (see Tensions). | D3; A25; A13 (key test) | policy |
| P9h | Conclusion first in each section; hard stops before routine detail. | Order by importance; the middle of a long input is weakest. | R13; B5; A25 | measured, vendor |
| P10 | On revision, keep unchanged steps word for word and in order. | The executor compares its manifest's instruction list with the plan's and stops with PRECONDITION_FAILED on drift. | executor Procedure 1 | repo contract |
| P11 | Mark steps "not repeatable" when running twice does harm. | Recovery must not blindly repeat a non-idempotent operation. | orchestrator Recovery step 3 | repo contract |
| P12 | `INSTRUCTIONS`: one action per step. | The executor records one manifest entry, status and evidence per instruction; a two-action step cannot be half done cleanly. Also one idea per unit. | executor Manifest; A25 (clear-short); A26 (procedures) | repo contract, vendor |
| P13 | Line budget rule: keep a line only if the executor would get something wrong without it. | The full plan goes to every phase dispatch, so its size is paid once per phase. Same logic as instruction files. | orchestrator Dispatch; R9; B1; B4 | inference from measured |
| P14 | Readiness adds: every brief field filled, one action per step, a check and a runner per criterion, parent-only commands listed. | Makes P1-P4 and P12 checkable. | this page | policy |

## Tensions

| ID | Conflict | Resolution |
| --- | --- | --- |
| X1 | Chisle drops articles and allows fragments (D3). Plain-language guides ask for complete active sentences and warn about compressed noun strings (A25). | Both cut filler. Keep chisle's cuts (pleasantries, hedges, restated headings). Keep articles and verbs in instructions, because chisle's own Auto-Clarity clause says to write in full where compression makes meaning ambiguous. Fragments stay in labels and table cells. Chisle's chat-reply rules (no headings, no tables) do not apply: the plan has a fixed schema. |
| X2 | Split attention (put related information together) against redundancy (remove duplicates), both B7. | Integrate through the brief. The plan states a shared contract once; the orchestrator copies it into each brief, so the executor sees it beside its instructions without a second source of truth. |
| X3 | The executor needs the entire plan (collision safety, C3) but longer input costs quality and money (B4, B5, A15). | Keep the whole-plan rule, which belongs to the orchestrator and executor, and shrink the plan instead (P6, P13). |
| X4 | A13 says long documents first, query last. | Already satisfied: the orchestrator sends the plan first and the phase brief last. No change. |

## Orchestrator alignment

`skills/orchestrating-plans/SKILL.md` follows the schema: it copies same-named phase fields into the brief (P1), expands shared-contract names (P6), runs `PARENT ACTIONS` itself (P3), gates parent-run criteria (P4), records executor and revision in Run notes, and keeps unchanged instructions stable on revision (P10). `agents/phase-executor.md` needed no change.

## Kept as is

- Header fields `baseline`, `workspace`, `execution authorization`, `status`, `revision`: the orchestrator reads them at takeover.
- `Evidence and assumptions` structure: A13 asks to investigate before claiming; the split verified, proposed, assumed, blocked makes that visible.
- `Integration and completion`, `Changes to the plan`: the orchestrator writes and reads them.
- Markdown headings and labels rather than XML tags (A13): a person reads the plan, and labeled fields already separate the content types. No source measured XML against headings for this case.
- Status vocabulary: owned by the orchestrator.

## Limits of this evidence

- A27 (ISO 24495-1) was read through search-result summaries only; its four principles (relevant, findable, understandable, usable) agree with A25 but no rule here rests on its text alone.
- B7 (cognitive load theory) was read through secondary teaching summaries; the primary papers were not retrieved. P6 and P9f name it as supporting only.
- A25 `clear-short` and `style` pages were read for their first 2,600 characters.
- No source gives a numeric size limit for a plan. P13 is a rule of use, not a number.
- Nothing here was tested against a no-skill baseline (R19). The next check is to run a planning task with the old and the new schema and compare executor reports for DEVIATIONS and BLOCKED counts.

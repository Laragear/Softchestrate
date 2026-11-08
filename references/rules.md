# Rules for this repository

The audit checklist. Each rule is a conclusion drawn from the sources in `sources.md`; the last column says how strong the backing is:

- **spec**: a hard constraint of a specification or validator.
- **vendor**: recommended by the harness or model vendor.
- **measured**: supported by a benchmark.
- **opinion**: expert or community view.
- **policy**: this repository's own choice, derived from the cited facts. Not an external fact.

Apply the checklist to every definition before shipping. `skills-format.md`, `skills-authoring.md`, `subagents.md` and `context-evidence.md` hold the underlying facts.

## Contents
- Skills: format
- Skills: content
- Agents
- Instruction files and duplication
- Tensions between sources

## Skills: format

| ID | Rule | Sources | Basis |
| --- | --- | --- | --- |
| R1 | Frontmatter holds only `name`, `description`, `license`, `compatibility`, `metadata`, `allowed-tools`. Extra data (such as `complexity`) goes under `metadata`, with string values. | A1, A7, A10 | spec |
| R2 | `name` equals the directory name: lowercase, digits, single hyphens, at most 64 chars. One naming pattern across the collection, gerund preferred. | A1, A7, A8 | spec, vendor |
| R3 | Description: at most 1,024 chars; says what the skill does and when to use it; key use case in the first sentence; no angle brackets, no step list. Aim under 600 chars because every installed description is in context every session. | A1, A3, A8, A10, A20 | spec, vendor, policy (600) |
| R4 | `SKILL.md` body under 500 lines and 5,000 tokens. That is a ceiling; cut until removing a line would make a baseline run fail. | A1, A2, B2, B4 | spec, measured |
| R5 | Detail used only by some tasks lives in `references/`, one level deep, each file linked from `SKILL.md` with the condition for reading it. Files over 100 lines start with a table of contents. | A1, A2, A8 | spec, vendor |
| R6 | Every path, script or agent a body mentions exists in the repository. A skill that tells the model to run a missing script is broken. | A8, A5 | vendor |
| R7 | No harness-specific tool names, model names or provider names. Name the capability and a fallback ("a question tool, else ask inline"). | AGENTS.md, A8 | policy, vendor |
| R8 | Description voice: third-person statement of capability, then a "Use when" clause. Satisfies both A8 and A3 (see T1). | A3, A8 | vendor |

## Skills: content

| ID | Rule | Sources | Basis |
| --- | --- | --- | --- |
| R9 | Keep what the model would get wrong without it: non-obvious conventions, exact contracts and formats, gotchas, safety stops. Delete explanations of things the model knows and narration of what the text already says. | A2, A8, B3 | vendor, measured |
| R10 | One term per concept and no contradictory rule between skills or agents that load together. Resolve overlaps by giving each rule one owner and linking to it by name. | A8, C5, B3 | vendor, measured |
| R11 | Give a default, not a menu. Be prescriptive only for fragile or irreversible steps. | A2, A8 | vendor |
| R12 | Explain the reason instead of shouting. Reserve emphatic wording for irreversible actions; express always-on invariants as tool restrictions or hooks where the harness has them. | A13, A19, A12 | vendor |
| R13 | Order content by importance: hard stops and the core procedure first, rare detail last. | B5, A10 | measured, vendor |
| R14 | No time-sensitive statements; no stale versions in the body. | A8, B3 | vendor, measured |
| R15 | One example per output type; prefer gotchas and anti-patterns over long worked examples. | A2, A15, B4 | vendor, measured |
| R16 | Output formats are short templates. Say who reads them. A template that a script checks must ship with that script. | A2, A8 | vendor |
| R17 | Scripts are shipped or not referenced. State run or read. Non-interactive, `--help`, structured output. | A5, A8 | vendor |
| R18 | A workflow with side effects (deploy, release, send) should be user-invoked only where the harness allows it; record this in the adaptation notes, since the flag is not a spec key. | A10, A12 | vendor |
| R19 | Judge a skill against a no-skill baseline: with/without runs, tokens and time, at least three cases, plus a should/should-not trigger set for the description. | A3, A4, A8, B3 | vendor, measured |

## Agents

| ID | Rule | Sources | Basis |
| --- | --- | --- | --- |
| R20 | The description tells the caller when to call, when not to, and what the task text must contain (modes, scope, change). Anything the caller needs is in the description, because the body is the subagent's system prompt. | A11 | vendor, inference |
| R21 | All agent descriptions together stay well under 15,000 tokens; keep each brief. | A11 | vendor |
| R22 | The body is addressed to the subagent: role, procedure, limits, report format. No text meant for the caller. | A11 | vendor, inference |
| R23 | Read-only roles state it as a capability need; the importer enforces it by restricting tools rather than relying on prose. | A12 | vendor |
| R24 | A dispatch carries objective, output format, tool/source guidance and boundaries; a writer also gets the full plan context. | A16, C3 | vendor, opinion |
| R25 | Writes stay single-threaded or in disjoint scopes; helpers around the writer are read-only. | C3, C4 | opinion |
| R26 | Reviewers start from a clean context and a scoped checklist. | C4, A12 | opinion, vendor |
| R27 | Returns are short and structured; bulky output goes to a file the caller can read. | A12, A16 | vendor |
| R28 | Use a subagent for verbose output, enforced limits or self-contained work; otherwise stay in the main conversation. | A11, A12, A13 | vendor |
| R29 | Where both sides of a handoff need a contract (dispatcher and receiver), keep the field names identical and the text on each side minimal, because a subagent does not see the dispatcher's skill. | A11 | vendor, inference |

## Instruction files and duplication

| ID | Rule | Sources | Basis |
| --- | --- | --- | --- |
| R30 | `AGENTS.md` holds only rules the agent cannot infer from the code. No repository overview, no copy of the README. It is loaded by subagents, so its size is paid per dispatch. | B1, A12, A11 | measured, vendor |
| R31 | Each rule has one owner file. The README table, the AGENTS.md rules and the skill bodies must not restate each other; counts and names in the README match the tree. | A8, C5 | vendor, measured |

## Tensions between sources

| ID | Conflict | Resolution here |
| --- | --- | --- |
| T1 | A3 says phrase descriptions as instructions ("Use this skill when"); A8 says always third person. | Statement in third person, then a "Use when" clause (R8). |
| T2 | C6 says a description must hold only triggers, never workflow; A1 and A8 say what **and** when. | A-tier wins; keep the capability to one clause and no steps (R3). C6 is unmeasured. |
| T3 | A3 and A19 say be pushy so skills trigger; A10 and A20 truncate or drop long descriptions; each description costs tokens every session. | Breadth through scope words, front-loaded, under 600 chars (R3). |
| T4 | A16 uses parallel subagents widely; C3 says not to build multi-agent systems; C4 reconciles them. | Parallel read-only work is fine; writes single-threaded (R25). |
| T5 | A22 and vendors encourage `AGENTS.md`; B1 finds no success gain and over 20% more cost. | Keep it to non-standard rules (R30). |
| T6 | A8 and the spec allow 500 lines; B2, B3 and B4 show smaller focused skills do better. | 500 lines is a ceiling (R4). |
| T7 | A2 says explain why, not just rules; many baselines use prohibitions in capitals. B4 shows anti-pattern rules work; A13 warns about over-triggering from aggressive wording. | Prohibitions stay, in normal case, with the reason when it is not obvious (R12). |

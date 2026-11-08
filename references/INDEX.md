# references/ index

Maintainer notes for this repository, gathered 2026-11-04 so nobody searches the web again for skill and subagent practice. This folder is not copied into harnesses; install only `agents/` and `skills/`.

**Start here.** Read this page and `rules.md`. Open the other files only for the underlying facts, or re-fetch a source from `sources.md` when a fact looks stale.

## Files

| File | Read it when you need | Main sources |
| --- | --- | --- |
| `rules.md` | The audit checklist (R1-R31) and the conflicts between sources (T1-T7) | all |
| `skills-format.md` | Frontmatter keys, validator behavior, limits, token costs, what each harness does with a skill, naming | A1, A6-A10, A20, A23, A24 |
| `skills-authoring.md` | How to write the content: what to cut, patterns, descriptions, scripts, evals | A2-A5, A8, A19 |
| `subagents.md` | Agent definition format, description rules, when to delegate, briefs, single-writer rule, AGENTS.md cost | A11-A13, A16, B1, C3, C4 |
| `writing-for-readers.md` | The plain-language, style-guide, cognitive-load and agent-briefing facts behind the plan schema, so they need no web search | A12, A13, A25-A28, B7, D3 |
| `plan-format.md` | Why each field and writing rule of the implementation-plan schema exists, with its sources | A11-A13, A16, A25-A27, B1, B4, B5, B7, D3; facts in `writing-for-readers.md` |
| `context-evidence.md` | The measured case for small prompts: papers, benchmarks, expert reports | B1-B6, C1, C2, C5 |
| `sources.md` | URL, tier and read depth for every ID | - |

Tier order: A authority, B research, C experts, D community. Higher tier wins.

## Quick answers

| Question | Answer | Where |
| --- | --- | --- |
| Which frontmatter keys may a skill use? | `name`, `description`, `license`, `compatibility`, `metadata`, `allowed-tools`; anything else under `metadata` with string values. | skills-format § Validator |
| Must `name` match the folder? | Yes, per the spec and the reference validator. | skills-format § The open format |
| Maximum description length? | 1,024 chars (spec); Claude Code cuts the listing entry at 1,536; the whole listing gets about 1% of the context window. | skills-format § Per-harness |
| Maximum body size? | 500 lines and 5,000 tokens recommended; a ceiling, not a target. | skills-format § The open format |
| Does a loaded skill stay in context? | Yes. After compaction only its first 5,000 tokens come back. Put key rules first. | skills-format § Loading model |
| How should skills be named? | Gerund, consistent across the collection (`processing-pdfs`). | skills-format § Naming |
| Do skills actually improve results? | Curated, focused ones do (+16.6 points in SkillsBench); many do nothing or hurt (39 of 49 gave no gain in SWE-Skills-Bench). | context-evidence |
| Is a long skill bad? | Measured: focused skills of at most three modules beat exhaustive ones; length-matched irrelevant text alone reproduced much of a skill's loss. | context-evidence |
| What goes in a description? | What it does, when to use it, key trigger first, under about 600 chars, no step list. | skills-authoring § Descriptions |
| Subagent or main conversation? | Subagent for verbose output, enforced limits, self-contained work; main for iterative work and shared context. | subagents § When a subagent pays off |
| What must a delegation brief contain? | Objective, output format, tool and source guidance, task boundaries. | subagents § Writing the brief |
| Can several agents write at once? | Fragile; keep writes single-threaded or in disjoint scopes, helpers read-only. | subagents § Single writer |
| Does the caller see an agent's body? | The caller works from the description; put the call contract there. | subagents § Descriptions |
| Should we keep a big AGENTS.md? | No. It raised cost 20%+ without a success gain; keep non-standard rules only. | subagents § Instruction files |
| How is an implementation plan structured and worded? | Brief-field names in each phase, outcomes at the top, checks per phase, plain active sentences, one owner per fact. | plan-format |
| What do the plain-language and style guides say? | Audience first, active voice, present tense, one idea per sentence, conditions before instructions, numbered steps. | writing-for-readers |
| Should deploy-like skills be auto-invoked? | Not where the harness lets you block it (`disable-model-invocation` in Claude Code, `allow_implicit_invocation: false` in Codex). | skills-format § Per-harness |

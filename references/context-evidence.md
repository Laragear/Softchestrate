# Context economy: measured evidence

Why a token spent on a skill or an agent prompt is not free, and what was measured. Source IDs are in `sources.md`. Papers were read at abstract level unless `sources.md` says otherwise; numbers are the authors' own and have not been reproduced here.

## Contents
- Why length costs quality
- Do skills and context files help?
- Design consequences
- Cache and reuse
- Caveats

## Why length costs quality

| Finding | Source |
| --- | --- |
| Context is a finite resource with diminishing returns: as tokens grow, recall of the context drops ("context rot"). The goal is the smallest set of high-signal tokens that makes the desired behavior likely. Minimal does not mean short. | A15 |
| Performance often peaks when relevant information sits at the start or end of the input and degrades in the middle, even for long-context models. | B5 |
| In tests that hold task difficulty constant, performance degrades as input length grows, non-uniformly, and distractors (content topically related to the answer) degrade performance. | B6 |
| Four failure modes: poisoning (an error persists), distraction (history swamps training), confusion (superfluous content is used), clash (parts of the context disagree). Tool-use leaderboards show models do worse with more tools offered; one small model failed with 46 tools and succeeded with 19. | C5 |
| Bloated tool sets and ambiguous decision points are the most common failure in agents; if a human cannot say which tool applies, the agent cannot either. | A15 |
| System prompts should sit at "the right altitude": not brittle hardcoded if-else logic, not vague generalities. A laundry list of edge cases is discouraged; a few diverse canonical examples are recommended. | A15 |

## Do skills and context files help?

| Study | Result | Source |
| --- | --- | --- |
| Context files (AGENTS.md) in real repositories | No general gain in task success and more than 20% higher inference cost, for LLM-written and developer-written files. Instructions in them are followed; repository overviews are not helpful. Useful for non-standard practices. Developer-written files beat LLM-written ones by about 7%. | B1 |
| SkillsBench, curated skills vs none, 87 tasks, 18 configurations | Pass rate 33.9% to 50.5% (+16.6 points on average; +4.1 to +25.7 by configuration). **Focused skills with at most three modules beat larger or exhaustive bundles.** Small models with skills can match larger models without. Earlier version: self-generated skills gave negligible or negative benefit; 2-3 skills per task was optimal. | B2 |
| SWE-Skills-Bench, 49 public software-engineering skills, about 565 tasks | 39 of 49 skills gave zero pass-rate gain; average +1.2%. Token overhead ranged from savings to +451%. Seven specialized skills gained up to +30%. Three skills lost up to 10% through version-mismatched guidance or overly comprehensive templates. In 24 zero-gain skills the base model already passed everything. | B3 (secondary) |
| WebDev-Skills-Bench, 31 skills, 4 models, length-matched controls | Injecting the target skill lowered mean Pass@2 by 1.3-4.2% and raised token cost by 72-394%; gains appeared in only 17-36% of skill-project pairs. Some models were length-distracted (an equally long irrelevant skill reproduced most of the loss), others content-misled. Losses concentrated on easy tasks. **Anti-pattern rules beat example-heavy content** inside helpful skills. | B4 |

Reading across B2, B3 and B4: a skill is a hypothesis about a task, a model and a codebase, not a portable asset. It earns its tokens only where the model would otherwise fail, and it hurts when it is long, outdated or conflicting.

## Design consequences

1. Put non-obvious, failure-preventing content in the skill; leave out what the model already does (A2, B3).
2. Keep each skill small and single-purpose (B2, A20); route rare detail to files read on demand (A8).
3. Put the most important instructions first, because the middle of a long context is weakest (B5) and compaction keeps only the first 5,000 tokens of a skill (A10).
4. Remove contradictions between skills that load together; clashing instructions degrade reasoning (C5, B3).
5. Prefer anti-patterns and gotchas over long worked examples (B4, A2).
6. Keep repository instruction files to non-standard rules (B1, A12).
7. Verify against a no-skill baseline before keeping a skill (A4, B3).
8. Reduce always-on text first: descriptions sit in every session (A10, A20).

## Cache and reuse

| Finding | Source |
| --- | --- |
| The KV-cache hit rate is the most important metric for a production agent; cached input costs about a tenth of uncached for Claude Sonnet in their example. Keep the prompt prefix stable (no timestamps), keep the context append-only, make serialization deterministic. | C2 |
| Treat the file system as external memory; compress reversibly (keep the URL or path, drop the content). | C2 |
| Rewriting a todo list repeatedly recites the objective into recent attention and counters lost-in-the-middle. | C2 |
| Do not clean failures out of the trace; the model uses the evidence. Repetitive few-shot examples make the model imitate the pattern. | C2 |
| Catalog cost per skill is a few dozen tokens in Simon Willison's measure and 50-100 in the client guide; MCP tool definitions from large servers can consume tens of thousands. | C1, A6 |

## Caveats

- B3 was read through a summary of the abstract; B2 and B4 and B1 at abstract and result-table level. None was replicated here.
- These studies measure coding and web tasks with specific harnesses and models; direction is consistent across them, magnitudes are not portable.
- A12 and A16 are vendor documents describing vendor products; C3 and C4 describe one company's agent.

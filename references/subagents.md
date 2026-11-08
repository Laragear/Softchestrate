# Subagents and instruction files

How to define and dispatch subagents, and what the repository instruction file costs. Source IDs are in `sources.md`.

## Contents
- Definition format
- Descriptions and delegation
- When a subagent pays off
- Writing the brief
- Single writer, read-only helpers
- Tools and enforcement
- Instruction files (AGENTS.md)

## Definition format

| Fact | Source |
| --- | --- |
| A subagent is a Markdown file: frontmatter plus a body that becomes its **system prompt**. Only `name` and `description` are required in Claude Code. | A11 |
| A subagent receives its own prompt, environment details and the project instruction files (`CLAUDE.md`, `AGENTS.md`). It does **not** see the parent's conversation, invoked skills or files already read. | A11 |
| Claude Code ignores unknown frontmatter fields silently, and a name containing `:` or starting with `-` is skipped. The filename need not match `name`. | A11 |
| Preloaded skills (`skills` field) inject their full content at startup. A skill with `disable-model-invocation` cannot be preloaded. | A11 |

## Descriptions and delegation

- The parent delegates from the `description` plus the task at hand; it sees the description, not the body (A11).
- Keep descriptions brief: Claude Code warns when all subagent descriptions together pass 15,000 tokens (A11).
- Put in the description what the parent needs to **call** the agent correctly: the trigger, the exclusions and the required task fields. Inference from A11 (the body is the subagent's system prompt, and the parent delegates from the description): a "caller contract" written only inside the body is read by the subagent, not by the caller.
- "Use proactively" in a description encourages automatic delegation (A11).
- Newer models delegate readily and can over-spawn, for instance a subagent for a search a single `grep` answers. Add guidance on when subagents are and are not warranted (A13).

## When a subagent pays off

| Use a subagent when | Stay in the main conversation when | Source |
| --- | --- | --- |
| The task produces verbose output the parent does not need | The work needs back-and-forth or iterative refinement | A11 |
| You want enforced tool limits or permissions | Several phases share a lot of context (plan, implement, test) | A11 |
| The work is self-contained and returns a summary | The change is small or latency matters, since a fresh subagent must first gather context | A11, A12 |

- Cost is mostly tokens: every subagent makes its own requests, and may run slower than doing it in place (A12).
- Multi-agent runs used about 15x the tokens of a chat and single agents about 4x in Anthropic's research system; the approach pays only where task value is high and the work parallelizes (A16).
- Use a cheaper model for simple subagent jobs, and ask for short summaries back (A12).
- Multi-agent suits breadth-first, parallelizable work. Domains where all agents must share the same context or have many dependencies fit it poorly (A16).

## Writing the brief

Each delegated task needs, per Anthropic's research system (A16):

1. an objective,
2. an output format,
3. guidance on tools and sources,
4. clear task boundaries.

Without that, subagents duplicate work, leave gaps or misread the task. Also:

- Embed effort-scaling rules in the lead prompt (one agent and a few calls for a simple lookup, more for a broad one); agents misjudge effort (A16).
- Let subagents write bulky results to files and return references, to avoid the "game of telephone" (A16).
- Share full context, not only the task sentence; actions carry implicit decisions that conflict when agents work in parallel (C3).
- The parent's own conversation rules do not reach a non-fork subagent; restate any rule that must apply (A11).

## Single writer, read-only helpers

| Fact | Source |
| --- | --- |
| Parallel agents that all write make fragmented decisions. Setups that work keep writes single-threaded while other agents contribute intelligence: search, review, planning. | C3, C4 |
| A reviewer with a clean context (no shared history with the author) catches bugs the author cannot see. | C4, A12 |
| A reviewer told to find problems will always find something; scope it ("check requirements X, skip style"). | A12 |
| A manager that splits work, children that execute and a manager that synthesizes is the practical shape; unstructured swarms are mostly a distraction. | C4 |

## Tools and enforcement

- Restrict tools in the definition so the harness enforces the limit instead of the prompt requesting it. A reviewer with only read tools cannot edit whatever its prompt says (A12).
- Hooks and permission modes enforce rules that must hold every time (A12, A11).
- A baseline that is harness-neutral should state the capability a role needs ("read-only", "can run shell") and leave the tool grant to the importer.

## Instruction files (AGENTS.md)

| Fact | Source |
| --- | --- |
| `AGENTS.md` is plain Markdown for agents; the closest file to the edited code wins. Codex concatenates files from the repository root down and stops at 32 KiB by default. | A22, A21 |
| Context files did not improve task success in a controlled study and raised inference cost by over 20% on average; this held for LLM-written and developer-written files. Agents follow the instructions inside, but repository overviews did not help. Context files are useful for **non-standard practices**. | B1 |
| Keep such a file to what the agent cannot work out from the code: exact commands, misleading places, unrecorded decisions, things corrected twice. | A12 |
| Subagents in Claude Code load `AGENTS.md`, so its size is paid again on every dispatch. | A11 |

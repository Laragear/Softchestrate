# Softchestrate agent baselines

A library of platform-neutral, model-agnostic source definitions for subagents and skills, to be copied or adapted into an agent harness. The directory itself is not a runtime discovery path. These rules apply to the whole tree.

**Who reads what.** An agent or person installing the baselines reads [Installing](#installing), [The complexity key](#the-complexity-key), [Dispatching subagents](#dispatching-subagents), [Adapting into a harness](#adapting-into-a-harness) and [Assigning models](#assigning-models). A contributor changing the baselines also reads [Layout](#layout) and [Contributing](#contributing).

## Installing

Never clone the repository to install. The [README](README.md#installation) owns the commands and the inventory of agents and skills (see its tables). In short:

- Skills: `npx skills add Laragear/Softchestrate` (add `--all -g -y` for everything, globally, without questions).
- Subagents: `curl -fsSL https://raw.githubusercontent.com/Laragear/Softchestrate/1.x/install-agents.sh | sh`. Read the script before you run it.
- By hand: copy `agents/` and `skills/`. Copy each skill whole, including its own `references/` and `scripts/`. Do not copy the root `references/`: it is maintainer research.
- Installed copies are replaced on every update. Adapt them under [Adapting into a harness](#adapting-into-a-harness), in the harness's own configuration, never by editing the copies.

## Layout

- `agents/*.md`: subagent definitions. Frontmatter holds `name`, `description` (used for listing and dispatch, so it carries the call contract) and an optional `complexity`, one of the five words under [The complexity key](#the-complexity-key). The Markdown body is the system prompt. One role per file.
- `skills/<name>/SKILL.md`: skill definitions. Frontmatter holds `name`, `description` and optional `license`, `compatibility` and `allowed-tools`, with no `metadata` block and no `complexity`. Optional `references/` and `scripts/` inside the skill are loaded on demand. The directory name equals `name`.
- `references/`: maintainer research on skill and subagent practice. Start at `references/INDEX.md`; the audit checklist is `references/rules.md`. Not copied into harnesses.
- Baselines say what to do and when, never where: no model names, providers or harness-specific configuration, tool names or settings.

## The complexity key

Subagent definitions may carry a top-level `complexity` field: `mundane`, `routine`, `interpreting`, `judgment` or `critical`. It says what kind of work the definition does, not which model runs it. It is a starting point for [Assigning models](#assigning-models), never a rule. If it is missing, read the whole file and decide.

| Tier | The work | Example |
| --- | --- | --- |
| `mundane` | One fully specified step where the spec settles every choice. | List all TODO comments. |
| `routine` | A prescribed procedure with light branching and local reads. | Run tests and report results grouped by root cause. |
| `interpreting` | Mixed evidence to weigh, prose quality that matters, or a plan that already fixes the approach. | Summarize an RFC thread's contested trade-offs. |
| `judgment` | Diagnosis, unfamiliar code, trade-offs, or open-ended work with no ready procedure. | Debug intermittent double-charging with no reproducer. |
| `critical` | Live or irreversible state changes, long-horizon orchestration, or foundational design. | Plan a billing-schema migration under live traffic. |

When you write a definition's tier, pick the higher of two: the tier describes its hardest typical run. The description's scope, risk and ambiguity say how far up or down to lean.

## Dispatching subagents

Choose the narrowest role that fits. Do not force a dispatch when no role applies.

- Start every dispatch from a fresh context window. Pick that explicitly where the harness offers a choice: some harnesses fork the parent conversation by default, and a fork inherits what the dispatch existed to escape.
- Do not assume the subagent has your context or tools. Include the objective, relevant context and user decisions, bounded scope, available capabilities, and acceptance or reporting criteria.
- Set model and effort per dispatch, under [Assigning models](#assigning-models).

## Adapting into a harness

The *harness configuration* is the harness's native settings, outside these baselines. Every adaptation is recorded there.

1. Copy `agents/` and `skills/` into the harness's discovery paths.
2. Translate the frontmatter into the format the harness records. Keep the body verbatim as the system prompt or skill instructions.
3. Decide each skill's invocation. Leave skills model-reachable unless the harness gives a reason. Where the harness can stop the model from starting a skill by itself, do that for `deploying-builds`.
4. Keep a skill's `description` a pointer: triggers and exclusions, never a summary of the body. Cut any identity or procedure the body already carries.
5. Grant tool access, including MCP servers where supported. Map each requested capability to the target's tools and set a practical fallback when one is missing.
6. Enforce read-only roles (`code-reviewer`, `build-doctor`, `code-explorer`, `refactoring-finder`, `security-auditor`) by restricting tools, not by prose.
7. Do not hard-wire one model per definition.

## Assigning models

Do this at import and for each dispatch. Record the result in the harness configuration, never in a baseline.

1. **Get current data.** Use the harness's record of model capabilities and prices if it is newer than the last import. Otherwise look up each model's vendor documentation and price list, and note the sources and date. If you cannot search, use each level's default tier and say so.
2. **Compare capabilities.** Record at least: reasoning depth for multi-step judgment; agentic coding and tool-use reliability; instruction following under strict constraints (read-only roles, fixed output formats); context length; speed; price per token; supported effort or thinking controls.
3. **Group models into tiers** by capability and price. Each model belongs to exactly one tier. Each complexity has a default tier.
4. **Evaluate the dispatch.** Ask how much judgment it needs, how large its blast radius is (live state, irreversible change, security conclusions), how much unfamiliar code or ambiguous spec it touches, and how much context it carries. Choose the cheapest tier that covers all four. Start from the complexity as a prior and move down only for a stated reason. A mundane task never runs on the top tier just because its definition says `critical`.
5. **Hold risky work at its default tier.** For deployments, destructive changes and other live-state work, never go below the complexity's default tier.
6. **Escalate on evidence, and refresh.** If a dispatch fails its acceptance criteria, retry once on the next tier up and record why. Do not start high to be safe. Repeat step 1 whenever the data is older than the last import.

Example: a dev-container build labelled `judgment` is a bounded procedure checked by commands, so a mid-tier model with strong tool use may cover it. A security audit labelled `judgment` needs deep judgment across unfamiliar code, so a strong tier is usually enough.

## Contributing

- Treat these files as read-only during ordinary task work. Modify a baseline only when the user explicitly asks to change the baseline itself. Do not edit, rename, reformat or remove one to tune an imported agent.
- Each rule has one owner. Link to it, do not restate it.
- Before you commit a change, check that:
  - frontmatter is valid and uses only the fields allowed under [Layout](#layout);
  - the directory name equals the skill's `name`;
  - every path a body mentions exists;
  - no model, provider, tool name or harness setting appears;
  - the file passes the audit checklist in `references/rules.md`;
  - a behavior change has one entry in `CHANGELOG.md`.

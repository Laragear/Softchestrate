# Skills: authoring guidance

How to write the content of a skill. Source IDs are in `sources.md`. Measured effects are in `context-evidence.md`.

## Contents
- Content principles
- Calibrating control
- Patterns that work
- Descriptions
- Scripts
- Testing and iteration
- Security

## Content principles

| Principle | Source |
| --- | --- |
| Ground the skill in real expertise: a completed task, runbooks, incident reports, review comments. A skill generated from an LLM's general knowledge yields vague procedures. | A2 |
| Add what the agent lacks, omit what it knows. Test each paragraph: would the agent get this wrong without it? If not, cut it. If the agent already does the task well without the skill, the skill adds nothing. | A2, A8 |
| Moderate detail beats exhaustive detail. Over-comprehensive skills make the agent chase instructions that do not apply. Concise stepwise guidance with one working example tends to win. | A2 |
| Scope a skill as a coherent unit, like a function. Too narrow forces several skills per task; too broad triggers imprecisely. One skill, one job. | A2, A20 |
| Use consistent terminology: one term per concept throughout (not "endpoint / URL / route / path"). | A8 |
| Do not write time-sensitive statements. Put legacy behavior in a collapsed "old patterns" section. | A8 |
| Favor reusable procedures over specific answers; specific details (output templates, constraints) are fine when the approach generalizes. | A2 |
| Provide a default and one escape hatch, not a menu of equal options. | A2, A8 |
| Keep rarely used material in `references/`, and say **when** to read each file ("read X if the API returns non-200"), not "see references/". | A2 |
| State the standing rules so they apply to the whole task ("run the tests after every edit"), because the skill is read once. | A10 |

## Calibrating control

- Give freedom when several approaches are valid and the task tolerates variation; explain why, which beats rigid directives (A2, A8, A19).
- Be prescriptive when an operation is fragile, consistency matters, or an exact sequence is required (A2, A8).
- Most skills mix both; calibrate each part separately (A2).
- Prefer explaining the reason over capitals and "MUST". Newer Claude models are more responsive to the system prompt and over-trigger on aggressive wording; "Use this tool when..." replaces "CRITICAL: You MUST use this tool when..." (A13, A19).
- If a line keeps being ignored despite emphasis, it is either buried in a long file or a rule with no exceptions that belongs in a hook (A12).

## Patterns that work

| Pattern | Use | Source |
| --- | --- | --- |
| Gotchas section in `SKILL.md` | Concrete corrections to mistakes the agent makes without being told. The highest-value content in many skills. Keep it in the body, not in a reference the agent may not open. | A2 |
| Output template | Agents pattern-match concrete structures better than prose descriptions. Short ones inline, long ones in `assets/` or `references/`. | A2, A8 |
| Checklist | Multi-step workflows with dependencies or validation gates. | A2, A8, A14 |
| Validation loop | Do the work, run a validator, fix, repeat until it passes. A reference document can be the validator. | A2, A8 |
| Plan, validate, execute | Batch or destructive operations: write a structured plan, check it against a source of truth with a verbose-error script, then execute. | A2, A8 |
| Conditional workflow | Branch at a decision point and send each branch to its own section or file. | A8 |
| Examples | Input/output pairs when style or level of detail matters; a few diverse canonical ones, not a laundry list of edge cases. | A8, A15 |

## Descriptions

The description is the only text always in context, so it carries the entire triggering burden (A3).

| Fact | Source |
| --- | --- |
| Say what the skill does and when to use it, with the keywords a user would say. | A1, A8 |
| Phrase it as an instruction to the agent ("Use this skill when...") and describe user intent, not internal mechanics. | A3 |
| Be a little pushy: list contexts where the skill applies even when the user does not name the domain. Models tend to under-trigger skills. | A3, A19 |
| Third person in the system prompt context ("Processes Excel files"), not "I can help you". | A8 |
| Hard cap 1,024 chars; a few sentences is usually right. Descriptions grow during tuning, so recheck the cap. | A1, A3 |
| Front-load the key use case: hosts shorten or drop long descriptions (1,536-char listing cap in Claude Code, 2% listing budget in Codex). | A10, A20 |
| Agents consult skills only for tasks they cannot do easily alone, so one-step requests rarely trigger a skill whatever the wording. | A3, A19 |
| Test with about 20 realistic queries, half should-trigger and half near-miss should-not-trigger, 3 runs each, a 60/40 train/validation split, and keep the best validation score. | A3, A19 |
| Expert variant: describe only the triggering conditions, never the workflow, because an agent that reads a workflow summary may follow it instead of the skill. This is an unmeasured claim and conflicts with the A-tier "what and when" rule (see `rules.md` § Tensions). | C6 |

## Scripts

| Fact | Source |
| --- | --- |
| Bundle a script when the agent reinvents the same logic across runs, or when determinism matters. Prefer plain instructions otherwise. | A2, A20 |
| Say whether to **run** the script (the usual case; only output enters context) or **read** it as reference. | A8 |
| Scripts must not prompt interactively, must document usage in `--help`, return helpful errors, emit structured output and use meaningful exit codes. Pin dependency versions. | A5 |
| Solve errors in the script instead of deferring them to the model; justify any constant. | A8 |
| Do not assume packages exist; list them. The API has no network or runtime installs; claude.ai can install from npm and PyPI. | A8 |
| Invoke scripts through their interpreter in prose (`bash scripts/x.sh`) because some packagers drop executable bits. | C6 |
| A referenced script that is not shipped is a broken skill: the model cannot run what is not there. | A8 (verify assumptions), repo audit |

## Testing and iteration

- Build evaluations before writing extensive documentation: run the tasks without the skill, record the gaps, write the minimum that closes them, compare against the baseline (A4, A8, A14).
- Run each case with the skill and without it (or with the previous version), and record time and tokens, so a skill that doubles tokens for no gain is visible (A4).
- At least three evaluations; test with every model you plan to use, since Haiku needs more guidance and Opus tolerates less over-explanation (A8).
- Read execution traces, not only outputs. Wasted steps point to vague instructions, inapplicable instructions or menus without a default (A2).
- Fold every correction you had to make into the gotchas section (A2).
- Many shipped skills give no benefit; keep a skill only if it beats the baseline (B2, B3, B4).

## Security

Audit skills from less-trusted sources before use: bundled code, dependencies, instructions that connect to external hosts (A14, A19).

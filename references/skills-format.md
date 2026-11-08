# Skills: format, limits and how harnesses load them

Facts about what a `SKILL.md` must look like and what each harness does with it. Source IDs are in `sources.md`.

## Contents
- The open format
- Validator behavior
- Loading model and token costs
- Per-harness behavior
- Naming
- Portability checklist

## The open format

| Fact | Source |
| --- | --- |
| A skill is a directory with a required `SKILL.md` (YAML frontmatter + Markdown body). Optional: `scripts/`, `references/`, `assets/`. | A1 |
| `name`: 1-64 chars, lowercase letters/digits/hyphens, no leading, trailing or consecutive hyphens, **must equal the parent directory name**. | A1, A7 |
| `description`: required, 1-1024 chars, says what the skill does **and** when to use it, with keywords that help the agent pick it. | A1 |
| Optional fields: `license`, `compatibility` (1-500 chars, only for real environment needs), `metadata` (map of **string to string**), `allowed-tools` (space-separated, experimental). | A1 |
| The body has no format restrictions. It loads whole on activation, so the spec recommends under 5,000 tokens and under 500 lines, with detail moved to separate files. | A1, A2 |
| References are relative paths from the skill root, **one level deep** from `SKILL.md`. | A1, A8 |
| Long reference files (over 100 lines) start with a table of contents, because the model may preview them with partial reads. | A8 |
| Use forward slashes in paths; name files by content (`finance.md`, not `doc2.md`). | A8 |

## Validator behavior

| Fact | Source |
| --- | --- |
| The reference validator accepts exactly these top-level keys: `name`, `description`, `license`, `allowed-tools`, `metadata`, `compatibility`. Any other key is an error. Custom data goes under `metadata`. | A7 |
| It errors when the directory name differs from `name`. | A7 |
| Its parser coerces `metadata` values to strings, so `complexity: 4` passes it, but the spec text says string values. Quote them (`"4"`) to satisfy strict readers. | A7, A1 |
| claude.ai uploads, the Skills API and `package_skill.py` hard-fail on any key outside the six above. Claude Code ignores unknown keys silently. | A10 |
| Reserved words: names may not contain `anthropic` or `claude`; no XML tags in `name` or `description`. | A8 |
| In Claude Code `<` and `>` in descriptions are shown as `&lt;` `&gt;`; use square brackets for placeholders. | A10 |
| If the YAML does not parse, Claude Code loads the body with empty metadata, so the skill cannot be matched by description. | A10 |

## Loading model and token costs

| Level | Loaded | Cost | Source |
| --- | --- | --- | --- |
| 1. Catalog (`name` + `description`) | every session, every installed skill | about 50-100 tokens per skill | A6, A9 |
| 2. Body | when the skill is activated | under 5,000 tokens recommended; it then **stays in context** for the rest of the session | A1, A10 |
| 3. Bundled files | only when the model reads them; scripts cost only their output | none until read | A8, A9 |

- Anything in `references/` is free until read, so it is the right home for rarely needed material (A8, A14).
- After activation Claude Code does not re-read the file. On compaction it re-attaches the most recent invocation of each skill, keeping only the **first 5,000 tokens** of each, within a combined 25,000-token budget. Put the rules that must survive at the top (A10).
- Rules that must hold on every occurrence belong in a hook or tool restriction, not in skill prose (A10, A12).
- A model may fail to load a relevant skill on its own; harnesses offer explicit invocation for that (D2, A10).

## Per-harness behavior

| Harness | Fact | Source |
| --- | --- | --- |
| Claude Code | `description` + `when_to_use` are cut at 1,536 chars per entry in the listing. The listing as a whole gets 1% of the context window; when it overflows, descriptions of the least-used skills are dropped first, names always stay. Put the key use case first. | A10, D1 |
| Claude Code | `disable-model-invocation: true` keeps a side-effecting workflow (deploy, commit, send) from being started by the model; it then runs only on explicit `/name`. Such skills also cannot be preloaded into subagents. | A10, A11 |
| Claude Code | Skills can run in a forked subagent with `context: fork`; subagents can preload skills with the `skills` field (full content injected at startup). | A10, A11 |
| Codex | Starts from name, description and path. The initial list is capped at 2% of the context window (8,000 chars if unknown) and Codex shortens descriptions first, then omits skills. Front-load the key use case. Discovery: `.agents/skills` from the working directory up to the repo root. | A20 |
| Codex | `agents/openai.yaml` with `allow_implicit_invocation: false` blocks implicit use. | A20 |
| Gemini CLI | The description drives activation; the model calls `activate_skill` and the user confirms with a consent prompt. | A23 |
| Zed | Catalog of name and description in the system prompt, a `skill` tool to load one; descriptions over 1,024 chars still load, with a warning. | A24 |
| pi | Does not require `name` to equal the directory name, but notes that matching is the portable choice. Warns that a model may not load a relevant skill unprompted. | D2 |

A cross-harness baseline therefore needs: spec-only frontmatter keys, `name` equal to the directory, and a description whose first sentence carries the trigger.

## Naming

| Fact | Source |
| --- | --- |
| Gerund form is preferred (`processing-pdfs`); noun phrases (`pdf-processing`) and imperatives (`process-pdfs`) are acceptable. | A8 |
| Avoid vague (`helper`, `utils`), over-generic (`documents`), reserved-word names, and **inconsistent patterns within one collection**. | A8 |
| Claude Code derives the `/command` from `name` or the directory, so renaming a skill renames its command. | A10 |

## Portability checklist

1. Frontmatter keys: only the six spec keys; extra data under `metadata` with string values.
2. `name` equals the directory name; lowercase, hyphens only.
3. Description at most 1,024 chars, key use case first, third person or imperative, no angle brackets.
4. Body under 500 lines; every bundled file is linked from `SKILL.md` and says when to read it.
5. No harness-specific tool names in the body; describe the capability and a fallback.
6. Scripts are referenced as run-or-read, are non-interactive and print `--help` (A5).

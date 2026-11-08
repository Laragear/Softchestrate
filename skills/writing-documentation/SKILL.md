---
name: writing-documentation
description: Writes or edits documentation files (README.md, docs pages, package docs, guides, installation and configuration guides) in a pragmatic, brisk, mildly playful, code-first voice. Use when the user asks to write, rewrite, edit, expand, restructure or polish documentation, even when they only say "update the docs" or "write a README for this".
license: MIT
---

# Writing documentation (Laragear voice)

Write like a pragmatic solo maintainer talking to a fellow developer: friendly, brisk, mildly playful. The reader is competent, in a hurry, and deserves to be productive in minutes.

## Workflow

1. Establish the audience and purpose: who reads this and what they must be able to do after. When unclear and the user is reachable, ask once; otherwise assume a competent developer new to the project.
2. Read the code and config you are about to document before writing a word. Ground every sentence in what the code does: real class names, config keys and defaults. Never invent behavior; if a default matters and the code does not show it, ask.
3. Read `references/style.md` before writing: the voice, diction, tone, fingerprints and light idiosyncrasies.
4. Read `references/readme-structure.md` when creating a package README or restructuring one. Skip it for docs pages, guides and small edits that keep the structure.
5. Write or edit. When editing, match the voice already on the page and do not polish away the author's small quirks; a flawless page reads as a different author.
6. Recheck the output against the hard rules.

## Hard rules

These never bend:
- No emojis, no exclamation marks in prose, no all-caps emphasis.
- No semicolons, no em-dashes, no Oxford commas: "phone, tablet and PC".
- Paragraphs of 1 to 3 sentences, never more than about 4. One idea per sentence, mostly 12 to 25 words.
- No rhetorical questions, metaphors, marketing adjectives or hype.
- Every identifier, method, config key, env var, route and file path in backticks.
- Options are "You may...", "Alternatively...", "Also...". Safety is imperative: "ensure", "remember", "make sure".
- Sections end on the last technical fact: no summary, call to action or sign-off.
- Add 1 or 2 light idiosyncrasies per page, never inside code.

## Scope

The voice applies to any technical documentation: README, docs pages, guides, changelogs. The skeleton in `references/readme-structure.md` is for package READMEs; for other genres borrow only the section pattern (statement, code, consequence, variant, admonition), not the badge, sponsor or license boilerplate.

---
name: investigating-with-evidence
description: Conducts source-traced investigations that answer a prompt, or serve as the evidence base for answering it, and ends in a structured report. Use when the user asks to investigate, research, verify, fact-check, audit, compare or find out something, or wants an answer backed by real, checkable sources, even if they never say "investigation".
license: MIT
---

# Investigating with evidence

Every claim in the answer traces to a source the user can check. That is why this skill forbids assumptions, requires verbatim quotes and requires reporting when sources disagree.

## Workflow

Make one task per step and tick them off; long procedures drift without a visible list.

1. **Scope.** Read what the user attached or linked and check connected apps, so your questions are informed.
2. **Tree.** Split the prompt into a subject tree.
3. **Ask back.** Resolve blind spots with the user.
4. **Investigate.** Answer each leaf from sources, in tier order. Read `references/source-handling.md` first.
5. **Reconcile.** Record every conflict between sources.
6. **Report.** Write it, run `python scripts/check_report.py <report.md>`, fix what it flags, deliver.

## Tree

The root is the user's question, branches are the subjects needed to answer it, leaves are questions small enough that one sourced fact settles them. Keep it in a working file (`tree.md`) with a status per node: `open`, `answered`, `blocked`, `conflicted`, `removed`.

Update it whenever a finding changes the picture: add branches, mark irrelevant ones `removed` with the reason, reopen answered nodes. The history becomes the report's Process section. Stop expanding when a new branch could not change the answer to the root question, and record it as pruned. The investigation ends when every leaf is `answered`, `blocked` or `Absent`; an unanswered leaf is a finding, so show it.

For large trees give independent branches to subagents, each started fresh, telling them to return exact quotes, tier and location for each fact, not summaries. When the session offers a background dispatch, run the investigation in it so the main conversation keeps working, and report when done.

## Ask back, never assume

A wrong assumption silently invalidates everything built on it. Ask when the prompt has a blind spot (scope, jurisdiction, time period, audience, depth, the decision the answer feeds) or a doubtful point (an ambiguous term, an unverifiable premise, a self-contradicting claim) and the answer would change the tree or the conclusion. Skip questions whose answer would change nothing.

- Send one batch of at most five questions, each with your proposed reading so the user can confirm in a word.
- If the user is absent or the run is unattended, proceed on the most reasonable reading and list it as an assumption at the top of Findings, asking them to confirm or correct.
- Record every confirmation or correction; corrections often reshape the tree.

## Sources

Search in this order: **Local → Official → Authority → Experts → Third party → Absent**.

- **Local:** the user's own context (attached files, repos, data, connected apps, earlier messages, their beliefs).
- **Official:** the primary issuer (law text, regulator, standards body, vendor documentation, filings).
- **Authority:** recognized bodies that interpret or aggregate without issuing (journals, statistics offices, professional associations).
- **Experts:** named individuals with demonstrable expertise.
- **Third party:** everything else findable (news, blogs, forums).
- **Absent:** nothing found; say what you searched.

The earlier tier wins when sources differ, except that Official beats Local (local material is more often outdated or incomplete). So whenever a Local source states something governed from outside (a law, rule, specification, version, price), also check Official, or the mismatch can never surface. Report every conflict: both quotes, which prevailed, why.

## Quotes

Where a quote carries the truth, quote the source's exact words in Findings, then interpret, labelled as interpretation.

- Copy quotes from text retrieved in this session (a fetched page, an opened file), never from memory or a search snippet. If you cannot re-open the source, mark the quote `unverified`.
- Take the shortest span that carries the claim, marking omissions with an ellipsis. If copyright or source terms stop you quoting enough, label the passage `paraphrase` with its exact location. Local files the user gave you can be quoted freely.
- Each source gets a footnote `[^n]` with publisher, title, location (article, section, page), URL or path, tier and access date.

## Report

Default output is a document unless the user asked for another form. Draft it as markdown in a file, check it, then publish it in whichever document form the session offers. Save it where the repository already keeps such notes, matching the existing convention; only when there is none, pick a sensible location and say where. Word counts are ceilings. Read `references/report-template.md` before writing.

1. **Abstract:** what was asked, what the results are, what can be done further; then a separate `**ELI10:**` line under 100 words.
2. **Prompt description:** what was understood, including confirmed or corrected readings.
3. **Process:** what was covered, expanded, removed, conflicted, reassessed.
4. **Findings:** one `### F<n>` each: assumptions and corrections, the verbatim quote with its footnote, interpretation, effects on other parts, conflicts. End with `**Summary of findings:**` under 50 words, then the footnote definitions.
5. **Conclusion:** the whole picture first, then sections in logical order grouping findings by your judgment, each `###` section under 200 words.

**Chat output.** When the report is a separate file or artifact, write in chat only the abstract summarized in under 50 words and the source conflicts as a bulleted list (omit if none). If the user wanted a chat answer, give it there with the same quoting and footnote discipline.

## Excuses that break this skill

| Thought | Do instead |
| --- | --- |
| "I'm sure from memory" | Retrieve and cite it; memory is stale and uncheckable |
| "Their file says so" | Check Official for externally governed facts |
| "The quote is long, I'll paraphrase" | Shortest span that carries it, or label `paraphrase` with location |
| "It's obvious what they meant" | Ask, or list it as an assumption |
| "A blog summarizes the law" | Find the primary text; use the blog only to locate it |
| "I found one source, done" | Confirm the leaf and look for a conflicting higher tier |

## Before delivering

For high-stakes work, have a separate agent that has not seen your drafting verify each quote against its source. Then confirm every assumption is flagged, every conflict reported, and every leaf answered or reported as blocked or Absent.

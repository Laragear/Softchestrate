# Branch briefs

Read this when you hand tree branches to subagents. The subagent sees only the brief, not this skill, so the brief must stand alone. The tier order, quote rules and conflict shape are in SKILL.md and `source-handling.md`; the brief repeats only the part the subagent needs.

## Brief

Start every subagent from a fresh context window. Send one brief per independent branch, all in parallel:

```
Investigate <narrow branch of the tree>.

Objective: <what the returned notes must cover>

Leaves (answer each one):
- <leaf question 1>
- <leaf question 2>

Constraints: <bounds from the user's prompt and confirmed readings: period, jurisdiction, version, audience>

Source order: Local, Official, Authority, Experts, Third party. Prefer the original document over a page describing it. Re-open every source you quote.

Budget: about 10 lookups, never more than 15. Stop early when every leaf is answered or new lookups stop adding facts. Do not repeat a query; vary the phrasing.

Return: write the notes to <absolute path>/<branch>.md in the format below. Quote exact words, never summaries.
```

Why the budget: an open-ended branch keeps searching after the answer is in hand, and the caller waits for the slowest one.

## Notes format

One block per leaf, so the caller can lift findings into the report without rereading sources:

```markdown
## <Leaf question>

### Takeaway
<one or two sentences>

### Quoted findings
- "<exact quote>" - <publisher, title, location, URL or path>. Tier: <tier>. Accessed <date>.
- ... Conflicts with: <second source and quote>.

### Inferences
- <what follows from the quotes above; no new facts>

### Gaps
- <what could not be found or opened, what was searched>
```

A fact without a source goes under Gaps, never under Quoted findings. Quotes copied from a search snippet or from memory are marked `unverified`.

## Closing gaps

When the branches return, read the Gaps. If a gap could change the root answer, run one more round of briefs for those leaves only, then write the report whatever comes back. Leaves still open are reported as `blocked` or Absent. Say in one line when you start the extra round, so the end of the work stays in sight.

## Extending earlier work

When the request extends or updates an earlier investigation, read its report and notes first, brief only what the new request adds or what needs a recheck, and write to a new file. Never overwrite the earlier report. When the user asks for the earlier work to be redone independently, do not pass it on.

# Source handling

The tier definitions and the conflict rule are in SKILL.md. This file covers how to work with sources in practice.

## Searching

- Tiers set which result you trust, not the order of tool calls. Run independent searches in parallel.
- Time-sensitive facts (who holds a role, prices, rules in force, versions) need a fresh lookup even when the answer feels familiar. Record the access date.
- Prefer the original document over a page describing it. If you only reach a description, record that and keep looking for the original.
- A source you could not open is not a source. Say you could not reach it.
- Within one tier, prefer the more recent and more specific source, and say so.
- A lower-tier source that adds detail without contradicting a higher one is supplementary, not a conflict; cite it as such.

## What to record per fact

Tier, publisher, title, location inside the source (article, section, page), URL or path, access date, and the exact quote. These become the footnote and the Findings entry.

## Reporting a conflict

Use this shape in Findings (and list it in the chat summary):

```
Conflict: <topic>
- Local (notes.md, line 12): "<quote>"
- Official (Regulation X, Art. 33(1)): "<quote>"
- Prevailed: Official, because Official contradicts Local and local material is more often outdated.
- Effect: <which findings or tree branches change>
```

## When nothing is found

Record the leaf as Absent: what you searched (tiers, terms), and that nothing was found. Do not fill the gap with an estimate or a recollection; the user can act on a stated gap, not on an invented number.

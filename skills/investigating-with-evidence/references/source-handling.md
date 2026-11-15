# Source handling

The tier definitions and the conflict rule are in SKILL.md. This file covers how to work with sources in practice.

## Searching

- Tiers set which result you trust, not the order of tool calls. Run independent searches in parallel.
- Time-sensitive facts (who holds a role, prices, rules in force, versions) need a fresh lookup even when the answer feels familiar. Record the access date.
- Prefer the original document over a page describing it. If you only reach a description, record that and keep looking for the original.
- A source you could not open is not a source. Say you could not reach it.
- Within one tier, prefer the more recent and more specific source, and say so.
- A lower-tier source that adds detail without contradicting a higher one is supplementary, not a conflict; cite it as such.

## Weighing a source

Tier says who published it; these checks say whether to believe this passage. Run them before a quote enters Findings.

- Fact or speculation? Predictions, "could" and "may", and future-tense narrative are not findings. Quote them as forecasts or leave them out.
- Original or aggregator? Follow a citation chain to its origin; if you cannot reach it, record that.
- Does the source show its basis? Passive voice with nameless sources ("it is said"), vague qualifiers without numbers, and repeated unconfirmed reports are weak even in a good outlet.
- Is it current? For anything time-sensitive, trust a fresh lookup over memory.

Note a failed check in the finding instead of dropping the source silently.

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

# Report template

Word limits and the section list live in SKILL.md. This file shows the markdown shape that `scripts/check_report.py` expects, and one worked finding.

## Skeleton

```markdown
# <Title>

## 1. Abstract
- **What was asked:** ...
- **Results:** ...
- **What can be done further:** ...

**ELI10:** ...

## 2. Prompt description
...

## 3. Process
...

## 4. Findings

### F1. <short title>
**Assumptions / corrections:** ...

> "<verbatim quote>" [^1]

**Interpretation:** ...
**Affects:** ...
**Conflict:** ... (omit if none)

**Summary of findings:** ...

[^1]: Publisher, title, location, URL or path. Tier: Official. Accessed 2026-10-27.

## 5. Conclusion
<whole picture>

### <Group 1>
...
```

## Worked finding

```markdown
### F2. Breach notification deadline
**Assumptions / corrections:** The user's notes (Local) say 7 days. Confirmed with the user that the question concerns the EU regulation itself.

> "...not later than 72 hours after having become aware of it..." [^2]

**Interpretation:** The deadline runs from awareness of the breach, not from its occurrence. (Interpretation, not quoted.)
**Affects:** F3 (incident-response timeline) must use 72 hours.
**Conflict:** Local notes say 7 days; Official says 72 hours. Official prevails because it contradicts Local and local notes are more often outdated.

[^2]: Regulation (EU) 2016/679, Art. 33(1), eur-lex.europa.eu. Tier: Official. Accessed 2026-10-27.
```

Notes:
- Footnote definitions must name a tier (Local, Official, Authority, Experts, Third party) so the reader sees how much weight the source carries.
- A leaf with no source gets its own `### F<n>` finding stating it is Absent, what was searched, and no quote.
- If the user asked for another output form (table, deck), keep the same quote-then-interpret logic and the same footnotes.

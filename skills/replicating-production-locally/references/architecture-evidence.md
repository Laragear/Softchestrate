# Architecture evidence

## Contents
- Source ranking
- Decided vs not decided
- Conflicts
- Evidence record

## Source ranking
Highest first. Use the highest available; lower ones only to fill gaps.
1. Deployed-state definitions: infrastructure-as-code, orchestration manifests, compose files used in production, firmware build and partition configs, kernel or driver build configs.
2. Deploy jobs in CI/CD that actually run for production.
3. Architecture decision records with an accepted status.
4. Runbooks and operations docs.
5. README and informal docs.

## Decided vs not decided
Decided: present in rank 1 or 2, or rank 3 accepted and not contradicted by rank 1 or 2.
Not decided: statuses such as proposed, draft, deprecated, superseded without replacement; TODO or "planned" sections; diagrams with no matching definition; anything only in rank 5.
Replicate decided parts only. Report undecided parts as out of scope, not as gaps you filled.

## Conflicts
When sources disagree, prefer the higher rank, show both to the user with `path:line`, and ask which one to follow if the difference changes a component.

## Evidence record
Each inventory row keeps: component, fact, `path:line`, rank, decided yes/no.

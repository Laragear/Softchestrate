# Aside: Rename post slugs

- id: rename-post-slugs
- origin: soft-delete-post
- reason: unrelated
- created: 2026-11-10T09:00:00+01:00

## Scope
Rename the slug column of posts. Unrelated to soft deletes.

## Known facts
- app/Models/Post.php: no slug attribute.

## Open decisions
- None.

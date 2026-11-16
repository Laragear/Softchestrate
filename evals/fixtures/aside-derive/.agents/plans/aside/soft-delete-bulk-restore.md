# Aside: Bulk restore of soft-deleted posts

- id: soft-delete-bulk-restore
- origin: soft-delete-post
- reason: nice-to-have
- created: 2026-11-10T09:00:00+01:00

## Scope
Restore many soft-deleted posts in one request. Covers no requirement of the soft-delete plan.

## Known facts
- app/Models/Post.php: Post has no SoftDeletes trait yet.

## Open decisions
- Max batch size. Recommendation: 100 ids per request.

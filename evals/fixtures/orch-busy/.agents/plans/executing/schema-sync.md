# Plan: Synchronize schema with the reporting replica

- id: schema-sync
- revision: 2
- workspace: /tmp/demo
- baseline: 4f2c9a1, clean
- updated: 2026-11-12T09:12:00+00:00
- status: executing
- execution authorization: full execution and commits authorized by the user

## Goal and acceptance criteria
Mirror the local schema changes onto the reporting replica without downtime.
AC1: replica tables match local migrations.
AC2: no lock longer than 2 seconds on replicated tables.

## Scope and constraints
- In scope: database/migrations, app/Models
- Out of scope: controllers, routes
- Decisions and conventions: batched DDL only, per the DBA note in docs/

## Evidence and assumptions
- Verified: replica is MySQL 8.0.34, per config/reporting.php

## Approach and contracts
Batched ALTERs with lock-timeout checks, one table per batch.

## Testing decisions
Verified at the migration seam: `php artisan migrate` against the replica copy asserts AC1.

## Phase rollup
| Phase | Depends on | Status | Run notes |
| --- | --- | --- | --- |
| 1 | - | complete | executor e-1, rev 2 |
| 2 | 1 | running | executor e-2, rev 2 |

## Phase 2: Backfill archived_at
- GOAL: Backfill archived_at for rows older than 2024-01-01.
- ACCEPTANCE CRITERIA: AC1 — check: row count with NULL archived_at under 100 — executor
- PRECONDITIONS: the archived_at column exists
- FILES IN SCOPE: database/migrations/2026_11_01_000000_backfill_archived_at.php
- PINNED CONTRACTS: none
- INSTRUCTIONS: 1. Add the batched backfill migration.
- EXEMPLARS: database/migrations/2026_10_01_000000_create_archive_table.php
- OUT OF SCOPE: models
- PARENT ACTIONS: none
- RISKS AND RECOVERY: long lock on big tables; run in batches of 10k.

## Integration and completion
Replica and local schemas match; no long locks recorded.

## Changes to the plan
- rev 2: batch sizes reduced after the DBA note.

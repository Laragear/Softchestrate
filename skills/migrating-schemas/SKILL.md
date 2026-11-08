---
name: migrating-schemas
description: Writes reversible database schema and data migrations that stay safe on tables already holding rows, using expand and contract steps, batched backfills and a reverse path, for any framework or SQL dialect. Authors migration files and their verification plan only; never runs them. Use when the user asks to add, rename, drop, retype or constrain a table, column, index or constraint, to backfill or transform existing data, or to write or review a migration, even when they only say "add a column". Applying a migration to a real database belongs to deploying-builds.
license: MIT
---

# Migrating Schemas

Write migrations that run safely against tables that already hold rows, and that can be reversed. This skill writes migration files and a verification plan. Applying a migration to a real database is a live change for `deploying-builds`.

## Procedure

1. **Read the schema as it stands.** Open the existing migrations in order, the current table definitions or models, and every code path that reads or writes the affected columns. A new migration goes after the newest existing one.
2. **Classify the change.**
   - Additive: a new table, a nullable column, an index. Usually one step.
   - Shape change: a rename, a retype, a split or merge of columns, a tighter constraint. Needs expand and contract.
   - Destructive: a dropped table or column, deleted rows. Needs a release in which nothing reads the removed part.
3. **Plan shape changes in releases.** Write each stage and name the release that ships it:
   - Expand: add the new shape, nullable or with a default the engine applies without rewriting the table.
   - Migrate: backfill existing rows while the code writes both shapes.
   - Contract: remove the old shape in a later migration, after the code that reads it has shipped and rolled out.
4. **Write backfills in batches.** Work through primary key ranges or chunks, commit each batch, and make reruns safe. Never update a whole large table in one transaction. Done when each batch commits on its own and a rerun over already-migrated rows changes nothing.
5. **Write the reverse path.** Each migration has a reverse that restores the previous shape. A reverse that cannot restore data, such as after a dropped column or a lossy retype, says so in the migration and in the report. Prefer deferring the drop to a later release. Done when every migration names its reverse or states why none exists.
6. **Check lock and rewrite risk per statement.** For the engine and version the project uses, find each statement that takes a long lock or rewrites a table. Use the engine's non-blocking form where one exists, such as a concurrent index build. Check the engine's own documentation, not memory. Done when every risky statement cites the doc section or flag that mitigates it.
7. **Keep migrations self-contained.** Name tables and columns literally. Do not call application models, services or config values inside a migration, since they change after it ships.

## Output

For each migration file, in run order:
- the path and what it changes;
- the release that ships it (expand, migrate or contract);
- the reverse, or why none exists;
- lock or rewrite risk per statement, and the mitigation used;
- any data loss;
- the verification for the caller to run before the real apply, on a copy of production-shaped data (build one with `replicating-production-locally` when none exists): apply, run the reverse, re-apply, and compare row counts and sample values.

Then list the application code changes the release needs, such as writes to both shapes or reads from the new one. This skill does not make those changes.

## Limits

- Never edit a migration that has run anywhere; add a new one.
- Never run a migration, seeder or database command here, including against a local database. The caller runs them.

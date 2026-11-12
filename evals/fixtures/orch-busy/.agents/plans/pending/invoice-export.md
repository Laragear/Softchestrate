# Plan: Invoice export endpoint

- id: invoice-export
- revision: 1
- workspace: /tmp/demo
- baseline: 4f2c9a1, clean
- updated: 2026-11-12T10:40:00+00:00
- status: ready
- execution authorization: full execution and commits authorized by the user

## Goal and acceptance criteria
Add an authenticated endpoint that exports the user's invoices as CSV.
AC1: GET /invoices/export streams a CSV of the user's invoices.
AC2: another user's invoices never appear.

## Scope and constraints
- In scope: app/Http/Controllers, routes
- Out of scope: database, models
- Decisions and conventions: streaming response, per the user's choice

## Evidence and assumptions
- Verified: Invoice model exists at app/Models/Invoice.php

## Approach and contracts
One controller action streaming CSV rows; route registered under the auth middleware.

## Testing decisions
Verified at the route seam: an HTTP test asserts the CSV header row and status.

## Phase rollup
| Phase | Depends on | Status | Run notes |
| --- | --- | --- | --- |

## Phase 1: Export endpoint
- GOAL: Ship the authenticated CSV export endpoint.
- ACCEPTANCE CRITERIA: AC1 — check: HTTP test GET /invoices/export expects CSV — parent
- PRECONDITIONS: Invoice model exists
- FILES IN SCOPE: app/Http/Controllers/InvoiceExportController.php, routes/web.php
- PINNED CONTRACTS: route name `invoices.export`
- INSTRUCTIONS: 1. Add the controller. 2. Register the route.
- EXEMPLARS: app/Http/Controllers/InvoiceController.php
- OUT OF SCOPE: models
- PARENT ACTIONS: none
- RISKS AND RECOVERY: none; revert the two files.

## Integration and completion
Route reachable for authenticated users only.

## Changes to the plan
None yet.

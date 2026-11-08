# Spec: Invoice CSV export

Add an export endpoint for the billing team's monthly reconciliation.

## Requirements

1. `GET /invoices-export` streams a CSV of the invoices of the authenticated user's own tenant as a download response (`Content-Type: text/csv`).
2. The CSV is produced by the internal reporting service at `http://reporting.internal/invoices/csv`, which the backend calls with the caller's tenant id. The URL is not caller-supplied.
3. When the reporting service is unreachable or errors, the endpoint returns the JSON body `{"error": "reporting_unavailable"}` with status 502.

## Out of scope

- Filtering by date range.
- Any other endpoint in `InvoiceController`.

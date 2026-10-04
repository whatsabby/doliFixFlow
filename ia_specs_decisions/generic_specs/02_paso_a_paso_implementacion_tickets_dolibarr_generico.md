# Step-by-step — Generic Ticket Implementation on Dolibarr

> Version: 0.1

## 1. Validate native Ticket module

Run manual checks before extension work.

## 2. Define native reuse vs extension

Keep base ticketing native; extend only operational gaps.

## 3. Create minimal module (`ticketflow`)

Ensure clean install/enable/disable and no core patching.

## 4. Implement status catalog

Use configurable status metadata and semantic flags.

## 5. Add required fields

Prefer extrafields for operational extensions.

## 6. Improve ticket detail and operational list

Expose required actions and visibility safely.

## 7. Apply permission model

Protect internal notes and enforce role boundaries.

## 8. Build importer (dry-run first)

Only run real imports after dry-run validation passes.

## 9. Run migration tests in staging

Validate counts, mappings, and duplicate prevention.

## 10. Run real operational scenarios

Confirm end-to-end usability with realistic workflows.

## 11. Integrate external entry points

Connect WordPress/forms only after core flow is stable.

## MVP

- installable module
- status model
- custom fields
- list/detail usability
- baseline permissions
- dry-run importer


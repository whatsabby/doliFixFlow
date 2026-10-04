# Point 1 — SupportCandy Inventory Artifact

This document stores the exact requirements for **Point 1** of the migration preparation.

## Objective

Create the canonical inventory file used by the TDD and migration phases:

- `research/supportcandy_api_inventory_2026-08-25.json`

## Mandatory inputs

- Discovery output from:
  - `research/supportcandy/supportcandy_discovery.sql`
- Raw exports from selected SupportCandy-related tables.

## Mandatory sections in the inventory JSON

Top-level keys required:

- `meta`
- `tables_discovered`
- `agents`
- `customers`
- `catalogs`
  - `statuses`
  - `priorities`
  - `categories`
- `fields`
- `tickets`
- `threads`
- `attachments`

## `meta` minimum fields

- `generated_at` (ISO 8601)
- `source_system` = `supportcandy`
- `wordpress_site` (host/subdomain)
- `db_engine` (MySQL/MariaDB version)
- `export_mode` (`read_only_select`)
- `notes`

## Data rules

- Do not invent data.
- Preserve original IDs from SupportCandy in exported records.
- Use UTF-8 encoding.
- Keep deterministic structure for re-runs.
- If a domain has no data, include it as an empty array (do not remove the key).

## Idempotency-prep fields (recommended in each migrated entity)

Where applicable, include these source identity fields:

- `source_system` = `supportcandy`
- `source_id` = original SupportCandy identifier
- `source_table` = original table name

These fields are required later for dedupe rules (`source_system + source_id`).

## Validation checklist

- [ ] JSON file exists at exact path.
- [ ] JSON is valid and parseable.
- [ ] All mandatory top-level keys exist.
- [ ] IDs are preserved from source.
- [ ] UTF-8 confirmed.
- [ ] File can be regenerated from same raw exports with same structure.

## Related files

- `research/supportcandy/EXPORT_CHECKLIST.md`
- `research/supportcandy/supportcandy_discovery.sql`

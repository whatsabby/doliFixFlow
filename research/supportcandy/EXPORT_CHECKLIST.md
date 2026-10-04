# SupportCandy Export Checklist (for Dolibarr Migration)

Use this checklist to produce the migration input artifacts for `doliFixFlow`.

## 0) Preconditions

- Work on a **staging clone** (not production).
- Use a **read-only DB user** (`SELECT` only).
- Confirm DB is MariaDB/MySQL and you know:
  - host
  - port
  - database
  - username
  - password

## 1) Discover real SupportCandy tables

Run the SQL script:

- `research/supportcandy/supportcandy_discovery.sql`

This will output:

- candidate WordPress prefixes,
- active plugin/version hints from options,
- SupportCandy candidate tables (`wpsc`, `wpsp`, `supportcandy`, `psmsc` patterns),
- row counts,
- columns for each candidate table.

## 2) Select source tables for export

From discovery output, prioritize tables containing these concepts:

- tickets
- ticket meta
- threads/replies
- customers
- agents
- statuses
- priorities
- categories
- custom fields
- attachments/files

> Do not guess fixed table names: SupportCandy versions can differ.

## 3) Export data (raw)

Export each selected table to CSV/JSON into:

- `research/supportcandy/raw/`

Recommended filenames:

- `table_<real_table_name>.csv`
- `table_<real_table_name>.json`

## 4) Build consolidated inventory artifact

Create this file:

- `research/supportcandy_api_inventory_2026-08-25.json`

Recommended shape:

- `meta`
- `tables_discovered`
- `agents`
- `customers`
- `catalogs` (`statuses`, `priorities`, `categories`)
- `fields`
- `tickets`
- `threads`
- `attachments`

## 5) Validation before handoff

- [ ] Discovery output saved.
- [ ] Table list + row counts saved.
- [ ] Raw exports for all selected tables saved.
- [ ] Consolidated inventory JSON created.
- [ ] No write operations were executed on production DB.

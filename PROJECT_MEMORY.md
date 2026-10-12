# Project Memory (Compact Context)

> Purpose: single source of truth for working context during implementation.
> Keep this file short and update it when decisions change.

## 1) Mission / Scope

- Build a Dolibarr module for Letsfix (Letsfix-first, TFM-ready).
- Later we will create a generic equivalent, but NOT now.
- All behaviors must be idempotent and parameterizable (no hardcoded WP prefix, brand strings, etc.).
- Reuse what Dolibarr already provides in its ticketing module whenever possible ("Dolibarr first").

## 2) Target runtime (Letsfix server)

User-provided environment (Point 1):
- OS: Linux Debian (kernel 5.10.0-45-cloud-amd64, date 2026-07-02)
- Web: Apache 2.4.67 + OpenSSL 1.1.1w
- PHP: 8.2.32
- DB: MariaDB 10.6.27
- DB charset/collation: utf8mb4 / utf8mb4_general_ci
- Virtual host: core.letsfix.es (443)
- Web root: /home/Letsfix/web/core.letsfix.es/public_html
- Dolibarr documents root: /home/Letsfix/web/core.letsfix.es/private/dolibarr-documents

## 3) Dolibarr version strategy

- Current installed: Dolibarr 20.0.2.
- Latest exists: Dolibarr 24.0.2.
- Strategy: develop for the newer behavior where possible, while maintaining compatibility with 20.x whenever feasible.

## 4) Current ticketing reality

- Production ticketing is SupportCandy (WordPress), not Dolibarr tickets.
- Dolibarr ticket module exists but historically unused.

## 5) SupportCandy data source (DB tables)

- Observed naming pattern: __WP_PREFIX__psmsc_*
- Example prefix: wp_
- Confirmed tables list is tracked in:
  - research/supportcandy/supportcandy_tables_reference_2026-10-04.md

## 6) SupportCandy export artifacts (read-only safe)

- Diagnostics (when discovery returns empty):
  - research/supportcandy/supportcandy_diagnostic.sql
- Discovery helpers:
  - research/supportcandy/supportcandy_discovery.sql
- Bulk export generator (SELECT-only):
  - research/supportcandy/supportcandy_bulk_export.sql
- Inventory artifact spec (Point 1):
  - research/supportcandy/POINT1_INVENTORY_ARTIFACT.md

## 7) TDD workflow (mandatory)

- Phase definitions live in:
  - lf_specs_definition/phase_0_definition.md ... lf_specs_definition/phase_5_definition.md
- TDD artifacts live in:
  - TDD/TDD_F0.md ... TDD/TDD_F5.md
- Conventions (source of truth for structure/governance):
  - TDD/TDD_CONVENTIONS.md

Rules:
- No implementation work without a matching phase definition + TDD artifact.
- For each phase:
  1) define phase
  2) define TDD
  3) get TDD green
  4) refactor + implement
  5) run tests
  6) close feature

## 8) Branding / parallel tracks

- Implement Letsfix-specific first.
- Generic track exists under ia_specs_decisions/generic_specs/ for later.

## 9) Repo docs / versioning

- Repo docs are being standardized in English.
- Changelog format follows Keep a Changelog.
- Version scheme was revised from 4 numbers to 3 numbers x.y.z (see CHANGELOG.md).

## 10) Next migration prerequisites

Captured on 2026-10-12:
- Column schemas for `wp_psmsc_tickets`, `wp_psmsc_threads`, `wp_psmsc_attachments`, `wp_psmsc_customers`, and `wp_psmsc_agents` are recorded in `research/supportcandy/supportcandy_tables_reference_2026-10-04.md`.
- A provisional mapping baseline is in `research/supportcandy/SUPPORTCANDY_DOLIBARR_MAPPING_DRAFT.md`; do not treat its target mappings as approved or implementation-ready.

Before implementing migration/module wiring:
- Validate native Dolibarr Ticket fields and import behavior in staging.
- Capture SupportCandy status, priority, category, and custom-field definitions/options.
- Obtain privacy-scrubbed representative values for ambiguous source fields and thread types.
- Export authorized WordPress user profile data needed to map customers/agents.
- Approve the source identity scope, dry-run/run contract, resume behavior, and reconciliation criteria through the Phase 4 gates.
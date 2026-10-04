# Parameter Matrix — `profile=brand` vs `profile=generic`

> Version: 0.1  
> Date: 2026-10-04  
> Status: ready for phased execution  
> Base: aligned with `01_especificacion_modulo_dolibarr_supportcandy.md` and dual-profile strategy

## 1) Objective

Define a single parameter catalog to run two profiles in parallel without forking core code:

- **Brand**: real production operation (owned profile).
- **Generic**: neutral profile for TFM/demo.

Mandatory rule: **no brand values in core code**; everything must come from configuration.

## 2) Key convention

- Recommended prefix: `lf.`
- Hierarchy: `domain.subdomain.key`
- Types: `string`, `bool`, `int`, `enum`, `json`
- Source: `env`, `db_config`, `seed_catalog`, `runtime`

## 3) Main matrix

| Key | Type | Brand (owned) | Generic (TFM) | Source | Priority | Impact |
|---|---|---|---|---|---|---|
| `lf.profile.id` | enum | `brand` | `generic` | env | High | Global routing |
| `lf.module.slug` | string | `letsfixtickets` | `ticketflow` | env | High | Routes/API/technical name |
| `lf.module.display_name` | string | `Letsfix Tickets` | `Ticket Flow` | db_config | High | UI |
| `lf.brand.enabled` | bool | `true` | `false` | env | High | Visible branding |
| `lf.brand.company_name` | string | `Letsfix` | `Organization` | db_config | High | Texts |
| `lf.brand.domain_label` | string | `letsfix.es` | `source-domain.local` | db_config | Medium | Copy and inventory |
| `lf.api.base_prefix` | string | `/api/letsfixtickets` | `/api/ticketflow` | env | High | Integrations |
| `lf.api.idempotency.enabled` | bool | `true` | `true` | env | High | Safe writes |
| `lf.api.idempotency.ttl_hours` | int | `24` | `24` | db_config | High | Retries |
| `lf.api.idempotency.scope` | enum | `method+path+key` | `method+path+key` | env | High | Dedupe |
| `lf.import.source_system` | string | `supportcandy` | `supportcandy` | env | High | Migration |
| `lf.import.dry_run_default` | bool | `true` | `true` | db_config | High | Safety |
| `lf.import.resume.enabled` | bool | `true` | `true` | env | Medium | Batch recovery |
| `lf.import.conflict_policy` | enum | `update_allowed_fields` | `update_allowed_fields` | db_config | High | Import idempotency |
| `lf.security.internal_notes_hidden` | bool | `true` | `true` | env | High | Privacy |
| `lf.attachments.max_size_mb` | int | `20` | `20` | db_config | Medium | Operations |
| `lf.attachments.allowed_mime` | json | `[...]` | `[...]` | db_config | Medium | Security |
| `lf.notifications.enabled` | bool | `true` | `true` | env | Medium | Communication |
| `lf.notifications.send_real_emails` | bool | `true` | `false` | env | High | Demo vs production environment |
| `lf.audit.log_level` | enum | `info` | `info` | env | Medium | Traceability |
| `lf.catalog.status.source` | enum | `seed+admin` | `seed+admin` | seed_catalog | High | Operational flow |
| `lf.catalog.priority.source` | enum | `seed+admin` | `seed+admin` | seed_catalog | Medium | Operations |
| `lf.catalog.category.source` | enum | `seed+admin` | `seed+admin` | seed_catalog | Medium | Operations |
| `lf.ui.default_view` | string | `my_tickets` | `all_open` | db_config | Low | UX |
| `lf.testing.dataset_mode` | enum | `masked_real` | `synthetic` | env | High | TFM/compliance |

## 4) Status matrix (shared semantics)

> Business semantics must be shared; only visible labeling/branding changes when needed.

| `status_code` | Semantics | Brand label | Generic label | `is_closed` | `is_waiting_customer` | `is_waiting_internal` |
|---|---|---|---|---:|---:|---:|
| `new` | Ticket created | 🚀 New | 🚀 New | 0 | 0 | 0 |
| `pending_reception` | Not yet received | 📦 Pending reception | 📦 Pending reception | 0 | 0 | 0 |
| `received` | Device received | 🏁 Received by Letsfix | 🏁 Received by workshop | 0 | 0 | 0 |
| `diagnosis` | Technical diagnosis | 🔍 In diagnosis by Letsfix | 🔍 In internal diagnosis | 0 | 0 | 1 |
| `assigned` | Technician assigned | 👨‍🔧/👩‍🔧 Technician assigned | 👨‍🔧/👩‍🔧 Technician assigned | 0 | 0 | 0 |
| `in_progress` | Active work | ⚙️ In progress | ⚙️ In progress | 0 | 0 | 0 |
| `repairing` | Active repair | 🛠️ Repairing | 🛠️ Repairing | 0 | 0 | 0 |
| `waiting_spare` | Waiting spare part | 🚚 Waiting spare part | 🚚 Waiting spare part | 0 | 0 | 1 |
| `waiting_customer` | Waiting customer reply | 💬 Waiting customer | 💬 Waiting customer | 0 | 1 | 0 |
| `waiting_internal` | Waiting internal reply | 🕓 Waiting Letsfix | 🕓 Waiting internal | 0 | 0 | 1 |
| `ready_to_ship` | Ready for delivery | ✅ Ready to ship | ✅ Ready to deliver | 0 | 0 | 0 |
| `shipped` | Shipped | ✈️ Shipped to customer | ✈️ Shipped | 0 | 0 | 0 |
| `delivered` | Delivered | 📬 Received by customer | 📬 Delivered | 1 | 0 | 0 |
| `quote_rejected` | Quote rejected | ❌ Quote rejected | ❌ Quote rejected | 1 | 0 | 0 |
| `closed` | Final closure | 🔒 Closed | 🔒 Closed | 1 | 0 | 0 |

## 5) API route matrix

| Operation | Template | Brand example | Generic example |
|---|---|---|---|
| List tickets | `GET /api/{module_slug}/tickets` | `/api/letsfixtickets/tickets` | `/api/ticketflow/tickets` |
| Create ticket | `POST /api/{module_slug}/tickets` | `/api/letsfixtickets/tickets` | `/api/ticketflow/tickets` |
| View ticket | `GET /api/{module_slug}/tickets/{id}` | `/api/letsfixtickets/tickets/123` | `/api/ticketflow/tickets/123` |
| Update ticket | `PUT /api/{module_slug}/tickets/{id}` | `/api/letsfixtickets/tickets/123` | `/api/ticketflow/tickets/123` |
| Add thread | `POST /api/{module_slug}/tickets/{id}/threads` | `/api/letsfixtickets/tickets/123/threads` | `/api/ticketflow/tickets/123/threads` |
| Import dry-run | `POST /api/{module_slug}/import/supportcandy/dry-run` | `/api/letsfixtickets/import/supportcandy/dry-run` | `/api/ticketflow/import/supportcandy/dry-run` |
| Import run | `POST /api/{module_slug}/import/supportcandy/run` | `/api/letsfixtickets/import/supportcandy/run` | `/api/ticketflow/import/supportcandy/run` |

## 6) Operational idempotency rules

1. Every write (`POST/PUT`) must accept `idempotency_key`.
2. Recommended uniqueness: `(http_method, canonical_path, idempotency_key, actor_id)`.
3. Repeat with same key and same payload => same logical response.
4. Repeat with same key and different payload => `409 Conflict`.
5. Import also uses dedupe by `source_system + source_id`.
6. `dry_run=true` never persists data.

## 7) Implementation order (sprint-ready)

1. Parameterize `module_slug`, `profile`, `api.base_prefix`.
2. Parameterize status catalog with stable `status_code`.
3. Introduce `idempotency_key` in API layer.
4. Align importer to dual dedupe (`idempotency_key` + `source_id`).
5. Move branding to profile file/config.
6. Run tests in both profiles with the same suite.

## 8) Acceptance checklist

- [ ] No brand-hardcoded routes remain in core.
- [ ] `brand` and `generic` start with no code changes.
- [ ] Reinstalling module does not duplicate seeds or tables.
- [ ] API retries do not create duplicates.
- [ ] SupportCandy re-import does not duplicate tickets/customers.
- [ ] Generic profile dataset and texts are suitable for TFM.

## 9) Open decisions

- Confirm final `lf.attachments.max_size_mb` value for production.
- Define minimum category catalog for generic profile.
- Define TFM dataset anonymization policy (`masked_real` vs `synthetic`).

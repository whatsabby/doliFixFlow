# Step-by-step — Letsfix Ticket Implementation in Dolibarr

> Version: 0.1  
> Goal: practical implementation guide to replace SupportCandy using native Dolibarr Ticket as base.

## Recommended approach

Do not clone SupportCandy from scratch.

Use native **Dolibarr Ticket** as the base and implement a Letsfix-specific extension module.

## 1. Validate native Dolibarr Ticket first

Manual checks:
- create ticket
- assign user
- change status
- add replies/notes
- upload attachments
- link to customer/third party
- review permission model

## 2. Separate native reuse vs custom extension

### Reuse natively
- base ticket entity
- third parties/contacts
- internal users
- attachments/documents
- permissions and API foundation

### Build in Letsfix extension
- operational statuses with colors
- repair-specific fields
- operational list views
- migration/import from SupportCandy
- mapping and sync metadata

## 3. Build minimal installable module (`letsfixtickets`)

Phase-0 module should:
- appear in modules list
- enable/disable cleanly
- avoid core patches
- create own config/tables when needed
- provide basic admin page

## 4. Implement statuses

Implement the operational status catalog with:
- label
- text/background colors
- order
- semantic flags
- optional mapping to native status

## 5. Add repair fields

Minimum fields:
- device type
- brand
- model
- reception visual inspection
- priority
- category
- legacy SC ticket/customer IDs
- WordPress user ID (if present)
- ticket origin

Prefer Dolibarr extrafields whenever possible.

## 6. Improve ticket detail view

Must clearly show:
- customer data
- device data
- status/priority
- assigned technician
- thread
- internal notes
- attachments
- inspection/diagnosis
- linked quote/invoice/order (if available)

## 7. Implement operational list views

Minimum columns:
- ticket ID
- status
- title
- customer
- technician(s)
- priority
- updated at

Minimum filters:
- all
- unresolved
- unassigned
- mine
- closed

## 8. Lock down permissions

- Customers cannot see internal notes.
- Technicians operate within role boundaries.
- Admin has full module-level control.
- Integration user has minimum required access.

## 9. Build SupportCandy importer with dry-run first

Dry-run should report:
- detected entities
- mapping quality
- create/update/skip counts
- conflicts and errors
- duplicate risk

## 10. Execute migration in test environment

Suggested order:
1. categories
2. priorities
3. statuses
4. agents mapping
5. customers mapping
6. tickets
7. threads
8. attachments

## 11. Validate with real ticket flows

Run real-world scenarios end-to-end before production cutover.

## 12. Connect WordPress later

Only after Dolibarr flow is stable:
- WordPress form -> Dolibarr API
- SC read-only transition
- final migration cutover plan

## Practical order

1. Validate native Ticket.
2. Build minimal module.
3. Add statuses.
4. Add fields.
5. Improve ticket view.
6. Build list views.
7. Permissions.
8. Importer dry-run.
9. Test migration.
10. Real ticket validation.
11. WordPress/API integration.

## MVP scope

Include:
- installable module
- status model
- repair fields
- operational lists/detail
- baseline permissions
- dry-run importer

Exclude (phase 1):
- autonomous AI replies
- complex real-time sync
- advanced public portal rewrite

## Key decision

Dolibarr becomes the operational source of truth. WordPress remains an optional entry point.


# Specification — SupportCandy to Dolibarr Migration for Letsfix

> Version: 0.1  
> Date: 2026-08-25  
> Status: technical draft to prepare IA Agent Spec, SDD, and TDD  
> Author: Claudia / Letsfix

## 1. Objective

Build an installable Dolibarr module that replaces current SupportCandy usage in WordPress for Letsfix ticket management, preserving current operational behavior while maximizing reuse of native Dolibarr capabilities.

This module is not intended to clone SupportCandy screen by screen. It must integrate with Dolibarr's data model so tickets coexist with third parties, contacts, internal users, calendar, documents, quotes/invoices, products/services, and future automations.

## 2. Functional Scope

### 2.1 Included

- Repair, diagnostics, maintenance, and inquiry ticket management.
- Customer handling equivalent to current SupportCandy customers.
- Technicians and administrators as internal Dolibarr users.
- Custom statuses with name, order, color, and background color.
- Priorities with colors.
- Categories.
- Custom fields for ticket, customer, and internal/agent use.
- Configurable list views similar to SupportCandy.
- Standard filters: all, unresolved, unassigned, mine, closed.
- One-or-many technician/agent assignment.
- Ticket conversation threads.
- Private internal notes.
- Attachments.
- Relevant change history.
- SupportCandy migration/import.
- API for WordPress, AI, automations, and external forms.
- Role/capability-based permissions.
- Future WordPress ↔ Dolibarr sync readiness.

### 2.2 Not Included in Phase 1 (unless explicitly approved)

- Replacing all WordPress public portal features.
- Real-time chat.
- Public knowledge base.
- Fully autonomous AI replies to customers.
- Full real-time bidirectional database sync.
- WooCommerce redesign.

## 3. Architecture Principle

### 3.1 Dolibarr-native First

Dolibarr already has a native ticket/helpdesk module. It supports ticket creation and tracking from backoffice and a lightweight public interface (`/public/ticket/`).

Recommended strategy:

1. Use native **Ticket** as functional base whenever possible.
2. Build a custom module (`letsfixtickets`) that extends native behavior instead of recreating everything.
3. Use Dolibarr **extrafields** whenever data fits extension fields.
4. Create custom tables only when native model is not enough (visual statuses, transition rules, advanced saved views, migration mapping, specific audit, sync metadata, custom SLA metadata).

### 3.2 Why Extend Dolibarr Instead of Cloning SupportCandy

- Lower technical debt.
- Better integration with third parties/contacts.
- Native permissions, users, documents, and agenda.
- Easier links to quotes, invoices, orders, products, and services.
- Reduced customer/technician duplication.
- Native API/hooks/triggers reuse.

## 4. Current SupportCandy Inventory (Letsfix)

Source: SupportCandy REST API in WordPress.  
Inventory file: `research/supportcandy_api_inventory_2026-08-25.json`.

### 4.1 Current Agents

| SC ID | Name | Type |
|---:|---|---|
| 1 | Abby | Agent |
| 4 | Claudia | Agent |
| 3 | Jose del Valle | Agent |
| 2 | letsfix.es | Agent |

### 4.2 Customers

- Current detected total in SC: **24 customers**.
- Target model: Dolibarr third parties + contacts.

Recommendation:
- Keep mapping table: `sc_customer_id` ↔ `fk_soc` / `fk_contact` / `wp_user_id`.
- Do not rely only on email as unique identifier.

### 4.3 Core Status Model (operational)

Suggested operational statuses:

1. 🚀 New
2. 📦 Pending reception
3. 🏁 Received by Letsfix
4. 🔍 Under diagnosis
5. 👨‍🔧/👩‍🔧 Technician assigned
6. ⚙️ In progress
7. 🛠️ Under repair
8. 🚚 Waiting spare part
9. 💬 Waiting customer reply
10. 🕓 Waiting internal reply
11. ✅ Ready to ship
12. ✈️ Shipped back to customer
13. 📬 Delivered to customer
14. ❌ Quote rejected
15. 🔒 Closed

Each status should define:
- label
- text/background colors
- order
- open/closed semantics
- wait flags (`waiting_customer`, `waiting_internal`)
- optional native Dolibarr equivalence

## 5. Data Model Guidelines

- Reuse native ticket entities where possible.
- Add extrafields for business-specific data.
- Add custom tables only for non-native capabilities.

Minimum custom extension areas:
- visual statuses and status metadata
- transition rules
- SupportCandy mapping
- thread metadata/audit log
- saved views

## 6. Security and Permissions

### Customer
- Create ticket
- See own tickets
- Add public replies
- Upload allowed attachments
- Cannot see internal notes

### Technician
- See assigned tickets (or scoped view)
- Add public replies/internal notes
- Change allowed statuses
- Add diagnosis/inspection fields

### Admin
- Full visibility and configuration
- Assignment/reassignment
- Migration execution
- Close/reopen

### Integration User
- Minimum permissions required for API/import
- Audited actions

## 7. API (Letsfix-first)

Base slug: `letsfixtickets` (current implementation scope).

- `GET /api/letsfixtickets/tickets`
- `POST /api/letsfixtickets/tickets`
- `GET /api/letsfixtickets/tickets/{id}`
- `PUT /api/letsfixtickets/tickets/{id}`
- `POST /api/letsfixtickets/tickets/{id}/threads`
- `GET /api/letsfixtickets/tickets/{id}/threads`
- `POST /api/letsfixtickets/tickets/{id}/attachments`
- `POST /api/letsfixtickets/tickets/{id}/assign`
- `POST /api/letsfixtickets/tickets/{id}/status`
- `GET /api/letsfixtickets/statuses`
- `GET /api/letsfixtickets/priorities`
- `GET /api/letsfixtickets/categories`
- `GET /api/letsfixtickets/fields`
- `POST /api/letsfixtickets/import/supportcandy/dry-run`
- `POST /api/letsfixtickets/import/supportcandy/run`

### API Requirements

- Stable authentication and authorization.
- Input validation.
- Stable JSON contracts.
- Pagination/filtering.
- Internal-note isolation.
- Idempotency:
  - same `idempotency_key` + same payload => same logical result
  - same `idempotency_key` + different payload => `409 Conflict`

## 8. SupportCandy Migration Strategy

1. Enable Dolibarr Ticket in staging.
2. Install `letsfixtickets` module.
3. Configure statuses, priorities, categories, extrafields.
4. Import SC catalogs.
5. Map SC agents to Dolibarr users.
6. Map customers to third parties/contacts.
7. Import tickets, threads, attachments.

### Mandatory Dry Run

Dry run must report:
- entities detected
- mappable/unmappable fields
- create/update/skip counts
- duplicate risk
- blocking errors

### Idempotency Rules

- Never duplicate ticket if `sc_ticket_id` already mapped.
- Never duplicate customer if `sc_customer_id` mapped.
- Re-import updates only allowed fields.
- Keep per-batch logs and resume capability.

## 9. TDD Outline

- Installation and reinstallation idempotency tests.
- Permission tests (internal notes isolation).
- Status semantics and transition tests.
- Field validation tests.
- API contract and idempotency tests.
- Import dry-run and re-import non-duplication tests.
- Regression tests across updates.

## 10. Open Questions

1. Exact Dolibarr target version in production?
2. Public portal in Dolibarr vs WordPress form?
3. Final definition of "terminal" statuses?
4. Allowed attachment types and max size?
5. AI assistant mode: draft-only or approved send?
6. Migration scope: all historical data or subset?

## 11. MVP Success Criteria

- Module installs without core patching.
- Letsfix operational ticket flow is covered.
- Key statuses/priorities/categories/fields are replicated.
- Customers mapped to third parties/contacts.
- Technicians mapped to Dolibarr users.
- Functional list views and ticket detail with notes/attachments.
- SupportCandy import with dry-run and idempotency.
- Core permissions enforced.

## 12. Final Recommendation

Build `letsfixtickets` as a Letsfix vertical layer on top of native Dolibarr Ticket, not as an isolated parallel system.


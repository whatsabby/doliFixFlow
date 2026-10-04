# Phase 2 Definition — Ticket Domain (Statuses, Fields, Permissions)

> Scope line: **Letsfix-first** implementation track.
> Status: Draft for approval.

## 1) Phase objective

Define the business-domain behavior for tickets with stable semantics, role-safe visibility, and operational completeness.

## 2) In scope

- Status model definition with stable `status_code` semantics.
- Transition-rule definition (valid/invalid transitions).
- Field model definition (required, optional, visibility by role).
- Permission model definition by actor type.
- Internal-note isolation rules from customer-facing views.

## 3) Out of scope

- API idempotency implementation details.
- External integration implementation.
- SupportCandy migration implementation.
- Hardening/load/security implementation.

## 4) Inputs and assumptions

- Phase 1 approved.
- Role baseline remains: customer, technician, admin, integration.
- Native Dolibarr Ticket remains the baseline object model.
- Domain semantics must remain stable across future profiles.

## 5) Deliverables for this phase

- `phase_2_definition.md` (this file).
- `TDD_F2.md` structure agreed (deferred until phase-definition approval).
- Status semantics matrix draft.
- Permission and visibility matrix draft.

## 6) Definition of done (DoD)

Phase 2 is considered complete when:

1. Ticket status semantics are approved.
2. Transition-rule policy is approved.
3. Field/visibility model is approved.
4. Permission boundaries are approved.
5. Go/no-go decision for Phase 2 TDD drafting is approved.

## 7) Risks to control in Phase 2

- Semantic drift between labels and real status meaning.
- Overexposure of internal data to customer roles.
- Ambiguous transition ownership.
- Tight coupling between UI labels and core domain rules.

## 8) Exit gate (approval checklist)

- [ ] Objective is approved.
- [ ] Scope is approved.
- [ ] Out-of-scope boundaries are approved.
- [ ] Inputs/assumptions are approved.
- [ ] DoD and risks are approved.
- [ ] Authorization granted to draft `TDD_F2.md`.

# Phase 0 Definition — Setup and Foundations

> Scope line: **Letsfix-first** implementation track.
> Status: Draft for approval.

## 1) Phase objective

Establish the minimum technical baseline to start safe, repeatable development without affecting production operations.

## 2) In scope

- Local development/staging strategy definition (production-safe workflow).
- Module skeleton definition for the Letsfix plugin track.
- Installation lifecycle baseline:
  - install,
  - uninstall,
  - reinstall (idempotent).
- Baseline validation against Dolibarr Ticket native module.
- CI smoke-check strategy definition (no implementation yet).
- Standard template definition for subsequent phase artifacts.

## 3) Out of scope

- Business logic implementation (statuses, fields, permissions).
- API endpoint implementation.
- SupportCandy migration implementation.
- Performance/security hardening implementation.

## 4) Inputs and assumptions

- Current operational Dolibarr version: `20.0.2`.
- Compatibility target to be considered in design: `24.0.2`.
- Native Dolibarr Ticket module is enabled and reused as baseline.
- Migration scope in future phases remains full historical data.
- Final phase-gate approver is the business owner.

## 5) Deliverables for this phase

- `phase_0_definition.md` (this file).
- `TDD_F0.md` structure agreed (content deferred until you approve this definition).
- `TEST_REPORT_F0.md` template agreed (empty skeleton only, deferred).
- `RETRO_F0.md` template agreed (empty skeleton only, deferred).

## 6) Definition of done (DoD)

Phase 0 is considered complete when:

1. Scope and exclusions are approved.
2. Idempotency baseline criteria are explicitly accepted.
3. Environment safety criteria are explicitly accepted.
4. Required artifacts and gate criteria are approved.
5. Go/no-go decision for Phase 0 TDD drafting is approved.

## 7) Risks to control in Phase 0

- Accidental coupling to production environment.
- Non-idempotent install/reinstall behavior.
- Hidden assumptions tied to one Dolibarr version only.
- Early hardcoding that blocks later generic parallelization.

## 8) Exit gate (approval checklist)

- [ ] Objective is approved.
- [ ] Scope is approved.
- [ ] Out-of-scope boundaries are approved.
- [ ] Inputs/assumptions are approved.
- [ ] DoD and risks are approved.
- [ ] Authorization granted to draft `TDD_F0.md`.

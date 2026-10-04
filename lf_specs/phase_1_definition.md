# Phase 1 Definition — Configurability Foundation

> Scope line: **Letsfix-first** implementation track.
> Status: Draft for approval.

## 1) Phase objective

Define and stabilize the configuration core so behavior is parameter-driven and free of brand hardcoding in shared logic.

## 2) In scope

- Configuration model definition (keys, defaults, validation rules).
- Profile resolution strategy (`brand` now, generic-ready later).
- `module_slug` and API base-prefix parameterization.
- Centralized config loading lifecycle definition.
- Policy definition to prevent brand strings in core logic.

## 3) Out of scope

- Ticket workflow business rules implementation.
- API endpoint implementation details.
- Data migration implementation.
- Performance/security hardening implementation.

## 4) Inputs and assumptions

- Phase 0 approved.
- Dolibarr-first strategy remains active.
- Current operational track is Letsfix-specific.
- Configuration must stay compatible with dual-profile future.

## 5) Deliverables for this phase

- `phase_1_definition.md` (this file).
- `TDD_F1.md` structure agreed (deferred until phase-definition approval).
- Parameter-key baseline catalog for Phase 1 scope.
- Config policy checklist (no-core-hardcoding rule).

## 6) Definition of done (DoD)

Phase 1 is considered complete when:

1. Configuration domains and keys are approved.
2. Profile resolution contract is approved.
3. Validation/fallback rules are approved.
4. No-core-hardcoding policy and detection strategy are approved.
5. Go/no-go decision for Phase 1 TDD drafting is approved.

## 7) Risks to control in Phase 1

- Hidden hardcoded strings in shared core.
- Ambiguous ownership of parameter values.
- Inconsistent config resolution across modules.
- Defaults that mask incorrect setup.

## 8) Exit gate (approval checklist)

- [ ] Objective is approved.
- [ ] Scope is approved.
- [ ] Out-of-scope boundaries are approved.
- [ ] Inputs/assumptions are approved.
- [ ] DoD and risks are approved.
- [ ] Authorization granted to draft `TDD_F1.md`.

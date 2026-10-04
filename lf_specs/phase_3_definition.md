# Phase 3 Definition — Idempotent API

> Scope line: **Letsfix-first** implementation track.
> Status: Draft for approval.

## 1) Phase objective

Define stable API contracts with deterministic idempotent behavior for safe retries and integration reliability.

## 2) In scope

- API contract definition for ticket operations.
- Write-operation idempotency policy (`idempotency_key`).
- Conflict behavior definition for key/payload mismatches.
- Authorization/error-contract definition (`403`, `409`, etc.).
- Pagination/filter response-shape stability criteria.

## 3) Out of scope

- SupportCandy migration execution.
- Load/security hardening execution.
- Release orchestration.

## 4) Inputs and assumptions

- Phase 2 approved.
- Idempotency baseline: same key + same payload => same logical result.
- TTL baseline for idempotency entries: 24h (pending final confirmation in implementation).
- Internal notes must never leak through customer endpoints.

## 5) Deliverables for this phase

- `phase_3_definition.md` (this file).
- `TDD_F3.md` structure agreed (deferred until phase-definition approval).
- API contract outline by operation.
- Idempotency and error-handling policy sheet.

## 6) Definition of done (DoD)

Phase 3 is considered complete when:

1. API operation catalog is approved.
2. Idempotency behavior contract is approved.
3. Error and authorization contract is approved.
4. Response-shape stability criteria are approved.
5. Go/no-go decision for Phase 3 TDD drafting is approved.

## 7) Risks to control in Phase 3

- Non-deterministic retries creating duplicates.
- Silent conflicts from reused idempotency keys.
- Inconsistent error mapping across endpoints.
- Data leakage through unauthorized views.

## 8) Exit gate (approval checklist)

- [ ] Objective is approved.
- [ ] Scope is approved.
- [ ] Out-of-scope boundaries are approved.
- [ ] Inputs/assumptions are approved.
- [ ] DoD and risks are approved.
- [ ] Authorization granted to draft `TDD_F3.md`.

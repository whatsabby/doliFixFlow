# Phase 4 Definition — SupportCandy Migration (Idempotent)

> Scope line: **Letsfix-first** implementation track.
> Status: Draft for approval.

## 1) Phase objective

Define a full-history migration approach from SupportCandy to Dolibarr that is traceable, resumable, and duplicate-safe.

## 2) In scope

- Migration contract definition (`dry-run` and `run`).
- Source-to-target identity strategy (`source_system + source_id`).
- Batch/retry/resume strategy definition.
- Partial-failure handling criteria.
- Migration traceability/evidence requirements.

## 3) Out of scope

- Final production cutover execution.
- Performance hardening beyond migration correctness scope.
- Broader release hardening activities.

## 4) Inputs and assumptions

- Phase 3 approved.
- Full historical migration scope remains mandatory.
- `dry-run` must never persist data.
- Re-import of same source records must be duplicate-safe.

## 5) Deliverables for this phase

- `phase_4_definition.md` (this file).
- `TDD_F4.md` structure agreed (deferred until phase-definition approval).
- Migration mapping baseline (entities and relationships).
- Resume/retry and reconciliation criteria sheet.

## 6) Definition of done (DoD)

Phase 4 is considered complete when:

1. Migration operation modes are approved.
2. Identity/deduplication contract is approved.
3. Resume and partial-failure handling is approved.
4. Traceability and evidence criteria are approved.
5. Go/no-go decision for Phase 4 TDD drafting is approved.

## 7) Risks to control in Phase 4

- Duplicate records after retry/re-import.
- Broken source-target relationships.
- Irrecoverable interrupted batches.
- Incomplete audit trail for migration decisions.

## 8) Exit gate (approval checklist)

- [ ] Objective is approved.
- [ ] Scope is approved.
- [ ] Out-of-scope boundaries are approved.
- [ ] Inputs/assumptions are approved.
- [ ] DoD and risks are approved.
- [ ] Authorization granted to draft `TDD_F4.md`.

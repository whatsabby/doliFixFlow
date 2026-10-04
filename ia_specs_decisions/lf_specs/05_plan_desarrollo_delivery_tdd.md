# TDD-based Development and Delivery Plan (lf_specs)

> Version: 0.1  
> Date: 2026-10-04  
> Status: execution-ready  
> Scope: **Letsfix-first implementation**

## 1. Delivery model

Each phase follows the same cycle:
1. define phase
2. define phase TDD
3. run red -> green -> refactor -> complete development
4. run phase tests
5. close feature/phase with evidence

No development starts without approved phase TDD.

## 2. Project phases

### Phase 0 — Setup and foundations
- module skeleton
- CI smoke
- install/uninstall/reinstall idempotency
- Ticket module baseline validation

### Phase 1 — Configurability foundation
- central configuration loader
- Letsfix-first profile resolution
- no brand hardcoding in core

### Phase 2 — Ticket domain
- statuses, fields, permissions
- internal-note isolation
- operational flow completion

### Phase 3 — Idempotent API
- stable contracts
- idempotency keys
- deterministic retries / conflict rules

### Phase 4 — SupportCandy migration
- dry-run first
- full historical import
- dedupe and traceability
- resumable batches

### Phase 5 — Hardening and release
- regression pack
- basic load/security checks
- go/no-go release evidence

## 3. Quality gates

- Gate 1: TDD approved
- Gate 2: red tests reproducible
- Gate 3: phase green
- Gate 4: refactor without regressions
- Gate 5: closure evidence approved

Phase does not advance if any gate fails.

## 4. Mandatory artifacts per phase

- `TDD_Fx.md`
- `TEST_REPORT_Fx.md`
- `CHANGELOG_Fx.md`
- `RETRO_Fx.md`

## 5. Start-up decisions (confirmed)

- Installed Dolibarr: `20.0.2`.
- Main target: compatibility design for `24.0.2` while keeping functional compatibility with `20.0.2`.
- Native Ticket module: enabled and reused as baseline.
- Migration scope: full history.
- Gate approver: business owner (Claudia).
- Execution start: **Phase 0**.

## 6. Default assumptions to unblock Phase 0/1

### Roles/permissions default
- Customer: create/view own/reply/upload.
- Technician: assigned scope/status changes/internal notes.
- Admin: full scope and configuration/import.
- Integration: minimum required API/import scope.

### API idempotency default
- `idempotency_key` required on sensitive writes.
- TTL: 24h.
- same key + same payload => same logical result.
- same key + different payload => `409 Conflict`.


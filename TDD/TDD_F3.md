# TDD_F3 — Idempotent API

> Phase: 3  
> Track: **Letsfix-first** (`brand`) with deterministic API behavior  
> Status: Draft for review  
> Source: `lf_specs/phase_3_definition.md`

## 1) Test objective

Validate that write APIs are idempotent, contracts are stable, and authorization/error behavior is consistent.

## 2) Scope under test

- CRUD contract behavior for ticket API operations.
- `idempotency_key` handling for write operations.
- Conflict behavior (`409`) for same key + different payload.
- Authorization behavior (`403`) and forbidden data visibility.
- Response-shape stability for list/pagination/filter operations.

## 3) Out of scope (Phase 3)

- SupportCandy migration runtime execution.
- Full load/security hardening execution.
- Final release orchestration.

## 4) Assumptions

- `lf_specs/phase_3_definition.md` approved.
- Idempotency baseline rules are accepted for this phase.
- TTL baseline is 24h (implementation-level finalization later).
- Internal notes must remain hidden from customer-facing endpoints.

## 5) Fixtures and test data

### 5.1 Request fixtures

- `fixture_create_ticket_valid`
- `fixture_update_ticket_valid`
- `fixture_idempotent_same_payload`
- `fixture_idempotent_conflict_payload`
- `fixture_missing_idempotency_key`

### 5.2 Authorization fixtures

- `fixture_api_actor_customer`
- `fixture_api_actor_technician`
- `fixture_api_actor_admin`
- `fixture_api_actor_unauthorized`

### 5.3 Pagination/filter fixtures

- `fixture_list_dataset_small`
- `fixture_list_dataset_large`
- `fixture_filter_sets`

## 6) Given/When/Then test matrix

### 6.1 Idempotency behavior

1. **Given** same write request, same `idempotency_key`, same payload  
   **When** request is retried  
   **Then** response is logically identical and no duplicate side effects occur.

2. **Given** same `idempotency_key` with different payload  
   **When** second write request is sent  
   **Then** request is rejected with `409 Conflict`.

3. **Given** write operation without required idempotency key  
   **When** request is validated  
   **Then** request is rejected with explicit contract error.

### 6.2 Authorization and data exposure

4. **Given** unauthorized actor  
   **When** protected write endpoint is called  
   **Then** response is `403`.

5. **Given** customer actor accessing ticket details  
   **When** payload is resolved  
   **Then** internal notes are excluded.

6. **Given** admin actor  
   **When** admin-allowed operation is called  
   **Then** operation is accepted per contract.

### 6.3 Contract stability

7. **Given** list endpoint with pagination and filters  
   **When** request variations are executed  
   **Then** response shape remains stable and documented.

8. **Given** known invalid input  
   **When** endpoint validation runs  
   **Then** error response structure remains consistent.

### 6.4 Deterministic retries under basic concurrency

9. **Given** concurrent retry attempts with same key/payload  
   **When** requests are processed  
   **Then** only one logical write is applied.

10. **Given** concurrent attempts with same key/different payload  
    **When** requests are processed  
    **Then** conflict behavior is deterministic and auditable.

## 7) Negative and edge cases

- Expired idempotency key.
- Reused key across different endpoints.
- Malformed key format.
- Partial payload differences (single-field drift) with same key.
- Pagination boundary values (0, max, overflow-like input).

## 8) Green criteria (pass conditions)

- 100% pass rate for critical idempotency, authorization, and contract tests.
- 0 duplicate writes under same-key retries.
- 100% deterministic `409` behavior for payload conflicts.
- 0 internal-note leakage in customer-facing responses.
- Stable response schema across all tested list/filter variants.

## 9) Coverage target

- 100% of Phase 3 critical idempotency rules.
- 100% of critical endpoint authorization paths.
- All listed edge cases executed at least once.

## 10) Risks covered / not covered

### Covered risks

- Duplicate write side effects on retries.
- Silent conflicts on key reuse.
- Inconsistent authorization outcomes.
- Unstable response contracts breaking integrations.

### Not covered in Phase 3

- Migration import correctness.
- Full release hardening and production go-live checks.

## 11) Evidence required

- Idempotency replay logs with request/response correlation.
- Conflict-case logs proving `409` behavior.
- Authorization/access-control report.
- Response-shape contract snapshots for list/filter endpoints.

## 12) Execution order (TDD cycle)

1. Write failing idempotency replay and conflict tests.
2. Implement minimum idempotency behavior to pass.
3. Write failing authorization/data-exposure tests.
4. Implement minimum access-control and masking behavior.
5. Write failing contract-stability tests.
6. Implement minimum schema-consistency guarantees.
7. Refactor while keeping all tests green.
8. Produce evidence package and request phase closure.

## 13) Entry and exit gates

### Entry gate

- `lf_specs/phase_3_definition.md` approved.
- Scope and assumptions confirmed.

### Exit gate

- All green criteria satisfied.
- Evidence set complete.
- Approval to move to Phase 4 TDD drafting.

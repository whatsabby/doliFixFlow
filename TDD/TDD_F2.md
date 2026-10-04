# TDD_F2 — Ticket Domain (Statuses, Fields, Permissions)

> Phase: 2  
> Track: **Letsfix-first** (`brand`) with stable domain semantics for future generic profile  
> Status: Draft for review  
> Source: `lf_specs/phase_2_definition.md`

## 1) Test objective

Validate that ticket domain behavior is semantically stable, permission-safe, and operationally complete.

## 2) Scope under test

- `status_code` semantic model and flags.
- Transition validation (allowed vs blocked).
- Field visibility and editability by role.
- Permission boundaries for customer, technician, admin, integration.
- Internal-note isolation from customer-facing access.

## 3) Out of scope (Phase 2)

- API idempotency runtime behavior.
- External integration implementation.
- SupportCandy migration behavior.
- Release hardening/load/security execution.

## 4) Assumptions

- `lf_specs/phase_2_definition.md` approved.
- Role baseline remains fixed for this phase.
- Native Dolibarr Ticket remains the baseline object model.
- Domain semantics must not depend on profile labels.

## 5) Fixtures and test data

### 5.1 Status fixtures

- `fixture_status_catalog_valid`
- `fixture_status_catalog_missing_code`
- `fixture_status_catalog_duplicate_code`
- `fixture_status_catalog_invalid_flags`

### 5.2 Transition fixtures

- `fixture_transition_valid_set`
- `fixture_transition_invalid_set`
- `fixture_transition_terminal_state`

### 5.3 Permission/visibility fixtures

- `fixture_user_customer`
- `fixture_user_technician`
- `fixture_user_admin`
- `fixture_user_integration`
- `fixture_ticket_with_internal_notes`

## 6) Given/When/Then test matrix

### 6.1 Status semantics

1. **Given** `fixture_status_catalog_valid`  
   **When** catalog is loaded  
   **Then** each `status_code` resolves with valid semantic flags.

2. **Given** duplicate `status_code` entries  
   **When** catalog validation runs  
   **Then** loading fails with explicit duplicate-code error.

3. **Given** invalid/contradictory status flags  
   **When** catalog validation runs  
   **Then** loading fails with explicit semantic-consistency error.

### 6.2 Transition policy

4. **Given** `fixture_transition_valid_set`  
   **When** status change is requested  
   **Then** transition is accepted.

5. **Given** `fixture_transition_invalid_set`  
   **When** status change is requested  
   **Then** transition is blocked with explicit rule error.

6. **Given** ticket in terminal status  
   **When** mutable transition is requested  
   **Then** transition is rejected unless explicitly allowed by policy.

### 6.3 Permissions and visibility

7. **Given** customer actor and ticket with internal note  
   **When** ticket details are resolved  
   **Then** internal note is not visible.

8. **Given** technician actor  
   **When** authorized operational updates are requested  
   **Then** only technician-allowed actions are accepted.

9. **Given** admin actor  
   **When** operational/admin updates are requested  
   **Then** full approved admin scope is accepted.

10. **Given** integration actor  
    **When** access is evaluated  
    **Then** only minimum configured integration scope is granted.

### 6.4 Profile-label independence

11. **Given** same `status_code` under different profile labels  
    **When** domain rule evaluation runs  
    **Then** semantic outcomes are identical.

## 7) Negative and edge cases

- Unknown `status_code` in transition request.
- Empty required field on status change.
- Role missing/undefined at authorization time.
- Conflicting field-level and role-level permissions.
- Concurrent updates targeting incompatible transitions.

## 8) Green criteria (pass conditions)

- 100% pass rate for all Phase 2 critical cases.
- 0 unauthorized data exposures.
- 0 acceptance of invalid transitions.
- Stable semantic behavior independent of display labels.
- Explicit actionable errors for policy violations.

## 9) Coverage target

- 100% of listed critical status/transition rules.
- 100% of role-permission matrix cells for Phase 2 scope.
- All listed edge cases executed at least once.

## 10) Risks covered / not covered

### Covered risks

- Semantic drift of statuses.
- Data leakage via role misconfiguration.
- Invalid transitions accepted in runtime.
- UI label coupling to domain logic.

### Not covered in Phase 2

- API idempotency behavior.
- Migration dedupe/resume behavior.
- Release hardening behavior.

## 11) Evidence required

- Status and transition validation reports.
- Permission matrix execution report.
- Internal-note visibility test output by role.
- Failure logs for blocked transitions and denied actions.

## 12) Execution order (TDD cycle)

1. Write failing tests for status catalog semantics.
2. Implement minimum semantic validation to pass.
3. Write failing transition-policy tests.
4. Implement minimum transition enforcement.
5. Write failing role/visibility tests.
6. Implement minimum authorization/visibility behavior.
7. Refactor while keeping full green.
8. Produce evidence package and request phase closure.

## 13) Entry and exit gates

### Entry gate

- `lf_specs/phase_2_definition.md` approved.
- Scope and assumptions confirmed.

### Exit gate

- All green criteria satisfied.
- Evidence set complete.
- Approval to move to Phase 3 TDD drafting.

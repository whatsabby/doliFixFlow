# TDD_F1 — Configurability Foundation

> Phase: 1  
> Track: **Letsfix-first** (`brand`) with generic-ready design  
> Status: Draft for review  
> Source: `lf_specs/phase_1_definition.md`

## 1) Test objective

Validate that configuration behavior is deterministic, parameter-driven, and free of brand hardcoding in shared core logic.

## 2) Scope under test

- Configuration key resolution.
- Profile resolution (`brand` active; `generic` contract-ready).
- Validation rules for required parameters.
- Fallback behavior for optional parameters.
- Policy enforcement: no brand literals in core logic.

## 3) Out of test scope (Phase 1)

- Ticket domain business rules.
- API runtime behavior and endpoint contracts.
- Data migration/import behavior.
- Performance/security stress scenarios.

## 4) Assumptions

- Phase 0 is approved and baseline environment strategy exists.
- Native Dolibarr Ticket remains the baseline integration target.
- Current operational profile is Letsfix (`brand`).
- Future `generic` profile compatibility must not be blocked by Phase 1 decisions.

## 5) Fixtures and test data

### 5.1 Config fixture sets

- `fixture_valid_brand`: complete valid config for `profile=brand`.
- `fixture_valid_generic_contract`: minimal valid config for `profile=generic` contract checks.
- `fixture_missing_required`: each required key removed one at a time.
- `fixture_invalid_types`: wrong type for each critical key.
- `fixture_optional_missing`: optional keys removed to verify fallback behavior.
- `fixture_conflicting_values`: logically inconsistent values to trigger validation errors.

### 5.2 Baseline key catalog (Phase 1)

- `lf.profile.id`
- `lf.module.slug`
- `lf.api.base_prefix`
- `lf.brand.enabled`
- `lf.brand.company_name`

## 6) Given/When/Then test matrix

### 6.1 Profile resolution

1. **Given** valid `fixture_valid_brand`  
   **When** config loader initializes profile resolution  
   **Then** resolved profile is `brand` and config state is valid.

2. **Given** valid `fixture_valid_generic_contract`  
   **When** config loader initializes profile resolution  
   **Then** resolved profile is `generic` and no brand-specific fallback is forced.

### 6.2 Required key validation

3. **Given** `fixture_missing_required` for `lf.module.slug`  
   **When** config validation runs  
   **Then** initialization fails with explicit required-key error.

4. **Given** `fixture_missing_required` for `lf.api.base_prefix`  
   **When** config validation runs  
   **Then** initialization fails with explicit required-key error.

5. **Given** `fixture_invalid_types` (`lf.brand.enabled` as non-boolean)  
   **When** config validation runs  
   **Then** initialization fails with explicit type error.

### 6.3 Fallback behavior

6. **Given** `fixture_optional_missing` for optional key(s)  
   **When** config loader resolves values  
   **Then** documented defaults are applied deterministically.

7. **Given** optional key present with valid value  
   **When** config loader resolves values  
   **Then** explicit value overrides default.

### 6.4 Determinism and consistency

8. **Given** the same valid fixture loaded repeatedly  
   **When** config loader runs N times  
   **Then** resolved config output is identical on each run.

9. **Given** two modules requesting same key in same context  
   **When** key resolution occurs  
   **Then** both receive identical resolved value.

### 6.5 No-hardcoding policy

10. **Given** core source scan policy for banned brand literals  
    **When** policy check runs on core scope  
    **Then** no forbidden brand literal is found.

11. **Given** a test-only injected brand literal in controlled fixture data  
    **When** policy check runs  
    **Then** it reports violation only if literal appears in core code, not in config fixtures.

## 7) Negative and edge cases

- Unknown profile value (`profile=unknown`) -> controlled validation error.
- Empty-string required values -> rejected as invalid.
- Whitespace-only strings in critical keys -> rejected.
- Duplicate key definitions with conflicting values -> deterministic precedence or explicit error.
- Missing config source (e.g., absent env + absent db_config fallback) -> controlled startup failure.
- Case-sensitivity mismatch in enum keys/values -> explicit normalization or validation failure (must be documented).

## 8) Green criteria (pass conditions)

- 100% pass rate for all Phase 1 critical tests in this document.
- 0 unresolved failures in required-key, type-validation, or profile-resolution groups.
- No-hardcoding policy check returns zero violations in scoped core paths.
- Determinism tests pass with identical output across repeated runs.
- Error messages are explicit and actionable (no generic/ambiguous startup errors).

## 9) Coverage target

- **Critical-rule coverage target**: 100% of Phase 1 listed rules.
- **Negative-path target**: all listed negative/edge cases executed at least once.
- **Policy coverage target**: core no-hardcoding check executed in every Phase 1 test run.

## 10) Risks covered / not covered

### Covered risks

- Hidden core brand hardcoding.
- Inconsistent config resolution behavior.
- Silent startup with invalid or incomplete configuration.
- Non-deterministic defaults and overrides.

### Not covered in Phase 1

- Runtime API idempotency behavior.
- Ticket domain transition semantics.
- Migration dedupe behavior.
- Load/performance characteristics.

## 11) Evidence required

- Test execution report for all matrix cases.
- Policy-check output for no-hardcoding scan.
- Resolved-config snapshots for determinism checks.
- Failure-report examples for each critical validation error.

## 12) Execution order (TDD cycle)

1. Write failing tests for profile resolution and required-key validation.
2. Implement minimum configuration behavior to pass those tests.
3. Add failing tests for fallback and determinism.
4. Implement minimum fallback/deterministic resolution behavior.
5. Add and run failing no-hardcoding policy tests.
6. Implement minimum policy enforcement/check integration.
7. Refactor while keeping all tests green.
8. Produce evidence package and request phase closure.

## 13) Entry and exit gates

### Entry gate

- `lf_specs/phase_1_definition.md` approved.
- Scope and assumptions confirmed.

### Exit gate

- All green criteria satisfied.
- Evidence set complete.
- Approval to move to Phase 2 TDD drafting.


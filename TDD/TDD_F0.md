# TDD_F0 — Setup and Foundations

> Phase: 0  
> Track: **Letsfix-first** (`brand`) with production-safe development workflow  
> Status: Draft for review  
> Source: `lf_specs/phase_0_definition.md`

## 1) Test objective

Validate that the project baseline is safe, repeatable, and idempotent before feature development begins.

## 2) Scope under test

- Environment safety boundaries (no production coupling by default).
- Module lifecycle baseline:
  - install,
  - uninstall,
  - reinstall.
- Idempotent behavior for install/reinstall operations.
- Baseline compatibility checks for Dolibarr Ticket native module.
- CI smoke strategy definition checks (artifact-level, no implementation execution).

## 3) Out of test scope (Phase 0)

- Business workflow rules for tickets.
- API contract behavior.
- SupportCandy migration behavior.
- Performance and security hardening tests.

## 4) Assumptions

- Operational Dolibarr baseline is `20.0.2`.
- Compatibility is designed for `24.0.2` while preserving operation with `20.0.2`.
- Native Dolibarr Ticket module is enabled and reused.
- Full historical migration remains a later-phase requirement.
- Final gate approval is owner-driven.

## 5) Fixtures and baseline data

### 5.1 Environment fixtures

- `fixture_env_dev_safe`: explicit non-production environment configuration.
- `fixture_env_missing_required`: startup with required environment values missing.
- `fixture_env_invalid_values`: invalid environment value types/formats.

### 5.2 Lifecycle fixtures

- `fixture_install_clean`: clean installation baseline.
- `fixture_uninstall_after_install`: uninstall right after install.
- `fixture_reinstall_cycle`: repeated install/uninstall/reinstall cycles.
- `fixture_ticket_module_enabled`: native Ticket module active.
- `fixture_ticket_module_disabled`: native Ticket module inactive for negative checks.

## 6) Given/When/Then test matrix

### 6.1 Environment safety

1. **Given** `fixture_env_dev_safe`  
   **When** startup prechecks run  
   **Then** environment is accepted as non-production-safe for development.

2. **Given** `fixture_env_missing_required`  
   **When** startup prechecks run  
   **Then** startup fails with explicit missing-config error.

3. **Given** `fixture_env_invalid_values`  
   **When** startup prechecks run  
   **Then** startup fails with explicit validation error.

### 6.2 Install/uninstall baseline

4. **Given** `fixture_install_clean`  
   **When** module installation runs once  
   **Then** installation succeeds and expected baseline artifacts are present.

5. **Given** successful installation  
   **When** uninstall runs  
   **Then** uninstall completes without orphaned critical artifacts.

### 6.3 Reinstall idempotency

6. **Given** `fixture_reinstall_cycle`  
   **When** install runs multiple times on same state  
   **Then** no duplicate schema/catalog baseline data appears.

7. **Given** install -> uninstall -> reinstall sequence  
   **When** lifecycle operations complete  
   **Then** final state is equivalent to single clean install baseline.

### 6.4 Native Ticket dependency baseline

8. **Given** `fixture_ticket_module_enabled`  
   **When** baseline dependency precheck runs  
   **Then** phase precondition passes.

9. **Given** `fixture_ticket_module_disabled`  
   **When** baseline dependency precheck runs  
   **Then** phase precondition fails with actionable dependency message.

### 6.5 CI smoke strategy artifact checks

10. **Given** Phase 0 artifact set  
    **When** artifact consistency check runs  
    **Then** required artifacts/templates are present and named correctly.

## 7) Negative and edge cases

- Reinstall after partial/failed previous install -> controlled recovery path.
- Uninstall called twice -> deterministic no-op or explicit harmless outcome.
- Install with pre-existing partial schema -> no duplicate creation.
- Missing Ticket module dependency -> explicit blocking error.
- Startup with mixed valid/invalid sources -> deterministic precedence and explicit errors.

## 8) Green criteria (pass conditions)

- 100% pass rate for Phase 0 critical tests listed in this file.
- 0 duplicate artifacts after reinstall cycles.
- 0 ambiguous startup/dependency errors.
- Deterministic lifecycle outcomes across repeated runs.
- Environment safety checks produce explicit pass/fail evidence.

## 9) Coverage target

- **Critical-rule coverage target**: 100% of listed Phase 0 rules.
- **Lifecycle coverage target**: all install/uninstall/reinstall scenarios executed.
- **Negative-path target**: all listed negative/edge cases executed at least once.

## 10) Risks covered / not covered

### Covered risks

- Non-idempotent reinstall behavior.
- Unsafe environment assumptions.
- Missing or opaque dependency failures.
- Inconsistent lifecycle outcomes.

### Not covered in Phase 0

- Domain semantics for ticket statuses and permissions.
- API idempotency runtime behavior.
- SupportCandy import/dedupe logic.
- Performance and security hardening behavior.

## 11) Evidence required

- Lifecycle run logs for install/uninstall/reinstall scenarios.
- Artifact snapshots before/after reinstall cycles.
- Dependency precheck reports (Ticket module enabled/disabled).
- Startup validation error samples for missing/invalid config.

## 12) Execution order (TDD cycle)

1. Write failing tests for environment and dependency prechecks.
2. Implement minimal behavior to satisfy explicit precheck outcomes.
3. Write failing install/uninstall/reinstall idempotency tests.
4. Implement minimal lifecycle behavior to pass tests.
5. Add negative/edge-case tests.
6. Refactor while keeping all tests green.
7. Produce evidence package and request phase closure.

## 13) Entry and exit gates

### Entry gate

- `lf_specs/phase_0_definition.md` approved.
- Scope and assumptions confirmed.

### Exit gate

- All green criteria satisfied.
- Evidence set complete.
- Approval to move to Phase 1 TDD drafting/execution.

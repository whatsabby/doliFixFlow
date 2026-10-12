# TDD_F0 — Setup and Foundations

> Phase: 0  
> Track: **Letsfix-first** (`brand`) with production-safe development workflow  
> Status: Approved for implementation (2026-10-12)  
> Approved by: Claudia  
> Source: `lf_specs_definition/phase_0_definition.md`

## 1) Test objective

Validate that the project baseline is safe, repeatable, and idempotent before feature development begins.

## 2) Scope under test

- Local/staging environment safety strategy (acceptance tests; no production coupling by default).
- Letsfix module skeleton and lifecycle baseline:
  - install,
  - uninstall,
  - reinstall.
- Idempotent behavior for install/reinstall operations.
- Baseline compatibility checks for Dolibarr Ticket native module.
- CI smoke-check strategy and standard artifact-template checks (artifact-level; no CI implementation in Phase 0).

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
- Final phase-gate approver is Claudia.

## 5) Fixtures and baseline data

### 5.1 Environment fixtures

- `fixture_target_local_or_staging`: explicit non-production host and database target.
- `fixture_target_production`: production host or database target, used to verify safe blocking behavior.
- `fixture_target_incomplete`: missing target/environment classification, used to verify fail-closed behavior.

### 5.2 Lifecycle fixtures

- `fixture_install_clean`: clean installation baseline.
- `fixture_uninstall_after_install`: uninstall right after install.
- `fixture_reinstall_cycle`: repeated install/uninstall/reinstall cycles.
- `fixture_module_schema_with_data`: module-created tables with representative rows before uninstall.
- `fixture_ticket_module_enabled`: native Ticket module active.
- `fixture_ticket_module_disabled`: native Ticket module inactive for negative checks.
- `fixture_partial_install_state`: interrupted module-owned installation state.
- `fixture_supported_dolibarr_versions`: runtime baseline `20.0.2` and compatibility target `24.0.2`.

## 6) Given/When/Then test matrix

### 6.1 Environment safety

1. **Given** `fixture_target_local_or_staging`  
   **When** an installation or lifecycle operation is requested  
   **Then** the target is explicitly classified as non-production before any write occurs.

2. **Given** `fixture_target_production`  
   **When** a Phase 0 lifecycle operation is requested  
   **Then** the operation is blocked before any write occurs.

3. **Given** `fixture_target_incomplete`  
   **When** a lifecycle operation is requested  
   **Then** it fails closed with an actionable environment-identification error.

### 6.2 Install/uninstall baseline

4. **Given** `fixture_install_clean` and `fixture_ticket_module_enabled`  
   **When** the module skeleton is installed once  
   **Then** installation succeeds and only the declared module-owned baseline artifacts are created.

5. **Given** `fixture_ticket_module_disabled`  
   **When** installation is requested  
   **Then** it stops with an actionable native Ticket dependency error and creates no partial artifacts.

6. **Given** a successful installation  
   **When** uninstall runs once  
   **Then** it uninstalls the module while preserving module-created tables/schema and their existing data unchanged.

### 6.3 Reinstall idempotency

7. **Given** `fixture_reinstall_cycle`  
   **When** install runs multiple times on same state  
   **Then** the module-owned schema and registration state remain equivalent to one successful installation, with no duplicates.

8. **Given** install -> uninstall -> reinstall sequence  
   **When** lifecycle operations complete  
   **Then** the module is active again, preserved schema/data remain unchanged, and no duplicate tables or registration artifacts exist.

9. **Given** `fixture_partial_install_state`  
   **When** installation is retried  
   **Then** it either recovers to the clean installed baseline or stops without worsening the partial state and reports the failure clearly.

10. **Given** an already-uninstalled module  
    **When** uninstall is called again  
   **Then** it completes as a deterministic harmless no-op and leaves preserved schema/data unchanged.

### 6.4 Native Ticket dependency baseline

11. **Given** `fixture_ticket_module_enabled`  
   **When** baseline dependency precheck runs  
   **Then** phase precondition passes.

12. **Given** `fixture_supported_dolibarr_versions`  
   **When** the module skeleton's native Ticket dependency is validated  
   **Then** runtime behavior is verified against `20.0.2` and compatibility assumptions for `24.0.2` are documented and testable.

### 6.5 CI smoke strategy and standard artifact checks

13. **Given** the Phase 0 CI smoke strategy and artifact templates  
   **When** the artifact consistency review runs  
   **Then** required checks, supported-version intent, artifact names, and evidence expectations are documented without claiming CI execution.

## 7) Negative and edge cases

- Reinstall after partial/failed previous install -> controlled recovery path.
- Uninstall called twice -> deterministic harmless no-op; preserved schema/data remain unchanged.
- Install with pre-existing partial module-owned schema -> no duplicate creation or destructive overwrite.
- Missing Ticket module dependency -> explicit blocking error and no partial writes.
- Target environment cannot be positively identified as non-production -> fail closed.
- Uninstall preserves module-created tables/schema and their existing data; reinstall reuses them without destructive changes.

## 8) Green criteria (pass conditions)

- 100% pass rate for Phase 0 critical tests listed in this file.
- 0 duplicate artifacts after reinstall cycles.
- 0 ambiguous environment/dependency errors.
- Deterministic lifecycle outcomes across repeated runs.
- Environment safety checks produce explicit pass/fail evidence before writes.
- Uninstall preserves module-created tables/schema and their existing data unchanged.

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
- Schema and representative data snapshots before uninstall, after uninstall, and after reinstall.
- Dependency precheck reports (Ticket module enabled/disabled).
- Environment-safety evidence for local/staging, production-target, and incomplete-target cases.
- Dolibarr Ticket dependency evidence for enabled/disabled states.
- Compatibility evidence for the `20.0.2` runtime baseline and `24.0.2` target assumptions.

## 12) Execution order (TDD cycle)

1. Phase 0 definition, environment safety rules, and uninstall preservation policy are approved and reflected in these test cases.
2. Write failing tests for environment safety and native Ticket dependency behavior.
3. Implement only the minimum module skeleton and dependency/lifecycle behavior required by the approved cases.
4. Write failing install/uninstall/reinstall idempotency tests, including partial-install recovery.
5. Implement the minimum lifecycle behavior to pass those tests.
6. Validate native Ticket compatibility against the approved Dolibarr version matrix.
7. Refactor while keeping all Phase 0 tests green; document CI smoke checks without implementing CI in this phase.
8. Produce the evidence package and request phase closure.

## 13) Entry and exit gates

### Entry gate

- [x] `lf_specs_definition/phase_0_definition.md` approved.
- [x] Scope and assumptions confirmed, including Dolibarr `20.0.2` baseline and `24.0.2` compatibility target.
- [x] Production and unidentified-environment blocking rules approved.
- [x] Uninstall preservation of module-created tables/schema approved.

### Exit gate

- All green criteria satisfied.
- Evidence set complete.
- Approval to move to Phase 1 TDD drafting/execution.

# TDD-based Development and Delivery Plan (generic_specs)

> Version: 0.1  
> Date: 2026-10-04  
> Status: execution-ready  
> Base: [03_arquitectura_paralela_idempotente_parametrizable_generic.md](C:/Users/moren/OneDrive/Documentos/repositorios/doliFixFlow/ia_specs_decisions/generic_specs/03_arquitectura_paralela_idempotente_parametrizable_generic.md)

## 1. Execution framework (global rule)

Each phase runs with the same cycle:

1. **Define phase** (objective, scope, risks, DoD).
2. **Define phase TDD** (cases, fixtures, green criteria).
3. **Green + refactor + development**:
   - write failing tests,
   - implement the minimum to pass,
   - refactor while keeping green,
   - complete functional development.
4. **Testing** (unit + integration + regression + non-functional as needed).
5. **Feature/phase closure** (evidence, metrics, closure record, residual backlog).

Mandatory rule: **no development outside a phase without a defined and approved TDD**.

## 2. Project phase structure

## Phase 0 — Technical foundations and environment

**Objective**
- Prepare environment, module structure, pipeline, and TDD template.

**Deliverables**
- Base module structure.
- Standard TDD test-case template.
- CI pipeline with test execution.
- `brand` and `generic` profile convention.

**Phase TDD (minimum)**
- Install/uninstall without error.
- Reinstall without duplicating tables/seeds.
- Start with `profile=brand` and `profile=generic` with no code changes.
- Configuration failure returns a controlled error.

**Green + refactor + development**
- Idempotent installation test goes red → minimal implementation → green.
- Refactor bootstrap/config loader without breaking tests.

**Exit tests**
- CI smoke in both profiles.
- UTF-8 encoding and Markdown lint verification.

**Phase closure**
- Signed DoD checklist.
- Parameter matrix linked and frozen for the next phase.

---

## Phase 1 — Parameterized configuration core

**Objective**
- Implement a configuration core with no brand hardcoding.

**Deliverables**
- Profile-based configuration loader.
- Resolution of `module_slug`, branding, and base catalogs.
- Central parameter registry and validations.

**Phase TDD (minimum)**
- Resolves `module_slug=letsfixtickets` in `brand`.
- Resolves `module_slug=ticketflow` in `generic`.
- Rejects invalid parameters with clear error.
- Default fallbacks work when an optional parameter is missing.
- No brand strings appear in core code (policy test).

**Green + refactor + development**
- Start with resolution/validation tests.
- Implement configuration service and profile factory.
- Refactor to remove duplicated config access.

**Exit tests**
- Config unit tests covering 100% of critical rules.
- “No hardcoding” regression test via automated search.

**Phase closure**
- Evidence that both profiles are operational.
- Signed “stable config core” record.

---

## Phase 2 — Ticket domain (statuses, fields, permissions)

**Objective**
- Implement ticket flow with shared semantics and profile-specific presentation.

**Deliverables**
- Status catalog with stable `status_code`.
- Parameterized priorities/categories.
- Technical fields and visibility rules.
- Role-based permissions.

**Phase TDD (minimum)**
- Each `status_code` maps correctly to flags (`is_closed`, etc.).
- Invalid transitions are blocked.
- Customer cannot view internal notes.
- Technician/admin respect defined permissions.
- Label rendering changes text by profile, not semantics.

**Green + refactor + development**
- Test-first state engine and authorization rules.
- Minimal repository/service implementation.
- Refactor to separate domain rules from UI layer.

**Exit tests**
- Full ticket integration: creation → assignment → closure.
- Permission and visibility regression.

**Phase closure**
- Functional UAT on key operational cases.
- End-to-end flow approval.

---

## Phase 3 — Idempotent and secure API

**Objective**
- Expose a stable ticket API with full idempotency.

**Deliverables**
- CRUD endpoints + threads + attachments + statuses.
- `idempotency_key` support on write operations.
- Consistent error contracts.

**Phase TDD (minimum)**
- Same `idempotency_key` + same payload => same response.
- Same `idempotency_key` + different payload => `409 Conflict`.
- No permission => `403`.
- Internal note not exposed in customer endpoints.
- Pagination and filters return stable shape.

**Green + refactor + development**
- Contract tests first (request/response).
- Implement idempotency middleware.
- Refactor to centralize input validations.

**Exit tests**
- Basic concurrency tests on write endpoints.
- Compatibility tests on both profiles (`/api/letsfixtickets` and `/api/ticketflow`).

**Phase closure**
- Published versioned API contract.
- Retry-stability evidence.

---

## Phase 4 — Idempotent SupportCandy import

**Objective**
- Migrate data without duplication and with full traceability.

**Deliverables**
- `dry-run` and `run` importer.
- `source_system + source_id` mapping.
- Batch logs and `resume_token`.

**Phase TDD (minimum)**
- `dry-run` does not persist data.
- Re-importing the same batch does not duplicate.
- Interrupted batch resumes correctly.
- Partial errors do not break global consistency.
- Mapped customers/tickets preserve source-target relationships.

**Green + refactor + development**
- Test-first import pipeline.
- Implement dedupe + merge for allowed fields.
- Refactor parser/mapping to isolate it from persistence engine.

**Exit tests**
- Controlled test dataset + import metrics.
- Pre/post comparison with expected counts.

**Phase closure**
- Signed migration report.
- Validated logical rollback plan.

---

## Phase 5 — Hardening, performance, and release

**Objective**
- Prepare production release with quality and observability.

**Deliverables**
- Fully automated regression suite.
- Minimum observability (logs, error metrics, latency metrics).
- Release plan, rollback plan, and operational checklist.

**Phase TDD (minimum)**
- Full regression green in both profiles.
- Minimum load tests for critical endpoints.
- Basic security tests (unauthorized access, data exposure).
- Idempotent reinstall/upgrade still green.

**Green + refactor + development**
- Fix technical debt found by tests.
- Final maintainability-focused refactor.

**Exit tests**
- Full test plan + archived results.
- Smoke tests in preproduction environment.

**Phase closure**
- Go/No-Go decision.
- Formal release closure and improvements backlog.

## 3. Standard TDD definition per phase (template)

Each phase must include a TDD document with:

- **Test objective**.
- **Assumptions and fixtures**.
- **Given/When/Then matrix**.
- **Negative and edge cases**.
- **Green criteria** (which percentages/cases are mandatory).
- **Covered / uncovered risks**.
- **Evidence** (logs, reports, screenshots, traces).

## 4. Mandatory quality gates

- Gate 1: TDD approved before development.
- Gate 2: reproducible red tests.
- Gate 3: full phase green.
- Gate 4: refactor without regression.
- Gate 5: closure with report and evidence.

If any gate fails, **the phase does not advance**.

## 5. Parallelization strategy (owned + generic)

- One shared core implementation is executed.
- Mandatory validation in two profiles:
  - `profile=brand`
  - `profile=generic`
- Every fixed bug must include regression tests for both profiles.

## 6. Suggested cadence (iteration)

For each phase:

- Day 1: definition + TDD.
- Day 2-3: green + minimum development.
- Day 4: refactor.
- Day 5: exit tests + closure.

(adjustable by complexity)

## 7. Delivery artifacts per phase

- `TDD_Fx.md` (phase test design).
- `TEST_REPORT_Fx.md` (execution results).
- `CHANGELOG_Fx.md` (what changed).
- `RETRO_Fx.md` (risks, debt, improvements).

## 8. Global success criteria

The plan is successful when:

1. All phases complete gates 1..5.
2. No duplicates appear in install/import/API under retries.
3. Brand and Generic pass the same critical suite.
4. Generic profile is ready for TFM defense without brand coupling.

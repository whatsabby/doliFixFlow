# TDD_F4 — SupportCandy Migration (Idempotent)

> Phase: 4  
> Track: **Letsfix-first** migration with full-history and duplicate-safe behavior  
> Status: Draft for review  
> Source: `lf_specs/phase_4_definition.md`

## 1) Test objective

Validate that SupportCandy migration is deterministic, resumable, and duplicate-safe while preserving source-target traceability.

## 2) Scope under test

- `dry-run` vs `run` migration mode behavior.
- Source identity mapping (`source_system + source_id`).
- Dedupe behavior on re-import/retry.
- Batch interruption and resume behavior.
- Partial-failure containment and reconciliation criteria.

## 3) Out of scope (Phase 4)

- Final production cutover execution.
- Broader release hardening activities.
- New feature development outside migration scope.

## 4) Assumptions

- `lf_specs/phase_4_definition.md` approved.
- Full historical data migration remains mandatory.
- `dry-run` must never persist writes.
- Re-import of identical source records must be idempotent.

## 5) Fixtures and test data

### 5.1 Source dataset fixtures

- `fixture_source_small_consistent`
- `fixture_source_large_consistent`
- `fixture_source_with_duplicates`
- `fixture_source_with_partial_errors`
- `fixture_source_interrupted_batch`

### 5.2 Mapping fixtures

- `fixture_mapping_valid_complete`
- `fixture_mapping_missing_required`
- `fixture_mapping_conflicting_identity`

### 5.3 Resume/retry fixtures

- `fixture_resume_token_valid`
- `fixture_resume_token_stale`
- `fixture_reimport_same_batch`

## 6) Given/When/Then test matrix

### 6.1 Dry-run safety

1. **Given** valid source dataset and `dry-run=true`  
   **When** migration executes  
   **Then** no data is persisted and a full preview report is produced.

2. **Given** dataset with mapping errors in dry-run  
   **When** migration executes  
   **Then** errors are reported without any persistent side effects.

### 6.2 Run mode correctness

3. **Given** valid source dataset and `run` mode  
   **When** migration executes  
   **Then** records are persisted with source-target traceability links.

4. **Given** records already imported previously  
   **When** same batch is re-imported  
   **Then** no duplicate customers/tickets are created.

### 6.3 Identity and dedupe

5. **Given** same `source_system + source_id` appears again  
   **When** import executes  
   **Then** importer resolves existing target record per dedupe policy.

6. **Given** conflicting identity mapping input  
   **When** validation executes  
   **Then** batch is blocked or flagged according to policy with explicit errors.

### 6.4 Resume and partial failures

7. **Given** interrupted batch with valid resume token  
   **When** resume executes  
   **Then** processing continues from correct checkpoint without duplication.

8. **Given** partial failures in a batch  
   **When** run completes  
   **Then** successful records remain consistent and failures are fully reported.

9. **Given** stale/invalid resume token  
   **When** resume is requested  
   **Then** operation fails safely with actionable guidance.

## 7) Negative and edge cases

- Empty source batch.
- Source records missing mandatory identity fields.
- Mixed valid/invalid records in same batch.
- Cross-entity ordering issues (child before parent).
- Retry after timeout/network interruption.

## 8) Green criteria (pass conditions)

- 100% pass rate for critical migration correctness/idempotency cases.
- 0 persistent writes in all dry-run scenarios.
- 0 duplicates after controlled re-import/retry scenarios.
- Resume behavior deterministic for interrupted batches.
- Full traceability report available for imported and failed records.

## 9) Coverage target

- 100% of critical migration mode and dedupe rules.
- 100% of resume/retry policy rules for listed scenarios.
- All listed edge cases executed at least once.

## 10) Risks covered / not covered

### Covered risks

- Duplicate records after retries.
- Loss of traceability between source and target.
- Unrecoverable interrupted batches.
- Hidden partial-failure inconsistencies.

### Not covered in Phase 4

- Production cutover operations.
- Full release hardening beyond migration correctness.

## 11) Evidence required

- Dry-run reports proving zero persistence.
- Import reconciliation reports (expected vs actual counts).
- Dedupe logs by `source_system + source_id`.
- Resume execution logs for interrupted-batch scenarios.

## 12) Execution order (TDD cycle)

1. Write failing dry-run safety tests.
2. Implement minimum dry-run behavior to pass.
3. Write failing dedupe/identity tests.
4. Implement minimum identity mapping and dedupe behavior.
5. Write failing resume/partial-failure tests.
6. Implement minimum resume and failure-handling behavior.
7. Refactor while preserving full green.
8. Produce evidence package and request phase closure.

## 13) Entry and exit gates

### Entry gate

- `lf_specs/phase_4_definition.md` approved.
- Scope and assumptions confirmed.

### Exit gate

- All green criteria satisfied.
- Evidence set complete.
- Approval to move to Phase 5 TDD drafting.

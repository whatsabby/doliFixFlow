# Parallel and Idempotent Architecture — Operational + Generic Tracks

> Version: 0.1  
> Date: 2026-10-04  
> Status: dual-execution design

## 1. Product decision

Run two tracks in parallel:
1. **Operational (Letsfix)** for real business usage.
2. **Generic** for TFM/demo and future generalization.

Current execution scope: **Letsfix-first**.

## 2. Mandatory principles

1. End-to-end idempotency (install, import, API, jobs).
2. Configuration-first (no brand hardcoding in core).
3. Shared core + profile-specific overlays.
4. Backward compatibility for active operations.

## 3. Layered architecture

- Core module: business logic.
- Profile layer: branding/labels/presets.
- Integration layer: SupportCandy/WordPress/API.
- Ops layer: installer/migrations/audit/recovery.

## 4. What must be configurable

- module identity and labels
- statuses/priorities/categories
- custom fields and visibility
- permissions
- list and filter defaults
- import mappings and conflict policy
- API endpoint base and idempotency settings
- notifications and attachment policy

## 5. Idempotency contract

### Install/upgrades
- safe create-if-not-exists
- upsert seeds
- re-runnable migrations

### Import
- `source_system + source_id` dedupe
- dry-run does not persist
- resumable batches

### API
- `idempotency_key` on writes
- deterministic repeat behavior
- conflict on same key + different payload

### Jobs
- scoped locking
- controlled retries

## 6. Acceptance criteria

- Letsfix profile works end-to-end.
- No duplicate creation under retry/re-import.
- No brand hardcoding in core logic.
- Generic profile stays documented as deferred scope.


# Specification — SupportCandy to Dolibarr Migration (Generic)

> Version: 0.1  
> Date: 2026-08-25  
> Status: technical draft

## Objective

Define a reusable, unbranded Dolibarr ticketing extension pattern inspired by SupportCandy, with full idempotency and high configurability.

## Scope (included)

- Ticket lifecycle for repair/diagnostics/maintenance/inquiries
- customizable statuses, priorities, categories
- configurable fields and list views
- role-based permissions
- conversation threads, internal notes, attachments
- API integration
- SupportCandy import with dry-run and idempotency

## Scope (not phase 1)

- full public portal replacement
- real-time chat
- autonomous AI customer sending
- full real-time bidirectional sync

## Architecture

- Native Dolibarr Ticket as baseline
- Generic extension layer for operational behavior
- Configuration-driven profile behavior
- Minimal custom tables only when native model is insufficient

## Core status model (example)

- New
- Pending reception
- Received
- Under diagnosis
- Assigned
- In progress
- Under repair
- Waiting spare part
- Waiting customer reply
- Waiting internal reply
- Ready to ship
- Shipped
- Delivered
- Quote rejected
- Closed

## API baseline

`/api/ticketflow/...` in generic profile.

## Import baseline

- mandatory dry-run
- `source_system + source_id` dedupe
- resumable batches
- deterministic re-import behavior

## TDD baseline

- install/reinstall idempotency
- permission isolation
- status semantics
- API idempotency
- import non-duplication

## MVP criteria

- installable extension over native Ticket
- operational lifecycle coverage
- idempotent import and write operations
- role-safe data visibility


# SupportCandy to Dolibarr Mapping Baseline (Draft)

> Captured: 2026-10-12  
> Scope: Letsfix-first migration; source schemas verified for tickets, threads, attachments, customers, and agents.  
> Status: Draft for Phase 4 review. Target field names below are logical Dolibarr concepts, not verified physical columns or API properties.

## 1. Mapping Principles

- Reuse Dolibarr's native Ticket, third parties, contacts, users, and document storage wherever possible.
- Use module extrafields for Letsfix-specific ticket data where native fields do not fit; add custom tables only for capabilities the native model and extrafields cannot represent.
- Preserve every original SupportCandy ID and source relationship. Do not use email as the sole customer identity.
- Do not import or log a field until its meaning and privacy classification are understood.
- Treat mappings marked `Validate` as blocked from production import until the listed evidence is reviewed.

## 2. Identity and Relationships

| Source entity | Source identity | Proposed target | Identity / relationship rule |
|---|---|---|---|
| Ticket | `wp_psmsc_tickets.id` | Native Dolibarr Ticket | Preserve as `sc_ticket_id`; deduplicate within the ticket mapping by `source_system=supportcandy` and source ID. |
| Customer | `wp_psmsc_customers.id` | Dolibarr third party + contact, as applicable | Preserve `sc_customer_id`; map through an explicit source-customer mapping, not email alone. |
| Agent | `wp_psmsc_agents.id` | Dolibarr internal user | Explicit mapping from SupportCandy agent ID to Dolibarr user ID; never assume the WordPress user ID equals a Dolibarr user ID. |
| Thread | `wp_psmsc_threads.id` | Native ticket message/thread capability, or module-owned thread extension if native behavior is insufficient | Preserve source thread ID and resolve `ticket` through the ticket mapping before import. Classify public replies versus internal notes before writing. |
| Attachment | `wp_psmsc_attachments.id` | Dolibarr document linked to its ticket/thread | Preserve source attachment ID and resolve owner/ticket/thread mappings. Copy files through a validated, secure file transfer; do not treat `file_path` as a Dolibarr document path. |

For a generalized mapping registry, scope source IDs by logical source entity so equal numeric IDs from different SupportCandy tables cannot collide. Keep the physical source table name as provenance. This is a proposal to review against the existing `source_system + source_id` rule and the ticket/customer `sc_*_id` requirements before implementation.

## 3. Ticket Fields — `wp_psmsc_tickets`

| Source field | Proposed handling | Status / validation |
|---|---|---|
| `id` | Native Ticket source identity (`sc_ticket_id`) and mapping registry | Preserve exactly; unique ticket dedupe key. |
| `is_active` | Determine whether the ticket is active, archived, or excluded | Validate values and meaning; do not equate directly with open/closed. |
| `customer` | Resolve through SupportCandy customer mapping to Dolibarr third party/contact | Required relationship; resolve before ticket creation. |
| `subject` | Native ticket subject/title | Direct semantic match; validate empty/length constraints. |
| `status` | Map through an explicit SupportCandy-to-Letsfix status catalog | Requires source status catalog and approved target status mapping. |
| `priority` | Map through an explicit priority catalog | Requires source priority catalog and target configuration. |
| `category` | Map through an explicit category catalog | Requires source category catalog and target configuration. |
| `assigned_agent` | Resolve to one or more Dolibarr users | Validate stored format; field is `text`, so do not assume a single numeric ID. |
| `date_created` | Native ticket creation timestamp, if supported by the import path | Preserve source timestamp; confirm timezone and target API behavior. |
| `date_updated` | Source audit metadata; do not overwrite target modification time without an approved import rule | Preserve for reconciliation. |
| `agent_created` | Map SupportCandy agent ID to Dolibarr user as creator, when resolvable | Validate relationship and fallback for deleted/unmapped agents. |
| `ip_address` | Restricted audit metadata or omit from operational target | Privacy/retention review required. |
| `source` | Preserve as source-channel/origin metadata | Confirm vocabulary and whether target has a suitable field. |
| `browser` | Optional restricted audit metadata or omit | Privacy/retention review required. |
| `os` | Optional restricted audit metadata or omit | Privacy/retention review required. |
| `add_recipients` | Preserve only if additional-recipient behavior is required | Validate serialized format and recipient handling; do not send notifications during import. |
| `prev_assignee` | Historical assignment audit only | Decode and validate format; do not treat as current assignee. |
| `date_closed` | Native close timestamp when status semantics confirm closed | Validate status/date consistency and timezone. |
| `user_type` | Source classification metadata, if needed | Validate vocabulary and whether redundant with customer/agent relation. |
| `last_reply_on` | Reconciliation value derived/checked against imported threads | Do not use as authoritative when thread history is available. |
| `last_reply_by` | Reconciliation value; resolve only after thread author mappings exist | Validate ID namespace and author type. |
| `last_reply_source` | Optional source-channel metadata | Validate vocabulary. |
| `auth_code` | Exclude from operational import and logs by default | Treat as potentially sensitive; retention requires explicit security approval. |
| `tags` | Preserve as tags or map to configured categories only if semantics match | Validate encoding and avoid conflating tags with the single category field. |
| `live_agents` | Do not import as current assignment without validation | Likely transient; inspect values and confirm business meaning. |
| `misc` | Preserve in restricted raw archive until its structure is understood | Decode and classify each key before mapping; never blindly copy into a visible field. |
| `cust_26` | Candidate custom-field value | Requires custom-field definition/options and sample values. |
| `cust_27` | Candidate custom-field value | Requires custom-field definition/options and sample values. |
| `cust_30` | Candidate custom-field value | Requires custom-field definition/options and sample values. |
| `ticket_summary` | Candidate ticket summary/description extension | Inspect sample values and overlap with `subject`/thread body before assigning a target. |

## 4. Thread Fields — `wp_psmsc_threads`

| Source field | Proposed handling | Status / validation |
|---|---|---|
| `id` | Preserve thread source identity | Required for re-import dedupe. |
| `ticket` | Resolve to mapped native ticket | Required parent relationship. |
| `is_active` | Preserve visibility/archive state | Validate meaning; inactive threads must not be silently discarded. |
| `customer` | Resolve author through customer mapping when populated | Determine whether this is the author or another customer relation. |
| `type` | Classify public reply, internal note, or other thread type | Blocking privacy check; inspect all distinct values before import. |
| `body` | Native ticket message/thread body | Preserve text and encoding; apply safe rendering on display. |
| `attachments` | Parse source attachment references and link mapped documents | Validate serialization and relation to `wp_psmsc_attachments.source_id`/`ticket_id`. |
| `ip_address` | Restricted audit metadata or omit | Privacy/retention review required. |
| `source` | Optional channel/origin metadata | Validate vocabulary. |
| `os` | Optional restricted audit metadata or omit | Privacy/retention review required. |
| `browser` | Optional restricted audit metadata or omit | Privacy/retention review required. |
| `seen` | Optional read/seen metadata if target supports it | Validate semantics and intended audience. |
| `date_created` | Preserve original message timestamp | Confirm timezone and target import support. |
| `date_updated` | Preserve source audit timestamp where useful | Do not replace creation time; confirm whether edits are represented in history. |

## 5. Customer Fields — `wp_psmsc_customers`

| Source field | Proposed handling | Status / validation |
|---|---|---|
| `id` | Preserve as `sc_customer_id` in customer mapping | Required identity; do not deduplicate solely by email. |
| `user` | WordPress user ID; use to retrieve/associate user profile data | Not a Dolibarr user ID. Requires authorized WordPress user data export. |
| `ticket_count` | Reconciliation metric only | Recompute against imported tickets; do not use as authoritative relationship data. |
| `name` | Candidate third-party/contact display name | Validate splitting and existing-entity matching rules. |

Customer email and other profile fields are not present in this table schema. If required for migration or matching, obtain them from the corresponding WordPress user records through an approved read-only export.

## 6. Agent Fields — `wp_psmsc_agents`

| Source field | Proposed handling | Status / validation |
|---|---|---|
| `id` | Preserve as SupportCandy agent identity in agent mapping | Required source identity. |
| `user` | WordPress user ID used to resolve the agent profile | Requires authorized WordPress user data export; not a Dolibarr user ID. |
| `customer` | Preserve for analysis until relationship meaning is confirmed | Do not use as an agent/customer join without samples. |
| `role` | Map to module role/permissions only after enumerating values | Must not grant privileges based on assumed numeric meanings. |
| `name` | Candidate display name for mapping review | Do not create a new Dolibarr user automatically. |
| `workload` | Reconciliation/operational statistic; normally do not import | Validate whether it is derived. |
| `unresolved_count` | Reconciliation/operational statistic; normally do not import | Validate whether it is derived. |
| `is_agentgroup` | Identify group records; do not map to a person user | Validate group-assignment behavior. |
| `is_active` | Candidate active/inactive source-agent state | Validate values and treatment of inactive historical assignees. |

## 7. Attachment Fields — `wp_psmsc_attachments`

| Source field | Proposed handling | Status / validation |
|---|---|---|
| `id` | Preserve attachment source identity | Required for re-import dedupe. |
| `name` | Original filename for target document metadata | Sanitize on storage and display. |
| `file_path` | Source locator only; resolve through an approved read-only file export | Never concatenate directly into a destination path; verify containment and file existence. |
| `is_image` | Optional media classification | Validate values; do not trust it for content safety. |
| `is_active` | Candidate visibility/deletion state | Validate semantics before excluding files. |
| `is_uploaded` | Upload-state metadata | Validate whether file content exists and is complete. |
| `date_created` | Preserve source attachment timestamp as metadata | Confirm timezone. |
| `source` | Source attachment context/type | Enumerate values and establish relationship semantics. |
| `source_id` | Possible source thread/message ID depending on `source` | Validate jointly with `source` and thread attachment references. |
| `ticket_id` | Resolve parent SupportCandy ticket to native Ticket | Required relationship when nonzero. |
| `customer_id` | Resolve associated customer when applicable | Validate zero/null semantics and relation. |
| `uploaded_by` | Preserve source uploader identifier as audit metadata | Determine identifier namespace; do not equate it to a Dolibarr user. |

## 8. Blocking Validation Before Import

1. Confirm the production Dolibarr version and inspect native Ticket fields/API behavior in the staging instance.
2. Export SupportCandy status, priority, category, and custom-field definitions/options.
3. Inspect representative, privacy-scrubbed values for `assigned_agent`, `prev_assignee`, `live_agents`, `misc`, `cust_*`, thread `type`/`attachments`, and attachment `source`/`source_id`.
4. Confirm WordPress user profile data needed to map customer and agent identities.
5. Confirm attachment storage access, allowed file types, and the policy for missing/inactive files.
6. Approve the identity registry scope, including how logical source entity is included to avoid ID collisions across entity types.

No production import should be implemented from this draft alone. Phase 4 mapping, dry-run, idempotency, resume, and reconciliation decisions remain subject to the phase approval gates.

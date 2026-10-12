# SupportCandy DB Tables (Observed)

Captured on: 2026-10-04T21:07:31.7418871+02:00

Discovery queries used:

```sql
SHOW TABLES LIKE '%psmsc%';
SHOW TABLES LIKE '%wpsc%';
```

Observed tables:

```
wp_psmsc_acb_messages
wp_psmsc_acb_sessions
wp_psmsc_agents
wp_psmsc_ai_logs
wp_psmsc_ai_training
wp_psmsc_archived_threads
wp_psmsc_archived_tickets
wp_psmsc_attachments
wp_psmsc_categories
wp_psmsc_custom_fields
wp_psmsc_customers
wp_psmsc_email_notifications
wp_psmsc_email_otp
wp_psmsc_holidays
wp_psmsc_logs
wp_psmsc_options
wp_psmsc_priorities
wp_psmsc_scheduled_tasks
wp_psmsc_statuses
wp_psmsc_threads
wp_psmsc_ticket_tags
wp_psmsc_tickets
wp_psmsc_wh_exceptions
wp_psmsc_working_hrs
```

## Verified Column Schemas

Captured on: 2026-10-12

The following schema was returned by querying `information_schema.columns` across schemas. The query output did not include nullability or key metadata.

### `wp_psmsc_tickets` (30 columns)

| Position | Column | Type |
|---:|---|---|
| 1 | `id` | `bigint(20)` |
| 2 | `is_active` | `int(1)` |
| 3 | `customer` | `bigint(20)` |
| 4 | `subject` | `text` |
| 5 | `status` | `int(11)` |
| 6 | `priority` | `int(11)` |
| 7 | `category` | `int(11)` |
| 8 | `assigned_agent` | `text` |
| 9 | `date_created` | `datetime` |
| 10 | `date_updated` | `datetime` |
| 11 | `agent_created` | `int(11)` |
| 12 | `ip_address` | `varchar(50)` |
| 13 | `source` | `varchar(50)` |
| 14 | `browser` | `varchar(50)` |
| 15 | `os` | `varchar(50)` |
| 16 | `add_recipients` | `text` |
| 17 | `prev_assignee` | `text` |
| 18 | `date_closed` | `datetime` |
| 19 | `user_type` | `varchar(100)` |
| 20 | `last_reply_on` | `datetime` |
| 21 | `last_reply_by` | `bigint(20)` |
| 22 | `last_reply_source` | `varchar(50)` |
| 23 | `auth_code` | `varchar(50)` |
| 24 | `tags` | `tinytext` |
| 25 | `live_agents` | `tinytext` |
| 26 | `misc` | `longtext` |
| 27 | `cust_26` | `tinytext` |
| 28 | `cust_27` | `tinytext` |
| 29 | `cust_30` | `tinytext` |
| 30 | `ticket_summary` | `text` |

### `wp_psmsc_agents` (9 columns)

| Position | Column | Type | Nullable | Default | Key |
|---:|---|---|---|---|---|
| 1 | `id` | `bigint(20)` | NO | NULL | PRI |
| 2 | `user` | `bigint(20)` | YES | 0 | |
| 3 | `customer` | `bigint(20)` | YES | 0 | |
| 4 | `role` | `int(11)` | NO | 0 | |
| 5 | `name` | `varchar(200)` | NO | NULL | |
| 6 | `workload` | `int(11)` | YES | NULL | |
| 7 | `unresolved_count` | `int(11)` | YES | NULL | |
| 8 | `is_agentgroup` | `int(1)` | NO | 0 | |
| 9 | `is_active` | `int(1)` | NO | 0 | |

### `wp_psmsc_attachments` (12 columns)

| Position | Column | Type | Nullable | Default | Key |
|---:|---|---|---|---|---|
| 1 | `id` | `bigint(20)` | NO | NULL | PRI |
| 2 | `name` | `varchar(200)` | NO | NULL | |
| 3 | `file_path` | `text` | NO | NULL | |
| 4 | `is_image` | `int(1)` | NO | 0 | |
| 5 | `is_active` | `int(1)` | NO | 0 | |
| 6 | `is_uploaded` | `int(1)` | NO | 0 | |
| 7 | `date_created` | `datetime` | NO | NULL | |
| 8 | `source` | `varchar(200)` | NO | NULL | |
| 9 | `source_id` | `bigint(20)` | NO | 0 | |
| 10 | `ticket_id` | `bigint(20)` | NO | 0 | |
| 11 | `customer_id` | `bigint(20)` | NO | 0 | |
| 12 | `uploaded_by` | `varchar(64)` | NO | '' | |

### `wp_psmsc_customers` (4 columns)

| Position | Column | Type | Nullable | Default | Key |
|---:|---|---|---|---|---|
| 1 | `id` | `bigint(20)` | NO | NULL | PRI |
| 2 | `user` | `bigint(20)` | NO | NULL | |
| 3 | `ticket_count` | `int(11)` | NO | 0 | |
| 4 | `name` | `varchar(200)` | NO | NULL | |

### `wp_psmsc_threads` (14 columns)

| Position | Column | Type | Nullable | Default | Key |
|---:|---|---|---|---|---|
| 1 | `id` | `bigint(20)` | NO | NULL | PRI |
| 2 | `ticket` | `bigint(20)` | NO | NULL | MUL |
| 3 | `is_active` | `int(1)` | NO | 1 | |
| 4 | `customer` | `bigint(20)` | YES | NULL | |
| 5 | `type` | `varchar(50)` | NO | NULL | |
| 6 | `body` | `longtext` | NO | NULL | |
| 7 | `attachments` | `text` | YES | NULL | |
| 8 | `ip_address` | `varchar(50)` | YES | NULL | |
| 9 | `source` | `varchar(50)` | YES | NULL | |
| 10 | `os` | `varchar(50)` | YES | NULL | |
| 11 | `browser` | `varchar(100)` | YES | NULL | |
| 12 | `seen` | `datetime` | YES | NULL | |
| 13 | `date_created` | `datetime` | NO | NULL | |
| 14 | `date_updated` | `datetime` | NO | NULL | |

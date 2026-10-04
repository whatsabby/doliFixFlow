/*
SupportCandy bulk export (SELECT-only)

Goal
- Generate deterministic, repeatable export SELECT statements for SupportCandy tables.
- Works with any WordPress prefix as long as tables match: __WP_PREFIX__psmsc_*
- Safe to run in production: SELECT statements only.

How to use
1) Connect to the WordPress DB that contains SupportCandy tables.
2) Run this script.
3) Copy/paste the generated SELECT statements (Section C) and run them.

Notes on idempotency
- The generator tries to ORDER BY the PRIMARY KEY columns when present.
- If a table has no PRIMARY KEY, it falls back to ORDER BY 1.

Parameterization
- This script never hardcodes the WP prefix.
- It detects SupportCandy tables by matching '%psmsc\_%' (escaped underscore).
- For chunked exports, use the emitted paged query template placeholders:
  - __LIMIT__  : max rows per chunk
  - __OFFSET__ : starting offset
*/

/* A) Context */
SELECT DATABASE() AS current_database;
SELECT @@version AS db_engine_version;

/* B) Table inventory (psmsc_*) */
SELECT
  t.table_name,
  t.table_rows,
  t.engine,
  t.create_time,
  t.update_time
FROM information_schema.tables t
WHERE t.table_schema = DATABASE()
  AND t.table_name LIKE '%psmsc\_%' ESCAPE '\\'
ORDER BY t.table_rows DESC, t.table_name;

/*
C) Export query generator

This emits one row per SupportCandy table with:
- count_query: COUNT(*) for sanity checks
- columns_query: column list discovery (for mapping and incremental export planning)
- export_query_full: SELECT * with deterministic ORDER BY
- export_query_paged: SELECT * with deterministic ORDER BY and LIMIT/OFFSET placeholders

You can paste these into your SQL client and run them one-by-one.
*/

SELECT
  t.table_name,
  CONCAT(
    'SELECT ''', t.table_name, ''' AS table_name, COUNT(*) AS cnt FROM `', t.table_name, '`;'
  ) AS count_query,
  CONCAT(
    'SELECT column_name, ordinal_position, data_type, is_nullable, column_key ',
    'FROM information_schema.columns ',
    'WHERE table_schema = DATABASE() AND table_name = ''', t.table_name, ''' ',
    'ORDER BY ordinal_position;'
  ) AS columns_query,
  CONCAT(
    'SELECT * FROM `', t.table_name, '` ORDER BY ',
    COALESCE(pk.pk_cols, '1'),
    ';'
  ) AS export_query_full,
  CONCAT(
    'SELECT * FROM `', t.table_name, '` ORDER BY ',
    COALESCE(pk.pk_cols, '1'),
    ' LIMIT __LIMIT__ OFFSET __OFFSET__;'
  ) AS export_query_paged
FROM information_schema.tables t
LEFT JOIN (
  SELECT
    s.table_schema,
    s.table_name,
    GROUP_CONCAT(CONCAT('`', s.column_name, '`') ORDER BY s.seq_in_index SEPARATOR ', ') AS pk_cols
  FROM information_schema.statistics s
  WHERE s.table_schema = DATABASE()
    AND s.index_name = 'PRIMARY'
    AND s.table_name LIKE '%psmsc\_%' ESCAPE '\\'
  GROUP BY s.table_schema, s.table_name
) pk
  ON pk.table_schema = t.table_schema
 AND pk.table_name = t.table_name
WHERE t.table_schema = DATABASE()
  AND t.table_name LIKE '%psmsc\_%' ESCAPE '\\'
ORDER BY t.table_name;

/*
D) Migration-focused "must export" table list

This is the minimum set typically needed for SC -> Dolibarr ticket migration.
(Your install may store extra data in other psmsc_* tables; keep them too if needed.)
*/

SELECT table_name
FROM information_schema.tables
WHERE table_schema = DATABASE()
  AND (
    table_name LIKE '%psmsc\_tickets' ESCAPE '\\'
    OR table_name LIKE '%psmsc\_threads' ESCAPE '\\'
    OR table_name LIKE '%psmsc\_attachments' ESCAPE '\\'
    OR table_name LIKE '%psmsc\_customers' ESCAPE '\\'
    OR table_name LIKE '%psmsc\_agents' ESCAPE '\\'
    OR table_name LIKE '%psmsc\_statuses' ESCAPE '\\'
    OR table_name LIKE '%psmsc\_priorities' ESCAPE '\\'
    OR table_name LIKE '%psmsc\_categories' ESCAPE '\\'
    OR table_name LIKE '%psmsc\_custom_fields' ESCAPE '\\'
    OR table_name LIKE '%psmsc\_ticket_tags' ESCAPE '\\'
    OR table_name LIKE '%psmsc\_archived_tickets' ESCAPE '\\'
    OR table_name LIKE '%psmsc\_archived_threads' ESCAPE '\\'
  )
ORDER BY table_name;

/*
E) Recommended export order (to reduce FK-like dependency issues in import)

This does NOT exclude any tables; it just highlights a sensible order
for the tables that most migrations will need first.
*/

SELECT
  t.table_name
FROM information_schema.tables t
WHERE t.table_schema = DATABASE()
  AND t.table_name LIKE '%psmsc\_%' ESCAPE '\\'
ORDER BY
  CASE
    WHEN t.table_name LIKE '%psmsc\_statuses' ESCAPE '\\' THEN 10
    WHEN t.table_name LIKE '%psmsc\_priorities' ESCAPE '\\' THEN 20
    WHEN t.table_name LIKE '%psmsc\_categories' ESCAPE '\\' THEN 30
    WHEN t.table_name LIKE '%psmsc\_custom_fields' ESCAPE '\\' THEN 40
    WHEN t.table_name LIKE '%psmsc\_ticket_tags' ESCAPE '\\' THEN 50
    WHEN t.table_name LIKE '%psmsc\_customers' ESCAPE '\\' THEN 60
    WHEN t.table_name LIKE '%psmsc\_agents' ESCAPE '\\' THEN 70
    WHEN t.table_name LIKE '%psmsc\_tickets' ESCAPE '\\' THEN 80
    WHEN t.table_name LIKE '%psmsc\_threads' ESCAPE '\\' THEN 90
    WHEN t.table_name LIKE '%psmsc\_attachments' ESCAPE '\\' THEN 100
    WHEN t.table_name LIKE '%psmsc\_archived_tickets' ESCAPE '\\' THEN 110
    WHEN t.table_name LIKE '%psmsc\_archived_threads' ESCAPE '\\' THEN 120
    ELSE 1000
  END,
  t.table_name;
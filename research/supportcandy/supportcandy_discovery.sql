/*
SupportCandy table discovery + export-prep queries
Compatible target: MySQL/MariaDB (including MariaDB 10.6)
Read-only safe: SELECT statements only

Updated to support the observed SupportCandy table naming pattern:
  __WP_PREFIX__psmsc_*   (example: wp_psmsc_tickets)
*/

/* 1) DB context */
SELECT DATABASE() AS current_database;

/* 2) Candidate WordPress prefixes (from core *_options tables) */
SELECT
  table_name AS options_table,
  REPLACE(table_name, 'options', '') AS guessed_prefix
FROM information_schema.tables
WHERE table_schema = DATABASE()
  AND table_name LIKE '%\_options' ESCAPE '\\'
ORDER BY table_name;

/* 3) Generate plugin/version-hint queries for each detected core options table (copy/paste output and run)
   - This helps confirm SupportCandy plugin activation and settings stored in wp_options.
*/
SELECT CONCAT(
  'SELECT ''', t.table_name, ''' AS options_table, option_name, LEFT(option_value,300) AS option_value_preview ',
  'FROM `', t.table_name, '` ',
  'WHERE option_name IN (''active_plugins'') ',
  'OR option_name LIKE ''%supportcandy%'' ',
  'OR option_name LIKE ''%psmsc%'' ',
  'OR option_name LIKE ''wpsc_%'' OR option_name LIKE ''supportcandy_%'' ',
  'ORDER BY option_name;'
) AS options_scan_query
FROM information_schema.tables t
WHERE t.table_schema = DATABASE()
  AND t.table_name LIKE '%\_options' ESCAPE '\\'
ORDER BY t.table_name;

/* 3b) Generate SupportCandy internal options-table scan (copy/paste output and run)
   SupportCandy stores most of its own configuration in __PREFIX__psmsc_options.
*/
SELECT CONCAT(
  'SELECT ''', t.table_name, ''' AS psmsc_options_table, option_name, LEFT(option_value,300) AS option_value_preview ',
  'FROM `', t.table_name, '` ',
  'ORDER BY option_name ',
  'LIMIT 200;'
) AS psmsc_options_scan_query
FROM information_schema.tables t
WHERE t.table_schema = DATABASE()
  AND t.table_name LIKE '%psmsc\_options' ESCAPE '\\'
ORDER BY t.table_name;

/* 4) Discover SupportCandy tables by the observed name pattern */
SELECT table_name
FROM information_schema.tables
WHERE table_schema = DATABASE()
  AND (
    table_name LIKE '%psmsc\_%' ESCAPE '\\'
  )
ORDER BY table_name;

/* 5) Candidate tables with row counts */
SELECT
  t.table_name,
  t.table_rows,
  t.engine,
  t.create_time,
  t.update_time
FROM information_schema.tables t
WHERE t.table_schema = DATABASE()
  AND (
    t.table_name LIKE '%psmsc\_%' ESCAPE '\\'
  )
ORDER BY t.table_rows DESC, t.table_name;

/* 6) Columns per candidate table */
SELECT
  c.table_name,
  c.ordinal_position,
  c.column_name,
  c.column_type,
  c.is_nullable,
  c.column_default,
  c.column_key
FROM information_schema.columns c
WHERE c.table_schema = DATABASE()
  AND (
    c.table_name LIKE '%psmsc\_%' ESCAPE '\\'
  )
ORDER BY c.table_name, c.ordinal_position;

/* 7) Fast semantic classification helper by table name */
SELECT
  t.table_name,
  CASE
    WHEN t.table_name REGEXP 'ticket' THEN 'tickets_or_ticket_related'
    WHEN t.table_name REGEXP 'thread|reply|conversation' THEN 'threads_or_replies'
    WHEN t.table_name REGEXP 'customer|contact|user' THEN 'customers_or_users'
    WHEN t.table_name REGEXP 'agent|staff' THEN 'agents'
    WHEN t.table_name REGEXP 'status' THEN 'statuses'
    WHEN t.table_name REGEXP 'priorit' THEN 'priorities'
    WHEN t.table_name REGEXP 'categor' THEN 'categories'
    WHEN t.table_name REGEXP 'field|custom' THEN 'custom_fields'
    WHEN t.table_name REGEXP 'attach|file|media' THEN 'attachments'
    WHEN t.table_name REGEXP 'meta|log|audit' THEN 'meta_or_logs'
    ELSE 'other_candidate'
  END AS guessed_domain,
  t.table_rows
FROM information_schema.tables t
WHERE t.table_schema = DATABASE()
  AND (
    t.table_name LIKE '%psmsc\_%' ESCAPE '\\'
  )
ORDER BY guessed_domain, t.table_rows DESC;

/* 8) Generate row-sample commands (copy/paste output and run) */
SELECT CONCAT('SELECT * FROM `', t.table_name, '` LIMIT 20;') AS sample_query
FROM information_schema.tables t
WHERE t.table_schema = DATABASE()
  AND (
    t.table_name LIKE '%psmsc\_%' ESCAPE '\\'
  )
ORDER BY t.table_name;

/* 9) Generate COUNT(*) commands (copy/paste output and run) */
SELECT CONCAT('SELECT ''', t.table_name, ''' AS table_name, COUNT(*) AS cnt FROM `', t.table_name, '`;') AS count_query
FROM information_schema.tables t
WHERE t.table_schema = DATABASE()
  AND (
    t.table_name LIKE '%psmsc\_%' ESCAPE '\\'
  )
ORDER BY t.table_name;

/*
SupportCandy diagnostics when discovery returns empty results
Read-only safe: SELECT statements only

Updated to prefer the observed SupportCandy pattern:
  __WP_PREFIX__psmsc_*   (example: wp_psmsc_tickets)
*/

/* A) Verify current DB and basic table count */
SELECT DATABASE() AS current_database;

SELECT COUNT(*) AS total_tables_in_db
FROM information_schema.tables
WHERE table_schema = DATABASE();

/* B) List first 200 tables to verify we are in the expected WordPress DB */
SELECT table_name
FROM information_schema.tables
WHERE table_schema = DATABASE()
ORDER BY table_name
LIMIT 200;

/* C) Detect all *_options-like tables and their row counts (core WordPress options tables) */
SELECT t.table_name, t.table_rows
FROM information_schema.tables t
WHERE t.table_schema = DATABASE()
  AND t.table_name LIKE '%\_options' ESCAPE '\\'
ORDER BY t.table_name;

/* D) Generate active_plugins queries for each detected core options table */
SELECT CONCAT(
  'SELECT ''', t.table_name, ''' AS options_table, option_name, LEFT(option_value,500) AS option_value_preview ',
  'FROM `', t.table_name, '` ',
  'WHERE option_name = ''active_plugins'' ',
  'OR option_name LIKE ''%supportcandy%'' ',
  'OR option_name LIKE ''%psmsc%'' ',
  'OR option_name LIKE ''%wpsc%'' ',
  'OR option_name LIKE ''%wpsp%'' ',
  'LIMIT 200;'
) AS run_this_query
FROM information_schema.tables t
WHERE t.table_schema = DATABASE()
  AND t.table_name LIKE '%\_options' ESCAPE '\\'
ORDER BY t.table_name;

/* E) Confirm SupportCandy tables exist by the observed prefix pattern */
SELECT table_name, table_rows
FROM information_schema.tables
WHERE table_schema = DATABASE()
  AND table_name LIKE '%psmsc\_%' ESCAPE '\\'
ORDER BY table_rows DESC, table_name;

/* F) Generate quick samples for SupportCandy tables (copy/paste output and run) */
SELECT CONCAT('SELECT ''', t.table_name, ''' AS table_name, COUNT(*) AS cnt FROM `', t.table_name, '`;') AS run_this_query
FROM information_schema.tables t
WHERE t.table_schema = DATABASE()
  AND t.table_name LIKE '%psmsc\_%' ESCAPE '\\'
ORDER BY t.table_name;

/* G) If you know the WP prefix, replace __PREFIX__ and run these samples */
/* Example: __PREFIX__ = wp_ */
/* SELECT option_name, LEFT(option_value,500) FROM __PREFIX__options WHERE option_name='active_plugins'; */
/* SELECT option_name, LEFT(option_value,500) FROM __PREFIX__psmsc_options ORDER BY option_name LIMIT 200; */

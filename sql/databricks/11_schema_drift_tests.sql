-- Phase 3 gap: the brief's 3 injected schema-drift tests (rename/type-change/drop),
-- proving a checker catches each. Built as OUR OWN portable checker (compares
-- INFORMATION_SCHEMA.COLUMNS against a stored expected-schema snapshot) rather than
-- relying on platform-specific magic - works the same way on Databricks and Snowflake,
-- a stronger answer to the brief's own R3 question than "trust the platform."
--
-- Real design constraint found while planning this: bronze stores every column as
-- STRING (the "raw, untouched" rule). That makes a schema-level type comparison
-- structurally blind to upstream type drift - STRING stays STRING even if the actual
-- values inside it change shape. Rename and drop genuinely change the column list, so
-- the schema checker catches those for real. Type drift is tested separately below, as
-- a VALUE-level problem (a cast failure), not a schema-level one - that's the honest
-- answer for this architecture, not a faked bronze-level type change.

CREATE SCHEMA IF NOT EXISTS workspace.ops;

-- ---- Step 1: snapshot the expected schema for bronze.brfss_2015 ----
CREATE OR REPLACE TABLE workspace.ops.expected_schema AS
SELECT 'brfss_2015' AS dataset_id, column_name, data_type, ordinal_position
FROM workspace.information_schema.columns
WHERE table_catalog='workspace' AND table_schema='bronze' AND table_name='brfss_2015';

SELECT count(*) FROM workspace.ops.expected_schema;   -- expect 333 (330 source + 3 metadata)

-- ---- Step 2: the checker itself - compares any table's live schema against a stored
-- expected snapshot, classifies what changed ----
CREATE OR REPLACE VIEW workspace.ops.schema_drift_check AS
WITH actual AS (
  SELECT column_name, data_type, ordinal_position
  FROM workspace.information_schema.columns
  WHERE table_catalog='workspace' AND table_schema='bronze' AND table_name='brfss_2015_drift_test'
),
expected AS (
  SELECT column_name, data_type, ordinal_position FROM workspace.ops.expected_schema WHERE dataset_id='brfss_2015'
)
SELECT COALESCE(e.column_name, a.column_name) AS column_name,
  CASE
    WHEN e.column_name IS NOT NULL AND a.column_name IS NULL THEN 'DROPPED'
    WHEN e.column_name IS NULL AND a.column_name IS NOT NULL THEN 'NEW_UNEXPECTED_COLUMN'
    WHEN e.data_type != a.data_type THEN 'TYPE_CHANGED'
    ELSE 'OK'
  END AS drift_status,
  e.data_type AS expected_type, a.data_type AS actual_type
FROM expected e
FULL OUTER JOIN actual a ON a.column_name = e.column_name
WHERE COALESCE(e.column_name, a.column_name) IS NOT NULL;

-- Severity classification: a DROPPED + NEW_UNEXPECTED_COLUMN pair with the SAME data
-- type is a likely rename (schema-diffing can never be fully certain - a human still
-- reviews it - but pairing on type is a real, useful heuristic). Anything else DROPPED
-- is CRITICAL (breaks any query referencing it directly). TYPE_CHANGED is CRITICAL
-- too (silent wrong-type reads). A lone NEW_UNEXPECTED_COLUMN is LOW (additive, safe).
CREATE OR REPLACE VIEW workspace.ops.schema_drift_classified AS
WITH base AS (SELECT * FROM workspace.ops.schema_drift_check),
paired AS (
  SELECT d.column_name AS dropped_col, n.column_name AS new_col
  FROM base d JOIN base n
    ON d.drift_status = 'DROPPED' AND n.drift_status = 'NEW_UNEXPECTED_COLUMN'
   AND d.expected_type = n.actual_type
)
SELECT b.*,
  CASE
    WHEN b.drift_status = 'DROPPED' AND b.column_name IN (SELECT dropped_col FROM paired) THEN 'LIKELY_RENAME'
    WHEN b.drift_status = 'NEW_UNEXPECTED_COLUMN' AND b.column_name IN (SELECT new_col FROM paired) THEN 'LIKELY_RENAME'
    WHEN b.drift_status = 'DROPPED' THEN 'CRITICAL'
    WHEN b.drift_status = 'TYPE_CHANGED' THEN 'CRITICAL'
    WHEN b.drift_status = 'NEW_UNEXPECTED_COLUMN' THEN 'LOW'
    ELSE 'NONE'
  END AS severity
FROM base b WHERE b.drift_status != 'OK';

-- ---- Baseline: prove the checker does NOT false-positive on the correct schema ----
CREATE OR REPLACE TABLE workspace.bronze.brfss_2015_drift_test AS SELECT * FROM workspace.bronze.brfss_2015 LIMIT 100;
SELECT drift_status, count(*) FROM workspace.ops.schema_drift_check GROUP BY drift_status;  -- expect only OK

-- ---- Test 1: RENAME - _STATE becomes _STATE_CODE ----
-- SELECT * RENAME (...) is Snowflake syntax, not Spark SQL - real syntax error hit
-- here, fixed with EXCEPT + explicit rename instead.
CREATE OR REPLACE TABLE workspace.bronze.brfss_2015_drift_test AS
SELECT * EXCEPT (_STATE), _STATE AS _STATE_CODE FROM workspace.bronze.brfss_2015 LIMIT 100;
SELECT * FROM workspace.ops.schema_drift_check WHERE drift_status != 'OK' ORDER BY drift_status;

-- ---- Test 2: DROP - remove DIABETE3 entirely (the actual target variable - high severity) ----
CREATE OR REPLACE TABLE workspace.bronze.brfss_2015_drift_test AS
SELECT * EXCEPT (DIABETE3) FROM workspace.bronze.brfss_2015 LIMIT 100;
SELECT * FROM workspace.ops.schema_drift_check WHERE drift_status != 'OK' ORDER BY drift_status;

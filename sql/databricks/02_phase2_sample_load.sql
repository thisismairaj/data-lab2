-- Databricks Phase 2 (sample). Run on the serverless SQL warehouse, catalog `workspace`.
-- Run on 2026-09-28. Loads a 50,000-row local sample of 2015.csv to bronze, all columns as text.
-- Verified: row count = 50,000 (matches the local sample exactly), column count = 333
-- (330 source columns + 3 load metadata columns).

CREATE VOLUME IF NOT EXISTS workspace.bronze.landing
  COMMENT 'Raw CSV files land here before being read into bronze';

-- File uploaded separately with: databricks fs cp <local sample> dbfs:/Volumes/workspace/bronze/landing/2015_sample_50k.csv

DROP TABLE IF EXISTS workspace.bronze.brfss_2015_sample;

-- schema is STRUCT<`_STATE` STRING, `FMONTH` STRING, ... > (all 330 source columns as STRING;
-- generated from the CSV header by scripts, not hand-typed here to keep this file readable).
-- See docs/schema_contract.md: bronze keeps every source column as text, unmodified.
CREATE TABLE workspace.bronze.brfss_2015_sample AS
SELECT
  *,
  '2015_sample_50k.csv' AS _source_file,
  current_timestamp()   AS _loaded_at,
  'phase2-sample-20260928' AS _run_id
FROM read_files(
  '/Volumes/workspace/bronze/landing/2015_sample_50k.csv',
  format => 'csv',
  header => true,
  schema => 'STRUCT<... all 330 source columns as STRING ...>'
);

-- Verification queries (see docs/metrics.md Q1-Q3):
SELECT count(*) FROM workspace.bronze.brfss_2015_sample;                 -- expect 50000
SELECT count(*) FROM (
  SELECT column_name FROM workspace.information_schema.columns
  WHERE table_catalog='workspace' AND table_schema='bronze'
    AND table_name='brfss_2015_sample'
);                                                                        -- expect 333

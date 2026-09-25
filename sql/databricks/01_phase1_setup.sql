-- Databricks Phase 1 setup. Run on the serverless SQL warehouse, catalog `workspace`.
-- Idempotent: safe to re-run. Run on 2026-09-25; verified with SHOW SCHEMAS and DESCRIBE TABLE.

CREATE SCHEMA IF NOT EXISTS workspace.bronze COMMENT 'BRFSS 2015 raw as delivered, all text';
CREATE SCHEMA IF NOT EXISTS workspace.silver COMMENT 'Typed, validated records plus quarantine';
CREATE SCHEMA IF NOT EXISTS workspace.gold   COMMENT 'Aggregates for consumers';
CREATE SCHEMA IF NOT EXISTS workspace.ref    COMMENT 'Reference lookups such as codebook_values';
CREATE SCHEMA IF NOT EXISTS workspace.ops    COMMENT 'Pipeline metrics and run bookkeeping';

-- One row per measurement. Columns match docs/metrics.md and the Snowflake twin.
CREATE TABLE IF NOT EXISTS workspace.ops.pipeline_metrics (
  platform     STRING,     -- 'databricks' or 'snowflake'
  phase        STRING,     -- e.g. phase1, bronze_load, silver_build
  metric_name  STRING,     -- from the catalog in docs/metrics.md
  value        DOUBLE,     -- NULL when not measured, never 0
  unit         STRING,     -- rows, seconds, percent, credits, dbu, usd, count, bool
  run_id       STRING,     -- ties the row to one pipeline run
  measured_at  TIMESTAMP,  -- when it was recorded (UTC)
  method       STRING,     -- how it was measured
  notes        STRING      -- caveats
) COMMENT 'One row per measurement. See docs/metrics.md';

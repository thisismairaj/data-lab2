-- Snowflake setup for the automated pipeline: warehouse, credit guardrail, database, schemas, landing stage.
-- Same names as the 2026-09 build (01_phase1_setup.sql) so the Snowflake and Databricks builds line up.

ALTER WAREHOUSE COMPUTE_WH SET AUTO_SUSPEND = 60;

-- Hard credit ceiling, same 10-credit guardrail as the earlier build. Raise it if the demo needs more.
CREATE RESOURCE MONITOR IF NOT EXISTS project_monitor
  WITH CREDIT_QUOTA = 10
  FREQUENCY = MONTHLY
  START_TIMESTAMP = IMMEDIATELY
  TRIGGERS
    ON 50 PERCENT DO NOTIFY
    ON 100 PERCENT DO SUSPEND;
ALTER WAREHOUSE COMPUTE_WH SET RESOURCE_MONITOR = project_monitor;

CREATE DATABASE IF NOT EXISTS BRFSS;
CREATE SCHEMA IF NOT EXISTS BRFSS.BRONZE;
CREATE SCHEMA IF NOT EXISTS BRFSS.SILVER;
CREATE SCHEMA IF NOT EXISTS BRFSS.GOLD;
CREATE SCHEMA IF NOT EXISTS BRFSS.REF;
CREATE SCHEMA IF NOT EXISTS BRFSS.OPS;

-- Landing area: the Snowflake counterpart of the Databricks volume workspace.bronze.landing.
CREATE STAGE IF NOT EXISTS BRFSS.BRONZE.LANDING
  DIRECTORY = (ENABLE = TRUE AUTO_REFRESH = TRUE)  -- file list refreshes itself on upload, so a stream can see new files
  COMMENT = 'BRFSS yearly CSV files land here';

CREATE TABLE IF NOT EXISTS BRFSS.OPS.PIPELINE_METRICS (
  PLATFORM STRING, PHASE STRING, METRIC_NAME STRING, VALUE DOUBLE, UNIT STRING,
  RUN_ID STRING, MEASURED_AT TIMESTAMP_NTZ, METHOD STRING, NOTES STRING
);

-- Snowflake Phase 1 setup. Run 2026-09-28.
-- Sets the required 60-second auto-suspend (was 300s, Snowflake's default), creates a
-- resource monitor with a real credit ceiling and a 50% alert (the brief's own wording),
-- and prepares the schemas that mirror the Databricks build (bronze/silver/gold/ref/ops).

ALTER WAREHOUSE COMPUTE_WH SET AUTO_SUSPEND = 60;

-- Resource monitor: a hard ceiling Snowflake can actually enforce (unlike Databricks Free
-- Edition, which only offers a soft daily quota with no visible remaining balance).
-- 10 credits is a deliberately small ceiling for this project's size (441K rows, X-Small
-- warehouse) - it's not meant to be close to the trial's real balance, just a real,
-- enforced number instead of "unlimited".
CREATE OR REPLACE RESOURCE MONITOR project_monitor
  WITH CREDIT_QUOTA = 10
  FREQUENCY = MONTHLY
  START_TIMESTAMP = IMMEDIATELY
  TRIGGERS
    ON 50 PERCENT DO NOTIFY
    ON 100 PERCENT DO SUSPEND;

ALTER WAREHOUSE COMPUTE_WH SET RESOURCE_MONITOR = project_monitor;

-- Schemas mirroring the Databricks build, so results are structurally comparable.
CREATE DATABASE IF NOT EXISTS BRFSS;
CREATE SCHEMA IF NOT EXISTS BRFSS.BRONZE;
CREATE SCHEMA IF NOT EXISTS BRFSS.SILVER;
CREATE SCHEMA IF NOT EXISTS BRFSS.GOLD;
CREATE SCHEMA IF NOT EXISTS BRFSS.REF;
CREATE SCHEMA IF NOT EXISTS BRFSS.OPS;

CREATE TABLE IF NOT EXISTS BRFSS.OPS.PIPELINE_METRICS (
  PLATFORM     STRING,
  PHASE        STRING,
  METRIC_NAME  STRING,
  VALUE        DOUBLE,
  UNIT         STRING,
  RUN_ID       STRING,
  MEASURED_AT  TIMESTAMP_NTZ,
  METHOD       STRING,
  NOTES        STRING
);

-- Verification
SHOW WAREHOUSES LIKE 'COMPUTE_WH';
SHOW RESOURCE MONITORS;
SHOW SCHEMAS IN DATABASE BRFSS;

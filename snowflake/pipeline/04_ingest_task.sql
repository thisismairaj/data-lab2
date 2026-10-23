-- Ingestion trigger: the Snowflake counterpart of the Databricks job's file-arrival trigger.
-- 1. The LANDING stage keeps a directory table (a list of its files) that refreshes itself
--    when a file is uploaded (AUTO_REFRESH = TRUE, set in 00_setup.sql).
-- 2. A stream on that stage records each new file.
-- 3. A triggered task (no schedule) runs as soon as the stream has data: it loads the new
--    file into bronze, logs it, then refreshes gold, which pulls silver along with it.
-- 4. If any step fails, the task emails the owner (EXCEPTION block) and still ends as FAILED.

-- Email channel used by the alerts in 05_alerts.sql.
-- Snowflake only emails addresses that are verified on a user in this account.
CREATE NOTIFICATION INTEGRATION IF NOT EXISTS DEMO_EMAIL
  TYPE = EMAIL
  ENABLED = TRUE
  ALLOWED_RECIPIENTS = ('isthismairaj@gmail.com');

CREATE TABLE IF NOT EXISTS BRFSS.OPS.INGEST_LOG (
  FILE_NAME STRING, FILE_SIZE NUMBER, FILE_LAST_MODIFIED TIMESTAMP_TZ,
  TASK_STARTED_AT TIMESTAMP_LTZ, LOADED_AT TIMESTAMP_LTZ
);

CREATE STREAM IF NOT EXISTS BRFSS.BRONZE.LANDING_FILES ON STAGE BRFSS.BRONZE.LANDING;

CREATE OR REPLACE TASK BRFSS.BRONZE.INGEST_BRFSS
  WAREHOUSE = COMPUTE_WH
  COMMENT = 'Runs when a new file lands in @BRFSS.BRONZE.LANDING: bronze load, then silver and gold refresh'
  WHEN SYSTEM$STREAM_HAS_DATA('BRFSS.BRONZE.LANDING_FILES')
AS EXECUTE IMMEDIATE $$
DECLARE
  started TIMESTAMP_LTZ DEFAULT CURRENT_TIMESTAMP();
BEGIN
  -- Load only files not loaded before (Snowflake remembers loaded files for 64 days).
  COPY INTO BRFSS.BRONZE.BRFSS_RAW
    FROM @BRFSS.BRONZE.LANDING
    FILE_FORMAT = (FORMAT_NAME = BRFSS.BRONZE.CSV_HEADER)
    MATCH_BY_COLUMN_NAME = CASE_INSENSITIVE
    INCLUDE_METADATA = (_SOURCE_FILE = METADATA$FILENAME, _LOADED_AT = METADATA$START_SCAN_TIME)
    PATTERN = '.*[.]csv([.]gz)?'
    ON_ERROR = ABORT_STATEMENT;

  -- Reading the stream in a DML statement moves it forward, so the task does not fire again for these files.
  INSERT INTO BRFSS.OPS.INGEST_LOG
    SELECT RELATIVE_PATH, SIZE, LAST_MODIFIED, :started, CURRENT_TIMESTAMP()
    FROM BRFSS.BRONZE.LANDING_FILES
    WHERE METADATA$ACTION = 'INSERT';

  -- Gold pulls STAGED, CHECKED and CLEAN along (they are TARGET_LAG = DOWNSTREAM).
  ALTER DYNAMIC TABLE BRFSS.GOLD.DIABETES_PREVALENCE_STATE REFRESH;
  -- Quarantine is not upstream of gold, so refresh it explicitly.
  ALTER DYNAMIC TABLE BRFSS.SILVER.QUARANTINE REFRESH;
  -- The five breakdown tables (03b_gold_breakdowns.sql) read silver.clean too.
  ALTER DYNAMIC TABLE BRFSS.GOLD.DIABETES_PREVALENCE_AGE_GROUP REFRESH;
  ALTER DYNAMIC TABLE BRFSS.GOLD.DIABETES_PREVALENCE_SMOKING REFRESH;
  ALTER DYNAMIC TABLE BRFSS.GOLD.DIABETES_PREVALENCE_BMI_CATEGORY REFRESH;
  ALTER DYNAMIC TABLE BRFSS.GOLD.DIABETES_COMORBIDITY REFRESH;
  ALTER DYNAMIC TABLE BRFSS.GOLD.DIABETES_RISK_STACKING REFRESH;
EXCEPTION
  -- Pipeline failure email (the Databricks pipeline's on-update-failure notification):
  -- email the owner, then re-raise so the run still shows as FAILED in task history.
  WHEN OTHER THEN
    CALL SYSTEM$SEND_EMAIL('DEMO_EMAIL', 'isthismairaj@gmail.com',
      'Snowflake BRFSS pipeline FAILED',
      'Task BRFSS.BRONZE.INGEST_BRFSS failed: ' || SQLERRM || ' (SQLSTATE ' || SQLSTATE || ')');
    RAISE;
END;
$$;

ALTER TASK BRFSS.BRONZE.INGEST_BRFSS RESUME;

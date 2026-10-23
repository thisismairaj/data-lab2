-- Alerts: the Snowflake counterpart of the Databricks SQL alert on the quarantine rate
-- (databricks/pipeline/resources/alerts.yml). Same rule: email when more than 0.1 percent of
-- rows are quarantined. Same schedule: daily at 07:00 UTC. The pipeline-failure email lives
-- in the ingest task itself (04_ingest_task.sql).

-- Quarantine rate in one place, so the alert and the dashboard read the same number.
CREATE OR REPLACE VIEW BRFSS.OPS.QUARANTINE_RATE
  COMMENT = 'Share of loaded rows held in quarantine, overall'
AS
SELECT q.quarantined_rows,
       c.clean_rows,
       q.quarantined_rows / NULLIF(q.quarantined_rows + c.clean_rows, 0) AS quarantine_rate
FROM (SELECT COUNT(*) AS quarantined_rows FROM BRFSS.SILVER.QUARANTINE) q,
     (SELECT COUNT(*) AS clean_rows       FROM BRFSS.SILVER.CLEAN) c;

CREATE OR REPLACE ALERT BRFSS.OPS.QUARANTINE_RATE_HIGH
  WAREHOUSE = COMPUTE_WH
  SCHEDULE = 'USING CRON 0 7 * * * UTC'
  COMMENT = 'Emails the owner when more than 0.1 percent of rows are quarantined'
  IF (EXISTS (SELECT 1 FROM BRFSS.OPS.QUARANTINE_RATE WHERE quarantine_rate > 0.001))
  THEN
    EXECUTE IMMEDIATE $$
    DECLARE
      msg STRING;
    BEGIN
      SELECT 'Quarantine rate is ' || TO_VARCHAR(ROUND(100 * quarantine_rate, 3)) || ' percent ('
             || quarantined_rows || ' quarantined, ' || clean_rows || ' clean). Limit is 0.1 percent.'
        INTO :msg FROM BRFSS.OPS.QUARANTINE_RATE;
      CALL SYSTEM$SEND_EMAIL('DEMO_EMAIL', 'isthismairaj@gmail.com',
        'Snowflake alert: BRFSS quarantine rate above 0.1 percent', :msg);
    END;
    $$;

ALTER ALERT BRFSS.OPS.QUARANTINE_RATE_HIGH RESUME;

-- Access control: the Snowflake counterpart of the Databricks grants to `account users`.
-- PUBLIC is the role every Snowflake user has, so it plays the same part here.
-- Readers see every gold table (summaries and the star schema). Bronze, silver and
-- quarantine stay private to the owner (ACCOUNTADMIN). Quarantine is still an open decision.
GRANT USAGE  ON DATABASE BRFSS                                TO ROLE PUBLIC;
GRANT USAGE  ON SCHEMA   BRFSS.GOLD                           TO ROLE PUBLIC;
GRANT SELECT ON ALL DYNAMIC TABLES IN SCHEMA BRFSS.GOLD TO ROLE PUBLIC;   -- summaries, FACT_SURVEY_RESPONSE, DIM_DATE
GRANT SELECT ON ALL TABLES IN SCHEMA BRFSS.GOLD TO ROLE PUBLIC;           -- the reference dimensions
-- Readers need compute to run a query, like Databricks viewers need warehouse access.
GRANT USAGE  ON WAREHOUSE COMPUTE_WH                          TO ROLE PUBLIC;

SHOW GRANTS TO ROLE PUBLIC;

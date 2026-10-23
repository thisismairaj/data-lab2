-- Access control: the Snowflake counterpart of the Databricks grants to `account users`.
-- PUBLIC is the role every Snowflake user has, so it plays the same part here.
-- Same scope as Databricks: readers see the gold state table only. Bronze, silver and
-- quarantine stay private to the owner (ACCOUNTADMIN). Quarantine is still an open decision.
GRANT USAGE  ON DATABASE BRFSS                                TO ROLE PUBLIC;
GRANT USAGE  ON SCHEMA   BRFSS.GOLD                           TO ROLE PUBLIC;
GRANT SELECT ON DYNAMIC TABLE BRFSS.GOLD.DIABETES_PREVALENCE_STATE TO ROLE PUBLIC;
-- Readers need compute to run a query, like Databricks viewers need warehouse access.
GRANT USAGE  ON WAREHOUSE COMPUTE_WH                          TO ROLE PUBLIC;

SHOW GRANTS TO ROLE PUBLIC;

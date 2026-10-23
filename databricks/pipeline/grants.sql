-- Access control: same scope as Snowflake (snowflake/pipeline/06_grants.sql).
-- `account users` is the built-in group every user in the Databricks account belongs to,
-- the counterpart of Snowflake's PUBLIC role. Readers see the gold table only; bronze,
-- silver and quarantine stay private to the owner.
GRANT USE CATALOG ON CATALOG brfss                          TO `account users`;
GRANT USE SCHEMA  ON SCHEMA  brfss.gold                     TO `account users`;
GRANT SELECT      ON TABLE   brfss.gold.diabetes_prevalence_state TO `account users`;

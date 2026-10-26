-- Governance and security: roles, a row access policy, a masking policy and tags.
-- Everything here shows up under Snowsight's "Governance & security" pages.
--
--   BRFSS_ENGINEER       the data team: every layer (bronze, silver, gold, ops), can run the load task
--   BRFSS_ANALYST        business analysts: gold, the semantic view and the app; quarantine reasons,
--                        but the raw quarantined record is masked
--   BRFSS_ANALYST_TEXAS  a regional analyst: the star schema, but only rows for Texas
--
-- Hierarchy: ENGINEER inherits ANALYST; both roll up to SYSADMIN (Snowflake's recommended practice,
-- so administrators can manage what these roles create). All three are granted to the demo user so
-- the video can switch between them.
--
-- The policies check CURRENT_ROLE() (the role picked in Snowsight), not secondary roles, so switching
-- role really changes what you see. Pipeline refreshes run as the owner and are never filtered.

USE ROLE ACCOUNTADMIN;
CREATE SCHEMA IF NOT EXISTS BRFSS.GOVERNANCE COMMENT = 'Tags and access policies for the BRFSS data';

-- ------------------------------------------------------------------ roles
CREATE ROLE IF NOT EXISTS BRFSS_ANALYST       COMMENT = 'Reads gold, the semantic view and the app';
CREATE ROLE IF NOT EXISTS BRFSS_ENGINEER      COMMENT = 'Data team: all BRFSS layers and the load task';
CREATE ROLE IF NOT EXISTS BRFSS_ANALYST_TEXAS COMMENT = 'Regional analyst: star schema, Texas rows only';

GRANT ROLE BRFSS_ANALYST  TO ROLE BRFSS_ENGINEER;
GRANT ROLE BRFSS_ENGINEER TO ROLE SYSADMIN;
GRANT ROLE BRFSS_ANALYST_TEXAS TO ROLE SYSADMIN;

GRANT ROLE BRFSS_ANALYST       TO USER ISTHISMAIRAJ;
GRANT ROLE BRFSS_ENGINEER      TO USER ISTHISMAIRAJ;
GRANT ROLE BRFSS_ANALYST_TEXAS TO USER ISTHISMAIRAJ;

-- Compute for all three.
GRANT USAGE ON WAREHOUSE COMPUTE_WH TO ROLE BRFSS_ANALYST;
GRANT USAGE ON WAREHOUSE COMPUTE_WH TO ROLE BRFSS_ANALYST_TEXAS;

-- ------------------------------------------------------------------ analyst: gold and self-service
GRANT USAGE ON DATABASE BRFSS TO ROLE BRFSS_ANALYST;
GRANT USAGE ON SCHEMA BRFSS.GOLD TO ROLE BRFSS_ANALYST;
GRANT SELECT ON ALL TABLES IN SCHEMA BRFSS.GOLD TO ROLE BRFSS_ANALYST;
GRANT SELECT ON ALL DYNAMIC TABLES IN SCHEMA BRFSS.GOLD TO ROLE BRFSS_ANALYST;
GRANT USAGE ON SCHEMA BRFSS.SEMANTIC TO ROLE BRFSS_ANALYST;
GRANT SELECT ON SEMANTIC VIEW BRFSS.SEMANTIC.BRFSS_DIABETES TO ROLE BRFSS_ANALYST;
GRANT USAGE ON STREAMLIT BRFSS.GOLD.BRFSS_DASHBOARD TO ROLE BRFSS_ANALYST;
-- Analysts may see why records were quarantined; the raw record itself is masked (policy below).
GRANT USAGE ON SCHEMA BRFSS.SILVER TO ROLE BRFSS_ANALYST;
GRANT SELECT ON DYNAMIC TABLE BRFSS.SILVER.QUARANTINE TO ROLE BRFSS_ANALYST;

-- ------------------------------------------------------------------ engineer: every layer, the task
GRANT USAGE ON ALL SCHEMAS IN DATABASE BRFSS TO ROLE BRFSS_ENGINEER;
GRANT SELECT ON ALL TABLES IN DATABASE BRFSS TO ROLE BRFSS_ENGINEER;
GRANT SELECT ON ALL DYNAMIC TABLES IN DATABASE BRFSS TO ROLE BRFSS_ENGINEER;
GRANT SELECT ON ALL VIEWS IN DATABASE BRFSS TO ROLE BRFSS_ENGINEER;
GRANT READ ON STAGE BRFSS.BRONZE.LANDING TO ROLE BRFSS_ENGINEER;
GRANT MONITOR, OPERATE ON TASK BRFSS.BRONZE.INGEST_BRFSS TO ROLE BRFSS_ENGINEER;

-- ------------------------------------------------------------------ Texas analyst: star schema only
GRANT USAGE ON DATABASE BRFSS TO ROLE BRFSS_ANALYST_TEXAS;
GRANT USAGE ON SCHEMA BRFSS.GOLD TO ROLE BRFSS_ANALYST_TEXAS;
GRANT SELECT ON DYNAMIC TABLE BRFSS.GOLD.FACT_SURVEY_RESPONSE TO ROLE BRFSS_ANALYST_TEXAS;
GRANT SELECT ON TABLE BRFSS.GOLD.DIM_STATE, BRFSS.GOLD.DIM_AGE_GROUP, BRFSS.GOLD.DIM_SEX,
  BRFSS.GOLD.DIM_EDUCATION, BRFSS.GOLD.DIM_INCOME, BRFSS.GOLD.DIM_GENERAL_HEALTH,
  BRFSS.GOLD.DIM_SMOKING_STATUS, BRFSS.GOLD.DIM_BMI_CATEGORY, BRFSS.GOLD.DIM_DIABETES_STATUS
  TO ROLE BRFSS_ANALYST_TEXAS;
GRANT SELECT ON DYNAMIC TABLE BRFSS.GOLD.DIM_DATE TO ROLE BRFSS_ANALYST_TEXAS;

-- ------------------------------------------------------------------ row access policy
-- One row per survey response; the Texas analyst sees only Texas (FIPS 48). Every other role sees all.
CREATE OR REPLACE ROW ACCESS POLICY BRFSS.GOVERNANCE.STATE_ACCESS
  AS (state_fips VARCHAR) RETURNS BOOLEAN ->
    CASE WHEN CURRENT_ROLE() = 'BRFSS_ANALYST_TEXAS' THEN state_fips = '48' ELSE TRUE END
  COMMENT = 'Regional analysts see only their state';
ALTER DYNAMIC TABLE BRFSS.GOLD.FACT_SURVEY_RESPONSE ADD ROW ACCESS POLICY BRFSS.GOVERNANCE.STATE_ACCESS ON (state_fips);

-- ------------------------------------------------------------------ masking policy
-- The raw quarantined record is visible to the data team only; everyone else sees it masked.
CREATE OR REPLACE MASKING POLICY BRFSS.GOVERNANCE.MASK_RAW_PAYLOAD
  AS (val VARCHAR) RETURNS VARCHAR ->
    CASE WHEN CURRENT_ROLE() IN ('ACCOUNTADMIN', 'SYSADMIN', 'BRFSS_ENGINEER') THEN val ELSE '*** masked ***' END
  COMMENT = 'Raw quarantined records: data team only';
ALTER DYNAMIC TABLE BRFSS.SILVER.QUARANTINE MODIFY COLUMN raw_payload SET MASKING POLICY BRFSS.GOVERNANCE.MASK_RAW_PAYLOAD;

-- ------------------------------------------------------------------ tags
CREATE TAG IF NOT EXISTS BRFSS.GOVERNANCE.DATA_DOMAIN ALLOWED_VALUES 'public_health' COMMENT = 'Business domain of the data';
CREATE TAG IF NOT EXISTS BRFSS.GOVERNANCE.SENSITIVITY ALLOWED_VALUES 'public', 'internal', 'restricted'
  COMMENT = 'How carefully the data must be handled';
ALTER DATABASE BRFSS SET TAG BRFSS.GOVERNANCE.DATA_DOMAIN = 'public_health';
ALTER SCHEMA BRFSS.BRONZE SET TAG BRFSS.GOVERNANCE.SENSITIVITY = 'restricted';
ALTER SCHEMA BRFSS.SILVER SET TAG BRFSS.GOVERNANCE.SENSITIVITY = 'internal';
ALTER SCHEMA BRFSS.GOLD   SET TAG BRFSS.GOVERNANCE.SENSITIVITY = 'public';
ALTER DYNAMIC TABLE BRFSS.SILVER.QUARANTINE MODIFY COLUMN raw_payload SET TAG BRFSS.GOVERNANCE.SENSITIVITY = 'restricted';
ALTER DYNAMIC TABLE BRFSS.GOLD.FACT_SURVEY_RESPONSE MODIFY COLUMN state_fips SET TAG BRFSS.GOVERNANCE.SENSITIVITY = 'internal';

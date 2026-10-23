-- Silver: same four tables as the Lakeflow pipeline (databricks/pipeline/transformations/02_silver.sql):
-- silver.staged, silver.checked, silver.clean, silver.quarantine. Same corrections (D1, D2, Z1) and the same rules
-- (D3, W1, R1, C1).
-- Dynamic tables: Snowflake keeps each one up to date from the table it reads, like the
-- Lakeflow pipeline does. TARGET_LAG = DOWNSTREAM means "refresh only when a table that
-- reads me needs fresh data"; the ingest task refreshes gold, which pulls these along.

USE SCHEMA BRFSS.SILVER;

CREATE OR REPLACE DYNAMIC TABLE STAGED
  TARGET_LAG = DOWNSTREAM
  WAREHOUSE = COMPUTE_WH
  COMMENT = 'Typed and corrected, before the clean/quarantine split'
AS
WITH b AS (
  SELECT r.*,
         REGEXP_REPLACE("IDATE", '^b''|''$', '') AS idate_clean          -- D1: strip the b'...' wrapper
  FROM BRFSS.BRONZE.BRFSS_RAW r
)
SELECT
  LPAD(TRY_TO_DOUBLE("_STATE")::INT::VARCHAR, 2, '0')        AS state_fips,      -- Z1
  TRY_TO_NUMBER(REGEXP_SUBSTR("_SOURCE_FILE", '\\d{4}'))     AS survey_year,     -- year from the file name
  TRY_TO_DOUBLE("SEQNO")::BIGINT                             AS seqno,
  TRY_TO_DATE(IFF(idate_clean LIKE ' %', '0' || SUBSTR(idate_clean, 2), idate_clean),  -- D2
              'MMDDYYYY')                                    AS interview_date,
  TRY_TO_DOUBLE("SEX")            AS sex_code,
  TRY_TO_DOUBLE("_AGEG5YR")       AS age_group_code,
  TRY_TO_DOUBLE("EDUCA")          AS education_code,
  TRY_TO_DOUBLE("INCOME2")        AS income_code,
  TRY_TO_DOUBLE("GENHLTH")        AS general_health_code,
  TRY_TO_DOUBLE("HLTHPLN1")       AS health_plan_code,
  TRY_TO_DOUBLE("_SMOKER3")       AS smoker_status_code,
  TRY_TO_DOUBLE("EXERANY2")       AS exercise_any_code,
  TRY_TO_DOUBLE("DIABETE3")       AS diabetes_code,
  TRY_TO_DOUBLE("_BMI5") / 100    AS bmi,
  TRY_TO_DOUBLE("_BMI5CAT")       AS bmi_category_code,
  TRY_TO_DOUBLE("_LLCPWT")        AS final_weight,
  -- Health conditions and access to care, for the comorbidity gold table.
  TRY_TO_DOUBLE("BPHIGH4")        AS high_bp_code,
  TRY_TO_DOUBLE("TOLDHI2")        AS high_cholesterol_code,
  TRY_TO_DOUBLE("CVDINFR4")       AS heart_attack_code,
  TRY_TO_DOUBLE("CVDCRHD4")       AS heart_disease_code,
  TRY_TO_DOUBLE("CVDSTRK3")       AS stroke_code,
  TRY_TO_DOUBLE("ADDEPEV2")       AS depression_code,
  TRY_TO_DOUBLE("CHCKIDNY")       AS kidney_disease_code,
  TRY_TO_DOUBLE("ASTHMA3")        AS asthma_code,
  TRY_TO_DOUBLE("MEDCOST")        AS cost_barrier_code,
  TRY_TO_DOUBLE("PERSDOC2")       AS personal_doctor_code,
  "_SOURCE_FILE"                  AS source_file,
  "_LOADED_AT"                    AS loaded_at
FROM b;

-- One flag per rule, computed once, so the clean and quarantine tables cannot disagree.
CREATE OR REPLACE DYNAMIC TABLE CHECKED
  TARGET_LAG = DOWNSTREAM
  WAREHOUSE = COMPUTE_WH
  COMMENT = 'Silver staged plus one pass/fail flag per contract rule'
AS
SELECT s.*,
  interview_date IS NULL                                        AS fail_d3,
  final_weight IS NULL OR final_weight <= 0                     AS fail_w1,
  bmi IS NOT NULL AND (bmi < 12 OR bmi > 70)                    AS fail_r1,
  (sex_code IS NOT NULL AND sex_code NOT IN (1,2))
  OR (age_group_code IS NOT NULL AND age_group_code NOT IN (1,2,3,4,5,6,7,8,9,10,11,12,13,14))
  OR (education_code IS NOT NULL AND education_code NOT IN (1,2,3,4,5,6,9))
  OR (income_code IS NOT NULL AND income_code NOT IN (1,2,3,4,5,6,7,8,77,99))
  OR (general_health_code IS NOT NULL AND general_health_code NOT IN (1,2,3,4,5,7,9))
  OR (health_plan_code IS NOT NULL AND health_plan_code NOT IN (1,2,7,9))
  OR (smoker_status_code IS NOT NULL AND smoker_status_code NOT IN (1,2,3,4,9))
  OR (exercise_any_code IS NOT NULL AND exercise_any_code NOT IN (1,2,7,9))
  OR (diabetes_code IS NOT NULL AND diabetes_code NOT IN (1,2,3,4,7,9))
  OR (bmi_category_code IS NOT NULL AND bmi_category_code NOT IN (1,2,3,4)) AS fail_c1
FROM STAGED s;

CREATE OR REPLACE DYNAMIC TABLE CLEAN
  TARGET_LAG = DOWNSTREAM
  WAREHOUSE = COMPUTE_WH
  COMMENT = 'Published records: passed every rule. Query this, never bronze or silver.staged.'
AS
SELECT state_fips, survey_year, seqno, interview_date, sex_code, age_group_code,
       education_code, income_code, general_health_code, health_plan_code,
       smoker_status_code, exercise_any_code, diabetes_code, bmi, bmi_category_code,
       final_weight, high_bp_code, high_cholesterol_code, heart_attack_code, heart_disease_code,
       stroke_code, depression_code, kidney_disease_code, asthma_code, cost_barrier_code,
       personal_doctor_code, source_file, loaded_at
FROM CHECKED
WHERE NOT (fail_d3 OR fail_w1 OR fail_r1 OR fail_c1);

CREATE OR REPLACE DYNAMIC TABLE QUARANTINE
  TARGET_LAG = DOWNSTREAM
  WAREHOUSE = COMPUTE_WH
  COMMENT = 'Records that failed at least one rule. Nothing is dropped without a row here.'
AS
SELECT
  seqno AS record_id,
  survey_year,
  'brfss' AS dataset_id,
  -- ARRAY_CONSTRUCT_COMPACT skips NULLs, so rule_id lists only the rules that failed
  -- (Snowflake's CONCAT_WS would return NULL if any part were NULL).
  ARRAY_TO_STRING(ARRAY_CONSTRUCT_COMPACT(
    IFF(fail_d3, 'D3', NULL), IFF(fail_w1, 'W1', NULL),
    IFF(fail_r1, 'R1', NULL), IFF(fail_c1, 'C1', NULL)), ',')  AS rule_id,
  'quarantine' AS severity,
  TO_JSON(OBJECT_CONSTRUCT('state_fips', state_fips, 'seqno', seqno, 'bmi', bmi,
                           'final_weight', final_weight, 'smoker_status_code', smoker_status_code,
                           'bmi_category_code', bmi_category_code))  AS raw_payload,
  'Failed one or more contract rules - see rule_id' AS reason,
  'new' AS status,
  source_file
FROM CHECKED
WHERE fail_d3 OR fail_w1 OR fail_r1 OR fail_c1;

-- Silver: typed and corrected (D1, D2, Z1), then split into clean and quarantine by the
-- contract rules (D3, W1, R1, C1). Same four tables, same columns as Snowflake's
-- snowflake/pipeline/02_silver.sql. Streaming tables, so each grows only by new bronze rows.

CREATE OR REFRESH STREAMING TABLE silver.staged (
  -- Expectations: counted on every run and shown in the pipeline UI, nothing dropped here.
  CONSTRAINT plausible_bmi   EXPECT (bmi IS NULL OR (bmi BETWEEN 12 AND 70)),   -- R1
  CONSTRAINT positive_weight EXPECT (final_weight > 0),                         -- W1
  CONSTRAINT real_date       EXPECT (interview_date IS NOT NULL)                -- D3
)
COMMENT 'Typed and corrected, before the clean/quarantine split'
AS
WITH b AS (
  SELECT *, regexp_replace(IDATE, "^b'|'$", '') AS idate_clean          -- D1: strip the b'...' wrapper
  FROM STREAM bronze.brfss_raw
)
SELECT
  lpad(CAST(CAST(_STATE AS DOUBLE) AS INT), 2, '0')            AS state_fips,      -- Z1
  CAST(regexp_extract(_source_file, '(\\d{4})', 1) AS INT)     AS survey_year,     -- year from the file name
  CAST(CAST(SEQNO AS DOUBLE) AS BIGINT)                        AS seqno,
  try_to_date(CASE WHEN idate_clean LIKE ' %'                                       -- D2
                   THEN concat('0', substring(idate_clean, 2)) ELSE idate_clean END,
              'MMddyyyy')                                      AS interview_date,
  CAST(SEX AS DOUBLE)         AS sex_code,
  CAST(_AGEG5YR AS DOUBLE)    AS age_group_code,
  CAST(EDUCA AS DOUBLE)       AS education_code,
  CAST(INCOME2 AS DOUBLE)     AS income_code,
  CAST(GENHLTH AS DOUBLE)     AS general_health_code,
  CAST(HLTHPLN1 AS DOUBLE)    AS health_plan_code,
  CAST(_SMOKER3 AS DOUBLE)    AS smoker_status_code,
  CAST(EXERANY2 AS DOUBLE)    AS exercise_any_code,
  CAST(DIABETE3 AS DOUBLE)    AS diabetes_code,
  CAST(_BMI5 AS DOUBLE) / 100 AS bmi,
  CAST(_BMI5CAT AS DOUBLE)    AS bmi_category_code,
  CAST(_LLCPWT AS DOUBLE)     AS final_weight,
  -- Health conditions and access to care, for the comorbidity gold table (1 = yes, 2 = no in most).
  CAST(BPHIGH4 AS DOUBLE)     AS high_bp_code,
  CAST(TOLDHI2 AS DOUBLE)     AS high_cholesterol_code,
  CAST(CVDINFR4 AS DOUBLE)    AS heart_attack_code,
  CAST(CVDCRHD4 AS DOUBLE)    AS heart_disease_code,
  CAST(CVDSTRK3 AS DOUBLE)    AS stroke_code,
  CAST(ADDEPEV2 AS DOUBLE)    AS depression_code,
  CAST(CHCKIDNY AS DOUBLE)    AS kidney_disease_code,
  CAST(ASTHMA3 AS DOUBLE)     AS asthma_code,
  CAST(MEDCOST AS DOUBLE)     AS cost_barrier_code,
  CAST(PERSDOC2 AS DOUBLE)    AS personal_doctor_code,
  _source_file                AS source_file,
  _loaded_at                  AS loaded_at
FROM b;

-- One flag per rule, computed once, so clean and quarantine cannot disagree.
CREATE OR REFRESH STREAMING TABLE silver.checked
COMMENT 'Silver staged plus one pass/fail flag per contract rule'
AS
SELECT *,
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
FROM STREAM silver.staged;

CREATE OR REFRESH STREAMING TABLE silver.clean
COMMENT 'Published records: passed every rule. Query this, never bronze or silver.staged.'
AS
SELECT state_fips, survey_year, seqno, interview_date, sex_code, age_group_code,
       education_code, income_code, general_health_code, health_plan_code,
       smoker_status_code, exercise_any_code, diabetes_code, bmi, bmi_category_code,
       final_weight, high_bp_code, high_cholesterol_code, heart_attack_code, heart_disease_code,
       stroke_code, depression_code, kidney_disease_code, asthma_code, cost_barrier_code,
       personal_doctor_code, source_file, loaded_at
FROM STREAM silver.checked
WHERE NOT (fail_d3 OR fail_w1 OR fail_r1 OR fail_c1);

CREATE OR REFRESH STREAMING TABLE silver.quarantine
COMMENT 'Records that failed at least one rule. Nothing is dropped without a row here.'
AS
SELECT
  seqno AS record_id,
  survey_year,
  'brfss' AS dataset_id,
  concat_ws(',', CASE WHEN fail_d3 THEN 'D3' END, CASE WHEN fail_w1 THEN 'W1' END,
                 CASE WHEN fail_r1 THEN 'R1' END, CASE WHEN fail_c1 THEN 'C1' END) AS rule_id,
  'quarantine' AS severity,
  to_json(named_struct('state_fips', state_fips, 'seqno', seqno, 'bmi', bmi,
                       'final_weight', final_weight, 'smoker_status_code', smoker_status_code,
                       'bmi_category_code', bmi_category_code)) AS raw_payload,
  'Failed one or more contract rules - see rule_id' AS reason,
  'new' AS status,
  source_file
FROM STREAM silver.checked
WHERE fail_d3 OR fail_w1 OR fail_r1 OR fail_c1;

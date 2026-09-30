"""Generates sql/snowflake/03b_silver_multiyear.sql: the 5-year version of
03_silver_and_quarantine.sql. Same rule set/dialect fixes already proven on the 2015-only
build (TRY_TO_DATE, ARRAY_CONSTRUCT_COMPACT+ARRAY_TO_STRING instead of CONCAT_WS, no
FILTER clause) - the only real change is a per-year STAGED_YYYY step (5 bronze tables,
5 schemas) unioned together before the shared CHECKED/KEYED/publish logic.

Unlike the Databricks build, TRY_TO_DATE was already used from the start here (the
2026-09-28 Snowflake notes already call out TO_DATE errors vs TRY_TO_DATE returning NULL
as a known dialect difference) - so the ANSI-mode bug hit on Databricks does not apply.
"""
YEARS = [2011, 2012, 2013, 2014, 2015]

staged_blocks = []
for y in YEARS:
    staged_blocks.append(f'''CREATE OR REPLACE TABLE SILVER.STAGED_{y} AS
SELECT
  LPAD(TO_VARCHAR(CAST(CAST("_STATE" AS DOUBLE) AS INT)), 2, '0')          AS STATE_FIPS,
  {y}                                                                      AS SURVEY_YEAR,
  CAST(CAST("SEQNO" AS DOUBLE) AS BIGINT)                                  AS SEQNO,
  REGEXP_REPLACE("IDATE", '^b''|''$', '')                                 AS IDATE_STRIPPED,
  CASE WHEN REGEXP_REPLACE("IDATE", '^b''|''$', '') LIKE ' %'
       THEN CONCAT('0', SUBSTR(REGEXP_REPLACE("IDATE", '^b''|''$', ''), 2))
       ELSE REGEXP_REPLACE("IDATE", '^b''|''$', '')
  END                                                                      AS IDATE_PADDED,
  CAST("SEX" AS DOUBLE)         AS SEX_CODE,
  CAST("_AGEG5YR" AS DOUBLE)    AS AGE_GROUP_CODE,
  CAST("EDUCA" AS DOUBLE)       AS EDUCATION_CODE,
  CAST("INCOME2" AS DOUBLE)     AS INCOME_CODE,
  CAST("GENHLTH" AS DOUBLE)     AS GENERAL_HEALTH_CODE,
  CAST("HLTHPLN1" AS DOUBLE)    AS HEALTH_PLAN_CODE,
  CAST("_SMOKER3" AS DOUBLE)    AS SMOKER_STATUS_CODE,
  CAST("EXERANY2" AS DOUBLE)    AS EXERCISE_ANY_CODE,
  CAST("DIABETE3" AS DOUBLE)    AS DIABETES_CODE,
  CAST("_BMI5" AS DOUBLE) / 100                                           AS BMI,
  CAST("_BMI5CAT" AS DOUBLE)    AS BMI_CATEGORY_CODE,
  CAST("_LLCPWT" AS DOUBLE)     AS FINAL_WEIGHT,
  "_RUN_ID"                     AS BRONZE_RUN_ID
FROM BRONZE.BRFSS_{y};''')

union_sql = "CREATE OR REPLACE TABLE SILVER.STAGED_ALL AS\n" + "\nUNION ALL\n".join(
    f"SELECT * FROM SILVER.STAGED_{y}" for y in YEARS
) + ";"

sql = f'''-- Snowflake: 5-year silver + quarantine (2011-2015), supersedes the 2015-only
-- 03_silver_and_quarantine.sql (kept in git history). Same rule set, same dialect fixes
-- already proven working (TRY_TO_DATE, ARRAY_CONSTRUCT_COMPACT+ARRAY_TO_STRING, no
-- FILTER clause) - only change is a per-year staging step unioned before the shared
-- CHECKED/KEYED/publish logic, matching sql/databricks/03b_silver_multiyear.sql exactly
-- in structure (direct translation, same as the 2015-only files were).

USE DATABASE BRFSS;

-- ---- Step 1: per-year staging, one block per bronze table ----

{chr(10).join(staged_blocks)}

-- ---- Step 2: union all 5 years ----

{union_sql}

-- ---- Step 3: checked (add HIT_<rule> flags) ----

CREATE OR REPLACE TABLE SILVER.CHECKED_ALL AS
SELECT *,
  TRY_TO_DATE(IDATE_PADDED, 'MMDDYYYY')                                   AS INTERVIEW_DATE,
  (TRY_TO_DATE(IDATE_PADDED, 'MMDDYYYY') IS NULL)                         AS HIT_D3_BAD_DATE,
  -- D4: generalized from hardcoded (2015,2016) to (SURVEY_YEAR, SURVEY_YEAR+1), same fix
  -- applied on the Databricks side - interviews can run into Jan-Mar of the next year.
  (TRY_TO_DATE(IDATE_PADDED, 'MMDDYYYY') IS NOT NULL
     AND YEAR(TRY_TO_DATE(IDATE_PADDED, 'MMDDYYYY')) NOT IN (SURVEY_YEAR, SURVEY_YEAR + 1)) AS HIT_D4_YEAR,
  (FINAL_WEIGHT IS NULL OR FINAL_WEIGHT <= 0)                             AS HIT_W1_WEIGHT,
  (BMI IS NOT NULL AND (BMI < 12 OR BMI > 70))                            AS HIT_R1_BMI,
  (STATE_FIPS NOT IN
    ('01','02','04','05','06','08','09','10','11','12','13','15','16','17','18','19',
     '20','21','22','23','24','25','26','27','28','29','30','31','32','33','34','35',
     '36','37','38','39','40','41','42','44','45','46','47','48','49','50','51','53',
     '54','55','56','66','72'))                                          AS HIT_S1_STATE,
  (SEX_CODE IS NOT NULL AND SEX_CODE NOT IN (1,2))                        AS HIT_C1_SEX,
  (AGE_GROUP_CODE IS NOT NULL AND AGE_GROUP_CODE NOT IN
     (1,2,3,4,5,6,7,8,9,10,11,12,13,14))                                  AS HIT_C1_AGE,
  (EDUCATION_CODE IS NOT NULL AND EDUCATION_CODE NOT IN (1,2,3,4,5,6,9))  AS HIT_C1_EDUC,
  (INCOME_CODE IS NOT NULL AND INCOME_CODE NOT IN
     (1,2,3,4,5,6,7,8,77,99))                                             AS HIT_C1_INCOME,
  (GENERAL_HEALTH_CODE IS NOT NULL AND GENERAL_HEALTH_CODE NOT IN
     (1,2,3,4,5,7,9))                                                     AS HIT_C1_GENHLTH,
  (HEALTH_PLAN_CODE IS NOT NULL AND HEALTH_PLAN_CODE NOT IN (1,2,7,9))    AS HIT_C1_HLTHPLN,
  (SMOKER_STATUS_CODE IS NOT NULL AND SMOKER_STATUS_CODE NOT IN
     (1,2,3,4,9))                                                         AS HIT_C1_SMOKER,
  (EXERCISE_ANY_CODE IS NOT NULL AND EXERCISE_ANY_CODE NOT IN (1,2,7,9))  AS HIT_C1_EXER,
  (DIABETES_CODE IS NOT NULL AND DIABETES_CODE NOT IN (1,2,3,4,7,9))      AS HIT_C1_DIAB,
  (BMI_CATEGORY_CODE IS NOT NULL AND BMI_CATEGORY_CODE NOT IN (1,2,3,4))  AS HIT_C1_BMICAT
FROM SILVER.STAGED_ALL;

-- ---- Step 4: keyed (K1) ----

CREATE OR REPLACE TABLE SILVER.KEYED_ALL AS
SELECT *,
  COUNT(*) OVER (PARTITION BY STATE_FIPS, SURVEY_YEAR, SEQNO) > 1         AS HIT_K1_DUP_PK
FROM SILVER.CHECKED_ALL;

-- ---- Step 5: publish ----

CREATE OR REPLACE TABLE SILVER.BRFSS_QUARANTINE AS
SELECT
  SEQNO AS RECORD_ID, CONCAT('brfss_', SURVEY_YEAR) AS DATASET_ID, BRONZE_RUN_ID AS RUN_ID,
  ARRAY_TO_STRING(ARRAY_CONSTRUCT_COMPACT(
    CASE WHEN HIT_D3_BAD_DATE THEN 'D3' END, CASE WHEN HIT_D4_YEAR THEN 'D4' END,
    CASE WHEN HIT_W1_WEIGHT THEN 'W1' END,  CASE WHEN HIT_R1_BMI THEN 'R1' END,
    CASE WHEN HIT_S1_STATE THEN 'S1' END,
    CASE WHEN HIT_C1_SEX OR HIT_C1_AGE OR HIT_C1_EDUC OR HIT_C1_INCOME OR HIT_C1_GENHLTH
              OR HIT_C1_HLTHPLN OR HIT_C1_SMOKER OR HIT_C1_EXER OR HIT_C1_DIAB OR HIT_C1_BMICAT
         THEN 'C1' END,
    CASE WHEN HIT_K1_DUP_PK THEN 'K1' END
  ), ',') AS RULE_ID,
  'quarantine' AS SEVERITY,
  TO_JSON(OBJECT_CONSTRUCT('state_fips', STATE_FIPS, 'survey_year', SURVEY_YEAR, 'seqno', SEQNO,
                            'idate_raw', IDATE_STRIPPED, 'bmi', BMI,
                            'final_weight', FINAL_WEIGHT))                AS RAW_PAYLOAD,
  'Failed one or more contract rules - see rule_id' AS REASON,
  'new' AS STATUS, CAST(NULL AS VARCHAR) AS RESOLVED_BY
FROM SILVER.KEYED_ALL
WHERE HIT_D3_BAD_DATE OR HIT_D4_YEAR OR HIT_W1_WEIGHT OR HIT_R1_BMI OR HIT_S1_STATE
   OR HIT_C1_SEX OR HIT_C1_AGE OR HIT_C1_EDUC OR HIT_C1_INCOME OR HIT_C1_GENHLTH
   OR HIT_C1_HLTHPLN OR HIT_C1_SMOKER OR HIT_C1_EXER OR HIT_C1_DIAB OR HIT_C1_BMICAT
   OR HIT_K1_DUP_PK;

CREATE OR REPLACE TABLE SILVER.BRFSS_CLEAN AS
SELECT
  STATE_FIPS, SURVEY_YEAR, SEQNO, INTERVIEW_DATE,
  SEX_CODE, AGE_GROUP_CODE, EDUCATION_CODE, INCOME_CODE, GENERAL_HEALTH_CODE,
  HEALTH_PLAN_CODE, SMOKER_STATUS_CODE, EXERCISE_ANY_CODE, DIABETES_CODE,
  BMI, BMI_CATEGORY_CODE, FINAL_WEIGHT,
  'D1_STRIP_BYTES,Z1_STATE_PAD' AS CORRECTIONS,
  BRONZE_RUN_ID AS RUN_ID
FROM SILVER.KEYED_ALL
WHERE NOT (HIT_D3_BAD_DATE OR HIT_D4_YEAR OR HIT_W1_WEIGHT OR HIT_R1_BMI OR HIT_S1_STATE
   OR HIT_C1_SEX OR HIT_C1_AGE OR HIT_C1_EDUC OR HIT_C1_INCOME OR HIT_C1_GENHLTH
   OR HIT_C1_HLTHPLN OR HIT_C1_SMOKER OR HIT_C1_EXER OR HIT_C1_DIAB OR HIT_C1_BMICAT
   OR HIT_K1_DUP_PK);

-- ---- Publication gate checks, per year and combined ----

WITH BRONZE_BY_YEAR AS (
  SELECT SURVEY_YEAR, COUNT(*) AS BRONZE_ROWS FROM SILVER.STAGED_ALL GROUP BY SURVEY_YEAR
),
CLEAN_BY_YEAR AS (
  SELECT SURVEY_YEAR, COUNT(*) AS CLEAN_ROWS FROM SILVER.BRFSS_CLEAN GROUP BY SURVEY_YEAR
),
QUARANTINE_BY_YEAR AS (
  SELECT CAST(GET(PARSE_JSON(RAW_PAYLOAD), 'survey_year') AS INT) AS SURVEY_YEAR, COUNT(*) AS QUARANTINE_ROWS
  FROM SILVER.BRFSS_QUARANTINE GROUP BY 1
)
SELECT b.SURVEY_YEAR, b.BRONZE_ROWS,
       COALESCE(c.CLEAN_ROWS, 0) + COALESCE(q.QUARANTINE_ROWS, 0) AS CLEAN_PLUS_QUARANTINE
FROM BRONZE_BY_YEAR b
LEFT JOIN CLEAN_BY_YEAR c ON c.SURVEY_YEAR = b.SURVEY_YEAR
LEFT JOIN QUARANTINE_BY_YEAR q ON q.SURVEY_YEAR = b.SURVEY_YEAR
ORDER BY b.SURVEY_YEAR;

SELECT CAST(GET(PARSE_JSON(RAW_PAYLOAD), 'survey_year') AS INT) AS SURVEY_YEAR, COUNT(*) AS QUARANTINED
FROM SILVER.BRFSS_QUARANTINE GROUP BY 1 ORDER BY 1;
SELECT COUNT(*) FROM SILVER.BRFSS_QUARANTINE;

SELECT COUNT(*) - COUNT(DISTINCT STATE_FIPS || '|' || SURVEY_YEAR || '|' || SEQNO)
FROM SILVER.BRFSS_CLEAN;

SELECT SURVEY_YEAR, COUNT(*) FROM SILVER.BRFSS_CLEAN GROUP BY SURVEY_YEAR ORDER BY SURVEY_YEAR;
'''

with open(r"D:\data-lab2\sql\snowflake\03b_silver_multiyear.sql", "w", encoding="utf-8") as f:
    f.write(sql)
print("wrote sql/snowflake/03b_silver_multiyear.sql")

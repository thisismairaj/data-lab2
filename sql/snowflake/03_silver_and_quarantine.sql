-- Snowflake Phase 3: silver + quarantine, built from BRONZE.BRFSS_2015 (441,456 rows).
-- Direct translation of sql/databricks/03_silver_and_quarantine.sql - same rule IDs, same
-- valid-code lists (copied exactly, not re-typed from memory, so both platforms enforce
-- identical rules), same 4-stage shape. Differences below are Snowflake syntax only, not
-- logic changes:
--   * Databricks: to_date(...) returns NULL on failure. Snowflake: TO_DATE errors on
--     failure, so TRY_TO_DATE is the equivalent here.
--   * Databricks regex used double-quoted patterns (Spark SQL allows it); Snowflake
--     reserves double quotes for identifiers, so patterns are single-quoted, with '' for
--     a literal apostrophe (the b'...' wrapper).
--   * named_struct(...) -> OBJECT_CONSTRUCT(...), Snowflake's equivalent.
--   * Unquoted new column names come out UPPERCASE in Snowflake (its default), vs
--     Databricks' lowercase - a style difference, not a logic one. Bronze's source
--     columns stay quoted ("_STATE" etc.) because that's how they were created.
--
-- Same 4-stage shape as Databricks, same reason: K1 (duplicate key) needs a window
-- function that has to see the whole table at once, so it gets its own step.

USE DATABASE BRFSS;

CREATE OR REPLACE TABLE SILVER.STAGED AS
SELECT
  -- Z1 (correction): "_STATE" is text like '1.0' -> cast, zero-pad to 2 chars.
  LPAD(TO_VARCHAR(CAST(CAST("_STATE" AS DOUBLE) AS INT)), 2, '0')          AS STATE_FIPS,
  2015                                                                     AS SURVEY_YEAR,
  CAST(CAST("SEQNO" AS DOUBLE) AS BIGINT)                                  AS SEQNO,

  -- D1 (correction): strip the b'...' wrapper - '' is an escaped literal apostrophe.
  -- D2 (correction): a leading space means a missing leading zero, replace it with '0'.
  REGEXP_REPLACE("IDATE", '^b''|''$', '')                                 AS IDATE_STRIPPED,
  CASE WHEN REGEXP_REPLACE("IDATE", '^b''|''$', '') LIKE ' %'
       THEN CONCAT('0', SUBSTR(REGEXP_REPLACE("IDATE", '^b''|''$', ''), 2))
       ELSE REGEXP_REPLACE("IDATE", '^b''|''$', '')
  END                                                                      AS IDATE_PADDED,

  -- Bronze holds every code column as text (e.g. '3.0'); CAST to a real number. No range/
  -- validity check yet - that's C1, one step later, once every column has a number.
  CAST("SEX" AS DOUBLE)         AS SEX_CODE,
  CAST("_AGEG5YR" AS DOUBLE)    AS AGE_GROUP_CODE,
  CAST("EDUCA" AS DOUBLE)       AS EDUCATION_CODE,
  CAST("INCOME2" AS DOUBLE)     AS INCOME_CODE,
  CAST("GENHLTH" AS DOUBLE)     AS GENERAL_HEALTH_CODE,
  CAST("HLTHPLN1" AS DOUBLE)    AS HEALTH_PLAN_CODE,
  CAST("_SMOKER3" AS DOUBLE)    AS SMOKER_STATUS_CODE,
  CAST("EXERANY2" AS DOUBLE)    AS EXERCISE_ANY_CODE,
  CAST("DIABETE3" AS DOUBLE)    AS DIABETES_CODE,
  -- "_BMI5" is an integer with 2 implied decimals: '2750' means BMI 27.50. Not a
  -- correction (nothing was wrong) - just decoding the source's format.
  CAST("_BMI5" AS DOUBLE) / 100                                           AS BMI,
  CAST("_BMI5CAT" AS DOUBLE)    AS BMI_CATEGORY_CODE,
  -- "_LLCPWT": the survey weight - how many real adults this respondent stands in for.
  CAST("_LLCPWT" AS DOUBLE)     AS FINAL_WEIGHT,
  "_RUN_ID"                     AS BRONZE_RUN_ID
FROM BRONZE.BRFSS_2015;

CREATE OR REPLACE TABLE SILVER.CHECKED AS
SELECT *,
  -- TRY_TO_DATE returns NULL if the string isn't a real calendar date under this format
  -- (e.g. '09312015' - September has no 31st day) instead of erroring, same intent as
  -- Databricks' to_date: an unparseable date is quarantined, never guessed at.
  TRY_TO_DATE(IDATE_PADDED, 'MMDDYYYY')                                   AS INTERVIEW_DATE,

  -- ---- one boolean HIT_<rule> column per quarantine rule; a row can hit more than one ----
  (TRY_TO_DATE(IDATE_PADDED, 'MMDDYYYY') IS NULL)                         AS HIT_D3_BAD_DATE,
  (TRY_TO_DATE(IDATE_PADDED, 'MMDDYYYY') IS NOT NULL
     AND YEAR(TRY_TO_DATE(IDATE_PADDED, 'MMDDYYYY')) NOT IN (2015, 2016)) AS HIT_D4_YEAR,
  (FINAL_WEIGHT IS NULL OR FINAL_WEIGHT <= 0)                             AS HIT_W1_WEIGHT,
  -- R1: BMI outside 12.00-70.00, the range the user explicitly approved. BLANK (NULL) is
  -- not a hit - only implausible non-null values are.
  (BMI IS NOT NULL AND (BMI < 12 OR BMI > 70))                            AS HIT_R1_BMI,
  -- S1: same 53-code list as Databricks, copied exactly from codebook15_llcp.md (local notes).
  (STATE_FIPS NOT IN
    ('01','02','04','05','06','08','09','10','11','12','13','15','16','17','18','19',
     '20','21','22','23','24','25','26','27','28','29','30','31','32','33','34','35',
     '36','37','38','39','40','41','42','44','45','46','47','48','49','50','51','53',
     '54','55','56','66','72'))                                          AS HIT_S1_STATE,
  -- C1: each code column must be NULL or a code that exists in the codebook for that
  -- variable - same 10 columns, same valid sets as the Databricks build.
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
FROM SILVER.STAGED;

CREATE OR REPLACE TABLE SILVER.KEYED AS
SELECT *,
  -- K1: primary key is (STATE_FIPS, SURVEY_YEAR, SEQNO). SEQNO alone restarts per state,
  -- so it's not unique by itself. This window function counts how many rows share a key;
  -- >1 means a genuine duplicate, quarantined rather than picking an arbitrary winner.
  COUNT(*) OVER (PARTITION BY STATE_FIPS, SURVEY_YEAR, SEQNO) > 1         AS HIT_K1_DUP_PK
FROM SILVER.CHECKED;

-- Publish: quarantine = any rule hit. Same quarantine table shape as Databricks
-- (record_id, dataset_id, run_id, rule_id, severity, raw_payload, reason, status,
-- resolved_by) - schema_contract.md (local notes)'s spec, reusable for any dataset.
CREATE OR REPLACE TABLE SILVER.BRFSS_QUARANTINE AS
SELECT
  SEQNO AS RECORD_ID, 'brfss_2015' AS DATASET_ID, BRONZE_RUN_ID AS RUN_ID,
  -- BUG FOUND 2026-09-28: Snowflake's CONCAT_WS is NOT like Databricks/Spark's - it
  -- returns NULL if ANY argument is NULL, rather than skipping NULLs. Tested directly:
  -- CONCAT_WS(',', NULL, 'X', NULL) -> NULL in Snowflake (would be 'X' in Databricks).
  -- Real, useful platform difference, not just a typo. Fixed with Snowflake's actual
  -- NULL-dropping tool: ARRAY_CONSTRUCT_COMPACT (builds an array, drops NULL elements)
  -- + ARRAY_TO_STRING (joins with the separator) - verified this combination gives 'R1'
  -- or 'D3,R1' correctly, matching Databricks' concat_ws behavior exactly.
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
  -- OBJECT_CONSTRUCT is Snowflake's named_struct equivalent; TO_JSON serializes it.
  TO_JSON(OBJECT_CONSTRUCT('state_fips', STATE_FIPS, 'seqno', SEQNO,
                            'idate_raw', IDATE_STRIPPED, 'bmi', BMI,
                            'final_weight', FINAL_WEIGHT))                AS RAW_PAYLOAD,
  'Failed one or more contract rules - see rule_id' AS REASON,
  'new' AS STATUS, CAST(NULL AS VARCHAR) AS RESOLVED_BY
FROM SILVER.KEYED
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
  -- Always applied to every surviving row; D2 is noted separately when it actually fires.
  'D1_STRIP_BYTES,Z1_STATE_PAD' AS CORRECTIONS,
  BRONZE_RUN_ID AS RUN_ID
FROM SILVER.KEYED
WHERE NOT (HIT_D3_BAD_DATE OR HIT_D4_YEAR OR HIT_W1_WEIGHT OR HIT_R1_BMI OR HIT_S1_STATE
   OR HIT_C1_SEX OR HIT_C1_AGE OR HIT_C1_EDUC OR HIT_C1_INCOME OR HIT_C1_GENHLTH
   OR HIT_C1_HLTHPLN OR HIT_C1_SMOKER OR HIT_C1_EXER OR HIT_C1_DIAB OR HIT_C1_BMICAT
   OR HIT_K1_DUP_PK);

-- ---- Publication gate checks - same three as the Databricks file ----
SELECT (SELECT COUNT(*) FROM SILVER.BRFSS_CLEAN)
     + (SELECT COUNT(*) FROM SILVER.BRFSS_QUARANTINE) AS CLEAN_PLUS_QUARANTINE,
       (SELECT COUNT(*) FROM BRONZE.BRFSS_2015) AS BRONZE_ROWS;

SELECT COUNT(*) FROM SILVER.BRFSS_QUARANTINE;

SELECT COUNT(*) - COUNT(DISTINCT STATE_FIPS || '|' || SURVEY_YEAR || '|' || SEQNO)
FROM SILVER.BRFSS_CLEAN;

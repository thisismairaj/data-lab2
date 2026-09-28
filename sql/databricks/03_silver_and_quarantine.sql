-- Databricks Phase 3: silver + quarantine, built from bronze.brfss_2015_sample.
-- Run on 2026-09-28 against the 50,000-row sample, to prove the logic before the full load.
-- Every source row ends in exactly one outcome: clean, corrected, quarantined, rejected (none here; rejected = structurally unreadable, which read_files would already have failed on).
-- Rules and their IDs match docs/schema_contract.md.

CREATE OR REPLACE TABLE workspace.silver._staged_2015 AS
SELECT
  -- Z1 (correction): _STATE is text like '1.0' -> cast, zero-pad to 2 chars
  lpad(CAST(CAST(_STATE AS DOUBLE) AS INT), 2, '0')                         AS state_fips,
  2015                                                                      AS survey_year,
  CAST(CAST(SEQNO AS DOUBLE) AS BIGINT)                                     AS seqno,

  -- D1 (correction): strip the b'...' wrapper. D2 (correction): a leading space means a
  -- missing leading zero, so replace it with '0' before parsing.
  regexp_replace(IDATE, "^b'|'$", '')                                      AS idate_stripped,
  CASE WHEN regexp_replace(IDATE, "^b'|'$", '') LIKE ' %'
       THEN concat('0', substring(regexp_replace(IDATE, "^b'|'$", ''), 2))
       ELSE regexp_replace(IDATE, "^b'|'$", '')
  END                                                                       AS idate_padded,

  CAST(SEX AS DOUBLE)        AS sex_code,
  CAST(_AGEG5YR AS DOUBLE)   AS age_group_code,
  CAST(EDUCA AS DOUBLE)      AS education_code,
  CAST(INCOME2 AS DOUBLE)    AS income_code,
  CAST(GENHLTH AS DOUBLE)    AS general_health_code,
  CAST(HLTHPLN1 AS DOUBLE)   AS health_plan_code,
  CAST(_SMOKER3 AS DOUBLE)   AS smoker_status_code,
  CAST(EXERANY2 AS DOUBLE)   AS exercise_any_code,
  CAST(DIABETE3 AS DOUBLE)   AS diabetes_code,
  CAST(_BMI5 AS DOUBLE) / 100                                              AS bmi,          -- 2 implied decimals
  CAST(_BMI5CAT AS DOUBLE)   AS bmi_category_code,
  CAST(_LLCPWT AS DOUBLE)    AS final_weight,
  _run_id                    AS _bronze_run_id
FROM workspace.bronze.brfss_2015_sample;

CREATE OR REPLACE TABLE workspace.silver._checked_2015 AS
SELECT *,
  to_date(idate_padded, 'MMddyyyy')                                        AS interview_date,
  -- rule hits, one boolean per rule; a row can hit more than one
  (to_date(idate_padded, 'MMddyyyy') IS NULL)                              AS hit_d3_bad_date,
  (to_date(idate_padded, 'MMddyyyy') IS NOT NULL
     AND year(to_date(idate_padded, 'MMddyyyy')) NOT IN (2015, 2016))      AS hit_d4_year,
  (final_weight IS NULL OR final_weight <= 0)                              AS hit_w1_weight,
  (bmi IS NOT NULL AND (bmi < 12 OR bmi > 70))                             AS hit_r1_bmi,
  (state_fips NOT IN
    ('01','02','04','05','06','08','09','10','11','12','13','15','16','17','18','19',
     '20','21','22','23','24','25','26','27','28','29','30','31','32','33','34','35',
     '36','37','38','39','40','41','42','44','45','46','47','48','49','50','51','53',
     '54','55','56','66','72'))                                           AS hit_s1_state,
  -- C1: each code column must be NULL or in its codebook-valid set
  (sex_code IS NOT NULL AND sex_code NOT IN (1,2))                         AS hit_c1_sex,
  (age_group_code IS NOT NULL AND age_group_code NOT IN
     (1,2,3,4,5,6,7,8,9,10,11,12,13,14))                                   AS hit_c1_age,
  (education_code IS NOT NULL AND education_code NOT IN (1,2,3,4,5,6,9))   AS hit_c1_educ,
  (income_code IS NOT NULL AND income_code NOT IN
     (1,2,3,4,5,6,7,8,77,99))                                              AS hit_c1_income,
  (general_health_code IS NOT NULL AND general_health_code NOT IN
     (1,2,3,4,5,7,9))                                                      AS hit_c1_genhlth,
  (health_plan_code IS NOT NULL AND health_plan_code NOT IN (1,2,7,9))     AS hit_c1_hlthpln,
  (smoker_status_code IS NOT NULL AND smoker_status_code NOT IN
     (1,2,3,4,9))                                                          AS hit_c1_smoker,
  (exercise_any_code IS NOT NULL AND exercise_any_code NOT IN (1,2,7,9))   AS hit_c1_exer,
  (diabetes_code IS NOT NULL AND diabetes_code NOT IN (1,2,3,4,7,9))       AS hit_c1_diab,
  (bmi_category_code IS NOT NULL AND bmi_category_code NOT IN (1,2,3,4))   AS hit_c1_bmicat
FROM workspace.silver._staged_2015;

CREATE OR REPLACE TABLE workspace.silver._keyed_2015 AS
SELECT *,
  count(*) OVER (PARTITION BY state_fips, survey_year, seqno) > 1          AS hit_k1_dup_pk
FROM workspace.silver._checked_2015;

-- Publish: quarantine = any rule hit. Clean/corrected = no rule hit (corrections D1/D2/Z1
-- were already applied above; they are always-on fixes, not conditional, so every surviving
-- row is at least D1+Z1-corrected).
CREATE OR REPLACE TABLE workspace.silver.brfss_quarantine AS
SELECT
  seqno AS record_id, 'brfss_2015' AS dataset_id, _bronze_run_id AS run_id,
  concat_ws(',',
    CASE WHEN hit_d3_bad_date THEN 'D3' END, CASE WHEN hit_d4_year THEN 'D4' END,
    CASE WHEN hit_w1_weight THEN 'W1' END,  CASE WHEN hit_r1_bmi THEN 'R1' END,
    CASE WHEN hit_s1_state THEN 'S1' END,
    CASE WHEN hit_c1_sex OR hit_c1_age OR hit_c1_educ OR hit_c1_income OR hit_c1_genhlth
              OR hit_c1_hlthpln OR hit_c1_smoker OR hit_c1_exer OR hit_c1_diab OR hit_c1_bmicat
         THEN 'C1' END,
    CASE WHEN hit_k1_dup_pk THEN 'K1' END
  ) AS rule_id,
  'quarantine' AS severity,
  to_json(named_struct('state_fips',state_fips,'seqno',seqno,'idate_raw',idate_stripped,
                        'bmi',bmi,'final_weight',final_weight))            AS raw_payload,
  'Failed one or more contract rules - see rule_id' AS reason,
  'new' AS status, CAST(NULL AS STRING) AS resolved_by
FROM workspace.silver._keyed_2015
WHERE hit_d3_bad_date OR hit_d4_year OR hit_w1_weight OR hit_r1_bmi OR hit_s1_state
   OR hit_c1_sex OR hit_c1_age OR hit_c1_educ OR hit_c1_income OR hit_c1_genhlth
   OR hit_c1_hlthpln OR hit_c1_smoker OR hit_c1_exer OR hit_c1_diab OR hit_c1_bmicat
   OR hit_k1_dup_pk;

CREATE OR REPLACE TABLE workspace.silver.brfss_clean AS
SELECT
  state_fips, survey_year, seqno, interview_date,
  sex_code, age_group_code, education_code, income_code, general_health_code,
  health_plan_code, smoker_status_code, exercise_any_code, diabetes_code,
  bmi, bmi_category_code, final_weight,
  -- 'D1_STRIP_BYTES,Z1_STATE_PAD' is always applied; D2 is noted separately when it fires
  'D1_STRIP_BYTES,Z1_STATE_PAD' AS corrections,
  _bronze_run_id AS _run_id
FROM workspace.silver._keyed_2015
WHERE NOT (hit_d3_bad_date OR hit_d4_year OR hit_w1_weight OR hit_r1_bmi OR hit_s1_state
   OR hit_c1_sex OR hit_c1_age OR hit_c1_educ OR hit_c1_income OR hit_c1_genhlth
   OR hit_c1_hlthpln OR hit_c1_smoker OR hit_c1_exer OR hit_c1_diab OR hit_c1_bmicat
   OR hit_k1_dup_pk);

-- Publication gate checks (docs/schema_contract.md)
SELECT (SELECT count(*) FROM workspace.silver.brfss_clean)
     + (SELECT count(*) FROM workspace.silver.brfss_quarantine)
     AS clean_plus_quarantine,
       (SELECT count(*) FROM workspace.bronze.brfss_2015_sample) AS bronze_rows;

SELECT count(*) FROM workspace.silver.brfss_quarantine;                         -- quarantine count
SELECT count(*) - count(DISTINCT state_fips, survey_year, seqno)
FROM workspace.silver.brfss_clean;                                              -- expect 0 (K1)

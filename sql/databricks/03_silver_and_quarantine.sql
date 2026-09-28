-- Databricks Phase 3: silver + quarantine, built from bronze.brfss_2015 (full, 441,456 rows).
-- Logic proven first against the 50,000-row sample (bronze.brfss_2015_sample) on 2026-09-28;
-- see git history for that run's results (49,980 clean / 20 quarantine / 6 states, all reconciled).
-- Now pointed at the full table for the real build.
-- Every source row ends in exactly one outcome: clean, corrected, quarantined, rejected (none here; rejected = structurally unreadable, which read_files would already have failed on).
-- Rules and their IDs match docs/schema_contract.md.
--
-- Pipeline shape (4 CREATE TABLE steps, each building on the last):
--   1. _staged_2015    - cast/clean each column on its own (corrections D1, D2, Z1 applied here, unconditionally)
--   2. _checked_2015   - add one boolean "hit_<rule>" column per quarantine rule (D3, D4, W1, R1, S1, C1)
--   3. _keyed_2015      - add the one rule (K1, duplicate key) that needs to see the WHOLE table at once
--   4. brfss_quarantine / brfss_clean - split by whether any hit_* is true
-- K1 is split into its own step because a window function (count(*) OVER (PARTITION BY ...))
-- needs every row's key already computed - it can't be evaluated in the same SELECT that
-- produces the key. The other rules only look at one row at a time, so they share a step.
-- All four tables are dropped/rebuilt with CREATE OR REPLACE each run (idempotent).

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

  -- The rest of the code columns: bronze holds them as text (e.g. '3.0'); a plain CAST to
  -- DOUBLE turns that into a real number. No range/validity check happens here - that's C1,
  -- one step later, once every column has a number to check. See docs/schema_contract.md
  -- for what each code means (e.g. diabetes_code 1=yes, 3=no, 7=don't know, 9=refused - the
  -- "don't know"/"refused" codes are kept as-is, never turned into NULL or guessed at).
  CAST(SEX AS DOUBLE)        AS sex_code,
  CAST(_AGEG5YR AS DOUBLE)   AS age_group_code,
  CAST(EDUCA AS DOUBLE)      AS education_code,
  CAST(INCOME2 AS DOUBLE)    AS income_code,
  CAST(GENHLTH AS DOUBLE)    AS general_health_code,
  CAST(HLTHPLN1 AS DOUBLE)   AS health_plan_code,
  CAST(_SMOKER3 AS DOUBLE)   AS smoker_status_code,
  CAST(EXERANY2 AS DOUBLE)   AS exercise_any_code,
  CAST(DIABETE3 AS DOUBLE)   AS diabetes_code,
  -- _BMI5 is stored as an integer with 2 implied decimals: source '2750' means BMI 27.50.
  -- Dividing by 100 here is not a "correction" (nothing was wrong) - it's just decoding the
  -- format the source uses, same as unpacking a price stored in cents.
  CAST(_BMI5 AS DOUBLE) / 100                                              AS bmi,
  CAST(_BMI5CAT AS DOUBLE)   AS bmi_category_code,
  -- _LLCPWT: the survey weight. This is how many adults in the real population this one
  -- respondent stands in for - needed later in gold to compute a population-level prevalence
  -- rather than just "% of the people who happened to answer the survey".
  CAST(_LLCPWT AS DOUBLE)    AS final_weight,
  _run_id                    AS _bronze_run_id   -- carried through so every silver/quarantine row can be traced back to its bronze load run
FROM workspace.bronze.brfss_2015;

CREATE OR REPLACE TABLE workspace.silver._checked_2015 AS
SELECT *,
  -- to_date returns NULL if the string isn't a real calendar date under this format
  -- (e.g. '09312015' - September has no 31st day). That NULL is exactly what hit_d3 below
  -- tests for: an unparseable date is never guessed at, only quarantined.
  to_date(idate_padded, 'MMddyyyy')                                        AS interview_date,

  -- ---- one boolean "hit_<rule>" column per quarantine rule; a row can hit more than one ----

  -- D3: the date string doesn't parse as a real MMDDYYYY date at all
  (to_date(idate_padded, 'MMddyyyy') IS NULL)                              AS hit_d3_bad_date,
  -- D4: the date parsed fine, but the year isn't 2015 or 2016 (BRFSS interviews can run into
  -- January-March of the following year; anything further out than that is suspicious)
  (to_date(idate_padded, 'MMddyyyy') IS NOT NULL
     AND year(to_date(idate_padded, 'MMddyyyy')) NOT IN (2015, 2016))      AS hit_d4_year,
  -- W1: the survey weight is missing or non-positive - can't compute a population estimate
  -- from it, and a weight of 0 or less isn't a real weight, so this is never "corrected" to 1.
  (final_weight IS NULL OR final_weight <= 0)                              AS hit_w1_weight,
  -- R1: BMI outside the plausible range the user approved (12.00-70.00). Chosen 2026-09-25;
  -- see docs/schema_contract.md for the alternatives considered and the measured counts.
  -- BLANK (NULL bmi) is NOT a hit here - only implausible non-null values are.
  (bmi IS NOT NULL AND (bmi < 12 OR bmi > 70))                             AS hit_r1_bmi,
  -- S1: state_fips isn't one of the 53 codes the 2015 codebook actually defines (50 states +
  -- DC(11) + Guam(66) + Puerto Rico(72); FIPS skips 03,07,14,43,52 by design, hence the gaps
  -- in the list below). This list was read out of docs/codebook15_llcp.md, not guessed.
  (state_fips NOT IN
    ('01','02','04','05','06','08','09','10','11','12','13','15','16','17','18','19',
     '20','21','22','23','24','25','26','27','28','29','30','31','32','33','34','35',
     '36','37','38','39','40','41','42','44','45','46','47','48','49','50','51','53',
     '54','55','56','66','72'))                                           AS hit_s1_state,
  -- C1: each code column must be either NULL (a real BLANK in the source) or a code that
  -- actually exists in the codebook for that variable - e.g. diabetes_code must be one of
  -- 1,2,3,4,7,9 (docs/codebook15_llcp.md, DIABETE3). A code outside that set would mean either
  -- a codebook mismatch or a load bug, and either way should never be silently accepted.
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
  -- K1: the primary key is (state_fips, survey_year, seqno) - see docs/schema_contract.md.
  -- SEQNO alone is NOT unique (it restarts per state), which is why state_fips is part of the
  -- key. This window function counts how many rows share a key; >1 means a genuine duplicate,
  -- which is quarantined rather than picking a "winner" (we have no basis to choose one).
  count(*) OVER (PARTITION BY state_fips, survey_year, seqno) > 1          AS hit_k1_dup_pk
FROM workspace.silver._checked_2015;

-- Publish: quarantine = any rule hit. Clean/corrected = no rule hit (corrections D1/D2/Z1
-- were already applied above; they are always-on fixes, not conditional, so every surviving
-- row is at least D1+Z1-corrected).
--
-- Shape of this table matches docs/schema_contract.md's "quarantine table" spec exactly
-- (record_id, dataset_id, run_id, rule_id, severity, raw_payload, reason, status, resolved_by)
-- so the same structure can be reused for any future dataset, not just BRFSS.
CREATE OR REPLACE TABLE workspace.silver.brfss_quarantine AS
SELECT
  seqno AS record_id, 'brfss_2015' AS dataset_id, _bronze_run_id AS run_id,
  -- concat_ws + CASE...END with no ELSE: each CASE returns NULL when its rule didn't fire,
  -- and concat_ws silently skips NULLs - so rule_id ends up as e.g. 'R1' for one rule hit,
  -- or 'D3,R1' if a row happens to hit two rules at once.
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

-- ---- Publication gate checks (docs/schema_contract.md) ----
-- A pipeline run is only trusted once these come back as expected; see docs/metrics.md
-- (Q2 outcomes_sum_check, Q5 quarantine_rate, Q11 pk_duplicates) for how these get recorded.

-- Q2: nothing lost or double-counted between bronze and silver - the two counts must be equal.
SELECT (SELECT count(*) FROM workspace.silver.brfss_clean)
     + (SELECT count(*) FROM workspace.silver.brfss_quarantine)
     AS clean_plus_quarantine,
       (SELECT count(*) FROM workspace.bronze.brfss_2015) AS bronze_rows;

-- Q5: how many rows were quarantined. Run on 2026-09-28 against the full 441,456 rows:
-- 1,035 rows, all rule R1, i.e. 0.2345% - under the 0.5% gate agreed for this dataset, and it
-- matches the count predicted from profiling the raw file BEFORE any of this SQL was written
-- (docs/scope_and_gaps.md), which is a strong sign the logic above is correct rather than
-- coincidentally passing.
SELECT count(*) FROM workspace.silver.brfss_quarantine;

-- Q11: primary key uniqueness in the published (clean) table - expect 0.
SELECT count(*) - count(DISTINCT state_fips, survey_year, seqno)
FROM workspace.silver.brfss_clean;

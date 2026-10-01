"""Generates sql/databricks/03b_silver_multiyear.sql: the 5-year version of
03_silver_and_quarantine.sql. Same rule set, same column casts, same publication-gate
checks - the only real change is a per-year _staged_YYYY step (since each year is its
own bronze table with its own schema) unioned together before _checked/_keyed/publish.

Verified before generating (see chat): all 15 core columns used below exist under the
same name in every year's real CSV header (2011-2015); BPHIGH4/TOLDHI2 (used later in
the comorbidity gold table, not here) are the only gaps, missing in 2012 and 2014 -
already known and already handled downstream the same way the Trial/Lakeflow build
handles it (NULL for years without the column).
"""
YEARS = [2011, 2012, 2013, 2014, 2015]

staged_blocks = []
for y in YEARS:
    staged_blocks.append(f'''CREATE OR REPLACE TABLE workspace.silver._staged_{y} AS
SELECT
  lpad(CAST(CAST(_STATE AS DOUBLE) AS INT), 2, '0')                         AS state_fips,
  {y}                                                                       AS survey_year,
  CAST(CAST(SEQNO AS DOUBLE) AS BIGINT)                                     AS seqno,
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
  CAST(_BMI5 AS DOUBLE) / 100                                              AS bmi,
  CAST(_BMI5CAT AS DOUBLE)   AS bmi_category_code,
  CAST(_LLCPWT AS DOUBLE)    AS final_weight,
  _run_id                    AS _bronze_run_id
FROM workspace.bronze.brfss_{y};''')

union_sql = "CREATE OR REPLACE TABLE workspace.silver._staged_all AS\n" + "\nUNION ALL\n".join(
    f"SELECT * FROM workspace.silver._staged_{y}" for y in YEARS
) + ";"

sql = f'''-- Databricks Free Edition: 5-year silver + quarantine (2011-2015), supersedes the
-- 2015-only 03_silver_and_quarantine.sql (kept in git history as the proof-of-concept
-- run). Same rule set, same column casts (schema_contract.md (local notes)) - the only change is
-- a per-year staging step (each year is its own bronze table, different source schema)
-- unioned together before the shared _checked/_keyed/publish logic, which is otherwise
-- untouched from the 2015-only version.
--
-- K1 (duplicate primary key) is PARTITION BY (state_fips, survey_year, seqno) - already
-- year-scoped in the single-year version, so this generalizes to multi-year with no
-- change: SEQNO restarts per state per year, not globally, so survey_year has to be
-- part of the key or 2011's seqno=1 in Alabama would collide with 2012's seqno=1 in
-- Alabama, which are two different real people.

-- ---- Step 1: per-year staging (cast + D1/D2/Z1 corrections), one block per bronze table ----

{chr(10).join(staged_blocks)}

-- ---- Step 2: union all 5 years into one staged table ----

{union_sql}

-- ---- Step 3: checked (add hit_<rule> flags) - identical logic to the 2015-only version ----

CREATE OR REPLACE TABLE workspace.silver._checked_all AS
SELECT *,
  -- try_to_date, not to_date: this runtime's ANSI mode makes to_date THROW on an
  -- unparseable date (e.g. '09312011' - September has no 31st) instead of returning
  -- NULL, which would crash the whole CREATE TABLE the moment 2011 (63 such rows) is
  -- in scope. try_to_date returns NULL on a bad date, which is exactly what hit_d3
  -- below needs - the 2015-only build never hit this because 2015 has no impossible
  -- dates (see scope_and_gaps.md (local notes) for the per-year counts: 63/1/0/9/0).
  try_to_date(idate_padded, 'MMddyyyy')                                    AS interview_date,
  (try_to_date(idate_padded, 'MMddyyyy') IS NULL)                          AS hit_d3_bad_date,
  -- D4: year must be the survey year or the following year (interviews can run into
  -- Jan-Mar of the next year - see scope_and_gaps.md (local notes)). Generalized from a hardcoded
  -- (2015,2016) to (survey_year, survey_year+1) so this rule means the same thing for
  -- every year, not just 2015.
  (try_to_date(idate_padded, 'MMddyyyy') IS NOT NULL
     AND year(try_to_date(idate_padded, 'MMddyyyy')) NOT IN (survey_year, survey_year + 1)) AS hit_d4_year,
  (final_weight IS NULL OR final_weight <= 0)                              AS hit_w1_weight,
  (bmi IS NOT NULL AND (bmi < 12 OR bmi > 70))                             AS hit_r1_bmi,
  (state_fips NOT IN
    ('01','02','04','05','06','08','09','10','11','12','13','15','16','17','18','19',
     '20','21','22','23','24','25','26','27','28','29','30','31','32','33','34','35',
     '36','37','38','39','40','41','42','44','45','46','47','48','49','50','51','53',
     '54','55','56','66','72'))                                           AS hit_s1_state,
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
FROM workspace.silver._staged_all;

-- ---- Step 4: keyed (K1, needs the whole table - see note above) ----

CREATE OR REPLACE TABLE workspace.silver._keyed_all AS
SELECT *,
  count(*) OVER (PARTITION BY state_fips, survey_year, seqno) > 1          AS hit_k1_dup_pk
FROM workspace.silver._checked_all;

-- ---- Step 5: publish (same shape as the 2015-only version) ----

CREATE OR REPLACE TABLE workspace.silver.brfss_quarantine AS
SELECT
  seqno AS record_id, concat('brfss_', survey_year) AS dataset_id, _bronze_run_id AS run_id,
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
  to_json(named_struct('state_fips',state_fips,'survey_year',survey_year,'seqno',seqno,
                        'idate_raw',idate_stripped,'bmi',bmi,'final_weight',final_weight)) AS raw_payload,
  'Failed one or more contract rules - see rule_id' AS reason,
  'new' AS status, CAST(NULL AS STRING) AS resolved_by
FROM workspace.silver._keyed_all
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
  'D1_STRIP_BYTES,Z1_STATE_PAD' AS corrections,
  _bronze_run_id AS _run_id
FROM workspace.silver._keyed_all
WHERE NOT (hit_d3_bad_date OR hit_d4_year OR hit_w1_weight OR hit_r1_bmi OR hit_s1_state
   OR hit_c1_sex OR hit_c1_age OR hit_c1_educ OR hit_c1_income OR hit_c1_genhlth
   OR hit_c1_hlthpln OR hit_c1_smoker OR hit_c1_exer OR hit_c1_diab OR hit_c1_bmicat
   OR hit_k1_dup_pk);

-- ---- Publication gate checks, per year and combined (metrics.md (local notes) Q2, Q5, Q11) ----

-- Q2 per year: bronze count must equal clean+quarantine for that year, for every year
-- (not just the total - a year-by-year check catches a bug that only affects one year,
-- which a combined-total check could hide if errors happened to cancel out). Written as
-- three independent per-year aggregates joined together, not correlated subqueries in
-- the SELECT list (Spark rejected that: SCALAR_SUBQUERY_IS_IN_GROUP_BY_OR_AGGREGATE_FUNCTION).
WITH bronze_by_year AS (
  SELECT survey_year, count(*) AS bronze_rows FROM workspace.silver._staged_all GROUP BY survey_year
),
clean_by_year AS (
  SELECT survey_year, count(*) AS clean_rows FROM workspace.silver.brfss_clean GROUP BY survey_year
),
quarantine_by_year AS (
  SELECT CAST(get_json_object(raw_payload, '$.survey_year') AS INT) AS survey_year, count(*) AS quarantine_rows
  FROM workspace.silver.brfss_quarantine GROUP BY 1
)
SELECT b.survey_year, b.bronze_rows,
       COALESCE(c.clean_rows, 0) + COALESCE(q.quarantine_rows, 0) AS clean_plus_quarantine
FROM bronze_by_year b
LEFT JOIN clean_by_year c ON c.survey_year = b.survey_year
LEFT JOIN quarantine_by_year q ON q.survey_year = b.survey_year
ORDER BY b.survey_year;

-- Q5: quarantine count and rate, per year and total
SELECT CAST(get_json_object(raw_payload, '$.survey_year') AS INT) AS survey_year, count(*) AS quarantined
FROM workspace.silver.brfss_quarantine GROUP BY 1 ORDER BY 1;
SELECT count(*) FROM workspace.silver.brfss_quarantine;                          -- total across all 5 years

-- Q11: primary key uniqueness in the published (clean) table - expect 0
SELECT count(*) - count(DISTINCT state_fips, survey_year, seqno)
FROM workspace.silver.brfss_clean;

-- Row count by year in the published clean table - sanity check against
-- scope_and_gaps.md (local notes)'s known per-year totals (506467/475687/491773/464664/441456)
SELECT survey_year, count(*) FROM workspace.silver.brfss_clean GROUP BY survey_year ORDER BY survey_year;
'''

with open(r"D:\data-lab2\sql\databricks\03b_silver_multiyear.sql", "w", encoding="utf-8") as f:
    f.write(sql)
print("wrote sql/databricks/03b_silver_multiyear.sql")

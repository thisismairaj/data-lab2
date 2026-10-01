"""Generates the 5-year versions of the 5 gold tables that don't already group by
survey_year (04_gold.sql, the state table, already does and needs no change).

06b/07b/08b are near-identical to their single-year originals, plus survey_year in the
SELECT/GROUP BY/ORDER BY. 09b (comorbidity) is the one genuinely new piece of logic: it
joins silver back to bronze for 10 extra columns, and bronze is now 5 separate tables
(one per year, different schemas) instead of one - so this generator first builds a
bronze_all view that UNIONs all 5 years, filling NULL for BPHIGH4/TOLDHI2 in the 2 years
that don't have them (2012, 2014 - verified earlier in this chat directly against each
year's real CSV header). 10b just adds survey_year like 06b/07b/08b.
"""
YEARS = [2011, 2012, 2013, 2014, 2015]
COMORBID_COLS = ["BPHIGH4", "TOLDHI2", "CVDINFR4", "CVDCRHD4", "CVDSTRK3",
                  "ADDEPEV2", "CHCKIDNY", "ASTHMA3", "MEDCOST", "PERSDOC2"]
# Confirmed by checking each year's real CSV header earlier in this session.
MISSING = {2012: {"BPHIGH4", "TOLDHI2"}, 2014: {"BPHIGH4", "TOLDHI2"}}

# ---- 06b/07b/08b: simple survey_year addition to the 3 category breakdowns ----------
simple_specs = [
    ("06b_gold_age_group_multiyear.sql", "diabetes_prevalence_age_group", "age_group_code",
     "a.label AS age_group_label", "_AGEG5YR",
     "CAST(CAST(c.age_group_code AS INT) AS STRING)", None, "c.age_group_code"),
    ("07b_gold_smoking_multiyear.sql", "diabetes_prevalence_smoking", "smoker_status_code",
     "CASE WHEN c.smoker_status_code IS NULL THEN 'Unknown (not captured)' ELSE a.label END AS smoking_label",
     "_SMOKER3", "CAST(CAST(c.smoker_status_code AS INT) AS STRING)", None, "c.smoker_status_code"),
    ("08b_gold_bmi_category_multiyear.sql", "diabetes_prevalence_bmi_category", "bmi_category_code",
     "CASE WHEN c.bmi_category_code IS NULL THEN 'Unknown (BMI not available)' ELSE a.label END AS bmi_category_label",
     "_BMI5CAT", "CAST(CAST(c.bmi_category_code AS INT) AS STRING)", None, "c.bmi_category_code"),
]

for fname, table, code_col, label_expr, codebook_var, join_cast, _, order_col in simple_specs:
    label_alias = label_expr.split(" AS ")[-1]
    sql = f'''-- Databricks: gold.{table}, 5-year version of {fname.replace("b_", "_").replace("_multiyear", "")}.
-- Same logic, survey_year added to SELECT/GROUP BY/ORDER BY so each year is its own row
-- per {code_col} instead of blending all 5 years into one.

CREATE OR REPLACE TABLE workspace.gold.{table} AS
SELECT
  c.{code_col},
  c.survey_year,
  {label_expr},
  count(*) FILTER (WHERE c.diabetes_code IN (1,2,3,4))            AS valid_respondents,
  count(*) FILTER (WHERE c.diabetes_code = 1)                     AS diabetes_yes,
  sum(c.final_weight) FILTER (WHERE c.diabetes_code = 1)          AS weighted_yes_sum,
  sum(c.final_weight) FILTER (WHERE c.diabetes_code IN (1,2,3,4)) AS weighted_valid_sum,
  100.0 * sum(c.final_weight) FILTER (WHERE c.diabetes_code = 1)
        / sum(c.final_weight) FILTER (WHERE c.diabetes_code IN (1,2,3,4))       AS prevalence_weighted_pct,
  100.0 * count(*) FILTER (WHERE c.diabetes_code = 1)
        / count(*) FILTER (WHERE c.diabetes_code IN (1,2,3,4))                  AS prevalence_unweighted_pct,
  count(*) FILTER (WHERE c.diabetes_code IN (7,9) OR c.diabetes_code IS NULL)   AS excluded_dont_know_refused_blank
FROM workspace.silver.brfss_clean c
LEFT JOIN workspace.ref.codebook_values a
  ON a.variable = '{codebook_var}' AND a.code = {join_cast}
GROUP BY c.{code_col}, c.survey_year, a.label
ORDER BY c.survey_year, {order_col};

-- ---- Verification ----
SELECT survey_year, count(*) FROM workspace.gold.{table} GROUP BY survey_year ORDER BY 1;
SELECT count(*) FROM workspace.gold.{table} WHERE {label_alias} IS NULL;                 -- expect 0
-- Per-year total must match silver's per-year row count (scope_and_gaps.md (local notes) known totals)
SELECT survey_year, sum(valid_respondents) + sum(excluded_dont_know_refused_blank) AS total
FROM workspace.gold.{table} GROUP BY survey_year ORDER BY survey_year;
SELECT survey_year, count(*) FROM workspace.silver.brfss_clean GROUP BY survey_year ORDER BY survey_year;
-- National trend across years (sanity check vs the Trial/Lakeflow build's own finding:
-- 9.8% (2011) -> 10.18% -> 10.27% -> 10.54% -> 10.5% (2015))
SELECT survey_year, round(100.0*sum(weighted_yes_sum)/sum(weighted_valid_sum), 2) AS national_pct
FROM workspace.gold.{table} GROUP BY survey_year ORDER BY survey_year;
'''
    with open(rf"D:\data-lab2\sql\databricks\{fname}", "w", encoding="utf-8") as f:
        f.write(sql)
    print("wrote", fname)

# ---- 09b: comorbidity, the one with real new logic (bronze union across 5 schemas) --
bronze_selects = []
for y in YEARS:
    cols = []
    for c in COMORBID_COLS:
        if c in MISSING.get(y, set()):
            cols.append(f"CAST(NULL AS STRING) AS {c}")
        else:
            cols.append(c)
    select_cols = ", ".join(["_STATE", "SEQNO"] + cols)
    bronze_selects.append(
        f"  SELECT {select_cols}, {y} AS survey_year FROM workspace.bronze.brfss_{y}"
    )
bronze_union = "\nUNION ALL\n".join(bronze_selects)

comorbid_sql = f'''-- Databricks: gold.diabetes_comorbidity, 5-year version of 09_gold_comorbidity.sql.
-- Same logic (join silver back to bronze for 10 extra condition columns not in the core
-- 18-column contract), extended two ways for multi-year:
--   1. bronze is now 5 tables with different schemas, not 1 - bronze_all below UNIONs
--      them, filling NULL for BPHIGH4/TOLDHI2 in the 2 years that never had those columns
--      (2012, 2014 - confirmed directly against each year's real CSV header, not assumed).
--      This is the same gap already found and handled the same way on the Trial/Lakeflow
--      build - NULL for years without the column, which the has_condition CASE already
--      treats as "unknown", excluded from that condition's own denominator.
--   2. The join key adds survey_year: SEQNO restarts per state PER YEAR, not just per
--      state, so (state_fips, seqno) alone would collide across years - same fix as the
--      Trial/Lakeflow build's comorbidity join (there disambiguated via _source_file).

CREATE OR REPLACE TABLE workspace.gold.diabetes_comorbidity AS
WITH bronze_all AS (
{bronze_union}
),
base AS (
  SELECT
    c.diabetes_code, c.final_weight, c.survey_year,
    CAST(b.BPHIGH4  AS DOUBLE) AS bphigh4,
    CAST(b.TOLDHI2  AS DOUBLE) AS toldhi2,
    CAST(b.CVDINFR4 AS DOUBLE) AS cvdinfr4,
    CAST(b.CVDCRHD4 AS DOUBLE) AS cvdcrhd4,
    CAST(b.CVDSTRK3 AS DOUBLE) AS cvdstrk3,
    CAST(b.ADDEPEV2 AS DOUBLE) AS addepev2,
    CAST(b.CHCKIDNY AS DOUBLE) AS chckidny,
    CAST(b.ASTHMA3  AS DOUBLE) AS asthma3,
    CAST(b.MEDCOST  AS DOUBLE) AS medcost,
    CAST(b.PERSDOC2 AS DOUBLE) AS persdoc2
  FROM workspace.silver.brfss_clean c
  JOIN bronze_all b
    ON CAST(CAST(b._STATE AS DOUBLE) AS INT) = CAST(c.state_fips AS INT)
   AND CAST(CAST(b.SEQNO  AS DOUBLE) AS BIGINT) = c.seqno
   AND b.survey_year = c.survey_year
),
grouped AS (
  SELECT *,
    CASE WHEN diabetes_code = 1      THEN 'Diabetic'
         WHEN diabetes_code IN (3,4) THEN 'Non-diabetic'
         ELSE NULL END AS diabetes_group
  FROM base
),
unpivoted AS (
  SELECT survey_year, diabetes_group, final_weight, 'high_blood_pressure' AS condition, 'Has high blood pressure' AS condition_label,
    CASE WHEN bphigh4 = 1 THEN 1 WHEN bphigh4 IN (3,4) THEN 0 END AS has_condition
  FROM grouped WHERE diabetes_group IS NOT NULL
  UNION ALL
  SELECT survey_year, diabetes_group, final_weight, 'high_cholesterol', 'Has high cholesterol',
    CASE WHEN toldhi2 = 1 THEN 1 WHEN toldhi2 = 2 THEN 0 END
  FROM grouped WHERE diabetes_group IS NOT NULL
  UNION ALL
  SELECT survey_year, diabetes_group, final_weight, 'heart_attack', 'Had a heart attack',
    CASE WHEN cvdinfr4 = 1 THEN 1 WHEN cvdinfr4 = 2 THEN 0 END
  FROM grouped WHERE diabetes_group IS NOT NULL
  UNION ALL
  SELECT survey_year, diabetes_group, final_weight, 'coronary_heart_disease', 'Has coronary heart disease',
    CASE WHEN cvdcrhd4 = 1 THEN 1 WHEN cvdcrhd4 = 2 THEN 0 END
  FROM grouped WHERE diabetes_group IS NOT NULL
  UNION ALL
  SELECT survey_year, diabetes_group, final_weight, 'stroke', 'Had a stroke',
    CASE WHEN cvdstrk3 = 1 THEN 1 WHEN cvdstrk3 = 2 THEN 0 END
  FROM grouped WHERE diabetes_group IS NOT NULL
  UNION ALL
  SELECT survey_year, diabetes_group, final_weight, 'depression', 'Has depression',
    CASE WHEN addepev2 = 1 THEN 1 WHEN addepev2 = 2 THEN 0 END
  FROM grouped WHERE diabetes_group IS NOT NULL
  UNION ALL
  SELECT survey_year, diabetes_group, final_weight, 'kidney_disease', 'Has kidney disease',
    CASE WHEN chckidny = 1 THEN 1 WHEN chckidny = 2 THEN 0 END
  FROM grouped WHERE diabetes_group IS NOT NULL
  UNION ALL
  SELECT survey_year, diabetes_group, final_weight, 'asthma', 'Has asthma',
    CASE WHEN asthma3 = 1 THEN 1 WHEN asthma3 = 2 THEN 0 END
  FROM grouped WHERE diabetes_group IS NOT NULL
  UNION ALL
  SELECT survey_year, diabetes_group, final_weight, 'cost_barrier', 'Skipped care due to cost',
    CASE WHEN medcost = 1 THEN 1 WHEN medcost = 2 THEN 0 END
  FROM grouped WHERE diabetes_group IS NOT NULL
  UNION ALL
  SELECT survey_year, diabetes_group, final_weight, 'no_personal_doctor', 'No personal doctor',
    CASE WHEN persdoc2 = 3 THEN 1 WHEN persdoc2 IN (1,2) THEN 0 END
  FROM grouped WHERE diabetes_group IS NOT NULL
)
SELECT
  survey_year, condition, condition_label, diabetes_group,
  count(*) FILTER (WHERE has_condition IN (0,1))                AS valid_respondents,
  count(*) FILTER (WHERE has_condition = 1)                     AS condition_yes_n,
  sum(final_weight) FILTER (WHERE has_condition = 1)            AS weighted_yes_sum,
  sum(final_weight) FILTER (WHERE has_condition IN (0,1))       AS weighted_valid_sum,
  100.0 * sum(final_weight) FILTER (WHERE has_condition = 1)
        / sum(final_weight) FILTER (WHERE has_condition IN (0,1))  AS condition_pct_weighted
FROM unpivoted
GROUP BY survey_year, condition, condition_label, diabetes_group;

-- ---- Verification ----
-- The bronze join must be exactly 1:1 per year - equal to silver.brfss_clean's own per-year count.
SELECT survey_year, count(*) FROM (
  SELECT c.survey_year, c.state_fips, c.seqno FROM workspace.silver.brfss_clean c
  JOIN (
{bronze_union}
  ) b
    ON CAST(CAST(b._STATE AS DOUBLE) AS INT) = CAST(c.state_fips AS INT)
   AND CAST(CAST(b.SEQNO  AS DOUBLE) AS BIGINT) = c.seqno
   AND b.survey_year = c.survey_year
) GROUP BY survey_year ORDER BY survey_year;
SELECT survey_year, count(*) FROM workspace.silver.brfss_clean GROUP BY survey_year ORDER BY survey_year;

-- Confirm BPHIGH4/TOLDHI2 show as having NO rows for 2012/2014 (correctly excluded, not silently zero)
SELECT survey_year, count(*) FROM workspace.gold.diabetes_comorbidity
WHERE condition IN ('high_blood_pressure','high_cholesterol') GROUP BY survey_year ORDER BY 1;

SELECT count(DISTINCT condition) FROM workspace.gold.diabetes_comorbidity;   -- expect 10
'''
with open(r"D:\data-lab2\sql\databricks\09b_gold_comorbidity_multiyear.sql", "w", encoding="utf-8") as f:
    f.write(comorbid_sql)
print("wrote 09b_gold_comorbidity_multiyear.sql")

# ---- 10b: risk stacking, simple survey_year addition ---------------------------------
risk_sql = '''-- Databricks: gold.diabetes_risk_stacking, 5-year version of 10_gold_risk_stacking.sql.
-- Same binary-flag logic, survey_year added to SELECT/GROUP BY - no bronze re-touch
-- needed (all 3 source columns already live in silver.brfss_clean for every year).

CREATE OR REPLACE TABLE workspace.gold.diabetes_risk_stacking AS
WITH flagged AS (
  SELECT
    survey_year,
    CASE WHEN bmi_category_code = 4 THEN 1 WHEN bmi_category_code IN (1,2,3) THEN 0 END AS obese_flag,
    CASE WHEN smoker_status_code IN (1,2) THEN 1 WHEN smoker_status_code IN (3,4) THEN 0 END AS smoker_flag,
    CASE WHEN exercise_any_code = 2 THEN 1 WHEN exercise_any_code = 1 THEN 0 END AS inactive_flag,
    diabetes_code, final_weight
  FROM workspace.silver.brfss_clean
)
SELECT
  survey_year, obese_flag, smoker_flag, inactive_flag,
  obese_flag + smoker_flag + inactive_flag AS risk_factor_count,
  count(*) FILTER (WHERE diabetes_code IN (1,2,3,4))            AS valid_respondents,
  count(*) FILTER (WHERE diabetes_code = 1)                     AS diabetes_yes,
  sum(final_weight) FILTER (WHERE diabetes_code = 1)            AS weighted_yes_sum,
  sum(final_weight) FILTER (WHERE diabetes_code IN (1,2,3,4))   AS weighted_valid_sum,
  100.0 * sum(final_weight) FILTER (WHERE diabetes_code = 1)
        / sum(final_weight) FILTER (WHERE diabetes_code IN (1,2,3,4))       AS prevalence_weighted_pct,
  100.0 * count(*) FILTER (WHERE diabetes_code = 1)
        / count(*) FILTER (WHERE diabetes_code IN (1,2,3,4))                AS prevalence_unweighted_pct,
  (count(*) FILTER (WHERE diabetes_code IN (1,2,3,4)) < 30)                 AS small_cell_suppressed
FROM flagged
WHERE obese_flag IS NOT NULL AND smoker_flag IS NOT NULL AND inactive_flag IS NOT NULL
GROUP BY survey_year, obese_flag, smoker_flag, inactive_flag
ORDER BY survey_year, risk_factor_count;

-- ---- Verification ----
SELECT survey_year, count(*) FROM workspace.gold.diabetes_risk_stacking GROUP BY survey_year ORDER BY 1;  -- expect 8 per year

-- The simplest chart per year: prevalence by risk factor count alone (0,1,2,3)
SELECT survey_year, risk_factor_count,
       sum(valid_respondents) AS valid_respondents,
       round(100.0 * sum(weighted_yes_sum) / sum(weighted_valid_sum), 2) AS weighted_pct
FROM workspace.gold.diabetes_risk_stacking
GROUP BY survey_year, risk_factor_count
ORDER BY survey_year, risk_factor_count;
'''
with open(r"D:\data-lab2\sql\databricks\10b_gold_risk_stacking_multiyear.sql", "w", encoding="utf-8") as f:
    f.write(risk_sql)
print("wrote 10b_gold_risk_stacking_multiyear.sql")

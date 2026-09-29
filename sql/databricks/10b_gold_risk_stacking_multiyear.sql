-- Databricks: gold.diabetes_risk_stacking, 5-year version of 10_gold_risk_stacking.sql.
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

-- Trial workspace (Lakeflow demo): risk-stacking gold table, multi-year (2011-2015).
-- Same definitions as sql/databricks/10_gold_risk_stacking.sql, extended with survey_year.
-- No new bronze columns needed - obese/smoker/inactive flags all derive from columns
-- already in silver_clean.

CREATE OR REPLACE TABLE workspace.gold.diabetes_risk_stacking AS
WITH flagged AS (
  SELECT
    survey_year,
    CASE WHEN bmi_category_code = 4 THEN 1 WHEN bmi_category_code IN (1,2,3) THEN 0 END AS obese_flag,
    CASE WHEN smoker_status_code IN (1,2) THEN 1 WHEN smoker_status_code IN (3,4) THEN 0 END AS smoker_flag,
    CASE WHEN exercise_any_code = 2 THEN 1 WHEN exercise_any_code = 1 THEN 0 END AS inactive_flag,
    diabetes_code, final_weight
  FROM workspace.lakeflow_demo.silver_clean
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
  (count(*) FILTER (WHERE diabetes_code IN (1,2,3,4)) < 30)                 AS small_cell_suppressed
FROM flagged
WHERE obese_flag IS NOT NULL AND smoker_flag IS NOT NULL AND inactive_flag IS NOT NULL
GROUP BY survey_year, obese_flag, smoker_flag, inactive_flag
ORDER BY survey_year, risk_factor_count;

-- Verification: the simple risk-factor-count rollup, per year - is the 3.4x gap consistent across years?
SELECT survey_year, risk_factor_count,
       sum(valid_respondents) AS valid_respondents,
       round(100.0 * sum(weighted_yes_sum) / sum(weighted_valid_sum), 2) AS weighted_pct
FROM workspace.gold.diabetes_risk_stacking
GROUP BY survey_year, risk_factor_count
ORDER BY survey_year, risk_factor_count;

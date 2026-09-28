-- Databricks: gold.diabetes_risk_stacking, built from silver.brfss_clean.
-- Shows how diabetes risk COMPOUNDS across three factors at once, not one at a time.
-- All three source columns are already in silver.brfss_clean - no bronze re-touch needed.
--
-- Design decision: each factor is collapsed to a binary split rather than using its full
-- code range. A raw BMI(4) x smoking(5) x exercise(4) cross gives up to 80 tiny cells -
-- the brief's own healthcare use case names "small-cell suppression" as a real risk, and
-- most of those 80 cells would be too small to trust. Binary splits give a clean 2x2x2=8
-- cells, each large enough to be meaningful, plus a simple 0-3 "risk factor count" for the
-- headline chart.
--   OBESE_FLAG:    bmi_category_code = 4 (obese) vs 1-3 (not obese). Excludes NULL (unknown BMI).
--   SMOKER_FLAG:   smoker_status_code IN (1,2) (current, daily or some days) vs (3,4)
--                  (former/never). Excludes 9 (don't know) - ambiguous smoking status
--                  would muddy a risk-stacking story.
--   INACTIVE_FLAG: exercise_any_code = 2 (no exercise) vs 1 (yes). Excludes 7,9 (unknown).

CREATE OR REPLACE TABLE workspace.gold.diabetes_risk_stacking AS
WITH flagged AS (
  SELECT
    CASE WHEN bmi_category_code = 4 THEN 1 WHEN bmi_category_code IN (1,2,3) THEN 0 END AS obese_flag,
    CASE WHEN smoker_status_code IN (1,2) THEN 1 WHEN smoker_status_code IN (3,4) THEN 0 END AS smoker_flag,
    CASE WHEN exercise_any_code = 2 THEN 1 WHEN exercise_any_code = 1 THEN 0 END AS inactive_flag,
    diabetes_code, final_weight
  FROM workspace.silver.brfss_clean
)
SELECT
  obese_flag, smoker_flag, inactive_flag,
  -- 0-3: how many of the three risk factors this group has. Lets a chart show the
  -- simplest possible story (risk factor count -> prevalence) alongside the detailed one.
  obese_flag + smoker_flag + inactive_flag AS risk_factor_count,
  count(*) FILTER (WHERE diabetes_code IN (1,2,3,4))            AS valid_respondents,
  count(*) FILTER (WHERE diabetes_code = 1)                     AS diabetes_yes,
  sum(final_weight) FILTER (WHERE diabetes_code = 1)            AS weighted_yes_sum,
  sum(final_weight) FILTER (WHERE diabetes_code IN (1,2,3,4))   AS weighted_valid_sum,
  100.0 * sum(final_weight) FILTER (WHERE diabetes_code = 1)
        / sum(final_weight) FILTER (WHERE diabetes_code IN (1,2,3,4))       AS prevalence_weighted_pct,
  100.0 * count(*) FILTER (WHERE diabetes_code = 1)
        / count(*) FILTER (WHERE diabetes_code IN (1,2,3,4))                AS prevalence_unweighted_pct,
  -- Never report a shaky percentage silently - flag any cell under 30 respondents.
  -- The brief's own small-cell-suppression concern, applied here explicitly.
  (count(*) FILTER (WHERE diabetes_code IN (1,2,3,4)) < 30)                 AS small_cell_suppressed
FROM flagged
WHERE obese_flag IS NOT NULL AND smoker_flag IS NOT NULL AND inactive_flag IS NOT NULL
GROUP BY obese_flag, smoker_flag, inactive_flag
ORDER BY risk_factor_count;

-- ---- Verification ----
SELECT count(*) FROM workspace.gold.diabetes_risk_stacking;                  -- expect 8 (2x2x2)
SELECT count(*) FROM workspace.gold.diabetes_risk_stacking WHERE small_cell_suppressed; -- how many cells are too small to trust

-- The headline comparison: the two extremes.
SELECT risk_factor_count, obese_flag, smoker_flag, inactive_flag,
       valid_respondents, small_cell_suppressed,
       round(prevalence_weighted_pct, 2) AS weighted_pct
FROM workspace.gold.diabetes_risk_stacking
ORDER BY risk_factor_count;

-- The simplest chart: prevalence by risk factor count alone (0,1,2,3), rolled up across
-- all combinations that share that count.
SELECT risk_factor_count,
       sum(valid_respondents) AS valid_respondents,
       round(100.0 * sum(weighted_yes_sum) / sum(weighted_valid_sum), 2) AS weighted_pct
FROM workspace.gold.diabetes_risk_stacking
GROUP BY risk_factor_count
ORDER BY risk_factor_count;

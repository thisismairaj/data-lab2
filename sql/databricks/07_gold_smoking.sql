-- Databricks: gold.diabetes_prevalence_smoking, built from silver.brfss_clean.
-- Same reconciled shape as 04_gold.sql / 06_gold_age_group.sql, grouped by smoker_status_code.
-- _SMOKER3 codes: 1=current smoker (daily), 2=current smoker (some days), 3=former smoker,
-- 4=never smoked, 9=don't know/refused/missing. No BLANK code for this variable in the
-- codebook, so (unlike BMI category below) every respondent should land in 1-4 or 9, never NULL -
-- the NULL-safety CASE is added anyway, for the same reason a smoke detector goes in a room
-- that's "supposed" to never catch fire: cheap to add, and it turns a silent NULL into an
-- honest "Unknown" row instead, if that assumption ever turns out wrong.

CREATE OR REPLACE TABLE workspace.gold.diabetes_prevalence_smoking AS
SELECT
  c.smoker_status_code,
  CASE WHEN c.smoker_status_code IS NULL THEN 'Unknown (not captured)' ELSE a.label END AS smoking_label,

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
  ON a.variable = '_SMOKER3' AND a.code = CAST(CAST(c.smoker_status_code AS INT) AS STRING)
GROUP BY c.smoker_status_code, a.label
ORDER BY c.smoker_status_code;

-- ---- Verification ----
SELECT count(*) FROM workspace.gold.diabetes_prevalence_smoking;                            -- expect <= 5 (4 smoking statuses + maybe "unknown")
SELECT count(*) FROM workspace.gold.diabetes_prevalence_smoking WHERE smoking_label IS NULL; -- expect 0 (the CASE should have covered every case)
SELECT sum(valid_respondents) + sum(excluded_dont_know_refused_blank)
FROM workspace.gold.diabetes_prevalence_smoking;                                             -- expect 440421, same total as silver.brfss_clean

SELECT smoker_status_code, smoking_label, valid_respondents,
       round(prevalence_weighted_pct, 2) AS weighted_pct,
       round(prevalence_unweighted_pct, 2) AS unweighted_pct
FROM workspace.gold.diabetes_prevalence_smoking
ORDER BY smoker_status_code;

-- Databricks: gold.diabetes_prevalence_bmi_category, built from silver.brfss_clean.
-- Same reconciled shape as the others, grouped by bmi_category_code.
-- _BMI5CAT codes: 1=underweight, 2=normal, 3=overweight, 4=obese. Unlike _SMOKER3, this
-- variable's "don't know/refused" case is a literal BLANK in the codebook, not a numbered
-- code - and bmi_category_code is CAST(...AS DOUBLE) in silver, so a source BLANK becomes a
-- real NULL, not a 9. A NULL will not match ref.codebook_values's text code 'BLANK' through
-- the int-cast join below (CAST(NULL AS INT) is NULL, not 'BLANK'), so the CASE below labels
-- that group explicitly instead of leaving it as an unexplained NULL row.

CREATE OR REPLACE TABLE workspace.gold.diabetes_prevalence_bmi_category AS
SELECT
  c.bmi_category_code,
  CASE WHEN c.bmi_category_code IS NULL THEN 'Unknown (BMI not available)' ELSE a.label END AS bmi_category_label,

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
  ON a.variable = '_BMI5CAT' AND a.code = CAST(CAST(c.bmi_category_code AS INT) AS STRING)
GROUP BY c.bmi_category_code, a.label
ORDER BY c.bmi_category_code;

-- ---- Verification ----
SELECT count(*) FROM workspace.gold.diabetes_prevalence_bmi_category;                                 -- expect <= 5 (4 categories + "unknown")
SELECT count(*) FROM workspace.gold.diabetes_prevalence_bmi_category WHERE bmi_category_label IS NULL; -- expect 0
SELECT sum(valid_respondents) + sum(excluded_dont_know_refused_blank)
FROM workspace.gold.diabetes_prevalence_bmi_category;                                                  -- expect 440421

SELECT bmi_category_code, bmi_category_label, valid_respondents,
       round(prevalence_weighted_pct, 2) AS weighted_pct,
       round(prevalence_unweighted_pct, 2) AS unweighted_pct
FROM workspace.gold.diabetes_prevalence_bmi_category
ORDER BY bmi_category_code;

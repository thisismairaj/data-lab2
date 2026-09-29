-- Trial workspace (Lakeflow demo): age/smoking/BMI gold tables, multi-year (2013-2015).
-- Direct extension of the Free-Edition single-year versions - same definitions, just
-- GROUP BY (code, survey_year) instead of (code) alone, since silver_clean here already
-- has 3 real years loaded. No new bronze columns needed - all three source columns
-- (age_group_code, smoker_status_code, bmi_category_code) are already in silver_clean.

CREATE OR REPLACE TABLE workspace.gold.diabetes_prevalence_age_group AS
SELECT
  c.age_group_code, c.survey_year, a.label AS age_group_label,
  count(*) FILTER (WHERE c.diabetes_code IN (1,2,3,4))            AS valid_respondents,
  count(*) FILTER (WHERE c.diabetes_code = 1)                     AS diabetes_yes,
  sum(c.final_weight) FILTER (WHERE c.diabetes_code = 1)          AS weighted_yes_sum,
  sum(c.final_weight) FILTER (WHERE c.diabetes_code IN (1,2,3,4)) AS weighted_valid_sum,
  100.0 * sum(c.final_weight) FILTER (WHERE c.diabetes_code = 1)
        / sum(c.final_weight) FILTER (WHERE c.diabetes_code IN (1,2,3,4))     AS prevalence_weighted_pct,
  count(*) FILTER (WHERE c.diabetes_code IN (7,9) OR c.diabetes_code IS NULL) AS excluded_dont_know_refused_blank
FROM workspace.lakeflow_demo.silver_clean c
LEFT JOIN workspace.ref.codebook_values a
  ON a.variable = '_AGEG5YR' AND a.code = CAST(CAST(c.age_group_code AS INT) AS STRING)
GROUP BY c.age_group_code, c.survey_year, a.label
ORDER BY c.survey_year, c.age_group_code;

CREATE OR REPLACE TABLE workspace.gold.diabetes_prevalence_smoking AS
SELECT
  c.smoker_status_code, c.survey_year,
  CASE WHEN c.smoker_status_code IS NULL THEN 'Unknown (not captured)' ELSE a.label END AS smoking_label,
  count(*) FILTER (WHERE c.diabetes_code IN (1,2,3,4))            AS valid_respondents,
  count(*) FILTER (WHERE c.diabetes_code = 1)                     AS diabetes_yes,
  sum(c.final_weight) FILTER (WHERE c.diabetes_code = 1)          AS weighted_yes_sum,
  sum(c.final_weight) FILTER (WHERE c.diabetes_code IN (1,2,3,4)) AS weighted_valid_sum,
  100.0 * sum(c.final_weight) FILTER (WHERE c.diabetes_code = 1)
        / sum(c.final_weight) FILTER (WHERE c.diabetes_code IN (1,2,3,4))     AS prevalence_weighted_pct
FROM workspace.lakeflow_demo.silver_clean c
LEFT JOIN workspace.ref.codebook_values a
  ON a.variable = '_SMOKER3' AND a.code = CAST(CAST(c.smoker_status_code AS INT) AS STRING)
GROUP BY c.smoker_status_code, c.survey_year, a.label
ORDER BY c.survey_year, c.smoker_status_code;

CREATE OR REPLACE TABLE workspace.gold.diabetes_prevalence_bmi_category AS
SELECT
  c.bmi_category_code, c.survey_year,
  CASE WHEN c.bmi_category_code IS NULL THEN 'Unknown (BMI not available)' ELSE a.label END AS bmi_category_label,
  count(*) FILTER (WHERE c.diabetes_code IN (1,2,3,4))            AS valid_respondents,
  count(*) FILTER (WHERE c.diabetes_code = 1)                     AS diabetes_yes,
  sum(c.final_weight) FILTER (WHERE c.diabetes_code = 1)          AS weighted_yes_sum,
  sum(c.final_weight) FILTER (WHERE c.diabetes_code IN (1,2,3,4)) AS weighted_valid_sum,
  100.0 * sum(c.final_weight) FILTER (WHERE c.diabetes_code = 1)
        / sum(c.final_weight) FILTER (WHERE c.diabetes_code IN (1,2,3,4))     AS prevalence_weighted_pct
FROM workspace.lakeflow_demo.silver_clean c
LEFT JOIN workspace.ref.codebook_values a
  ON a.variable = '_BMI5CAT' AND a.code = CAST(CAST(c.bmi_category_code AS INT) AS STRING)
GROUP BY c.bmi_category_code, c.survey_year, a.label
ORDER BY c.survey_year, c.bmi_category_code;

-- Verification
SELECT survey_year, count(*) FROM workspace.gold.diabetes_prevalence_age_group GROUP BY survey_year ORDER BY 1;
SELECT survey_year, count(*) FROM workspace.gold.diabetes_prevalence_smoking GROUP BY survey_year ORDER BY 1;
SELECT survey_year, count(*) FROM workspace.gold.diabetes_prevalence_bmi_category GROUP BY survey_year ORDER BY 1;
-- National prevalence per year, from the age-group table (sanity check vs the state table's known numbers)
SELECT survey_year, round(100.0*sum(weighted_yes_sum)/sum(weighted_valid_sum),2) AS national_pct
FROM workspace.gold.diabetes_prevalence_age_group GROUP BY survey_year ORDER BY 1;

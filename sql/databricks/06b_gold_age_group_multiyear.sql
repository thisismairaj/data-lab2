-- Databricks: gold.diabetes_prevalence_age_group, 5-year version of 06_gold_age_group.sql.
-- Same logic, survey_year added to SELECT/GROUP BY/ORDER BY so each year is its own row
-- per age_group_code instead of blending all 5 years into one.

CREATE OR REPLACE TABLE workspace.gold.diabetes_prevalence_age_group AS
SELECT
  c.age_group_code,
  c.survey_year,
  a.label AS age_group_label,
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
  ON a.variable = '_AGEG5YR' AND a.code = CAST(CAST(c.age_group_code AS INT) AS STRING)
GROUP BY c.age_group_code, c.survey_year, a.label
ORDER BY c.survey_year, c.age_group_code;

-- ---- Verification ----
SELECT survey_year, count(*) FROM workspace.gold.diabetes_prevalence_age_group GROUP BY survey_year ORDER BY 1;
SELECT count(*) FROM workspace.gold.diabetes_prevalence_age_group WHERE age_group_label IS NULL;                 -- expect 0
-- Per-year total must match silver's per-year row count (docs/scope_and_gaps.md known totals)
SELECT survey_year, sum(valid_respondents) + sum(excluded_dont_know_refused_blank) AS total
FROM workspace.gold.diabetes_prevalence_age_group GROUP BY survey_year ORDER BY survey_year;
SELECT survey_year, count(*) FROM workspace.silver.brfss_clean GROUP BY survey_year ORDER BY survey_year;
-- National trend across years (sanity check vs the Trial/Lakeflow build's own finding:
-- 9.8% (2011) -> 10.18% -> 10.27% -> 10.54% -> 10.5% (2015))
SELECT survey_year, round(100.0*sum(weighted_yes_sum)/sum(weighted_valid_sum), 2) AS national_pct
FROM workspace.gold.diabetes_prevalence_age_group GROUP BY survey_year ORDER BY survey_year;

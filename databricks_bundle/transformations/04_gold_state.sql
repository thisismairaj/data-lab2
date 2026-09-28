-- Lakeflow Declarative Pipeline: gold layer.
-- MATERIALIZED VIEW, not a streaming table - this is an aggregate (GROUP BY state), so
-- it needs to recompute over the current full silver_clean table on every pipeline
-- update, not process row-by-row. Lakeflow manages the refresh itself; we don't write
-- MERGE/incremental logic by hand here, unlike bronze/silver above.
CREATE OR REFRESH MATERIALIZED VIEW gold_diabetes_prevalence_state
COMMENT 'One row per state. The only table dashboards/consumers should query.'
AS
SELECT
  state_fips,
  survey_year,
  count(*) FILTER (WHERE diabetes_code IN (1,2,3,4))            AS valid_respondents,
  count(*) FILTER (WHERE diabetes_code = 1)                     AS diabetes_yes,
  sum(final_weight) FILTER (WHERE diabetes_code = 1)            AS weighted_yes_sum,
  sum(final_weight) FILTER (WHERE diabetes_code IN (1,2,3,4))   AS weighted_valid_sum,
  100.0 * sum(final_weight) FILTER (WHERE diabetes_code = 1)
        / sum(final_weight) FILTER (WHERE diabetes_code IN (1,2,3,4))  AS prevalence_weighted_pct,
  count(*) FILTER (WHERE diabetes_code IN (7,9) OR diabetes_code IS NULL) AS excluded_dont_know_refused_blank
FROM silver_clean
GROUP BY state_fips, survey_year;

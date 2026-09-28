-- Databricks: gold.diabetes_prevalence_state, built from silver.brfss_clean.
-- Definitions match docs/schema_contract.md. State names come from ref.codebook_values (_STATE labels).

CREATE OR REPLACE TABLE workspace.gold.diabetes_prevalence_state AS
SELECT
  c.state_fips,
  s.label AS state_name,
  c.survey_year,
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
LEFT JOIN workspace.ref.codebook_values s
  ON s.variable = '_STATE' AND s.code = CAST(CAST(c.state_fips AS INT) AS STRING)
GROUP BY c.state_fips, s.label, c.survey_year;

-- Verification (docs/schema_contract.md publication gate + Q10/Q11 style checks)
SELECT count(*) FROM workspace.gold.diabetes_prevalence_state;                             -- expect <= 53
SELECT count(*) FROM workspace.gold.diabetes_prevalence_state WHERE state_name IS NULL;     -- expect 0 (every code must resolve)
SELECT sum(valid_respondents) FROM workspace.gold.diabetes_prevalence_state;                -- should equal clean rows with diabetes_code in (1,2,3,4)
SELECT sum(valid_respondents) + sum(excluded_dont_know_refused_blank) FROM workspace.gold.diabetes_prevalence_state; -- should equal total clean rows

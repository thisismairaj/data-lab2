-- Databricks: gold.diabetes_prevalence_age_group, built from silver.brfss_clean.
-- Same shape and logic as 04_gold.sql (diabetes_prevalence_state), just grouped by
-- age_group_code instead of state_fips. Meant to be run by hand in a notebook to learn
-- the pattern - see learning_log.md (local notes) for the walkthrough.

CREATE OR REPLACE TABLE workspace.gold.diabetes_prevalence_age_group AS
SELECT
  c.age_group_code,
  a.label AS age_group_label,                                     -- decoded via ref.codebook_values, e.g. "Age 60 to 64"

  -- Same denominator rule as the state table: "valid" = a usable diabetes answer
  -- (1 yes, 2 pregnancy-only, 3 no, 4 pre-diabetic). Code 14 ("don't know/refused/missing"
  -- age) still gets its OWN row here - we never drop people, we just report their group
  -- honestly, including "we don't know their age band".
  count(*) FILTER (WHERE c.diabetes_code IN (1,2,3,4))            AS valid_respondents,
  count(*) FILTER (WHERE c.diabetes_code = 1)                     AS diabetes_yes,

  -- Sums stored (not just the ratio) so multiple age groups can be correctly rolled up
  -- later by re-dividing summed numerator by summed denominator - same reasoning as gold's
  -- state table.
  sum(c.final_weight) FILTER (WHERE c.diabetes_code = 1)          AS weighted_yes_sum,
  sum(c.final_weight) FILTER (WHERE c.diabetes_code IN (1,2,3,4)) AS weighted_valid_sum,

  100.0 * sum(c.final_weight) FILTER (WHERE c.diabetes_code = 1)
        / sum(c.final_weight) FILTER (WHERE c.diabetes_code IN (1,2,3,4))       AS prevalence_weighted_pct,
  100.0 * count(*) FILTER (WHERE c.diabetes_code = 1)
        / count(*) FILTER (WHERE c.diabetes_code IN (1,2,3,4))                  AS prevalence_unweighted_pct,

  count(*) FILTER (WHERE c.diabetes_code IN (7,9) OR c.diabetes_code IS NULL)   AS excluded_dont_know_refused_blank
FROM workspace.silver.brfss_clean c
-- age_group_code is a DOUBLE in silver (e.g. 9.0); the codebook's own codes are plain
-- text ('9'), hence the cast-to-int-then-back-to-string round trip, same trick used for
-- the state join in 04_gold.sql.
LEFT JOIN workspace.ref.codebook_values a
  ON a.variable = '_AGEG5YR' AND a.code = CAST(CAST(c.age_group_code AS INT) AS STRING)
GROUP BY c.age_group_code, a.label
ORDER BY c.age_group_code;                                        -- so the table reads youngest -> oldest, not alphabetically

-- ---- Verification ----
SELECT count(*) FROM workspace.gold.diabetes_prevalence_age_group;                     -- expect <= 14 (13 age bands + "don't know")
SELECT count(*) FROM workspace.gold.diabetes_prevalence_age_group WHERE age_group_label IS NULL;  -- expect 0
SELECT sum(valid_respondents) + sum(excluded_dont_know_refused_blank)
FROM workspace.gold.diabetes_prevalence_age_group;                                     -- expect 440421, same total as silver.brfss_clean

-- The actual answer, ordered youngest to oldest:
SELECT age_group_code, age_group_label, valid_respondents,
       round(prevalence_weighted_pct, 2) AS weighted_pct,
       round(prevalence_unweighted_pct, 2) AS unweighted_pct
FROM workspace.gold.diabetes_prevalence_age_group
ORDER BY age_group_code;

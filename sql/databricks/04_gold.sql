-- Databricks: gold.diabetes_prevalence_state, built from silver.brfss_clean.
-- Definitions match schema_contract.md (local notes) ("Gold: gold.diabetes_prevalence_state").
-- One row per state. This is the table users/Power BI query - never silver or bronze directly.
--
-- Run on 2026-09-28 against the full 441,456-row silver table. Results: 53 rows (all states +
-- DC + Guam + Puerto Rico), national weighted prevalence 10.5% - close to published CDC BRFSS
-- 2015 figures, and the state ranking (Mississippi/West Virginia/Alabama highest, Colorado/
-- Utah/Minnesota lowest) matches the well-known "diabetes belt" pattern. A useful sanity check,
-- but not proof by itself - the real proof is the reconciliation queries at the bottom.

CREATE OR REPLACE TABLE workspace.gold.diabetes_prevalence_state AS
SELECT
  c.state_fips,
  s.label AS state_name,                                          -- decoded via ref.codebook_values, not hardcoded
  c.survey_year,

  -- "Valid" here means: answered the diabetes question with a real, usable code (1 yes,
  -- 2 pregnancy-only, 3 no, 4 pre-diabetic). This is the DENOMINATOR for both percentages
  -- below - it deliberately excludes 7 (don't know), 9 (refused) and NULL (blank), which are
  -- counted separately in excluded_dont_know_refused_blank instead of being dropped silently.
  count(*) FILTER (WHERE c.diabetes_code IN (1,2,3,4))            AS valid_respondents,
  count(*) FILTER (WHERE c.diabetes_code = 1)                     AS diabetes_yes,

  -- Sums (not just the ratio) are stored so a dashboard or a later query can roll several
  -- states up into one number correctly. Percentages can't be averaged across states of
  -- different sizes - you have to re-divide the summed numerator by the summed denominator.
  -- This is the same reason a "national" figure is computed the same way in the verification
  -- block below, and not as an average of the 53 state percentages.
  sum(c.final_weight) FILTER (WHERE c.diabetes_code = 1)          AS weighted_yes_sum,
  sum(c.final_weight) FILTER (WHERE c.diabetes_code IN (1,2,3,4)) AS weighted_valid_sum,

  -- The headline number: uses final_weight, so this estimates prevalence in the real adult
  -- population of the state, not just among the people who happened to answer the survey.
  100.0 * sum(c.final_weight) FILTER (WHERE c.diabetes_code = 1)
        / sum(c.final_weight) FILTER (WHERE c.diabetes_code IN (1,2,3,4))       AS prevalence_weighted_pct,

  -- Shown alongside the weighted figure on purpose, so the effect of weighting is visible
  -- rather than hidden - e.g. measured for Alabama: 13.46% weighted vs 17.14% unweighted.
  100.0 * count(*) FILTER (WHERE c.diabetes_code = 1)
        / count(*) FILTER (WHERE c.diabetes_code IN (1,2,3,4))                  AS prevalence_unweighted_pct,

  -- Reported, never imputed: this is the count of people whose answer we simply don't have
  -- a usable value for. A reader can see how much of the state's data is "unknown" rather
  -- than that uncertainty being swallowed into the percentage above.
  count(*) FILTER (WHERE c.diabetes_code IN (7,9) OR c.diabetes_code IS NULL)   AS excluded_dont_know_refused_blank
FROM workspace.silver.brfss_clean c
-- ref.codebook_values holds every code->label pair from the codebook for every variable;
-- filtering to variable='_STATE' turns it into just a state-code -> state-name lookup here.
-- state_fips is text like '06' in silver; the codebook's own codes are unpadded ('6'), hence
-- the cast-to-int-then-back-to-string round trip to make the two sides match.
LEFT JOIN workspace.ref.codebook_values s
  ON s.variable = '_STATE' AND s.code = CAST(CAST(c.state_fips AS INT) AS STRING)
GROUP BY c.state_fips, s.label, c.survey_year;

-- ---- Verification (schema_contract.md (local notes) publication gate) ----

-- Expect <= 53: one row per state/DC/territory that actually appears in silver.
SELECT count(*) FROM workspace.gold.diabetes_prevalence_state;

-- Expect 0: every state_fips value in silver must resolve to a real name via the codebook
-- join - a NULL here would mean either a bad code slipped past rule S1, or the join itself
-- is wrong (e.g. the cast/pad mismatch described above).
SELECT count(*) FROM workspace.gold.diabetes_prevalence_state WHERE state_name IS NULL;

-- Reconciliation: nothing should vanish between silver and gold. valid_respondents summed
-- across all states, plus everyone excluded as don't-know/refused/blank, must equal the
-- total row count of silver.brfss_clean - if it doesn't, the GROUP BY or a FILTER above has
-- a bug (e.g. double-counting a state, or a diabetes_code value falling through every bucket).
SELECT sum(valid_respondents) FROM workspace.gold.diabetes_prevalence_state;
SELECT sum(valid_respondents) + sum(excluded_dont_know_refused_blank)
FROM workspace.gold.diabetes_prevalence_state;

-- The national figure, computed the same way as each state row (sum-then-divide, not an
-- average of the 53 percentages) - measured 2026-09-28: 10.5%.
SELECT 100.0 * sum(weighted_yes_sum) / sum(weighted_valid_sum) AS national_prevalence_weighted_pct
FROM workspace.gold.diabetes_prevalence_state;

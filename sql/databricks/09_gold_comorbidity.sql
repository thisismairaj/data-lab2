-- Databricks: gold.diabetes_comorbidity, built from silver.brfss_clean JOINed back to
-- bronze.brfss_2015 for 10 extra condition columns that are NOT part of the 18-column
-- contract in schema_contract.md (local notes). Deliberately NOT added to the silver build: these
-- columns have no quarantine rules defined for them, and widening the core contract mid-
-- project would be scope creep. Instead we join onto bronze directly for just this table,
-- reusing silver's already-quarantined diabetes_code/final_weight/keys - so a BMI-outlier
-- row (rule R1) that got quarantined out of silver is correctly excluded here too, without
-- redoing the whole quarantine pipeline for these 10 extra columns.
--
-- Long/tall shape on purpose (10 conditions x 2 diabetes groups = up to 20 rows), not wide,
-- because that's what a Power BI grouped bar chart needs: one row per (category, series).
-- See the chat/learning log for the visualization reasoning.

CREATE OR REPLACE TABLE workspace.gold.diabetes_comorbidity AS
WITH base AS (
  -- Join key: (state_fips, seqno) - proven unique on both sides (schema_contract.md (local notes)
  -- primary key section; bronze itself was checked unique during Step 1 profiling), so this
  -- join can only produce exactly one bronze row per silver row - no fan-out risk.
  SELECT
    c.diabetes_code, c.final_weight,
    CAST(b.BPHIGH4  AS DOUBLE) AS bphigh4,    -- 1 yes, 2 yes-pregnancy-only, 3 no, 4 borderline, 7/9 unknown
    CAST(b.TOLDHI2  AS DOUBLE) AS toldhi2,    -- 1 yes, 2 no, 7/9 unknown
    CAST(b.CVDINFR4 AS DOUBLE) AS cvdinfr4,   -- 1 yes, 2 no, 7/9 unknown  (heart attack)
    CAST(b.CVDCRHD4 AS DOUBLE) AS cvdcrhd4,   -- 1 yes, 2 no, 7/9 unknown  (coronary heart disease / angina)
    CAST(b.CVDSTRK3 AS DOUBLE) AS cvdstrk3,   -- 1 yes, 2 no, 7/9 unknown  (stroke)
    CAST(b.ADDEPEV2 AS DOUBLE) AS addepev2,   -- 1 yes, 2 no, 7/9 unknown  (depression)
    CAST(b.CHCKIDNY AS DOUBLE) AS chckidny,   -- 1 yes, 2 no, 7/9 unknown  (kidney disease)
    CAST(b.ASTHMA3  AS DOUBLE) AS asthma3,    -- 1 yes, 2 no, 7/9 unknown
    CAST(b.MEDCOST  AS DOUBLE) AS medcost,    -- 1 yes (skipped care, cost), 2 no, 7/9 unknown
    CAST(b.PERSDOC2 AS DOUBLE) AS persdoc2    -- 1 one doctor, 2 more than one, 3 NO doctor, 7 unknown - ternary, not yes/no
  FROM workspace.silver.brfss_clean c
  JOIN workspace.bronze.brfss_2015 b
    ON CAST(CAST(b._STATE AS DOUBLE) AS INT) = CAST(c.state_fips AS INT)
   AND CAST(CAST(b.SEQNO  AS DOUBLE) AS BIGINT) = c.seqno
),
grouped AS (
  -- Two groups only: clear diabetics (code 1) vs clear non-diabetics (code 3 no, 4 pre-
  -- diabetic). Code 2 (pregnancy-only) and unknowns (7/9/NULL) are excluded from BOTH
  -- groups here - group membership itself has to be unambiguous, same principle as gold's
  -- diabetes_prevalence_state table excluding "don't know" from its denominator.
  SELECT *,
    CASE WHEN diabetes_code = 1      THEN 'Diabetic'
         WHEN diabetes_code IN (3,4) THEN 'Non-diabetic'
         ELSE NULL END AS diabetes_group
  FROM base
),
-- One SELECT per condition, all UNIONed into one long table. Each CASE follows the same
-- rule: 1 = has the condition, 0 = doesn't, NULL = unknown/refused (excluded from that
-- condition's own denominator, same "never guess" rule as everywhere else in this project).
unpivoted AS (
  SELECT diabetes_group, final_weight, 'high_blood_pressure' AS condition, 'Has high blood pressure' AS condition_label,
    CASE WHEN bphigh4 = 1 THEN 1 WHEN bphigh4 IN (3,4) THEN 0 END AS has_condition
  FROM grouped WHERE diabetes_group IS NOT NULL
  UNION ALL
  SELECT diabetes_group, final_weight, 'high_cholesterol', 'Has high cholesterol',
    CASE WHEN toldhi2 = 1 THEN 1 WHEN toldhi2 = 2 THEN 0 END
  FROM grouped WHERE diabetes_group IS NOT NULL
  UNION ALL
  SELECT diabetes_group, final_weight, 'heart_attack', 'Had a heart attack',
    CASE WHEN cvdinfr4 = 1 THEN 1 WHEN cvdinfr4 = 2 THEN 0 END
  FROM grouped WHERE diabetes_group IS NOT NULL
  UNION ALL
  SELECT diabetes_group, final_weight, 'coronary_heart_disease', 'Has coronary heart disease',
    CASE WHEN cvdcrhd4 = 1 THEN 1 WHEN cvdcrhd4 = 2 THEN 0 END
  FROM grouped WHERE diabetes_group IS NOT NULL
  UNION ALL
  SELECT diabetes_group, final_weight, 'stroke', 'Had a stroke',
    CASE WHEN cvdstrk3 = 1 THEN 1 WHEN cvdstrk3 = 2 THEN 0 END
  FROM grouped WHERE diabetes_group IS NOT NULL
  UNION ALL
  SELECT diabetes_group, final_weight, 'depression', 'Has depression',
    CASE WHEN addepev2 = 1 THEN 1 WHEN addepev2 = 2 THEN 0 END
  FROM grouped WHERE diabetes_group IS NOT NULL
  UNION ALL
  SELECT diabetes_group, final_weight, 'kidney_disease', 'Has kidney disease',
    CASE WHEN chckidny = 1 THEN 1 WHEN chckidny = 2 THEN 0 END
  FROM grouped WHERE diabetes_group IS NOT NULL
  UNION ALL
  SELECT diabetes_group, final_weight, 'asthma', 'Has asthma',
    CASE WHEN asthma3 = 1 THEN 1 WHEN asthma3 = 2 THEN 0 END
  FROM grouped WHERE diabetes_group IS NOT NULL
  UNION ALL
  SELECT diabetes_group, final_weight, 'cost_barrier', 'Skipped care due to cost',
    CASE WHEN medcost = 1 THEN 1 WHEN medcost = 2 THEN 0 END
  FROM grouped WHERE diabetes_group IS NOT NULL
  UNION ALL
  SELECT diabetes_group, final_weight, 'no_personal_doctor', 'No personal doctor',
    CASE WHEN persdoc2 = 3 THEN 1 WHEN persdoc2 IN (1,2) THEN 0 END
  FROM grouped WHERE diabetes_group IS NOT NULL
)
SELECT
  condition, condition_label, diabetes_group,
  count(*) FILTER (WHERE has_condition IN (0,1))                AS valid_respondents,
  count(*) FILTER (WHERE has_condition = 1)                     AS condition_yes_n,
  sum(final_weight) FILTER (WHERE has_condition = 1)            AS weighted_yes_sum,
  sum(final_weight) FILTER (WHERE has_condition IN (0,1))       AS weighted_valid_sum,
  100.0 * sum(final_weight) FILTER (WHERE has_condition = 1)
        / sum(final_weight) FILTER (WHERE has_condition IN (0,1))  AS condition_pct_weighted
FROM unpivoted
GROUP BY condition, condition_label, diabetes_group;

-- ---- Verification ----

-- The bronze join must be exactly 1:1 - expect 440421, the same as silver.brfss_clean.
-- A smaller number would mean some silver rows have no bronze match (a join bug); a larger
-- number would mean the join fanned out (a duplicate-key bug).
SELECT count(*) FROM (
  SELECT c.state_fips, c.seqno FROM workspace.silver.brfss_clean c
  JOIN workspace.bronze.brfss_2015 b
    ON CAST(CAST(b._STATE AS DOUBLE) AS INT) = CAST(c.state_fips AS INT)
   AND CAST(CAST(b.SEQNO  AS DOUBLE) AS BIGINT) = c.seqno
);

-- Group sizes must match a direct count from silver - proves the CASE-based grouping logic
-- above didn't drop or misclassify anyone.
SELECT count(*) FROM workspace.silver.brfss_clean WHERE diabetes_code = 1;        -- Diabetic group size
SELECT count(*) FROM workspace.silver.brfss_clean WHERE diabetes_code IN (3,4);   -- Non-diabetic group size

-- Shape check: 10 conditions, up to 20 rows (10 x 2 groups).
SELECT count(DISTINCT condition) FROM workspace.gold.diabetes_comorbidity;   -- expect 10
SELECT count(*) FROM workspace.gold.diabetes_comorbidity;                    -- expect <= 20

-- The actual answer, one row per condition x group:
SELECT condition_label, diabetes_group, valid_respondents,
       round(condition_pct_weighted, 2) AS pct_weighted
FROM workspace.gold.diabetes_comorbidity
ORDER BY condition, diabetes_group;

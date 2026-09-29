-- Trial workspace (Lakeflow demo): comorbidity gold table, multi-year (2011-2015).
-- Same pattern as sql/databricks/09_gold_comorbidity.sql, extended with survey_year.
-- BPHIGH4 and TOLDHI2 are missing from BOTH 2012 and 2014 (checked directly against
-- bronze_brfss - not just 2014, as first assumed from the 2014-vs-2015 comparison done
-- on Free Edition). Handled the same way schema evolution already handles it: NULL for
-- years that don't have the column, which the has_condition CASE already treats as
-- "unknown", excluded from that condition's own denominator - no extra logic needed.

CREATE OR REPLACE TABLE workspace.gold.diabetes_comorbidity AS
WITH base AS (
  SELECT
    c.diabetes_code, c.final_weight, c.survey_year,
    CAST(b.BPHIGH4  AS DOUBLE) AS bphigh4,
    CAST(b.TOLDHI2  AS DOUBLE) AS toldhi2,
    CAST(b.CVDINFR4 AS DOUBLE) AS cvdinfr4,
    CAST(b.CVDCRHD4 AS DOUBLE) AS cvdcrhd4,
    CAST(b.CVDSTRK3 AS DOUBLE) AS cvdstrk3,
    CAST(b.ADDEPEV2 AS DOUBLE) AS addepev2,
    CAST(b.CHCKIDNY AS DOUBLE) AS chckidny,
    CAST(b.ASTHMA3  AS DOUBLE) AS asthma3,
    CAST(b.MEDCOST  AS DOUBLE) AS medcost,
    CAST(b.PERSDOC2 AS DOUBLE) AS persdoc2
  FROM workspace.lakeflow_demo.silver_clean c
  JOIN workspace.lakeflow_demo.bronze_brfss b
    ON CAST(CAST(b._STATE AS DOUBLE) AS INT) = CAST(c.state_fips AS INT)
   AND CAST(CAST(b.SEQNO  AS DOUBLE) AS BIGINT) = c.seqno
   AND b._source_file = concat(c.survey_year, '.csv')   -- disambiguates SEQNO across years (it repeats per year, not just per state)
),
grouped AS (
  SELECT *,
    CASE WHEN diabetes_code = 1      THEN 'Diabetic'
         WHEN diabetes_code IN (3,4) THEN 'Non-diabetic'
         ELSE NULL END AS diabetes_group
  FROM base
),
unpivoted AS (
  SELECT survey_year, diabetes_group, final_weight, 'high_blood_pressure' AS condition, 'Has high blood pressure' AS condition_label,
    CASE WHEN bphigh4 = 1 THEN 1 WHEN bphigh4 IN (3,4) THEN 0 END AS has_condition
  FROM grouped WHERE diabetes_group IS NOT NULL
  UNION ALL
  SELECT survey_year, diabetes_group, final_weight, 'high_cholesterol', 'Has high cholesterol',
    CASE WHEN toldhi2 = 1 THEN 1 WHEN toldhi2 = 2 THEN 0 END
  FROM grouped WHERE diabetes_group IS NOT NULL
  UNION ALL
  SELECT survey_year, diabetes_group, final_weight, 'heart_attack', 'Had a heart attack',
    CASE WHEN cvdinfr4 = 1 THEN 1 WHEN cvdinfr4 = 2 THEN 0 END
  FROM grouped WHERE diabetes_group IS NOT NULL
  UNION ALL
  SELECT survey_year, diabetes_group, final_weight, 'coronary_heart_disease', 'Has coronary heart disease',
    CASE WHEN cvdcrhd4 = 1 THEN 1 WHEN cvdcrhd4 = 2 THEN 0 END
  FROM grouped WHERE diabetes_group IS NOT NULL
  UNION ALL
  SELECT survey_year, diabetes_group, final_weight, 'stroke', 'Had a stroke',
    CASE WHEN cvdstrk3 = 1 THEN 1 WHEN cvdstrk3 = 2 THEN 0 END
  FROM grouped WHERE diabetes_group IS NOT NULL
  UNION ALL
  SELECT survey_year, diabetes_group, final_weight, 'depression', 'Has depression',
    CASE WHEN addepev2 = 1 THEN 1 WHEN addepev2 = 2 THEN 0 END
  FROM grouped WHERE diabetes_group IS NOT NULL
  UNION ALL
  SELECT survey_year, diabetes_group, final_weight, 'kidney_disease', 'Has kidney disease',
    CASE WHEN chckidny = 1 THEN 1 WHEN chckidny = 2 THEN 0 END
  FROM grouped WHERE diabetes_group IS NOT NULL
  UNION ALL
  SELECT survey_year, diabetes_group, final_weight, 'asthma', 'Has asthma',
    CASE WHEN asthma3 = 1 THEN 1 WHEN asthma3 = 2 THEN 0 END
  FROM grouped WHERE diabetes_group IS NOT NULL
  UNION ALL
  SELECT survey_year, diabetes_group, final_weight, 'cost_barrier', 'Skipped care due to cost',
    CASE WHEN medcost = 1 THEN 1 WHEN medcost = 2 THEN 0 END
  FROM grouped WHERE diabetes_group IS NOT NULL
  UNION ALL
  SELECT survey_year, diabetes_group, final_weight, 'no_personal_doctor', 'No personal doctor',
    CASE WHEN persdoc2 = 3 THEN 1 WHEN persdoc2 IN (1,2) THEN 0 END
  FROM grouped WHERE diabetes_group IS NOT NULL
)
SELECT
  survey_year, condition, condition_label, diabetes_group,
  count(*) FILTER (WHERE has_condition IN (0,1))                AS valid_respondents,
  count(*) FILTER (WHERE has_condition = 1)                     AS condition_yes_n,
  sum(final_weight) FILTER (WHERE has_condition = 1)            AS weighted_yes_sum,
  sum(final_weight) FILTER (WHERE has_condition IN (0,1))       AS weighted_valid_sum,
  100.0 * sum(final_weight) FILTER (WHERE has_condition = 1)
        / sum(final_weight) FILTER (WHERE has_condition IN (0,1))  AS condition_pct_weighted
FROM unpivoted
GROUP BY survey_year, condition, condition_label, diabetes_group;

-- Verification
SELECT survey_year, count(*) FROM workspace.gold.diabetes_comorbidity GROUP BY survey_year ORDER BY 1;
-- Confirm BPHIGH4/TOLDHI2 show as having NO rows for 2012/2014 (correctly excluded, not silently zero)
SELECT survey_year, count(*) FROM workspace.gold.diabetes_comorbidity
WHERE condition IN ('high_blood_pressure','high_cholesterol') GROUP BY survey_year ORDER BY 1;

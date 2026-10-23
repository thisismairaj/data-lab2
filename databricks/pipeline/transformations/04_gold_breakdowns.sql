-- Gold breakdowns: diabetes prevalence by age group, smoking status and BMI category, the
-- comorbidity comparison (diabetic vs non-diabetic) and risk stacking. Same definitions as
-- the earlier multi-year build; labels come from the BRFSS 2015 codebook (docs/codebook15_llcp.json).
-- Same tables on Snowflake: snowflake/pipeline/03b_gold_breakdowns.sql.
-- Prevalence is always survey-weighted: sum of weights for "yes" over sum of weights for valid answers.

CREATE OR REFRESH MATERIALIZED VIEW gold.diabetes_prevalence_age_group
COMMENT 'Diabetes prevalence by 5-year age group and survey year'
AS
SELECT
  c.age_group_code, c.survey_year, a.label AS age_group_label,
  count(*) FILTER (WHERE c.diabetes_code IN (1,2,3,4))            AS valid_respondents,
  count(*) FILTER (WHERE c.diabetes_code = 1)                     AS diabetes_yes,
  sum(c.final_weight) FILTER (WHERE c.diabetes_code = 1)          AS weighted_yes_sum,
  sum(c.final_weight) FILTER (WHERE c.diabetes_code IN (1,2,3,4)) AS weighted_valid_sum,
  100.0 * sum(c.final_weight) FILTER (WHERE c.diabetes_code = 1)
        / sum(c.final_weight) FILTER (WHERE c.diabetes_code IN (1,2,3,4)) AS prevalence_weighted_pct,
  count(*) FILTER (WHERE c.diabetes_code IN (7,9) OR c.diabetes_code IS NULL) AS excluded_dont_know_refused_blank
FROM silver.clean c
LEFT JOIN (VALUES (1,'Age 18 to 24'),(2,'Age 25 to 29'),(3,'Age 30 to 34'),(4,'Age 35 to 39'),
                  (5,'Age 40 to 44'),(6,'Age 45 to 49'),(7,'Age 50 to 54'),(8,'Age 55 to 59'),
                  (9,'Age 60 to 64'),(10,'Age 65 to 69'),(11,'Age 70 to 74'),(12,'Age 75 to 79'),
                  (13,'Age 80 or older'),(14,'Don''t know/Refused/Missing')) AS a(code, label)
  ON a.code = c.age_group_code
GROUP BY c.age_group_code, c.survey_year, a.label;

CREATE OR REFRESH MATERIALIZED VIEW gold.diabetes_prevalence_smoking
COMMENT 'Diabetes prevalence by smoking status and survey year'
AS
SELECT
  c.smoker_status_code, c.survey_year,
  CASE WHEN c.smoker_status_code IS NULL THEN 'Unknown (not captured)' ELSE a.label END AS smoking_label,
  count(*) FILTER (WHERE c.diabetes_code IN (1,2,3,4))            AS valid_respondents,
  count(*) FILTER (WHERE c.diabetes_code = 1)                     AS diabetes_yes,
  sum(c.final_weight) FILTER (WHERE c.diabetes_code = 1)          AS weighted_yes_sum,
  sum(c.final_weight) FILTER (WHERE c.diabetes_code IN (1,2,3,4)) AS weighted_valid_sum,
  100.0 * sum(c.final_weight) FILTER (WHERE c.diabetes_code = 1)
        / sum(c.final_weight) FILTER (WHERE c.diabetes_code IN (1,2,3,4)) AS prevalence_weighted_pct
FROM silver.clean c
LEFT JOIN (VALUES (1,'Current smoker - now smokes every day'),(2,'Current smoker - now smokes some days'),
                  (3,'Former smoker'),(4,'Never smoked'),(9,'Don''t know/Refused/Missing')) AS a(code, label)
  ON a.code = c.smoker_status_code
GROUP BY c.smoker_status_code, c.survey_year, a.label;

CREATE OR REFRESH MATERIALIZED VIEW gold.diabetes_prevalence_bmi_category
COMMENT 'Diabetes prevalence by BMI category and survey year'
AS
SELECT
  c.bmi_category_code, c.survey_year,
  CASE WHEN c.bmi_category_code IS NULL THEN 'Unknown (BMI not available)' ELSE a.label END AS bmi_category_label,
  count(*) FILTER (WHERE c.diabetes_code IN (1,2,3,4))            AS valid_respondents,
  count(*) FILTER (WHERE c.diabetes_code = 1)                     AS diabetes_yes,
  sum(c.final_weight) FILTER (WHERE c.diabetes_code = 1)          AS weighted_yes_sum,
  sum(c.final_weight) FILTER (WHERE c.diabetes_code IN (1,2,3,4)) AS weighted_valid_sum,
  100.0 * sum(c.final_weight) FILTER (WHERE c.diabetes_code = 1)
        / sum(c.final_weight) FILTER (WHERE c.diabetes_code IN (1,2,3,4)) AS prevalence_weighted_pct
FROM silver.clean c
LEFT JOIN (VALUES (1,'Underweight'),(2,'Normal Weight'),(3,'Overweight'),(4,'Obese')) AS a(code, label)
  ON a.code = c.bmi_category_code
GROUP BY c.bmi_category_code, c.survey_year, a.label;

-- How common each condition is among diabetic vs non-diabetic adults. One row per year,
-- condition and group. A condition a year's survey did not ask (NULL code) has no valid
-- answers, so it simply has no row for that year rather than a false zero.
CREATE OR REFRESH MATERIALIZED VIEW gold.diabetes_comorbidity
COMMENT 'Share of diabetic vs non-diabetic adults with each condition, by survey year'
AS
WITH grouped AS (
  SELECT *,
    CASE WHEN diabetes_code = 1 THEN 'Diabetic' WHEN diabetes_code IN (3,4) THEN 'Non-diabetic' END AS diabetes_group
  FROM silver.clean
),
unpivoted AS (
  SELECT survey_year, diabetes_group, final_weight, condition, condition_label, has_condition
  FROM grouped
  LATERAL VIEW stack(10,
    'high_blood_pressure',    'Has high blood pressure',
      CASE WHEN high_bp_code = 1 THEN 1 WHEN high_bp_code IN (3,4) THEN 0 END,
    'high_cholesterol',       'Has high cholesterol',
      CASE WHEN high_cholesterol_code = 1 THEN 1 WHEN high_cholesterol_code = 2 THEN 0 END,
    'heart_attack',           'Had a heart attack',
      CASE WHEN heart_attack_code = 1 THEN 1 WHEN heart_attack_code = 2 THEN 0 END,
    'coronary_heart_disease', 'Has coronary heart disease',
      CASE WHEN heart_disease_code = 1 THEN 1 WHEN heart_disease_code = 2 THEN 0 END,
    'stroke',                 'Had a stroke',
      CASE WHEN stroke_code = 1 THEN 1 WHEN stroke_code = 2 THEN 0 END,
    'depression',             'Has depression',
      CASE WHEN depression_code = 1 THEN 1 WHEN depression_code = 2 THEN 0 END,
    'kidney_disease',         'Has kidney disease',
      CASE WHEN kidney_disease_code = 1 THEN 1 WHEN kidney_disease_code = 2 THEN 0 END,
    'asthma',                 'Has asthma',
      CASE WHEN asthma_code = 1 THEN 1 WHEN asthma_code = 2 THEN 0 END,
    'cost_barrier',           'Skipped care due to cost',
      CASE WHEN cost_barrier_code = 1 THEN 1 WHEN cost_barrier_code = 2 THEN 0 END,
    'no_personal_doctor',     'No personal doctor',
      CASE WHEN personal_doctor_code = 3 THEN 1 WHEN personal_doctor_code IN (1,2) THEN 0 END
  ) AS condition, condition_label, has_condition
  WHERE diabetes_group IS NOT NULL
)
SELECT
  survey_year, condition, condition_label, diabetes_group,
  count(*) FILTER (WHERE has_condition IN (0,1))              AS valid_respondents,
  count(*) FILTER (WHERE has_condition = 1)                   AS condition_yes_n,
  sum(final_weight) FILTER (WHERE has_condition = 1)          AS weighted_yes_sum,
  sum(final_weight) FILTER (WHERE has_condition IN (0,1))     AS weighted_valid_sum,
  100.0 * sum(final_weight) FILTER (WHERE has_condition = 1)
        / sum(final_weight) FILTER (WHERE has_condition IN (0,1)) AS condition_pct_weighted
FROM unpivoted
GROUP BY survey_year, condition, condition_label, diabetes_group
HAVING count(*) FILTER (WHERE has_condition IN (0,1)) > 0;

-- Prevalence by combination of three risk factors: obese, current smoker, physically inactive.
CREATE OR REFRESH MATERIALIZED VIEW gold.diabetes_risk_stacking
COMMENT 'Diabetes prevalence by number and combination of risk factors (obese, smoker, inactive)'
AS
WITH flagged AS (
  SELECT survey_year, diabetes_code, final_weight,
    CASE WHEN bmi_category_code = 4 THEN 1 WHEN bmi_category_code IN (1,2,3) THEN 0 END AS obese_flag,
    CASE WHEN smoker_status_code IN (1,2) THEN 1 WHEN smoker_status_code IN (3,4) THEN 0 END AS smoker_flag,
    CASE WHEN exercise_any_code = 2 THEN 1 WHEN exercise_any_code = 1 THEN 0 END AS inactive_flag
  FROM silver.clean
)
SELECT
  survey_year, obese_flag, smoker_flag, inactive_flag,
  obese_flag + smoker_flag + inactive_flag AS risk_factor_count,
  count(*) FILTER (WHERE diabetes_code IN (1,2,3,4))          AS valid_respondents,
  count(*) FILTER (WHERE diabetes_code = 1)                   AS diabetes_yes,
  sum(final_weight) FILTER (WHERE diabetes_code = 1)          AS weighted_yes_sum,
  sum(final_weight) FILTER (WHERE diabetes_code IN (1,2,3,4)) AS weighted_valid_sum,
  100.0 * sum(final_weight) FILTER (WHERE diabetes_code = 1)
        / sum(final_weight) FILTER (WHERE diabetes_code IN (1,2,3,4)) AS prevalence_weighted_pct,
  count(*) FILTER (WHERE diabetes_code IN (1,2,3,4)) < 30     AS small_cell_suppressed
FROM flagged
WHERE obese_flag IS NOT NULL AND smoker_flag IS NOT NULL AND inactive_flag IS NOT NULL
GROUP BY survey_year, obese_flag, smoker_flag, inactive_flag;

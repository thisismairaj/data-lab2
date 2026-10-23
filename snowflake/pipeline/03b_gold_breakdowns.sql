-- Gold breakdowns: the same five tables as the Lakeflow pipeline
-- (databricks/pipeline/transformations/04_gold_breakdowns.sql): prevalence by age group,
-- smoking status and BMI category, comorbidity and risk stacking. Labels from the BRFSS
-- 2015 codebook. Snowflake has no FILTER (WHERE ...) or stack(), so COUNT_IF, SUM(IFF(...))
-- and a cross join with a list of conditions do the same work.
-- TARGET_LAG = DOWNSTREAM: refreshed by the ingest task after each load (04_ingest_task.sql).

CREATE OR REPLACE DYNAMIC TABLE BRFSS.GOLD.DIABETES_PREVALENCE_AGE_GROUP
  TARGET_LAG = DOWNSTREAM WAREHOUSE = COMPUTE_WH
  COMMENT = 'Diabetes prevalence by 5-year age group and survey year'
AS
SELECT
  c.age_group_code, c.survey_year, a.label AS age_group_label,
  COUNT_IF(c.diabetes_code IN (1,2,3,4))                         AS valid_respondents,
  COUNT_IF(c.diabetes_code = 1)                                  AS diabetes_yes,
  SUM(IFF(c.diabetes_code = 1, c.final_weight, NULL))            AS weighted_yes_sum,
  SUM(IFF(c.diabetes_code IN (1,2,3,4), c.final_weight, NULL))   AS weighted_valid_sum,
  100.0 * SUM(IFF(c.diabetes_code = 1, c.final_weight, NULL))
        / SUM(IFF(c.diabetes_code IN (1,2,3,4), c.final_weight, NULL)) AS prevalence_weighted_pct,
  COUNT_IF(c.diabetes_code IN (7,9) OR c.diabetes_code IS NULL)  AS excluded_dont_know_refused_blank
FROM BRFSS.SILVER.CLEAN c
LEFT JOIN (SELECT column1 AS code, column2 AS label FROM (VALUES
    (1,'Age 18 to 24'),(2,'Age 25 to 29'),(3,'Age 30 to 34'),(4,'Age 35 to 39'),
    (5,'Age 40 to 44'),(6,'Age 45 to 49'),(7,'Age 50 to 54'),(8,'Age 55 to 59'),
    (9,'Age 60 to 64'),(10,'Age 65 to 69'),(11,'Age 70 to 74'),(12,'Age 75 to 79'),
    (13,'Age 80 or older'),(14,'Don''t know/Refused/Missing'))) a
  ON a.code = c.age_group_code
GROUP BY c.age_group_code, c.survey_year, a.label;

CREATE OR REPLACE DYNAMIC TABLE BRFSS.GOLD.DIABETES_PREVALENCE_SMOKING
  TARGET_LAG = DOWNSTREAM WAREHOUSE = COMPUTE_WH
  COMMENT = 'Diabetes prevalence by smoking status and survey year'
AS
SELECT
  c.smoker_status_code, c.survey_year,
  IFF(c.smoker_status_code IS NULL, 'Unknown (not captured)', a.label) AS smoking_label,
  COUNT_IF(c.diabetes_code IN (1,2,3,4))                         AS valid_respondents,
  COUNT_IF(c.diabetes_code = 1)                                  AS diabetes_yes,
  SUM(IFF(c.diabetes_code = 1, c.final_weight, NULL))            AS weighted_yes_sum,
  SUM(IFF(c.diabetes_code IN (1,2,3,4), c.final_weight, NULL))   AS weighted_valid_sum,
  100.0 * SUM(IFF(c.diabetes_code = 1, c.final_weight, NULL))
        / SUM(IFF(c.diabetes_code IN (1,2,3,4), c.final_weight, NULL)) AS prevalence_weighted_pct
FROM BRFSS.SILVER.CLEAN c
LEFT JOIN (SELECT column1 AS code, column2 AS label FROM (VALUES
    (1,'Current smoker - now smokes every day'),(2,'Current smoker - now smokes some days'),
    (3,'Former smoker'),(4,'Never smoked'),(9,'Don''t know/Refused/Missing'))) a
  ON a.code = c.smoker_status_code
GROUP BY c.smoker_status_code, c.survey_year, a.label;

CREATE OR REPLACE DYNAMIC TABLE BRFSS.GOLD.DIABETES_PREVALENCE_BMI_CATEGORY
  TARGET_LAG = DOWNSTREAM WAREHOUSE = COMPUTE_WH
  COMMENT = 'Diabetes prevalence by BMI category and survey year'
AS
SELECT
  c.bmi_category_code, c.survey_year,
  IFF(c.bmi_category_code IS NULL, 'Unknown (BMI not available)', a.label) AS bmi_category_label,
  COUNT_IF(c.diabetes_code IN (1,2,3,4))                         AS valid_respondents,
  COUNT_IF(c.diabetes_code = 1)                                  AS diabetes_yes,
  SUM(IFF(c.diabetes_code = 1, c.final_weight, NULL))            AS weighted_yes_sum,
  SUM(IFF(c.diabetes_code IN (1,2,3,4), c.final_weight, NULL))   AS weighted_valid_sum,
  100.0 * SUM(IFF(c.diabetes_code = 1, c.final_weight, NULL))
        / SUM(IFF(c.diabetes_code IN (1,2,3,4), c.final_weight, NULL)) AS prevalence_weighted_pct
FROM BRFSS.SILVER.CLEAN c
LEFT JOIN (SELECT column1 AS code, column2 AS label FROM (VALUES
    (1,'Underweight'),(2,'Normal Weight'),(3,'Overweight'),(4,'Obese'))) a
  ON a.code = c.bmi_category_code
GROUP BY c.bmi_category_code, c.survey_year, a.label;

-- How common each condition is among diabetic vs non-diabetic adults. A condition a year's
-- survey did not ask (NULL code) has no valid answers, so it has no row for that year.
CREATE OR REPLACE DYNAMIC TABLE BRFSS.GOLD.DIABETES_COMORBIDITY
  TARGET_LAG = DOWNSTREAM WAREHOUSE = COMPUTE_WH
  COMMENT = 'Share of diabetic vs non-diabetic adults with each condition, by survey year'
AS
WITH grouped AS (
  SELECT c.*,
    CASE WHEN diabetes_code = 1 THEN 'Diabetic' WHEN diabetes_code IN (3,4) THEN 'Non-diabetic' END AS diabetes_group
  FROM BRFSS.SILVER.CLEAN c
),
conditions AS (
  SELECT column1 AS condition, column2 AS condition_label FROM (VALUES
    ('high_blood_pressure','Has high blood pressure'), ('high_cholesterol','Has high cholesterol'),
    ('heart_attack','Had a heart attack'), ('coronary_heart_disease','Has coronary heart disease'),
    ('stroke','Had a stroke'), ('depression','Has depression'), ('kidney_disease','Has kidney disease'),
    ('asthma','Has asthma'), ('cost_barrier','Skipped care due to cost'),
    ('no_personal_doctor','No personal doctor'))
),
unpivoted AS (
  SELECT g.survey_year, g.diabetes_group, g.final_weight, k.condition, k.condition_label,
    CASE k.condition
      WHEN 'high_blood_pressure'    THEN CASE WHEN g.high_bp_code = 1 THEN 1 WHEN g.high_bp_code IN (3,4) THEN 0 END
      WHEN 'high_cholesterol'       THEN CASE WHEN g.high_cholesterol_code = 1 THEN 1 WHEN g.high_cholesterol_code = 2 THEN 0 END
      WHEN 'heart_attack'           THEN CASE WHEN g.heart_attack_code = 1 THEN 1 WHEN g.heart_attack_code = 2 THEN 0 END
      WHEN 'coronary_heart_disease' THEN CASE WHEN g.heart_disease_code = 1 THEN 1 WHEN g.heart_disease_code = 2 THEN 0 END
      WHEN 'stroke'                 THEN CASE WHEN g.stroke_code = 1 THEN 1 WHEN g.stroke_code = 2 THEN 0 END
      WHEN 'depression'             THEN CASE WHEN g.depression_code = 1 THEN 1 WHEN g.depression_code = 2 THEN 0 END
      WHEN 'kidney_disease'         THEN CASE WHEN g.kidney_disease_code = 1 THEN 1 WHEN g.kidney_disease_code = 2 THEN 0 END
      WHEN 'asthma'                 THEN CASE WHEN g.asthma_code = 1 THEN 1 WHEN g.asthma_code = 2 THEN 0 END
      WHEN 'cost_barrier'           THEN CASE WHEN g.cost_barrier_code = 1 THEN 1 WHEN g.cost_barrier_code = 2 THEN 0 END
      WHEN 'no_personal_doctor'     THEN CASE WHEN g.personal_doctor_code = 3 THEN 1 WHEN g.personal_doctor_code IN (1,2) THEN 0 END
    END AS has_condition
  FROM grouped g CROSS JOIN conditions k
  WHERE g.diabetes_group IS NOT NULL
)
SELECT
  survey_year, condition, condition_label, diabetes_group,
  COUNT_IF(has_condition IN (0,1))                       AS valid_respondents,
  COUNT_IF(has_condition = 1)                            AS condition_yes_n,
  SUM(IFF(has_condition = 1, final_weight, NULL))        AS weighted_yes_sum,
  SUM(IFF(has_condition IN (0,1), final_weight, NULL))   AS weighted_valid_sum,
  100.0 * SUM(IFF(has_condition = 1, final_weight, NULL))
        / SUM(IFF(has_condition IN (0,1), final_weight, NULL)) AS condition_pct_weighted
FROM unpivoted
GROUP BY survey_year, condition, condition_label, diabetes_group
HAVING COUNT_IF(has_condition IN (0,1)) > 0;

-- Prevalence by combination of three risk factors: obese, current smoker, physically inactive.
CREATE OR REPLACE DYNAMIC TABLE BRFSS.GOLD.DIABETES_RISK_STACKING
  TARGET_LAG = DOWNSTREAM WAREHOUSE = COMPUTE_WH
  COMMENT = 'Diabetes prevalence by number and combination of risk factors (obese, smoker, inactive)'
AS
WITH flagged AS (
  SELECT survey_year, diabetes_code, final_weight,
    CASE WHEN bmi_category_code = 4 THEN 1 WHEN bmi_category_code IN (1,2,3) THEN 0 END AS obese_flag,
    CASE WHEN smoker_status_code IN (1,2) THEN 1 WHEN smoker_status_code IN (3,4) THEN 0 END AS smoker_flag,
    CASE WHEN exercise_any_code = 2 THEN 1 WHEN exercise_any_code = 1 THEN 0 END AS inactive_flag
  FROM BRFSS.SILVER.CLEAN
)
SELECT
  survey_year, obese_flag, smoker_flag, inactive_flag,
  obese_flag + smoker_flag + inactive_flag AS risk_factor_count,
  COUNT_IF(diabetes_code IN (1,2,3,4))                       AS valid_respondents,
  COUNT_IF(diabetes_code = 1)                                AS diabetes_yes,
  SUM(IFF(diabetes_code = 1, final_weight, NULL))            AS weighted_yes_sum,
  SUM(IFF(diabetes_code IN (1,2,3,4), final_weight, NULL))   AS weighted_valid_sum,
  100.0 * SUM(IFF(diabetes_code = 1, final_weight, NULL))
        / SUM(IFF(diabetes_code IN (1,2,3,4), final_weight, NULL)) AS prevalence_weighted_pct,
  COUNT_IF(diabetes_code IN (1,2,3,4)) < 30                  AS small_cell_suppressed
FROM flagged
WHERE obese_flag IS NOT NULL AND smoker_flag IS NOT NULL AND inactive_flag IS NOT NULL
GROUP BY survey_year, obese_flag, smoker_flag, inactive_flag;

GRANT SELECT ON ALL DYNAMIC TABLES IN SCHEMA BRFSS.GOLD TO ROLE PUBLIC;

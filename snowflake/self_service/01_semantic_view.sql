-- Self-service: a semantic view over the BRFSS star schema (snowflake/pipeline/03c_gold_star_schema.sql).
-- It tells Snowflake's AI (Cortex Analyst, Snowflake Intelligence) what each table means, how the
-- fact joins to each dimension, and the one correct way to compute each number. With the star,
-- Cortex Analyst can answer across dimensions: for example prevalence among smokers aged 45 to 64
-- in Texas. Quarantine is included so data-quality questions work too.

-- Kept in its own schema, not GOLD: BI tools that browse GOLD (Power BI) try to read every object
-- there as a table, and reading a semantic view that way fails.
CREATE SCHEMA IF NOT EXISTS BRFSS.SEMANTIC;
GRANT USAGE ON SCHEMA BRFSS.SEMANTIC TO ROLE PUBLIC;

CREATE OR REPLACE SEMANTIC VIEW BRFSS.SEMANTIC.BRFSS_DIABETES
  TABLES (
    responses AS BRFSS.GOLD.FACT_SURVEY_RESPONSE PRIMARY KEY (response_id)
      COMMENT = 'One row per survey response (CDC BRFSS), with its survey weight and answers.',
    states AS BRFSS.GOLD.DIM_STATE PRIMARY KEY (state_fips)
      COMMENT = 'US state, District of Columbia, Guam or Puerto Rico.',
    age_groups AS BRFSS.GOLD.DIM_AGE_GROUP PRIMARY KEY (age_group_code),
    sexes AS BRFSS.GOLD.DIM_SEX PRIMARY KEY (sex_code),
    education AS BRFSS.GOLD.DIM_EDUCATION PRIMARY KEY (education_code),
    income AS BRFSS.GOLD.DIM_INCOME PRIMARY KEY (income_code),
    general_health AS BRFSS.GOLD.DIM_GENERAL_HEALTH PRIMARY KEY (general_health_code),
    smoking AS BRFSS.GOLD.DIM_SMOKING_STATUS PRIMARY KEY (smoker_status_code),
    bmi AS BRFSS.GOLD.DIM_BMI_CATEGORY PRIMARY KEY (bmi_category_code),
    diabetes AS BRFSS.GOLD.DIM_DIABETES_STATUS PRIMARY KEY (diabetes_code),
    dates AS BRFSS.GOLD.DIM_DATE PRIMARY KEY (date),
    quarantine AS BRFSS.SILVER.QUARANTINE
      COMMENT = 'Survey records held back by a data-quality rule, one row per record.'
  )
  RELATIONSHIPS (
    response_state AS responses (state_fips) REFERENCES states,
    response_age AS responses (age_group_code) REFERENCES age_groups,
    response_sex AS responses (sex_code) REFERENCES sexes,
    response_education AS responses (education_code) REFERENCES education,
    response_income AS responses (income_code) REFERENCES income,
    response_health AS responses (general_health_code) REFERENCES general_health,
    response_smoking AS responses (smoker_status_code) REFERENCES smoking,
    response_bmi AS responses (bmi_category_code) REFERENCES bmi,
    response_diabetes AS responses (diabetes_code) REFERENCES diabetes,
    response_date AS responses (interview_date) REFERENCES dates
  )
  FACTS (
    responses.diabetes_weight AS diabetes_weight
      COMMENT = 'Survey weight if the respondent has diabetes, else 0. Numerator of prevalence.',
    responses.valid_answer_weight AS valid_answer_weight
      COMMENT = 'Survey weight if the diabetes answer is a valid yes or no, else 0. Denominator of prevalence.',
    responses.valid_answer AS valid_answer
      COMMENT = '1 if the diabetes answer is a valid yes or no, else 0.',
    responses.survey_weight AS survey_weight
      COMMENT = 'How many adults in the population this response represents.',
    responses.high_bp_weight AS IFF(has_high_blood_pressure = 1, survey_weight, 0),
    responses.high_bp_answered_weight AS IFF(has_high_blood_pressure IS NOT NULL, survey_weight, 0),
    responses.heart_attack_weight AS IFF(had_heart_attack = 1, survey_weight, 0),
    responses.heart_attack_answered_weight AS IFF(had_heart_attack IS NOT NULL, survey_weight, 0),
    responses.no_coverage_weight AS IFF(has_health_coverage = 0, survey_weight, 0),
    responses.coverage_answered_weight AS IFF(has_health_coverage IS NOT NULL, survey_weight, 0)
  )
  DIMENSIONS (
    responses.survey_year AS survey_year
      WITH SYNONYMS = ('year') COMMENT = 'Year of the CDC BRFSS survey file.',
    states.state_name AS state_name
      WITH SYNONYMS = ('state') COMMENT = 'US state name.',
    age_groups.age_group AS age_group
      WITH SYNONYMS = ('age') COMMENT = 'Five-year age group, for example 45 to 49.',
    age_groups.age_band AS age_band
      COMMENT = 'Broad age band: 18 to 44, 45 to 64, 65 and over.',
    sexes.sex AS sex WITH SYNONYMS = ('gender'),
    education.education AS education,
    education.education_level AS education_level
      COMMENT = 'Short education grouping: less than high school, high school, some college, college graduate.',
    income.income AS income COMMENT = 'Household income bracket.',
    income.income_band AS income_band COMMENT = 'Broad household income band.',
    general_health.general_health AS general_health WITH SYNONYMS = ('self-rated health'),
    smoking.smoking_status AS smoking_status WITH SYNONYMS = ('smoker', 'smoking'),
    smoking.is_current_smoker AS is_current_smoker,
    bmi.bmi_category AS bmi_category WITH SYNONYMS = ('weight', 'obesity'),
    diabetes.diabetes_status AS diabetes_status,
    dates.interview_month AS month_name COMMENT = 'Month the survey interview took place.',
    quarantine.rule_id AS rule_id
      WITH SYNONYMS = ('rule', 'reason', 'quality rule')
      COMMENT = 'Rules the record failed. D3 impossible interview date; W1 missing or non-positive survey weight; R1 BMI outside 12 to 70; C1 answer code not defined in the codebook.',
    quarantine.quarantine_year AS survey_year
      COMMENT = 'Survey year of the quarantined record.'
  )
  METRICS (
    responses.diabetes_prevalence_pct AS 100 * SUM(responses.diabetes_weight) / NULLIF(SUM(responses.valid_answer_weight), 0)
      WITH SYNONYMS = ('prevalence', 'diabetes rate', 'share with diabetes')
      COMMENT = 'Survey-weighted share of adults with diabetes, in percent. Correct for any combination of dimensions. Never average percentages.',
    responses.respondents AS SUM(responses.valid_answer)
      WITH SYNONYMS = ('sample size', 'number of respondents')
      COMMENT = 'Respondents with a valid diabetes answer (unweighted).',
    responses.adults_represented AS SUM(responses.survey_weight)
      WITH SYNONYMS = ('population', 'weighted population')
      COMMENT = 'Number of adults the responses represent (sum of survey weights).',
    responses.high_blood_pressure_pct AS 100 * SUM(responses.high_bp_weight) / NULLIF(SUM(responses.high_bp_answered_weight), 0)
      COMMENT = 'Survey-weighted share with high blood pressure, in percent. Not asked in 2014.',
    responses.heart_attack_pct AS 100 * SUM(responses.heart_attack_weight) / NULLIF(SUM(responses.heart_attack_answered_weight), 0)
      COMMENT = 'Survey-weighted share who had a heart attack, in percent.',
    responses.no_health_coverage_pct AS 100 * SUM(responses.no_coverage_weight) / NULLIF(SUM(responses.coverage_answered_weight), 0)
      WITH SYNONYMS = ('uninsured rate')
      COMMENT = 'Survey-weighted share without health care coverage, in percent.',
    quarantine.quarantined_records AS COUNT(quarantine.record_id)
      WITH SYNONYMS = ('quarantined rows', 'rejected records')
      COMMENT = 'Number of records held in quarantine.'
  )
  COMMENT = 'CDC BRFSS diabetes survey as a star schema: survey responses with state, age, sex, education, income, health, smoking, BMI and date; plus data-quality quarantine.';

GRANT SELECT ON SEMANTIC VIEW BRFSS.SEMANTIC.BRFSS_DIABETES TO ROLE PUBLIC;

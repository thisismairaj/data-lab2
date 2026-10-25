-- Gold star schema for BRFSS: one fact table at the grain of one survey response, joined to
-- dimensions that describe the respondent. Built on top of SILVER.CLEAN, next to the six
-- summary tables (03_gold.sql, 03b_gold_breakdowns.sql), which keep working unchanged.
--
-- Why a star: the summary tables answer one slice each (prevalence by state, or by age, ...).
-- The fact table keeps every response with its survey weight, so prevalence can be computed for
-- any combination: for example smokers aged 45 to 64 in Texas.
--
-- Prevalence is survey-weighted: sum of weights of respondents with diabetes, divided by the sum
-- of weights of respondents with a valid yes/no answer. The fact carries both weights per row.
--
-- Labels come from the CDC BRFSS 2015 codebook (docs/codebook15_llcp.json). An unanswered
-- question gets code -1 ("Not asked or missing") instead of a NULL key, so every response joins
-- to every dimension.

USE SCHEMA BRFSS.GOLD;

-- ---------------------------------------------------------------- dimensions (reference data)

CREATE OR REPLACE TABLE DIM_STATE (state_fips VARCHAR PRIMARY KEY, state_name VARCHAR)
  COMMENT = 'US state, District of Columbia, Guam or Puerto Rico, by FIPS code'
AS SELECT column1, column2 FROM VALUES
  ('01','Alabama'),('02','Alaska'),('04','Arizona'),('05','Arkansas'),('06','California'),('08','Colorado'),
  ('09','Connecticut'),('10','Delaware'),('11','District of Columbia'),('12','Florida'),('13','Georgia'),
  ('15','Hawaii'),('16','Idaho'),('17','Illinois'),('18','Indiana'),('19','Iowa'),('20','Kansas'),
  ('21','Kentucky'),('22','Louisiana'),('23','Maine'),('24','Maryland'),('25','Massachusetts'),
  ('26','Michigan'),('27','Minnesota'),('28','Mississippi'),('29','Missouri'),('30','Montana'),
  ('31','Nebraska'),('32','Nevada'),('33','New Hampshire'),('34','New Jersey'),('35','New Mexico'),
  ('36','New York'),('37','North Carolina'),('38','North Dakota'),('39','Ohio'),('40','Oklahoma'),
  ('41','Oregon'),('42','Pennsylvania'),('44','Rhode Island'),('45','South Carolina'),('46','South Dakota'),
  ('47','Tennessee'),('48','Texas'),('49','Utah'),('50','Vermont'),('51','Virginia'),('53','Washington'),
  ('54','West Virginia'),('55','Wisconsin'),('56','Wyoming'),('66','Guam'),('72','Puerto Rico');

CREATE OR REPLACE TABLE DIM_AGE_GROUP (age_group_code INT PRIMARY KEY, age_group VARCHAR, age_band VARCHAR)
  COMMENT = 'Five-year age group, plus a broader band for simpler grouping'
AS SELECT column1, column2, column3 FROM VALUES
  (1,'18 to 24','18 to 44'),(2,'25 to 29','18 to 44'),(3,'30 to 34','18 to 44'),(4,'35 to 39','18 to 44'),
  (5,'40 to 44','18 to 44'),(6,'45 to 49','45 to 64'),(7,'50 to 54','45 to 64'),(8,'55 to 59','45 to 64'),
  (9,'60 to 64','45 to 64'),(10,'65 to 69','65 and over'),(11,'70 to 74','65 and over'),
  (12,'75 to 79','65 and over'),(13,'80 or older','65 and over'),
  (14,'Don''t know, refused or missing','Unknown'),(-1,'Not asked or missing','Unknown');

CREATE OR REPLACE TABLE DIM_SEX (sex_code INT PRIMARY KEY, sex VARCHAR)
  COMMENT = 'Respondent sex'
AS SELECT column1, column2 FROM VALUES (1,'Male'),(2,'Female'),(-1,'Not asked or missing');

CREATE OR REPLACE TABLE DIM_EDUCATION (education_code INT PRIMARY KEY, education VARCHAR, education_level VARCHAR)
  COMMENT = 'Highest education level, plus a short grouping'
AS SELECT column1, column2, column3 FROM VALUES
  (1,'Never attended school or only kindergarten','Less than high school'),
  (2,'Grades 1 through 8','Less than high school'),
  (3,'Grades 9 through 11','Less than high school'),
  (4,'High school graduate or GED','High school'),
  (5,'Some college or technical school','Some college'),
  (6,'College graduate','College graduate'),
  (9,'Refused','Unknown'),(-1,'Not asked or missing','Unknown');

CREATE OR REPLACE TABLE DIM_INCOME (income_code INT PRIMARY KEY, income VARCHAR, income_band VARCHAR, sort_order INT)
  COMMENT = 'Annual household income bracket, plus a broader band'
AS SELECT column1, column2, column3, column4 FROM VALUES
  (1,'Less than $10,000','Under $25,000',1),(2,'$10,000 to $15,000','Under $25,000',2),
  (3,'$15,000 to $20,000','Under $25,000',3),(4,'$20,000 to $25,000','Under $25,000',4),
  (5,'$25,000 to $35,000','$25,000 to $50,000',5),(6,'$35,000 to $50,000','$25,000 to $50,000',6),
  (7,'$50,000 to $75,000','$50,000 to $75,000',7),(8,'$75,000 or more','$75,000 or more',8),
  (77,'Don''t know','Unknown',9),(99,'Refused','Unknown',10),(-1,'Not asked or missing','Unknown',11);

CREATE OR REPLACE TABLE DIM_GENERAL_HEALTH (general_health_code INT PRIMARY KEY, general_health VARCHAR)
  COMMENT = 'Self-rated general health'
AS SELECT column1, column2 FROM VALUES
  (1,'Excellent'),(2,'Very good'),(3,'Good'),(4,'Fair'),(5,'Poor'),
  (7,'Don''t know'),(9,'Refused'),(-1,'Not asked or missing');

CREATE OR REPLACE TABLE DIM_SMOKING_STATUS (smoker_status_code INT PRIMARY KEY, smoking_status VARCHAR, is_current_smoker BOOLEAN)
  COMMENT = 'Smoking status'
AS SELECT column1, column2, column3 FROM VALUES
  (1,'Smokes every day',TRUE),(2,'Smokes some days',TRUE),(3,'Former smoker',FALSE),
  (4,'Never smoked',FALSE),(9,'Don''t know, refused or missing',NULL),(-1,'Not asked or missing',NULL);

CREATE OR REPLACE TABLE DIM_BMI_CATEGORY (bmi_category_code INT PRIMARY KEY, bmi_category VARCHAR)
  COMMENT = 'Body mass index category'
AS SELECT column1, column2 FROM VALUES
  (1,'Underweight'),(2,'Normal weight'),(3,'Overweight'),(4,'Obese'),(-1,'Not available');

CREATE OR REPLACE TABLE DIM_DIABETES_STATUS (diabetes_code INT PRIMARY KEY, diabetes_status VARCHAR, counts_as_diabetes BOOLEAN)
  COMMENT = 'Answer to "Ever told you have diabetes". Only "Yes" counts as diabetes in prevalence.'
AS SELECT column1, column2, column3 FROM VALUES
  (1,'Yes',TRUE),(2,'Yes, only during pregnancy',FALSE),(3,'No',FALSE),
  (4,'No, pre-diabetes or borderline',FALSE),(7,'Don''t know',NULL),(9,'Refused',NULL),
  (-1,'Not asked or missing',NULL);

-- ---------------------------------------------------------------- fact

CREATE OR REPLACE DYNAMIC TABLE FACT_SURVEY_RESPONSE
  TARGET_LAG = DOWNSTREAM
  WAREHOUSE = COMPUTE_WH
  COMMENT = 'One row per published survey response, with its survey weight and answer codes'
AS
SELECT
  survey_year || '-' || state_fips || '-' || seqno                    AS response_id,
  survey_year,
  interview_date,
  state_fips,
  COALESCE(age_group_code::INT, -1)                                   AS age_group_code,
  COALESCE(sex_code::INT, -1)                                         AS sex_code,
  COALESCE(education_code::INT, -1)                                   AS education_code,
  COALESCE(income_code::INT, -1)                                      AS income_code,
  COALESCE(general_health_code::INT, -1)                              AS general_health_code,
  COALESCE(smoker_status_code::INT, -1)                               AS smoker_status_code,
  COALESCE(bmi_category_code::INT, -1)                                AS bmi_category_code,
  COALESCE(diabetes_code::INT, -1)                                    AS diabetes_code,
  bmi,
  final_weight                                                        AS survey_weight,
  -- Prevalence building blocks: weight counted in the numerator / denominator, else 0.
  IFF(diabetes_code = 1, final_weight, 0)                             AS diabetes_weight,
  IFF(diabetes_code IN (1,2,3,4), final_weight, 0)                    AS valid_answer_weight,
  IFF(diabetes_code IN (1,2,3,4), 1, 0)                               AS valid_answer,
  IFF(diabetes_code = 1, 1, 0)                                        AS has_diabetes,
  -- Other conditions and access to care: 1 yes, 0 no, NULL not asked or no valid answer.
  CASE WHEN high_bp_code = 1 THEN 1 WHEN high_bp_code IN (3,4) THEN 0 END                   AS has_high_blood_pressure,
  CASE WHEN high_cholesterol_code = 1 THEN 1 WHEN high_cholesterol_code = 2 THEN 0 END      AS has_high_cholesterol,
  CASE WHEN heart_attack_code = 1 THEN 1 WHEN heart_attack_code = 2 THEN 0 END              AS had_heart_attack,
  CASE WHEN heart_disease_code = 1 THEN 1 WHEN heart_disease_code = 2 THEN 0 END            AS has_heart_disease,
  CASE WHEN stroke_code = 1 THEN 1 WHEN stroke_code = 2 THEN 0 END                          AS had_stroke,
  CASE WHEN depression_code = 1 THEN 1 WHEN depression_code = 2 THEN 0 END                  AS has_depression,
  CASE WHEN kidney_disease_code = 1 THEN 1 WHEN kidney_disease_code = 2 THEN 0 END          AS has_kidney_disease,
  CASE WHEN asthma_code = 1 THEN 1 WHEN asthma_code = 2 THEN 0 END                          AS has_asthma,
  CASE WHEN cost_barrier_code = 1 THEN 1 WHEN cost_barrier_code = 2 THEN 0 END              AS skipped_care_due_to_cost,
  CASE WHEN health_plan_code = 1 THEN 1 WHEN health_plan_code = 2 THEN 0 END                AS has_health_coverage,
  CASE WHEN exercise_any_code = 1 THEN 1 WHEN exercise_any_code = 2 THEN 0 END              AS exercised_past_month
FROM BRFSS.SILVER.CLEAN;

-- Calendar of interview dates actually in the data.
CREATE OR REPLACE DYNAMIC TABLE DIM_DATE
  TARGET_LAG = DOWNSTREAM
  WAREHOUSE = COMPUTE_WH
  COMMENT = 'One row per interview date in the data'
AS
SELECT DISTINCT
  interview_date                         AS date,
  YEAR(interview_date)                   AS year,
  QUARTER(interview_date)                AS quarter,
  MONTH(interview_date)                  AS month,
  MONTHNAME(interview_date)              AS month_name,
  DAYNAME(interview_date)                AS day_name
FROM FACT_SURVEY_RESPONSE
WHERE interview_date IS NOT NULL;

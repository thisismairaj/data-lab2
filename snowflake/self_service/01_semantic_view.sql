-- Self-service: the Snowflake counterpart of the Databricks Genie space (databricks/self_service/genie_agent.json).
-- A semantic view tells Snowflake's AI (Cortex Analyst, Snowflake Intelligence) what the tables
-- mean: names, synonyms and the one correct way to compute each number. Same two tables and
-- the same descriptions as the Genie space.

CREATE OR REPLACE SEMANTIC VIEW BRFSS.GOLD.BRFSS_DIABETES
  TABLES (
    prevalence AS BRFSS.GOLD.DIABETES_PREVALENCE_STATE
      PRIMARY KEY (state_fips, survey_year)
      COMMENT = 'Survey-weighted diabetes prevalence, one row per US state per survey year (CDC BRFSS).',
    quarantine AS BRFSS.SILVER.QUARANTINE
      COMMENT = 'Survey records held back by a data-quality rule, one row per record.'
  )
  FACTS (
    prevalence.weighted_yes AS weighted_yes_sum
      COMMENT = 'Sum of survey weights over respondents with diabetes; numerator of weighted prevalence.',
    prevalence.weighted_valid AS weighted_valid_sum
      COMMENT = 'Sum of survey weights over valid respondents; denominator of weighted prevalence.',
    prevalence.valid_n AS valid_respondents
      COMMENT = 'Respondents with a valid yes/no diabetes answer.',
    prevalence.yes_n AS diabetes_yes
      COMMENT = 'Unweighted count of respondents who answered yes to diabetes.'
  )
  DIMENSIONS (
    prevalence.state_name AS state_name
      WITH SYNONYMS = ('state')
      COMMENT = 'US state name (50 states, District of Columbia, Guam, Puerto Rico).',
    prevalence.survey_year AS survey_year
      WITH SYNONYMS = ('year')
      COMMENT = 'Year of the CDC BRFSS survey file.',
    quarantine.rule_id AS rule_id
      WITH SYNONYMS = ('rule', 'reason', 'quality rule')
      COMMENT = 'Comma-separated rules the record failed. D3 = impossible interview date; W1 = missing or non-positive survey weight; R1 = BMI outside 12 to 70; C1 = answer code not defined in the codebook.',
    quarantine.quarantine_year AS survey_year
      COMMENT = 'Survey year of the quarantined record.'
  )
  METRICS (
    prevalence.weighted_prevalence_pct AS 100 * SUM(prevalence.weighted_yes) / SUM(prevalence.weighted_valid)
      WITH SYNONYMS = ('prevalence', 'diabetes rate', 'diabetes percentage')
      COMMENT = 'Survey-weighted diabetes prevalence in percent (0 to 100). Correct at any level: state, year or national. Never average state percentages.',
    prevalence.respondents AS SUM(prevalence.valid_n)
      WITH SYNONYMS = ('sample size', 'respondents')
      COMMENT = 'Respondents with a valid diabetes answer.',
    prevalence.diabetes_yes_count AS SUM(prevalence.yes_n)
      COMMENT = 'Unweighted number of respondents reporting diabetes.',
    quarantine.quarantined_records AS COUNT(quarantine.record_id)
      WITH SYNONYMS = ('quarantined rows', 'rejected records')
      COMMENT = 'Number of records held in quarantine.'
  )
  COMMENT = 'CDC BRFSS diabetes prevalence by state and year, plus data-quality quarantine.';

GRANT SELECT ON SEMANTIC VIEW BRFSS.GOLD.BRFSS_DIABETES TO ROLE PUBLIC;

SELECT survey_year, state_fips, state_name, valid_respondents, diabetes_yes, weighted_yes_sum, weighted_valid_sum, prevalence_weighted_pct / 100.0 AS prevalence_ratio
FROM gold.diabetes_prevalence_state

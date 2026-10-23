SELECT rule_id, survey_year, count(*) AS quarantined_rows FROM silver.quarantine GROUP BY rule_id, survey_year

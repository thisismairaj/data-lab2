-- Lakeflow Declarative Pipeline: the actual clean/quarantine split.
-- Same rule set as the manual build (docs/schema_contract.md), just S1/K1/C1 left out of
-- this first cut to keep the demo focused - R1 (bmi range) is the one rule that actually
-- fires in this dataset, so it's the one that matters for proving the split works.
-- Both tables are STREAMING TABLEs so they grow incrementally as bronze grows, same as
-- everything upstream - this is what makes the whole chain incremental end to end.

CREATE OR REFRESH STREAMING TABLE silver_clean
COMMENT 'Published records: passed every rule. Query this, never bronze or silver_staged.'
AS
SELECT state_fips, survey_year, seqno, interview_date, sex_code, age_group_code,
       education_code, income_code, general_health_code, health_plan_code,
       smoker_status_code, exercise_any_code, diabetes_code, bmi, bmi_category_code,
       final_weight, _source_file, _loaded_at
FROM STREAM silver_staged
WHERE interview_date IS NOT NULL                              -- D3
  AND (final_weight IS NOT NULL AND final_weight > 0)          -- W1
  AND (bmi IS NULL OR (bmi BETWEEN 12 AND 70));                -- R1

CREATE OR REFRESH STREAMING TABLE silver_quarantine
COMMENT 'Records that failed at least one rule. Nothing is dropped without a row here.'
AS
SELECT
  seqno AS record_id, 'brfss' AS dataset_id,
  concat_ws(',',
    CASE WHEN interview_date IS NULL THEN 'D3' END,
    CASE WHEN final_weight IS NULL OR final_weight <= 0 THEN 'W1' END,
    CASE WHEN bmi IS NOT NULL AND (bmi < 12 OR bmi > 70) THEN 'R1' END
  ) AS rule_id,
  'quarantine' AS severity,
  to_json(named_struct('state_fips', state_fips, 'seqno', seqno, 'bmi', bmi,
                        'final_weight', final_weight))          AS raw_payload,
  'Failed one or more contract rules - see rule_id' AS reason,
  'new' AS status
FROM STREAM silver_staged
WHERE interview_date IS NULL
   OR final_weight IS NULL OR final_weight <= 0
   OR (bmi IS NOT NULL AND (bmi < 12 OR bmi > 70));

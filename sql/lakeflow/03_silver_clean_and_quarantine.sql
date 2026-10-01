-- Lakeflow Declarative Pipeline: the actual clean/quarantine split.
-- Same rule set as the manual build (schema_contract.md (local notes)). S1/K1 still left out (state
-- and duplicate-key checks never fire on this data's shape); C1 (code validity) ADDED
-- 2026-09-29 after real corrupted rows were found once 2013/2014 data was loaded:
-- bmi_category_code values like 2281.0 (should only be 1-4) and smoker_status_code=5
-- (should only be 1-4 or 9) - these look like values that landed in the wrong column for
-- a handful of rows. The original cut skipped C1 "to keep the demo focused" - that was a
-- real gap, not a stylistic choice, and it let corrupted data straight into gold silently.
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
  AND (bmi IS NULL OR (bmi BETWEEN 12 AND 70))                 -- R1
  -- C1: each code column must be NULL or a value the codebook actually defines
  AND (sex_code IS NULL OR sex_code IN (1,2))
  AND (age_group_code IS NULL OR age_group_code IN (1,2,3,4,5,6,7,8,9,10,11,12,13,14))
  AND (education_code IS NULL OR education_code IN (1,2,3,4,5,6,9))
  AND (income_code IS NULL OR income_code IN (1,2,3,4,5,6,7,8,77,99))
  AND (general_health_code IS NULL OR general_health_code IN (1,2,3,4,5,7,9))
  AND (health_plan_code IS NULL OR health_plan_code IN (1,2,7,9))
  AND (smoker_status_code IS NULL OR smoker_status_code IN (1,2,3,4,9))
  AND (exercise_any_code IS NULL OR exercise_any_code IN (1,2,7,9))
  AND (diabetes_code IS NULL OR diabetes_code IN (1,2,3,4,7,9))
  AND (bmi_category_code IS NULL OR bmi_category_code IN (1,2,3,4));

CREATE OR REFRESH STREAMING TABLE silver_quarantine
COMMENT 'Records that failed at least one rule. Nothing is dropped without a row here.'
AS
SELECT
  seqno AS record_id, 'brfss' AS dataset_id,
  concat_ws(',',
    CASE WHEN interview_date IS NULL THEN 'D3' END,
    CASE WHEN final_weight IS NULL OR final_weight <= 0 THEN 'W1' END,
    CASE WHEN bmi IS NOT NULL AND (bmi < 12 OR bmi > 70) THEN 'R1' END,
    CASE WHEN (sex_code IS NOT NULL AND sex_code NOT IN (1,2))
           OR (age_group_code IS NOT NULL AND age_group_code NOT IN (1,2,3,4,5,6,7,8,9,10,11,12,13,14))
           OR (education_code IS NOT NULL AND education_code NOT IN (1,2,3,4,5,6,9))
           OR (income_code IS NOT NULL AND income_code NOT IN (1,2,3,4,5,6,7,8,77,99))
           OR (general_health_code IS NOT NULL AND general_health_code NOT IN (1,2,3,4,5,7,9))
           OR (health_plan_code IS NOT NULL AND health_plan_code NOT IN (1,2,7,9))
           OR (smoker_status_code IS NOT NULL AND smoker_status_code NOT IN (1,2,3,4,9))
           OR (exercise_any_code IS NOT NULL AND exercise_any_code NOT IN (1,2,7,9))
           OR (diabetes_code IS NOT NULL AND diabetes_code NOT IN (1,2,3,4,7,9))
           OR (bmi_category_code IS NOT NULL AND bmi_category_code NOT IN (1,2,3,4))
         THEN 'C1' END
  ) AS rule_id,
  'quarantine' AS severity,
  to_json(named_struct('state_fips', state_fips, 'seqno', seqno, 'bmi', bmi,
                        'final_weight', final_weight, 'smoker_status_code', smoker_status_code,
                        'bmi_category_code', bmi_category_code))  AS raw_payload,
  'Failed one or more contract rules - see rule_id' AS reason,
  'new' AS status
FROM STREAM silver_staged
WHERE interview_date IS NULL
   OR final_weight IS NULL OR final_weight <= 0
   OR (bmi IS NOT NULL AND (bmi < 12 OR bmi > 70))
   OR (sex_code IS NOT NULL AND sex_code NOT IN (1,2))
   OR (age_group_code IS NOT NULL AND age_group_code NOT IN (1,2,3,4,5,6,7,8,9,10,11,12,13,14))
   OR (education_code IS NOT NULL AND education_code NOT IN (1,2,3,4,5,6,9))
   OR (income_code IS NOT NULL AND income_code NOT IN (1,2,3,4,5,6,7,8,77,99))
   OR (general_health_code IS NOT NULL AND general_health_code NOT IN (1,2,3,4,5,7,9))
   OR (health_plan_code IS NOT NULL AND health_plan_code NOT IN (1,2,7,9))
   OR (smoker_status_code IS NOT NULL AND smoker_status_code NOT IN (1,2,3,4,9))
   OR (exercise_any_code IS NOT NULL AND exercise_any_code NOT IN (1,2,7,9))
   OR (diabetes_code IS NOT NULL AND diabetes_code NOT IN (1,2,3,4,7,9))
   OR (bmi_category_code IS NOT NULL AND bmi_category_code NOT IN (1,2,3,4));

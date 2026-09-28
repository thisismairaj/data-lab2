-- Lakeflow Declarative Pipeline: silver staging.
-- Applies the same corrections as the manual build (D1 strip byte-wrapper, Z1 zero-pad
-- state) and casts codes to real numbers. Declares EXPECTATIONS for the checks we care
-- about - these are Lakeflow's native data-quality feature: every run, the pipeline
-- counts how many rows pass/fail each one and shows it in the pipeline's UI/event log,
-- WITHOUT dropping anything here (no ON VIOLATION clause = observe only). The actual
-- clean/quarantine split still happens explicitly in the next file, same as our manual
-- build - expectations alone don't give us a queryable quarantine table with reasons,
-- which docs/schema_contract.md requires.
CREATE OR REFRESH STREAMING TABLE silver_staged (
  CONSTRAINT plausible_bmi   EXPECT (bmi IS NULL OR (bmi BETWEEN 12 AND 70)),   -- R1
  CONSTRAINT positive_weight EXPECT (final_weight > 0),                         -- W1
  CONSTRAINT real_date       EXPECT (interview_date IS NOT NULL)                -- D3
)
COMMENT 'Typed and corrected, before the clean/quarantine split'
AS
SELECT
  lpad(CAST(CAST(_STATE AS DOUBLE) AS INT), 2, '0')  AS state_fips,   -- Z1
  -- BUG FIX 2026-09-28: this was hardcoded '2015 AS survey_year', copied from the
  -- Free-Edition build which was genuinely 2015-only. Once 2014.csv landed in the same
  -- folder, every 2014 row was silently mislabeled as survey_year=2015 - caught via the
  -- gold-by-year verification query, not before. Derived from the filename instead, since
  -- _source_file is already tracked per row from bronze.
  CAST(regexp_extract(_source_file, '(\\d{4})', 1) AS INT) AS survey_year,
  CAST(CAST(SEQNO AS DOUBLE) AS BIGINT)               AS seqno,
  to_date(
    CASE WHEN regexp_replace(IDATE, "^b'|'$", '') LIKE ' %'                     -- D2
         THEN concat('0', substring(regexp_replace(IDATE, "^b'|'$", ''), 2))
         ELSE regexp_replace(IDATE, "^b'|'$", '')                               -- D1
    END, 'MMddyyyy')                                  AS interview_date,
  CAST(SEX AS DOUBLE)         AS sex_code,
  CAST(_AGEG5YR AS DOUBLE)    AS age_group_code,
  CAST(EDUCA AS DOUBLE)       AS education_code,
  CAST(INCOME2 AS DOUBLE)     AS income_code,
  CAST(GENHLTH AS DOUBLE)     AS general_health_code,
  CAST(HLTHPLN1 AS DOUBLE)    AS health_plan_code,
  CAST(_SMOKER3 AS DOUBLE)    AS smoker_status_code,
  CAST(EXERANY2 AS DOUBLE)    AS exercise_any_code,
  CAST(DIABETE3 AS DOUBLE)    AS diabetes_code,
  CAST(_BMI5 AS DOUBLE) / 100 AS bmi,
  CAST(_BMI5CAT AS DOUBLE)    AS bmi_category_code,
  CAST(_LLCPWT AS DOUBLE)     AS final_weight,
  _source_file, _loaded_at
FROM STREAM bronze_brfss;

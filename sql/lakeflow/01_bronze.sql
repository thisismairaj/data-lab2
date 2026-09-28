-- Lakeflow Declarative Pipeline: bronze layer.
-- CREATE STREAMING TABLE (not CREATE TABLE AS): this is the declarative-pipeline
-- equivalent of Auto Loader - it watches the /Volumes/workspace/bronze/landing/ FOLDER,
-- not one file, and on every pipeline update only ingests files it hasn't seen before
-- (tracked via an internal checkpoint). This is what we're testing: add 2014.csv to the
-- same folder later, re-run, and bronze should grow by exactly 2014's row count, not
-- reprocess 2015 from scratch.
--
-- Schema left to INFERENCE on purpose (no hardcoded STRUCT<...>, unlike our manual
-- Free-Edition build) so we can observe real behavior when 2014's different column set
-- lands in the same folder, instead of forcing a predetermined outcome.
CREATE OR REFRESH STREAMING TABLE bronze_brfss
COMMENT 'BRFSS raw as delivered, all text, one row per source CSV row. Auto-detects new files in the landing folder.'
AS
SELECT
  *,
  _metadata.file_name      AS _source_file,   -- which file this row came from (built-in column, not one we add manually)
  current_timestamp()      AS _loaded_at
FROM STREAM read_files(
  '/Volumes/workspace/bronze/landing/',
  format => 'csv',
  header => true,
  schemaEvolutionMode => 'addNewColumns'  -- if a new file introduces a column 2015 didn't have, add it rather than fail
);

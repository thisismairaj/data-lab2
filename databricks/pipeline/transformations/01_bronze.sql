-- Bronze: every source column kept as text, exactly as delivered, plus the source file name
-- and load time. Same table as Snowflake's BRFSS.BRONZE.BRFSS_RAW (snowflake/pipeline/01_bronze.sql).
-- STREAM read_files is Auto Loader: it watches the landing folder and, on each pipeline
-- update, reads only files it has not seen before.
CREATE OR REFRESH STREAMING TABLE bronze.brfss_raw
COMMENT 'BRFSS raw as delivered, all text, one row per source CSV row'
AS
SELECT
  *,
  _metadata.file_name   AS _source_file,
  current_timestamp()   AS _loaded_at
FROM STREAM read_files(
  '/Volumes/brfss/bronze/landing/',
  format => 'csv',
  header => true,
  -- The CSV escapes a quote inside a quoted field by doubling it (""), the standard way.
  -- Spark's default escape is a backslash, which split a free-text answer at its comma and
  -- shifted later columns on 13 rows of 2014. Snowflake reads "" correctly by default.
  escape => '"',
  -- BPHIGH4 and TOLDHI2 (blood pressure, cholesterol) are not in every year's file (2014 lacks
  -- them). Declaring them means they always exist, NULL for years that did not ask.
  schemaHints => 'BPHIGH4 STRING, TOLDHI2 STRING',
  schemaEvolutionMode => 'addNewColumns'  -- a later file with extra columns adds them instead of failing
);

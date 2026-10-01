-- Databricks Phase 2 (full). Run on the serverless SQL warehouse, catalog `workspace`.
-- Run on 2026-09-28. Loads the real 2015.csv (541 MB, 441,456 rows, 330 columns) to bronze.
-- This supersedes the 50k sample in 02_phase2_sample_load.sql, which stays in git history
-- as the proof-of-concept run (that table, bronze.brfss_2015_sample, is left in place too).
--
-- Verified after running:
--   row count    = 441,456  (exact match with `wc -l` on the local file, minus the header)
--   column count = 333      (330 source columns + 3 load-metadata columns below)
--   distinct states in the raw _STATE column = 53 (50 states + DC + Guam + Puerto Rico)

-- The file was uploaded separately, outside SQL, with:
--   databricks fs cp <local 2015.csv> dbfs:/Volumes/workspace/bronze/landing/2015.csv

DROP TABLE IF EXISTS workspace.bronze.brfss_2015;

-- CREATE TABLE ... AS SELECT (CTAS): read the CSV once, materialize it as a managed
-- Delta table. We do NOT use COPY INTO here because CTAS is simpler for a one-shot
-- full reload; COPY INTO would matter once we're doing incremental loads (out of
-- scope for this project - see scope_and_gaps.md (local notes)).
CREATE TABLE workspace.bronze.brfss_2015 AS
SELECT
  *,                                      -- every one of the 330 source columns, untouched, as text
  '2015.csv'               AS _source_file,   -- which file this row came from (bronze keeps a full audit trail)
  current_timestamp()      AS _loaded_at,     -- when this row was loaded
  'phase2-full-20260928'   AS _run_id         -- which pipeline run produced it; ties back to ops.pipeline_metrics
FROM read_files(
  '/Volumes/workspace/bronze/landing/2015.csv',
  format => 'csv',
  header => true,
  -- read_files needs a full struct type, one `column_name` STRING per source column - a bare
  -- 'STRING' is rejected (see learning_log.md (local notes), "Day 2026-09-28"). The 330-entry struct
  -- string is generated from the CSV header by a script rather than typed by hand here, to
  -- avoid 330 lines of boilerplate; the principle - every bronze column stays STRING, nothing
  -- is silently coerced - is the part that matters and is spelled out in schema_contract.md (local notes).
  schema => 'STRUCT<... all 330 source columns as STRING ...>'
);

-- Verification queries (metrics.md (local notes) I1; schema_contract.md (local notes) publication gate)
SELECT count(*) FROM workspace.bronze.brfss_2015;                             -- expect 441456
SELECT count(*) FROM (
  SELECT column_name FROM workspace.information_schema.columns
  WHERE table_catalog='workspace' AND table_schema='bronze' AND table_name='brfss_2015'
);                                                                             -- expect 333
SELECT count(DISTINCT _STATE) FROM workspace.bronze.brfss_2015;               -- expect 53

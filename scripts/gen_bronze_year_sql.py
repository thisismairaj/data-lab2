"""Generates one bronze CTAS SQL file per BRFSS year (2011-2014), matching the exact
pattern already used and verified for 2015 (sql/databricks/05_phase2_full_load.sql):
every source column stays STRING (bronze = raw, untouched - see docs/schema_contract.md),
the STRUCT schema is generated from each file's own real CSV header (not hand-typed,
since column count differs every year: 454/359/336/279/330 - see docs/scope_and_gaps.md),
and three load-metadata columns are added (_source_file, _loaded_at, _run_id).

Run once locally (reads the local CSVs only for their header row - the actual data is
read by Databricks from the volume, not from here).
"""
import csv, os

HERE = os.path.dirname(os.path.abspath(__file__))
ARCHIVE = os.environ.get("BRFSS_ARCHIVE_DIR", os.path.join(HERE, "..", "data", "archive"))
OUT_DIR = os.path.join(HERE, "..", "sql", "databricks")
RUN_ID = "phase2-5yr-extension-20260929"

YEARS = [2011, 2012, 2013, 2014]
LETTER = {2011: "a", 2012: "b", 2013: "c", 2014: "d"}


def struct_schema(year):
    with open(os.path.join(ARCHIVE, f"{year}.csv"), encoding="utf-8", newline="") as f:
        header = next(csv.reader(f))
    cols = ", ".join(f"`{c}` STRING" for c in header)
    return f"STRUCT<{cols}>", len(header)


for year in YEARS:
    schema, ncols = struct_schema(year)
    sql = f'''-- Databricks Free Edition: bronze for {year}, same pattern as 05_phase2_full_load.sql
-- (2015). Part of the 5-year extension (2026-09-29) - each year gets its own bronze
-- table because each year's CSV has a different column set ({ncols} columns for {year};
-- see docs/scope_and_gaps.md for the full 454/359/336/279/330 breakdown). Silver unions
-- all 5 bronze tables together (see 03b_silver_multiyear.sql).

DROP TABLE IF EXISTS workspace.bronze.brfss_{year};

CREATE TABLE workspace.bronze.brfss_{year} AS
SELECT
  *,
  '{year}.csv'                  AS _source_file,
  current_timestamp()           AS _loaded_at,
  '{RUN_ID}'                    AS _run_id
FROM read_files(
  '/Volumes/workspace/bronze/landing/{year}.csv',
  format => 'csv',
  header => true,
  schema => '{schema}'
);

-- Verification (docs/scope_and_gaps.md Step 1 profile numbers)
SELECT count(*) FROM workspace.bronze.brfss_{year};                             -- expect the {year} row count from scope_and_gaps.md
SELECT count(*) FROM (
  SELECT column_name FROM workspace.information_schema.columns
  WHERE table_catalog='workspace' AND table_schema='bronze' AND table_name='brfss_{year}'
);                                                                                -- expect {ncols + 3} ({ncols} source + 3 load-metadata)
'''
    out_path = os.path.join(OUT_DIR, f"05{LETTER[year]}_bronze_{year}.sql")
    with open(out_path, "w", encoding="utf-8") as f:
        f.write(sql)
    print(f"wrote {out_path} ({ncols} source columns)")

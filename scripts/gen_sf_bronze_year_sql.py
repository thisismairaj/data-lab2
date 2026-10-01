"""Generates one Snowflake bronze CTAS+COPY INTO SQL file per BRFSS year (2011-2014),
mirroring sql/snowflake/02_phase2_bronze_load.sql (2015) exactly in shape: an explicit
VARCHAR column list (Snowflake has no single-string STRUCT shortcut like Databricks'
read_files), a positional COPY INTO ($1..$N in CSV column order), METADATA$FILENAME for
provenance. Column list/order generated from each year's real CSV header, not hand-typed
(column count differs every year: 454/359/336/279/330 - docs/scope_and_gaps.md).
"""
import csv, os

HERE = os.path.dirname(os.path.abspath(__file__))
ARCHIVE = os.environ.get("BRFSS_ARCHIVE_DIR", os.path.join(HERE, "..", "data", "archive"))
OUT_DIR = os.path.join(HERE, "..", "sql", "snowflake")
RUN_ID = "phase2-5yr-extension-20260929"
YEARS = [2011, 2012, 2013, 2014]
LETTER = {2011: "a", 2012: "b", 2013: "c", 2014: "d"}


def header(year):
    with open(os.path.join(ARCHIVE, f"{year}.csv"), encoding="utf-8", newline="") as f:
        return next(csv.reader(f))


for year in YEARS:
    cols = header(year)
    col_defs = ",\n".join(f'  "{c}" VARCHAR' for c in cols)
    positional = ", ".join(f"${i+1}" for i in range(len(cols)))
    sql = f'''-- Snowflake: bronze for {year}, same pattern as 02_phase2_bronze_load.sql (2015).
-- Part of the 5-year extension (2026-09-29) - each year gets its own bronze table
-- because each year's CSV has a different column set ({len(cols)} columns for {year};
-- see docs/scope_and_gaps.md). Silver unions all 5 bronze tables together.
--
-- The file must be uploaded to the stage first (client-side, via the Python connector -
-- see scripts/sf_upload_stage.py):
--   PUT file://<local path>/{year}.csv @BRONZE.LANDING AUTO_COMPRESS=TRUE

USE DATABASE BRFSS;

CREATE OR REPLACE TABLE BRONZE.BRFSS_{year} (
{col_defs},
  "_SOURCE_FILE" VARCHAR,
  "_LOADED_AT" TIMESTAMP_NTZ,
  "_RUN_ID" VARCHAR
);

COPY INTO BRONZE.BRFSS_{year}
FROM (
  SELECT {positional}, METADATA$FILENAME, CURRENT_TIMESTAMP(), '{RUN_ID}'
  FROM @BRONZE.LANDING/{year}.csv.gz
)
FILE_FORMAT = (FORMAT_NAME = BRONZE.CSV_RAW)
ON_ERROR = ABORT_STATEMENT;

-- Verification
SELECT COUNT(*) FROM BRONZE.BRFSS_{year};                                        -- expect the {year} row count from scope_and_gaps.md
SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA='BRONZE' AND TABLE_NAME='BRFSS_{year}';  -- expect {len(cols) + 3}
'''
    out_path = os.path.join(OUT_DIR, f"02{LETTER[year]}_bronze_{year}.sql")
    with open(out_path, "w", encoding="utf-8") as f:
        f.write(sql)
    print(f"wrote {out_path} ({len(cols)} source columns)")

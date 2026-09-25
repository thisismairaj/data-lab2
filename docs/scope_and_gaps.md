# Scope and gaps

Status: DRAFT after Step 1 (dataset review). Phase scope is not yet approved.
Every number below was measured on 2026-09-25 by profiling the local files with DuckDB (all columns read as text, so nothing was coerced).

## Scope change (2026-09-25, user decision): 2015 only

The pipeline uses **`2015.csv` only** (441,456 rows, 330 columns). 2011–2014 stay out of scope. The Step 1 profile below covers all five years and is kept for reference. The rules in `schema_contract.md` use 2015 numbers only. Findings that only affected other years (bad dates in 2011/2012/2014, the `DISPCODE` 110→1100 vocabulary change, 2011's blank `DIABETE3` values) do not apply to 2015.

Effect on the brief: even less data (441,456 rows, 0.44% of the 100M target), and no cross-year schema drift to detect. The 3 injected drift tests (rename, type change, dropped column) become the only drift evidence.

## Dataset used

`C:\Users\muham\Downloads\archive` (the path in the request, `D:\data-eng\archive`, does not exist).
CDC BRFSS survey, 2011–2015: five yearly CSVs, one `2015_formats.json`, one codebook PDF.

## Cloud and region (Phase 1 research: "region decided")

The brief requires both platforms on the same cloud and region. Measured 2026-09-25:

| Platform | Cloud | Region | How it was measured |
|---|---|---|---|
| Databricks | AWS | us-east-2 (Ohio) | `databricks metastores summary` on the saved workspace login (`dbc-41ec11e5-6bda`): `cloud: aws`, `region: us-east-2`, `global_metastore_id: aws:us-east-2:...`. Independently confirmed by the user with `current_metastore()` in a notebook: `aws:us-east-2:47bb06d4-e613-49d8-87b4-d06d7ae92209` (same ID). |
| Snowflake | AWS | ap-south-1 (Mumbai) | `SELECT CURRENT_REGION()` via `snow sql -c trial` on 2026-09-25: `AWS_AP_SOUTH_1`. Account `vsieues-oq50575`, Snowflake 10.34.101. |

**MISMATCH: same cloud (AWS), different regions (Ohio vs Mumbai).** A Snowflake account's region cannot be changed after signup. Decision: PENDING (options below).

| Option | Effect |
|---|---|
| A. New Snowflake trial in AWS US East (Ohio) | Regions match. Costs one more signup. |
| B. Keep both as they are, record as a deviation | Fastest. Loads from this laptop and the Day 3 pandas client depend on distance to each region, so those timings are not comparable. Only in-platform timings (query time inside the warehouse or cluster) stay fair. |

Existing Snowflake warehouses found on 2026-09-25 (`SHOW WAREHOUSES`): `COMPUTE_WH` (X-Small, auto-suspend 300 s), `SNOWFLAKE_LEARNING_WH` (X-Small, 300 s), `SYSTEM$STREAMLIT_NOTEBOOK_WH` (X-Small, 60 s). The brief requires 60 s on every warehouse, so two need changing in Phase 1. All were SUSPENDED.

## Deviations from the brief

| # | Brief says | What we have | Impact |
|---|-----------|--------------|--------|
| D1 | Primary dataset must be on **both marketplaces** (Snowflake Marketplace and Databricks Marketplace), verified before committing | A **local archive** from Downloads. Not listed on either marketplace, as far as we checked. NOT VERIFIED on the marketplaces themselves. | No marketplace mount, no listing-to-first-query time, no Delta Sharing / Snowpipe ingestion test. Data is loaded from files to both platforms instead (same source on both sides, so the comparison still holds). |
| D2 | Primary dataset **over 100M rows** | **441,456 rows** (2015 only, by scope decision). All five years together are 2,380,047 rows (2011: 506,467 · 2012: 475,687 · 2013: 491,773 · 2014: 464,664 · 2015: 441,456). About 0.44% of the target for 2015 alone. | "Ingestion cost per 100M rows" must be extrapolated from a small load. Extrapolation is an estimate, not a measurement, and must be labelled as such. |
| D3 | Primary has an "update cadence" | Static historical files. No updates. | Freshness lag: NOT APPLICABLE. |
| D4 | Secondary dataset is semi-structured: nested fields, variable schema per record | `2015_formats.json` is a **value-label codebook** (299 variables → code → label, 2 levels deep, 2015 only). It is nested, but it is a lookup table, not record-level data. | Usable to decode values in gold. It does not test "variable schema between records". This is a partial fit only. |
| D5 | Stretch dataset: unstructured | `codebook15_llcp.pdf` exists (6.9 MB). Not extracted. | Stretch is dropped. The brief marks it optional. |
| D6 | Two engineers, each owning one platform, neither measures their own | One engineer, both platforms | No cross-measurement. Metrics are self-measured; say so in the report. |
| D7 | Phase 4 external consumer via Snowflake reader account / Delta Sharing | Planned: plain Python + pandas client reads gold from both. If Delta Sharing is unavailable on our Databricks account, use the Databricks SQL connector for Python and record it here. | To be filled after Phase 4 lite. |

## Data problems found in Step 1 (before any fixing)

- **Columns change every year.** 454 / 359 / 336 / 279 / 330 columns (2011→2015). Only **158 columns exist in all five years**; 644 distinct column names overall. This is real schema drift in the source itself.
- **Byte-string artefacts.** `IDATE`, `IMONTH`, `IDAY`, `IYEAR` are stored as literal `b'01202011'` in every row of every file. 7–12 columns per file have this (also `INTVID`, `MRACE`, `RCSBIRTH`, …).
- **Numbers stored as floats.** `_STATE` is `1.0`, `SEQNO` is `2011000003.0`. State code should be a 2-character string.
- **Impossible dates.** `09312011` (63 rows), `11312012` (1), `09312014` (5), `02292014` (4; 2014 is not a leap year). Quarantine, do not guess. 2011 also has 55 rows with a space where a leading zero should be (e.g. `b' 9142011'`). These are fixable by left-padding.
- **Interview date is not the file year.** `IYEAR` differs from the file year in 3,057 (2011), 3,584 (2012), 5,679 (2013), 4,820 (2014) and 10,915 (2015) rows. Dates run into Jan–Mar of the next year. This is normal for BRFSS (late-year interviews), not an error. The contract must say which "year" is the partition key.
- **Nulls.** Fully empty columns per file: 55 / 12 / 5 / 1 / 4. Columns that are over 95% empty (not fully empty): 116 / 70 / 42 / 47 / 67. Most are skip-pattern questions, so empty does not mean bad. Codes such as `7`, `9`, `77`, `88`, `99` mean "don't know / refused / none" and must not be read as numbers.
- **Keys.** `SEQNO` alone is **not unique** (it restarts per state). `(_STATE, SEQNO)` is unique in all five files. There are **0 full-row duplicates** in any file.

## Out of scope for this delivery (Phases 5–7)

To be written after the phase plan is approved.

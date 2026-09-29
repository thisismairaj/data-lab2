# Lakeflow Declarative Pipeline demo

Built 2026-09-28 in a separate Databricks **trial** workspace (`actual-trial-personal-email`
profile, AWS us-east-2), not the Free Edition workspace used for the main build. Free
Edition blocks editing warehouses and has no cluster/pipeline creation; the trial does not.

## What this proves
The same medallion logic as the manual Free Edition build (`sql/databricks/`), but
declared instead of hand-sequenced: I never told the engine "run bronze before silver" —
it inferred that from each table's SQL referencing the one before it.

Built with direct API calls (`databricks pipelines create`, `databricks jobs create`),
not a Databricks Asset Bundle (`databricks.yml`) — a bundle is the "real" git-deployable
form of this, but was skipped here to save time; the SQL logic itself is identical either way.

## Objects created (trial workspace)
| Object | ID | What |
|---|---|---|
| Pipeline | `cec13faa-2611-47b9-a2cf-158b699c9a19` | `brfss-medallion-lakeflow` |
| Job | `957230567997934` | `brfss-medallion-lakeflow-job`, wraps the pipeline in a `pipeline_task`, daily cron (**paused**) |

Source files live in the workspace filesystem at
`/Workspace/Users/thisismairaj@gmail.com/lakeflow_brfss/` (uploaded via
`databricks workspace import-dir`), copies checked into this folder.

## Results, first run (2015.csv only)
| Table | Rows | Matches manual build? |
|---|---|---|
| `bronze_brfss` | 441,456 | Yes, exact |
| `silver_clean` | 440,421 | Yes, exact |
| `silver_quarantine` | 1,035 (all rule R1) | Yes, exact |
| `gold_diabetes_prevalence_state` | 53 | Yes, exact |

Job run (`run-now`) result: `SUCCESS`, 62 seconds, task `run_medallion_pipeline` correctly
invoked the pipeline.

## Scope trimmed for time
Core columns only (the state gold table), not all 7 gold tables built on Free Edition.
Quarantine rules limited to D1-D3, W1, R1 (the ones that actually fire in this dataset) -
S1, C1, K1 left out of this demo; same reasoning as the manual build, just not re-implemented
here to save time.

## Incremental load + real schema drift test (2014.csv added to the same folder)

**Incremental ingestion: worked correctly.** Bronze grew from 441,456 to 906,120
(441,456 + 464,664 exact) - 2015 was not reprocessed, confirmed per `_source_file`.

**Schema evolution: worked correctly, and caught mid-run.** Adding 2014.csv (76 columns
2015 doesn't have; missing 2 columns 2015 does have - `BPHIGH4`, `TOLDHI2`) triggered the
engine to detect a schema change *during* the bronze flow's execution, stop that flow,
correctly **skip every downstream table** rather than run them against a half-changed
bronze, then **automatically cancel and restart** the whole update under cause
`SCHEMA_CHANGE`. The restart succeeded: `BPHIGH4`/`TOLDHI2` now exist as real columns,
NULL for every 2014 row (which never had them), populated for 2015 rows.

**Bug found via the verification query, not assumed away.** `02_silver_staged.sql`
hardcoded `2015 AS survey_year` (correct for the original 2015-only build, silently wrong
once 2014 landed - every 2014 row was mislabeled as 2015). Caught because gold-by-year
showed only one year despite two years of source data. Fixed: `survey_year` is now
derived from `_source_file` via regex, not a constant.

**Final state, both years correct:**

| Table | 2014 | 2015 | Total |
|---|---|---|---|
| `silver_clean` | 464,544 | 440,421 (exact match to the Free Edition manual build) | 904,965 |
| `silver_quarantine` | 120 | 1,035 | 1,155 |
| `gold_diabetes_prevalence_state` | 53 rows | 53 rows | 106 |

Reconciliation: `904,965 + 1,155 = 906,120` = bronze total, exact.
Alabama sample: 12.94% (2014) vs 13.46% (2015) weighted - close, not identical, as real
year-over-year data should look.

## Update 2026-09-29: extended to all 5 years (2011-2015), extra gold tables added, one real bug found and fixed

**2011 and 2012 were added** (user uploaded them to the volume directly). Bronze now holds
all 2,380,047 rows across 5 files, exact match to known per-year totals. A `--full-refresh`
run happened to pick up the newly uploaded files mid-run, without needing a separate trigger.

**Real bug found and fixed: rule C1 (code validity) was missing from this pipeline's
original build.** Once 2013/2014 landed, corrupted values appeared - `bmi_category_code`
values like `2281.0` (should only be 1-4) and `smoker_status_code = 5` (should only be
1-4 or 9), a handful of rows per year. These look like values that landed in the wrong
column. The Free Edition build already had this check; this demo had explicitly skipped it
"to keep the demo focused" - that was a real gap, not a stylistic choice, and it let
corrupted data straight into gold silently. C1 has been added to
`03_silver_clean_and_quarantine.sql`, matching the Free Edition contract exactly. 1,318
corrupted rows across all 5 years are now correctly quarantined instead of silently
appearing in gold.

**A second, unrelated bug found during the fix:** `04_gold_state.sql`'s workspace copy had
gotten corrupted at some earlier point (literal folder-path text spliced into the SQL) -
not something caused by this session's edits, just never surfaced until a full refresh
forced Databricks to re-validate every file, not only the one being edited. Fixed by
re-uploading a clean copy from the local repo.

**Extra gold tables added, all multi-year** (age, smoking, BMI, comorbidity, risk-stacking)
- same definitions as the Free Edition equivalents, extended with `survey_year`:
- `BPHIGH4`/`TOLDHI2` (blood pressure/cholesterol) are missing from **both 2012 and 2014**,
  not just 2014 as first found on Free Edition (2014-vs-2015 comparison only). Those years
  correctly show 0 respondents / no percentage for those two conditions, not a fake zero.
- The compounding-risk finding (obesity x smoking x inactivity) holds across **all 5
  independent years**: the 0-vs-3-risk-factor ratio ranges 3.39x-3.71x every year. Much
  stronger evidence than a single year.
- National prevalence shows a real, gradual rise: 9.8% (2011) -> 10.18% -> 10.27% ->
  10.54% -> 10.5% (2015) - visible now with 5 years, where 3 years looked flat/noisy.

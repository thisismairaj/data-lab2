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

## Next: incremental load + real schema drift test
`2014.csv` is being added to the same landing folder (previously confirmed missing 2 columns
that 2015 has: `BPHIGH4`, `TOLDHI2` - see docs/scope_and_gaps.md) to observe:
1. Does bronze grow by exactly 2014's row count, or does it reprocess 2015 too (checkpoint working correctly)?
2. Does `schemaEvolutionMode => 'addNewColumns'` handle 2014's missing columns gracefully, or fail?
Results recorded here once run.

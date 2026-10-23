# Public Data Pipeline on Databricks + Snowflake

Same public health dataset, built into the same medallion pipeline on
**Databricks** and **Snowflake** in parallel, to prove both produce identical
results from identical rules — evidence for a platform decision, not opinion.

The raw-data defects behind the quarantine/silver rules here are written up as a
[Kaggle notebook](https://www.kaggle.com/code/thisismairaj/brfss-2011-2015-a-data-cleaning-case-study).

## Results (real, measured)

- **2,380,047 rows** (CDC BRFSS, 2011–2015) loaded identically on both platforms
- **29,402 / 29,402** gold-table values match, value by value, across both platforms
- **11 of 11** CDC-published health indicators reproduced exactly
- National diabetes prevalence trend, 2011→2015: **9.8% → 10.18% → 10.27% → 10.54% → 10.5%** —
  two independently-built pipelines (a hand-sequenced build and a declarative
  Lakeflow pipeline) agree on this to the decimal
- **Nothing silently dropped:** 73 rows quarantined for impossible dates,
  1,813,677 bad cells corrected or quarantined, each with a written reason

## Architecture

Both platforms use the same layered pattern: **bronze → silver → quarantine → gold**,
with a gate that stops the run if the numbers don't reconcile.

```
5 source files
     │
     ▼
┌─── Databricks ───┐   ┌─── Snowflake ───┐
│ bronze            │   │ bronze           │
│ silver             │   │ silver           │
│ quarantine         │   │ quarantine       │
│ gold               │   │ gold             │
│ gate               │   │ gate             │
└─────────┬─────────┘   └────────┬─────────┘
          └── compared value by value ──┘
                       │
                       ▼
              Power BI dashboard
```

## Repo layout

| Path | Contents |
|---|---|
| `databricks/pipeline/` | Databricks Asset Bundle: Lakeflow pipeline SQL (`transformations/`: bronze, silver, gold), file-arrival job, quarantine-rate alert, `grants.sql`. Unity Catalog catalog `brfss`. |
| `databricks/dashboard/` | AI/BI dashboard (dataset SQL plus the builder script) |
| `databricks/self_service/` | Genie space definition and builder |
| `snowflake/pipeline/` | Snowflake pipeline, run in order: setup and landing stage, bronze, silver (dynamic tables), gold, file-triggered ingest task, alerts, grants. Database `BRFSS`. |
| `snowflake/self_service/` | Semantic view and Snowflake Intelligence agent |
| `snowflake/dashboard/` | Streamlit in Snowflake app (dashboard plus Cortex Analyst questions) |
| `scripts/` | SQL runners and helper scripts |

Both platforms use the same names: `bronze.brfss_raw`, `silver.staged`, `silver.checked`, `silver.clean`, `silver.quarantine`, `gold.diabetes_prevalence_state`.

Power BI project files (`.pbip`) are generated locally from the Databricks gold tables.

## Status

Five of six core requirements have real, measured evidence behind them; a
formal platform recommendation is held back until the remaining latency/cost
metrics exist, rather than delivered as opinion.

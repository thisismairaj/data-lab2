# Public Data Pipeline on Databricks + Snowflake

Same public health dataset, built into the same medallion pipeline on
**Databricks** and **Snowflake** in parallel, to prove both produce identical
results from identical rules — evidence for a platform decision, not opinion.

Full evidence report: [`docs/manager_report.md`](docs/manager_report.md).
Narrative overview: [`docs/stakeholder_overview.md`](docs/stakeholder_overview.md).

## Results (real, measured — see `docs/manager_report.md` for sources)

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
with a gate that stops the run if the numbers don't reconcile. Rationale in
`docs/manager_report.md` §4 ("Why we chose medallion architecture").

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
| `docs/` | Brief, schema contract, metrics definitions, manager report, stakeholder overview, learning log, scope/gaps |
| `sql/databricks/` | Bronze/silver/gold SQL for the Databricks Free Edition build |
| `sql/lakeflow/` | Databricks Lakeflow declarative pipeline (trial workspace) |
| `sql/snowflake/` | Bronze/silver/gold SQL for the Snowflake build |
| `scripts/` | SQL generators, platform deploy scripts, cross-platform metric comparison |
| `databricks_bundle/` | Databricks Asset Bundle (dev/staging/prod targets), deployed as code |

Power BI project files (`.pbip`) are generated locally from `sql/` gold tables
and are git-ignored — not tracked in this repo.

## Status

Day 2 of a 3-day brief timebox. Five of six brief requirements have real,
measured evidence behind them; the platform recommendation itself is
deliberately deferred until the remaining Phase 5–6 metrics exist, rather than
delivered as opinion. Full status: `docs/manager_report.md` §2.

## Where to start reading

1. `docs/brief.md` — the original brief this project answers
2. `docs/manager_report.md` — full evidence report, all numbers sourced
3. `docs/scope_and_gaps.md` — honest list of where this deviates from the brief

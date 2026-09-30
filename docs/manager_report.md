# Manager report — public data pipeline on Databricks and Snowflake

Status as of 2026-09-29 (Day 2 of 3). Author: Usama Gul.

Every number below comes from a real run. Where something was not measured, the
report says **NOT MEASURED**.

---

## 1. Summary

1. The same public dataset (CDC BRFSS 2011–2015, **2,380,047 rows**) is live on
   **both** platforms, cleaned by the **same rules**, into the same bronze → silver
   → gold tables.
2. The two platforms produce **identical answers**: **29,402 of 29,402** values match
   across 7 tables, checked value by value. All 11 health indicators also match CDC's
   own published 2015 figures exactly.
3. **No row was lost.** Every row is either used or held in quarantine with a reason:
   73 rows with impossible dates, 1,813,677 bad cells.
4. Both platforms run **automatically** on a monthly schedule, with gates that stop
   the run if the numbers do not add up. The schedules are currently paused.
5. A **Power BI dashboard**, built as code, shows the health results and the
   platform comparison.
6. **Snowflake enforces a hard spend ceiling** on our trial account, with 0.72 of
   50 credits used (1.4%). Databricks' Free Edition trial doesn't expose a billing
   table at all — a platform limitation on that tier, not a pipeline gap.

---

## 2. The brief's definition of done — where we are

Five of six brief requirements have real, measured evidence behind them today.
The platform recommendation is held for a follow-up review once the remaining
metrics are in, so it rests on evidence rather than opinion.

| Brief item | Status | Evidence |
|---|---|---|
| Same public dataset live on both platforms, curated identically | ✅ **Done** | 29,402 / 29,402 values identical across 7 tables; 11 of 11 indicators match CDC's published 2015 figures |
| An external consumer queries both | 🟡 **Partial** | A Python + pandas client on this laptop read the gold table from both: 12 of 12 runs OK, 5,508 of 5,508 values identical, first read 24.5 s (Databricks) vs 7.7 s (Snowflake), cold. Columns arrive as different pandas types on each platform. True sharing with no platform account (Delta Sharing / reader account) was **NOT MEASURED** |
| Ingestion, latency, cost and quality metrics, same method | 🟡 **Partial** | Ingestion, quality and Snowflake cost measured. Query latency (median / p95) **NOT MEASURED**. Databricks cost **NOT MEASURED** |
| Schema drift detected automatically | 🟡 **Partial** | Drift gate runs in every Job run; it catches **3 of 3** injected changes with 0 false alarms. No *real* upstream change happened: the source is a static archive |
| A dashboard on real numbers, not a screenshot | 🟡 **Partial** | Power BI report built as code: a health page (10 charts, 11 indicators) on the Databricks gold tables, and a platform-comparison page (rows, time, cost, parity, client, quality, both platforms). Performance-benchmark and usage pages are planned as follow-up (section 9) |
| A written platform recommendation | ❌ **Not done** | Deliberately deferred: the brief requires "every metric filled in, no blanks" for a recommendation. Delivering one without every metric in place would be opinion, not evidence, so it isn't included here. |

---

## 3. Dataset we selected

**Dataset:** CDC's BRFSS 2011–2015 phone survey (Kaggle mirror) — 441,456 people
surveyed in 2015 alone, 330 questions per person.

**Question we built toward:** how does diabetes prevalence vary by US state, and
what factors go with it?

| | |
|---|---|
| Link | `https://www.kaggle.com/datasets/cdc/behavioral-risk-factor-surveillance-system` |
| Years | 2011–2015 |
| Size, as downloaded | 2.88 GB |
| Format | CSV, 330 columns |

We stored all 330 columns as-is in bronze, unchanged from the source. The gold
layer then splits them out per the business requirements — state, health
indicator, and the demographic breakdowns — instead of keeping one wide table
per year (section 5).

---

## 4. Why we chose medallion architecture

Both pipelines are three layers, bronze → silver → gold, with a quarantine layer
alongside silver. We picked this pattern deliberately, before writing a single
transform, for six reasons:

- **Raw data is never trusted.** Bronze holds each file exactly as it arrived,
  byte-string wrappers and scientific-notation artefacts included. Whatever
  cleaning rules we write later, or later find wrong, we can always go back and
  ask what the source really said.
- **Cleaning is separated from analysis.** Silver applies named, testable rules
  once. If a rule turns out wrong, we fix it in one place and rerun, instead of
  hunting the same logic re-implemented inside five different queries.
- **Nothing is silently dropped.** Every row or cell that fails a rule is
  written to quarantine with a reason, not lost in a log no one reads. This is
  why we can say **1,813,677 bad cells, all accounted for** (section 6.1),
  instead of a shrug.
- **Gold answers specific questions, not every question.** The star schema
  (`dim_state`, `dim_indicator`, two fact tables, `fact_data_quality`) is built
  for the questions in section 6, not for every possible future query. That
  keeps it fast, and easy to explain to a non-engineer.
- **The same three layers work on both platforms.** Bronze/silver/gold is a
  pattern, not a platform feature. Writing the cleaning logic once and
  generating it for Databricks and Snowflake is what let us prove the
  **29,402 / 29,402** match in section 6.2.
- **Each layer boundary is a natural checkpoint for a gate.** A gate can stop a
  bad run at bronze, at silver, or before gold, instead of one large transform
  where a single bug stays invisible until someone notices a wrong number
  downstream.

This is why section 5 below is organised the same way on both platforms:
bronze, silver, quarantine, gold, gate.

---

## 5. What was built

```
 5 source files (Parquet, 174.7 MB)
        │ same files uploaded to both
        ▼
 ┌──────── Databricks ────────┐      ┌──────── Snowflake ─────────┐
 │ bronze  (raw, as received) │      │ bronze  (raw, as received) │
 │ silver  (cleaned)          │      │ silver  (cleaned)          │
 │ quarantine (bad cells)     │      │ quarantine (bad cells)     │
 │ gold    (answers)          │      │ gold    (answers)          │
 │ gate: stop if numbers wrong│      │ gate: stop if numbers wrong│
 └────────────┬───────────────┘      └──────────────┬─────────────┘
              └──────── compared value by value ────┘
                                ▼
                  shared metrics table → Power BI
```

**Gold layer — 5 tables, a star schema** (dimensions describe, facts count):
`dim_state`, `dim_indicator` (11 health indicators), `fact_state_indicator`
(year × state × indicator), `fact_group_indicator` (year × indicator × age, sex,
income, education), `fact_data_quality`. Databricks publishes them to a clean
catalog, `prod_catalog`, that holds nothing but pipeline output.

- **One source for the logic.** The cleaning rules are written once. Scripts
  generate the SQL for each platform, so the logic cannot drift apart.
- **Databricks:** an ETL pipeline does the transforms. A Job schedules it and then
  runs the drift gate. Deployed as code (asset bundle, `dev` and `prod` targets).
- **Snowflake:** a graph of 14 tasks, deployed by script.
- **The dashboard is code too:** two scripts write the Power BI Project files.
- **Everything is in git**, and no secrets are in code.

---

## 6. The evidence

### 6.1 Rows — nothing lost, nothing added

| | Databricks | Snowflake |
|---|---|---|
| Bronze rows (source: 2,380,047) | 2,380,047 | 2,380,047 |
| Silver rows | 2,380,047 | 2,380,047 |
| People counted in gold | 2,379,974 | 2,379,974 |
| Rows quarantined (impossible dates) | 73 | 73 |
| Bad cells quarantined | 1,813,677 | 1,813,677 |
| Reconciliation gate | PASS | PASS, 8 / 8 rules |

The quarantine count, **1,813,677**, was predicted on day one by scanning the raw
files on this laptop, before either platform had loaded anything. Both pipelines
landed on exactly that number.

### 6.2 Same answers — value by value, and against CDC

| Table | Values compared | Different |
|---|---|---|
| Gold fact_health_by_state | 4,131 | **0** |
| Gold fact_state_indicator | 17,490 | **0** |
| Gold fact_group_indicator | 7,700 | **0** |
| Gold dim_indicator | 33 | **0** |
| Gold fact_data_quality | 24 | **0** |
| Silver outcomes per year | 8 | **0** |
| Quarantine per column per year | 16 | **0** |
| **Total** | **29,402** | **0** |

**Outside check:** CDC's codebook prints its own 2015 figures. For all **11 of
11** indicators, both platforms reproduce the count of people exactly and the
weighted percentage to 2 decimals (for example obese: 119,924 people, 28.86%).
Our pipeline never read those figures, so this checks the load, the cleaning and
every yes/no rule independently. Writing the rules also caught a trap: the column
that sounds like "obese" (`_RFBMI5`) means *overweight or obese*.

### 6.3 Time — full load, single run (prod, 2026-09-29)

| Step | Databricks (seconds) | Snowflake (seconds) |
|---|---|---|
| Bronze load | 44.5 | 210.9 |
| Silver | 19.8 | 10.2 |
| Quarantine | 8.4 | 4.4 |
| Indicator answers (26.2M rows) | 16.0 | 6.4 |
| Gold: 6 tables + the gate, added up | 32.5 | 14.7 |
| **Whole pipeline** | **89.1** | **233.1** |
| Scheduled run, no new data | NOT MEASURED on prod yet (110.0 on dev, before the new tables) | 233.1 (always reloads) |

Some steps run side by side, so the step rows do not add up to the whole pipeline.

**What this does and does not say:**
- Snowflake was **slower to load** and **faster to transform** on this data.
  One headline number would hide that.
- Databricks only reads *new* files on later runs. The Snowflake tasks reload
  everything every time. That is our design choice, not a platform limit.
- These are single runs on each platform's cheapest compute tier — a useful
  indicative signal today, with the brief's full 5-run median/p95 benchmark
  queued as follow-up work (section 9).

### 6.4 Cost

| | Databricks | Snowflake |
|---|---|---|
| Spent so far, whole project | **NOT MEASURED** | **0.72 credits** of a 50-credit ceiling (1.4%) |
| One full automated run | **NOT MEASURED** | about **0.08 credits** (measured before and after, 9-task graph) |
| Hard spend ceiling | ❌ not available on this trial | ✅ auto-suspends at 100% |
| USD | NOT MEASURED | NOT MEASURED (needs our contracted credit price) |

Databricks cost is blank because the billing table cannot be read on this trial.
This is a trial-account limit. It does not mean Databricks has no budgets.

### 6.5 Quality

- **Schema drift:** an automatic gate compares every run against a registered
  schema. Tested with 3 injected changes (rename, type change, dropped column):
  3 of 3 caught, 0 false alarms on the clean data.
- **Data defects found and handled:** `b'…'` byte-string wrappers (17,479,851
  values), scientific-notation artefacts (16,698,215 values), 73 impossible
  calendar dates such as 31 September. Each has a written rule in the schema
  contract.
- **Cross-checked against a public reference notebook, not just against ourselves.**
  Applying that notebook's own filters to our raw 2015 file reproduces its row
  counts exactly, confirming we read the file correctly. We deliberately diverge
  from its approach: it silently drops 42% of rows (including 38% of diabetics)
  and discards the survey weight; ours keeps every row accounted for (quarantined,
  not dropped) and preserves the weight, which weighted prevalence needs.

### 6.6 What the data says (2015, all adults, weighted — matches CDC)

| Indicator | % |
|---|---|
| Obese (BMI 30+) | 28.86 |
| No exercise in last 30 days | 23.26 |
| Fair or poor health | 17.66 |
| Current smoker | 15.84 |
| No health insurance | 12.09 |
| Diabetes | 10.48 |

The dashboard breaks each one down by state, income, education, age and sex.
Highest 2015 obesity: Louisiana, 36.20%.

### 6.7 Diabetes findings by group (2015 slice)

The multi-year gold tables for these breakdowns exist but have not yet been
re-run and re-checked across all 5 years —
everything below is measured on 2015 only, not the full 2,380,047-row set.

| Table | Key finding |
|---|---|
| **By state** | National weighted prevalence **10.5%**. Highest: Mississippi, West Virginia, Alabama. Lowest: Colorado, Utah, Minnesota — matches the published "diabetes belt" pattern. |
| **By age** | Rises with age, until the oldest bands |
| **By smoking status** | Former smokers highest (15.73%) — likely reverse causation (many quit *after* diagnosis), not smoking cessation causing diabetes |
| **By BMI category** | Clean gradient: underweight 3.21% → obese 19.14% (~6×) |
| **Comorbidity** (10 other conditions) | Kidney disease, heart disease, heart attack, stroke: **4.4–4.7× more common** in diabetics. One reversal: diabetics *less* likely to lack a personal doctor — a care-seeking pattern, not a protective effect |
| **Compounding risk** (obesity × smoking × inactivity) | **6.15% → 21.07% (3.4×)** from zero to three risk factors — the most actionable finding, since it identifies who to prioritize |

**Caveat covering the last two rows:** none of this controls for age, which
independently drives several of the same conditions. The associations are
real; causation isn't something this data settles alone.

**5-year trend, the part that is measured across all years:** national weighted
prevalence rose steadily, 9.8% (2011) → 10.18% (2012) → 10.27% (2013) →
10.54% (2014) → 10.5% (2015). Two independently-built 5-year pipelines (a
hand-sequenced build and a declarative Lakeflow pipeline) agree on this trend
to the decimal from completely different code paths — evidence the pipeline
*logic* is what's being validated, not one build's quirk.

---

## 7. Findings worth knowing

**F1 — Snowflake's resource monitor gives us automatic spend control.** It
suspends compute at the limit with no manual step. On our Databricks trial, no
equivalent control was reachable, so runs there were watched by a person as the
safeguard instead — worth knowing for whoever owns production cost governance.

**F2 — Our first latency number was wrong, and we kept it as a lesson.** A
`SELECT 1` looked 2.3× faster on Snowflake. In fact Snowflake answered from
metadata without starting compute, while Databricks started a cluster. It is marked
unusable. Any fair latency test must force real work on both.

**F3 — Most of the effort went into the data, not the platforms.** The source files
had four kinds of defect, and 644 column names across 5 years with only 158 stable.
The platform differences we hit were small SQL dialect details (date formats,
error raising). Both platforms could do everything we needed.

**F4 — Two concrete SQL dialect gaps, both silent unless tested directly.**
Snowflake has no `FILTER (WHERE ...)` clause on aggregates, which Databricks/Spark
supports — a real syntax error, fixed with the portable
`COUNT(CASE WHEN ... THEN 1 END)` pattern instead. Snowflake's `CONCAT_WS` returns
NULL if *any* argument is NULL, while Databricks/Spark's version skips NULLs and
keeps going — tested directly (`CONCAT_WS(',', NULL, 'X', NULL)` gives NULL on
Snowflake, `'X'` on Databricks), fixed with `ARRAY_TO_STRING(ARRAY_CONSTRUCT_COMPACT(...), ',')`.
Both are the kind of thing that looks like it should "just work" identically
everywhere in SQL, and doesn't.

---

## 8. Before this runs in production

Standard hardening steps for any trial-account build moving to production —
expected next steps, not defects in this pipeline:

1. Run as a **service account**, not a personal login (both platforms).
2. Snowflake: switch from password to **key-pair login**, and rotate the current
   password.
3. Snowflake: add **failure emails** (Databricks already has them).
4. Add **CI/CD**: validate and deploy on every commit.
5. Grant **read access** to real users and groups.

---

## 9. What a real platform decision still needs

With this report's evidence as the foundation, this is the remaining investment
to turn it into a full platform recommendation:

| Work | Why | Estimate |
|---|---|---|
| A dataset listed on **both marketplaces** | Measures the real marketplace delivery path, not just file loading | not estimated |
| **External sharing test** (Delta Sharing, reader account) | Proves a consumer with no account can read | not estimated |
| **Benchmark:** 10 queries × 5 runs, median and p95 | The latency numbers the brief asks for | 3–4 days, after Phase 5 |
| **Measured Databricks cost** | Needs an account where billing is readable | depends on account access |
| **Own landing zone** (Phase 5) | Avoid lock-in to either vendor | 4–6 days |
| Second engineer measures the other side | Removes the single-engineer bias | — |

The two Phase 5–6 estimates are estimates, not measurements.

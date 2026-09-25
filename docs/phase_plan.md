# Phase plan

Approved by the user on 2026-09-25. Scope: 3 days, one engineer, trial accounts, **BRFSS 2015 only**. Hours are estimates, not measurements. Order: Databricks first, then Snowflake, one platform at a time.

## Day 1
| Phase | Work | Est. h | Status |
|---|---|---|---|
| 0 | Git, environment, `.env`, both CLIs authenticated | 1.5 | Done |
| 0 | Schema contract (draft written; open decisions: BMI range R1, row-level quarantine) | 1 | Draft |
| 0 | Metric definitions (`docs/metrics.md`) | 1 | Not started |
| 1 (Databricks) | Catalog and schema structure, warehouse settings, cost guardrails, first query time and cost recorded | 2 | Not started |
| 1 (Snowflake) | Same, after Databricks. Region decision needed first. | 2 | Not started |
| 2 start | Small sample (first ~50k rows) into bronze, Databricks then Snowflake | 2 | Not started |

## Day 2
| Phase | Work | Est. h |
|---|---|---|
| 2 finish | Full 2015 load (441,456 rows) to bronze on both. Row counts must match exactly. | 2.5 |
| 2 | Build and load `ref.codebook_values` on both (code → meaning lookup) | 1 |
| 3 | Silver with quarantine, gold. Same logic on both. Check C2 against the codebook. | 4 |
| 3 | Schema drift check: 3 injected tests (rename, type change, dropped column) on both | 1.5 |
| 3 | External reproduction check on bronze, both platforms: the Kaggle notebook's filters must give 343,606 then 253,680 rows (class counts 213,703 / 4,631 / 35,346). Already reproduced locally in DuckDB. | 0.5 |

## Day 3
| Phase | Work | Est. h |
|---|---|---|
| 4 lite | Plain Python + pandas client reads gold from both. Count steps, time it, note failures. Fallback: Databricks SQL connector if Delta Sharing is unavailable. | 2 |
| – | Metrics table filled with real numbers, both platforms (`docs/metrics.md`) | 1.5 |
| – | Power BI dashboard on gold + metrics | 2 |
| – | Manager report (`docs/manager_report.md`) and buffer for fixes | 2.5 |

## Out of scope (Phases 5–7)
Landing zone in own storage, benchmark suite and analytics layer, platform recommendation. What each needs is written in `docs/scope_and_gaps.md`.

## Main risks
1. Databricks looks like Free Edition (serverless only), so cluster policies and pinned runtimes may not be possible. To be tested and recorded as a deviation.
2. Snowflake is in Mumbai and Databricks in Ohio. Load and client timings are not comparable until this is resolved or documented.
3. Data is small (441,456 rows), so per-100M-row costs are extrapolations and must be labelled that way.
4. One engineer measures both platforms (no cross-measurement).
5. Trial credits: any load or warehouse start needs an expected cost and the user's OK first.

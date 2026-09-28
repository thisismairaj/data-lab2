# Metrics: definitions and method (DRAFT for approval)

Agreed **before** any measuring, so both platforms are measured the same way. A metric measured two different ways is not a comparison.

**Rule:** every value in this file is "NOT MEASURED" until a real run produces it. Nothing here is an estimate. When a number is filled in, it gets the run ID, the time and the method next to it.

Scope: BRFSS 2015 only (441,456 source rows). One engineer measures both platforms, so there is no cross-measurement (deviation D6 in `scope_and_gaps.md`).

## Measurement method (identical on both platforms)

1. **One runner, two targets.** A single Python script runs the same steps on each platform. It takes every timing itself with `time.perf_counter()` around each call. Nobody times things by hand.
2. **Two clocks for every query.**
   - *Client time* = from the moment the script submits the query to the moment the result is back in Python. Includes network distance to the region.
   - *Server time* = the platform's own recorded execution time from its query history. Excludes the network.
   - The comparison between platforms uses **server time**. Client time is reported too, but labelled "client side, from this laptop", because Snowflake is in Mumbai and Databricks is in Ohio until the Snowflake account is moved.
3. **Turn result caches off** before timing any query on either platform, or repeat runs return instantly and measure nothing. The exact setting for each platform is checked and recorded at build time.
4. **Repeat.** Each query is run 5 times. Report the median and the slowest run. With only 5 runs a true p95 is not meaningful, so it is labelled n=5. The first run after the warehouse has been idle is reported separately as the **cold start**.
5. **Loads are run once**, because repeating a load costs credits. A single-run number is labelled as such.
6. **Compute size.** Each platform uses its smallest available compute (Snowflake X-Small warehouse, Databricks serverless SQL warehouse 2X-Small). They are not the same machine. This is stated next to every timing.
7. **Where results go.** Every measurement is appended as one row to `ops.pipeline_metrics` on the platform it ran on. Both tables have the same columns, and Power BI stacks them.
8. **Empty is not zero.** A value not yet measured is stored as NULL with a note. It is never stored as 0.

## Table: `ops.pipeline_metrics`

| Column | Type | Meaning |
|---|---|---|
| `platform` | STRING | `databricks` or `snowflake` |
| `phase` | STRING | e.g. `phase1`, `bronze_load`, `silver_build`, `gold_build`, `drift`, `client_access` |
| `metric_name` | STRING | From the catalog below |
| `value` | DOUBLE | The number. NULL if not measured. |
| `unit` | STRING | `rows`, `seconds`, `percent`, `credits`, `dbu`, `usd`, `count`, `bool` |
| `run_id` | STRING | Ties the row to one pipeline run |
| `measured_at` | TIMESTAMP | When it was measured |
| `method` | STRING | Short description, e.g. `perf_counter client side` or `query_history server side` |
| `notes` | STRING | Caveats, e.g. `single run`, `cold start`, `cost view lags` |

## Metric catalog

Targets come from the brief. "Status" is NOT MEASURED for all of them today.

### Ingestion
| ID | Metric | Definition | Target | Status |
|---|---|---|---|---|
| I1 | `rows_bronze` | `count(*)` of `bronze.brfss_2015` after load | 441,456, the row count of `2015.csv` counted locally | **Databricks: 441,456. Exact match. Measured 2026-09-28.** Snowflake: NOT MEASURED. |
| I2 | `load_seconds` | Wall clock from start of the load command until the first successful `count(*)` on bronze | Recorded and compared | **Databricks: 11.4s, PROVISIONAL (CLI wall clock, not the Python runner yet).** Snowflake: NOT MEASURED. |
| I3 | `upload_seconds` | Time to move the file to the platform (stage or volume), reported separately from I2. This is the number most affected by region distance. | Recorded | **Databricks: 106.8s for the 541MB file, PROVISIONAL.** Snowflake: NOT MEASURED. |
| I4 | `load_cost` | Platform cost units used by the load, then converted to USD | Recorded and compared | Databricks: **NOT MEASURABLE** (Free Edition, no billing table - see below). Snowflake: NOT MEASURED. |
| I5 | `failed_loads` | Load attempts that errored | Zero | **Databricks: 0 (2/2 loads succeeded - the sample and the full file).** Snowflake: NOT MEASURED. |

Cost per 100M rows is **not reported** as a measurement. At 441,456 rows it would be an extrapolation (about 0.44% of 100M), and would be labelled as such if shown.

### Transformation and quality
| ID | Metric | Definition | Target | Status |
|---|---|---|---|---|
| Q1 | `rows_silver`, `rows_quarantine`, `rows_rejected`, `rows_gold` | Count of each layer | Identical on both platforms | **Databricks: silver 440,421 · quarantine 1,035 · rejected 0 · gold 53. Measured 2026-09-28.** Snowflake: NOT MEASURED. |
| Q2 | `outcomes_sum_check` | clean + corrected + quarantined + rejected = 441,456 | Exact | **Databricks: 440,421 + 1,035 + 0 = 441,456. Exact. Measured 2026-09-28.** Snowflake: NOT MEASURED. |
| Q3 | `row_count_parity` | Absolute difference between platforms for each of Q1 | 0 | NOT MEASURED (needs Snowflake built first) |
| Q4 | `null_rate_<column>` | nulls ÷ rows × 100, for each of the 18 silver columns | Both platforms within 0.01 percentage points | NOT MEASURED (not yet run per-column) |
| Q5 | `quarantine_rate` | rows_quarantine ÷ 441,456 × 100 | Under 0.5% (dataset limit, see contract) | **Databricks: 0.2345% (1,035/441,456). Under the gate. Measured 2026-09-28** — matches the 0.23% predicted from raw-file profiling on 2026-09-25, before this SQL existed. Snowflake: NOT MEASURED. |
| Q6 | `quarantine_by_rule` | Count of quarantined rows per rule ID | Identical on both platforms | **Databricks: R1=1,035, all other rules=0. Measured 2026-09-28.** Snowflake: NOT MEASURED. |
| Q7 | `corrections_by_type` | Count of corrected rows per correction | Identical on both platforms | **Databricks: D1 (strip byte-string wrapper) + Z1 (state zero-pad) applied to all 440,421 clean rows; D2 (space-pad date) fired on 0 rows in 2015. Measured 2026-09-28.** Snowflake: NOT MEASURED. |
| Q8 | `code_check_C2` | Silver + quarantine count per code equals the codebook frequency | All equal | NOT MEASURED (rule C1 checks code *validity*, which passed at 0 hits; this separate check - comparing *counts per code* against the codebook's own frequency column - has not been run yet) |
| Q9 | `external_reproduction` | The Kaggle notebook's filters on bronze give 343,606, then 253,680 rows | Exact | Reproduced locally in DuckDB only (2026-09-25). NOT MEASURED as a query against either platform's bronze table yet. |
| Q10 | `gold_parity` | Every gold column equal on both platforms (floating-point sums compared to 6 decimals) | Equal | NOT MEASURED (needs Snowflake built first) |
| Q11 | `pk_duplicates` | Duplicate `(state_fips, survey_year, seqno)` in silver | 0 | **Databricks: 0. Measured 2026-09-28.** Snowflake: NOT MEASURED. |

### Schema drift
| ID | Metric | Definition | Target | Status |
|---|---|---|---|---|
| S1 | `drift_detected` | Out of 3 injected tests (rename a column, change a type, drop a column) on a test copy, how many the checker flagged | 3 of 3 on each platform | NOT MEASURED |
| S2 | `drift_severity_correct` | Out of those 3, how many were given the right severity | 3 of 3 | NOT MEASURED |
| S3 | `view_survives_rename` | The contract view keeps working through a rename with no consumer-side change | Yes | NOT MEASURED |

### Performance
| ID | Metric | Definition | Target | Status |
|---|---|---|---|---|
| P1 | `first_query_seconds` | Phase 1 trivial query: client and server time | Recorded on both | NOT MEASURED |
| P2 | `gold_query_median_s`, `gold_query_max_s` | The gold "prevalence by state" query, 5 runs, server time | Recorded | NOT MEASURED |
| P3 | `cold_start_penalty_s` | First query after idle minus the warm median | Recorded | NOT MEASURED |
| P4 | `gold_build_seconds` | Time to build gold from silver | Recorded | NOT MEASURED |
| P5 | `silver_build_seconds` | Time to build silver and quarantine from bronze | Recorded | NOT MEASURED |

### Cost
| ID | Metric | Definition | Target | Status |
|---|---|---|---|---|
| C1 | `cost_native` | Credits (Snowflake) or DBU (Databricks) used per phase, read from each platform's usage records | Recorded | NOT MEASURED |
| C2 | `cost_usd` | C1 × the list price per unit for our edition and region. **The price used and where it came from are written next to the number.** If the price cannot be found, only native units are shown. | Recorded, one currency | NOT MEASURED |
| C3 | `idle_cost_per_day` | Cost with zero queries over a full day | Near zero | NOT MEASURED. Needs a full idle day. Recorded as a gap if time does not allow. |
| C4 | `budget_consumed_pct` | Trial credits used ÷ trial credits granted | Under 80% | NOT MEASURED |

**Databricks cost is not measurable on this workspace.** Checked 2026-09-25: `system.billing.usage` does not exist on the Free Edition workspace. C1, C2 and C4 are therefore reported as NOT MEASURABLE for Databricks, not NOT MEASURED. Only Snowflake cost can be read. The comparison must say this.

**Cost timing risk.** Usage views on both platforms can lag by hours, and Databricks billing tables may not exist on Free Edition. So loads run on Day 2 and cost is read on Day 3. Anything still missing shows as NOT MEASURED, never estimated.

### External client (Phase 4 lite)
| ID | Metric | Definition | Target | Status |
|---|---|---|---|---|
| E1 | `client_steps` | Number of setup steps to get from nothing to a first pandas result | Counted on both | NOT MEASURED |
| E2 | `client_seconds` | Time from a clean Python environment to the first result | Under 60 minutes, both | NOT MEASURED |
| E3 | `client_failures` | Errors hit on the way, with the exact error text | Documented | NOT MEASURED |
| E4 | `type_fidelity` | Decimal and date values read back equal the values in gold | 0 mismatches | NOT MEASURED |

## Not measured on purpose
- **Freshness lag:** static historical file, not applicable (D3).
- **Usage metrics** (queries per user, bytes per user): out of scope with Phase 6.
- **Benchmark suite** (10 queries, three engines): out of scope (Phase 6).

## Known weaknesses of this comparison (to repeat in the report)
1. Different compute sizes and pricing models, so cost per second is not like for like.
2. Region mismatch (Mumbai vs Ohio) until Snowflake is moved. It affects I3 and all client times.
3. Very small data, so load times are seconds and noise is large relative to differences.
4. One engineer measured both sides.
5. Load runs once, so a single number has no error bars.

# Schema contract (DRAFT for approval)

Written once, implemented twice (Databricks and Snowflake). Both sides must produce identical columns, types, rules and counts.

**Scope: BRFSS 2015 only** (`2015.csv`, 441,456 rows, 330 columns). Narrowed from 2011–2015 by user decision on 2026-09-25. Code meanings come from `docs/codebook15_llcp.md`.
All counts were measured on 2026-09-25 with DuckDB on the local file. Anything not measured is marked NOT MEASURED.

## Business question (gold)

**How does diabetes prevalence vary by state in 2015?**

## Layers

| Layer | Content | Rule |
|---|---|---|
| bronze | `bronze.brfss_2015`: all 330 source columns as **text**, exactly as delivered, plus load metadata | Never modified |
| silver | `silver.brfss_clean`: the 18 contract columns below, typed and validated | Only records that pass every rule (or are corrected, and flagged) |
| quarantine | `silver.brfss_quarantine`: one row per failed record, with rule and reason | Nothing is dropped without a row here |
| gold | `gold.diabetes_prevalence_state` | Built only from silver. Users query gold, never bronze. |
| reference | `ref.codebook_values`: code → meaning lookup from the codebook | Loaded once, identical on both platforms. See below. |

Bronze load metadata (added by our loader, not in the source): `_source_file`, `_source_row_number`, `_run_id`, `_loaded_at`.

## Silver columns

Types are Databricks / Snowflake. Code columns keep the **raw code** (including "don't know" and "refused" codes). We never turn those into NULL or a guess. A BLANK in the source becomes NULL.

| # | Column | Source | Type (DBX / SF) | Meaning and rule |
|---|---|---|---|---|
| 1 | `state_fips` | `_STATE` | STRING(2) / VARCHAR(2) | State FIPS code, zero-padded (`1.0` → `01`). Must be one of the 53 codes in the codebook (50 states, DC, Guam 66, Puerto Rico 72). |
| 2 | `survey_year` | constant | SMALLINT | 2015. Kept so the contract still works if more years are added later. It is **not** `IYEAR`: 10,915 rows have an interview date in 2016. |
| 3 | `seqno` | `SEQNO` | BIGINT | Not null. Not unique alone (restarts per state). |
| 4 | `interview_date` | `IDATE` | DATE | Source is text like `b'01292015'` = MMDDYYYY. See rules D1, D3. |
| 5 | `sex_code` | `SEX` | SMALLINT | 1 male, 2 female |
| 6 | `age_group_code` | `_AGEG5YR` | SMALLINT | 1–13 = five-year bands from 18–24 to 80+; **14 = don't know / refused / missing** |
| 7 | `education_code` | `EDUCA` | SMALLINT | 1–6; 9 = refused |
| 8 | `income_code` | `INCOME2` | SMALLINT | 1–8 bands; 77 = don't know; 99 = refused |
| 9 | `general_health_code` | `GENHLTH` | SMALLINT | 1 excellent … 5 poor; 7 = don't know; 9 = refused |
| 10 | `health_plan_code` | `HLTHPLN1` | SMALLINT | 1 yes, 2 no, 7 don't know, 9 refused |
| 11 | `smoker_status_code` | `_SMOKER3` | SMALLINT | 1–4; 9 = don't know / refused / missing |
| 12 | `exercise_any_code` | `EXERANY2` | SMALLINT | 1 yes, 2 no, 7 don't know, 9 refused |
| 13 | `diabetes_code` | `DIABETE3` | SMALLINT | 1 yes · 2 yes, pregnancy only · 3 no · 4 no, pre-diabetes · 7 don't know · 9 refused |
| 14 | `bmi` | `_BMI5` | DECIMAL(5,2) / NUMBER(5,2) | Source is an integer with **2 implied decimals** (`2750` → `27.50`). BLANK → NULL. |
| 15 | `bmi_category_code` | `_BMI5CAT` | SMALLINT | 1 underweight, 2 normal, 3 overweight, 4 obese. BLANK → NULL. |
| 16 | `final_weight` | `_LLCPWT` | DOUBLE / FLOAT | Survey weight (how many adults this respondent represents). Must be > 0. |
| 17 | `corrections` | derived | STRING | Comma list of corrections applied to the row (e.g. `DATE_STRIP_BYTES`), or NULL. The original stays in bronze. |
| 18 | `_run_id` | loader | STRING | Which pipeline run produced the row |

**Primary key:** (`state_fips`, `survey_year`, `seqno`). Measured on 2015: `(_STATE, SEQNO)` is unique (0 duplicates), and there are 0 full-row duplicates.

## Reference table: `ref.codebook_values`

The code → meaning mapping from `docs/codebook15_llcp.md`, loaded as a table so gold and Power BI can show "Yes / No" instead of 1 / 3, and so silver can be checked against the source document.

| Column | Type | Meaning |
|---|---|---|
| `variable` | STRING | Source variable name, e.g. `DIABETE3` |
| `code` | STRING | The code as printed in the codebook: `1`, `77`, `BLANK`, or a range such as `1 - 30` or `HIDDEN`. Kept as text because it is not always a number. |
| `label` | STRING | The meaning as printed, e.g. `Yes` |
| `source_frequency` | BIGINT | Rows with that code in `2015.csv`, as stated in the codebook. NULL where the codebook gives none. |

Generated from `docs/codebook15_llcp.json` by a script in `scripts/`, so it is reproducible. The seed file will be `config/codebook_values.csv`. Row count: NOT MEASURED until generated (the JSON holds 1,882 value rows across 330 variables).

Check C2 (ties silver to the codebook): for each of the 13 code columns, `count(silver) + count(quarantined)` per code must equal `source_frequency`. A mismatch means rows were lost or a code was changed. Result: NOT MEASURED.

## Rules

Every record ends in exactly one outcome: **clean**, **corrected**, **quarantined** or **rejected**. The four counts must add up to the input count (441,456), or the run fails.

### Corrected (deterministic, reversible, flagged in `corrections`)
| ID | Defect | Fix | Measured in 2015 |
|---|---|---|---|
| D1 | `IDATE` stored as `b'MMDDYYYY'` | Strip the `b'` and `'` wrapper | 441,456 rows (all) |
| D2 | Space instead of a leading zero in `IDATE` | Left-pad with `0` | 0 rows |
| Z1 | `_STATE` stored as float text (`1.0`) | Cast, then left-pad to 2 characters | 441,456 rows (all) |

`_BMI5` ÷ 100 is a documented encoding, not a defect, so it is not counted as a correction.

### Quarantined (no safe fix, never guessed)
| ID | Rule | Measured in 2015 |
|---|---|---|
| D3 | `IDATE` is not a real calendar date | 0 rows |
| D4 | Interview date year not 2015 or 2016 | 0 rows |
| K1 | Duplicate primary key | 0 rows |
| W1 | `final_weight` null or ≤ 0 | 0 rows |
| S1 | `state_fips` not among the 53 codebook codes | NOT MEASURED (53 distinct codes exist in the data; not yet compared to the codebook list) |
| C1 | A code column holds a value outside the allowed set | 0 expected: for every column, the codebook frequencies sum to 441,456. NOT MEASURED directly. |
| R1 | `bmi` outside the plausible range. **Range needs a decision.** | See below |

**R1 measured counts** (raw `_BMI5` range is 12.02–99.95; 36,398 BLANK are NULL, not violations):

| Range kept | Rows quarantined | % of 441,456 |
|---|---|---|
| 12–70 | 1,035 | 0.23% |
| 12–98 | 1 | 0.0002% |
| 15–50 | 4,043 | 0.92% |

### Never done
- No imputation of any missing value. BLANK stays NULL.
- Codes 7, 9, 77, 99 and 88 are kept as codes and never averaged.

## Publication gate (a failed run is blocked, not published with a warning)
| Check | Threshold |
|---|---|
| clean + corrected + quarantined + rejected = input rows | Exact |
| Quarantine rate | Under the threshold we document (brief metric says 0.1%). With R1 = 12–70 it would be 0.23% and would fail. |
| Silver schema matches this contract | Exact |
| Primary key unique | No duplicates |
| Both platforms: silver row counts and per-column null counts | Row counts identical; null rate within 0.01% |

## Gold: `gold.diabetes_prevalence_state`

One row per `state_fips` (expected 53).

| Column | Definition |
|---|---|
| `state_fips`, `state_name` | State name decoded from the codebook `_STATE` table |
| `valid_respondents` | Rows with `diabetes_code` in (1, 2, 3, 4) |
| `diabetes_yes` | Rows with `diabetes_code` = 1 |
| `weighted_yes_sum` | Σ`final_weight` where code = 1. Stored so a dashboard can add states up correctly (percentages cannot be averaged). |
| `weighted_valid_sum` | Σ`final_weight` where code in (1, 2, 3, 4) |
| `prevalence_weighted_pct` | 100 × `weighted_yes_sum` ÷ `weighted_valid_sum` |
| `prevalence_unweighted_pct` | 100 × `diabetes_yes` ÷ `valid_respondents`, shown so the effect of weighting is visible |
| `excluded_dont_know_refused_blank` | Rows with `diabetes_code` 7, 9 or NULL. Reported, never imputed. |

Definition choices (ours, so they can be challenged): code 2 (pregnancy only) and code 4 (pre-diabetes) count as **not** diabetic but stay in the denominator.

Measured `diabetes_code` counts in 2015: 3 → 372,104 · 1 → 57,256 · 4 → 7,690 · 2 → 3,608 · 7 → 598 · 9 → 193 · NULL → 7.

## Open decisions
1. **R1 BMI range.** It decides whether the quarantine table has real content, and whether the 0.1% gate holds.
2. **Row-level quarantine.** A quarantined record disappears from silver and gold entirely, even if only its BMI is doubtful.
3. **Guam (66) and Puerto Rico (72)** are kept in gold with the 50 states + DC.

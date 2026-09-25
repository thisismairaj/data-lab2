# Schema contract (DRAFT for approval)

Written once, implemented twice (Databricks and Snowflake). Both sides must produce identical columns, types, rules and counts.
Source: BRFSS 2011–2015 CSVs. Code meanings come from `docs/codebook15_llcp.md` (2015 codebook only).
All counts below were measured on 2026-09-25 with DuckDB on the local files. Anything not measured is marked NOT MEASURED.

## Business question (gold)

**How does diabetes prevalence vary by state and year, 2011–2015?**

## Layers

| Layer | Content | Rule |
|---|---|---|
| bronze | One table per year (`bronze.brfss_2011` … `_2015`), every source column as **text**, exactly as delivered, plus load metadata | Never modified. Column counts differ per year (454/359/336/279/330). |
| silver | One table, `silver.brfss_clean`, the 19 contract columns below, typed and validated | Only records that pass every rule (or are corrected, and flagged) |
| quarantine | `silver.brfss_quarantine`, one row per failed record | Nothing is dropped without a row here |
| gold | `gold.diabetes_prevalence_state_year` | Built only from silver. Users query gold, never bronze. |

Bronze load metadata columns (added by our loader, not in the source): `_source_file`, `_source_row_number`, `_run_id`, `_loaded_at`.

## Silver columns

Types are given as Databricks / Snowflake. Code columns keep the **raw code** (including "don't know" and "refused" codes). We never turn them into NULL or a guess. A BLANK in the source becomes NULL.

| # | Column | Source | Type (DBX / SF) | Meaning and rule |
|---|---|---|---|---|
| 1 | `state_fips` | `_STATE` | STRING(2) / VARCHAR(2) | State FIPS code, zero-padded (`1.0` → `01`). Must be one of the 53 codes in the codebook (50 states, DC, Guam 66, Puerto Rico 72). Otherwise quarantine. |
| 2 | `survey_year` | file name | SMALLINT | 2011–2015. This is the **file** year, not `IYEAR`: 3,057 to 10,915 rows per file have an interview date in the next year. |
| 3 | `seqno` | `SEQNO` | BIGINT | Not null. Not unique alone (restarts per state). |
| 4 | `interview_date` | `IDATE` | DATE | Source is text like `b'01202011'` = MMDDYYYY. See rules D1–D3. |
| 5 | `dispcode_raw` | `DISPCODE` | SMALLINT | Final disposition, as delivered. 2011 uses `110/120`; 2012–2015 use `1100/1200`. Kept as delivered. |
| 6 | `dispcode_vocab` | derived | STRING | `3digit` for 2011, `4digit` for 2012–2015 (vocabulary version column). |
| 7 | `sex_code` | `SEX` | SMALLINT | 1 male, 2 female |
| 8 | `age_group_code` | `_AGEG5YR` | SMALLINT | 1–13 = five-year bands from 18–24 to 80+; **14 = don't know / refused / missing** |
| 9 | `education_code` | `EDUCA` | SMALLINT | 1–6; 9 = refused |
| 10 | `income_code` | `INCOME2` | SMALLINT | 1–8 bands; 77 = don't know; 99 = refused |
| 11 | `general_health_code` | `GENHLTH` | SMALLINT | 1 excellent … 5 poor; 7 = don't know; 9 = refused |
| 12 | `health_plan_code` | `HLTHPLN1` | SMALLINT | 1 yes, 2 no, 7 don't know, 9 refused |
| 13 | `smoker_status_code` | `_SMOKER3` | SMALLINT | 1–4; 9 = don't know / refused / missing |
| 14 | `exercise_any_code` | `EXERANY2` | SMALLINT | 1 yes, 2 no, 7 don't know, 9 refused |
| 15 | `diabetes_code` | `DIABETE3` | SMALLINT | 1 yes · 2 yes, pregnancy only · 3 no · 4 no, pre-diabetes · 7 don't know · 9 refused. Same codes in all 5 years. |
| 16 | `bmi` | `_BMI5` | DECIMAL(5,2) / NUMBER(5,2) | Source is an integer with **2 implied decimals** (`2750` → `27.50`). BLANK → NULL. |
| 17 | `bmi_category_code` | `_BMI5CAT` | SMALLINT | 1 underweight, 2 normal, 3 overweight, 4 obese. BLANK → NULL. |
| 18 | `final_weight` | `_LLCPWT` | DOUBLE / FLOAT | Survey weight (how many adults this respondent represents). Must be > 0. Present in all 5 years, no nulls. |
| 19 | `corrections` | derived | STRING | Comma list of corrections applied to this row (e.g. `DATE_STRIP_BYTES,DATE_PAD`), or NULL if none. The original stays in bronze. |

**Primary key:** (`state_fips`, `survey_year`, `seqno`). Measured: `(_STATE, SEQNO)` is unique in all 5 files, and there are 0 full-row duplicates.

Columns deliberately left out: `_RFHYPE5` and `_RFCHOL` (missing in 2012 and 2014), `_RACE`/`_RACEGR3` (only 2013 onward). Only 158 of 644 column names exist in all 5 years, so this contract uses the ones that do.

## Rules

Every record ends in exactly one outcome: **clean**, **corrected**, **quarantined** or **rejected**. The four counts must add up to the input count, or the run fails.

### Corrected (deterministic, reversible, flagged in `corrections`)
| ID | Defect | Fix | Measured |
|---|---|---|---|
| D1 | `IDATE` stored as `b'MMDDYYYY'` | Strip the `b'` and `'` wrapper | All 2,380,047 rows |
| D2 | Space instead of leading zero (`b' 9142011'`) | Left-pad with `0` | 55 rows (2011 only) |
| Z1 | `_STATE` stored as float text (`1.0`) | Cast and left-pad to 2 characters | All rows |
| B1 | `_BMI5` integer with 2 implied decimals | Divide by 100 | Not a defect; a documented encoding |

### Quarantined (no safe fix, never guessed)
| ID | Rule | Measured |
|---|---|---|
| D3 | `IDATE` is not a real calendar date (`09312011`, `02292014` in a non-leap year) | 73 rows: 63 in 2011, 1 in 2012, 9 in 2014 |
| D4 | Interview date not in `survey_year` or `survey_year + 1` | NOT MEASURED |
| K1 | Duplicate primary key with any difference in values | 0 seen in a check of the `(_STATE, SEQNO)` pair |
| S1 | `state_fips` not in the 53 known codes | NOT MEASURED |
| W1 | `final_weight` null or ≤ 0 | 0 rows |
| C1 | A code column holds a value outside the allowed set for that column | NOT MEASURED |
| R1 | `bmi` outside the plausible range. **Proposed 12.00–70.00, needs your decision.** Observed raw range across all years is 12.01–99.95. | NOT MEASURED against the proposed range |

### Never done
- No imputation of any missing value. BLANK stays NULL.
- Codes 7, 9, 77, 99 and 88 are kept as codes and never averaged.

## Publication gate (a run that fails is blocked, not published with a warning)
| Check | Threshold |
|---|---|
| clean + corrected + quarantined + rejected = input rows | Exact |
| Quarantine rate | Under 0.1% (brief). Known so far: 73 of 2,380,047 = 0.003% (D3 only). |
| Silver schema matches this contract | Exact |
| Primary key unique | No duplicates |
| Both platforms: silver row counts and per-column null counts | Row counts identical; null rate within 0.01% |

## Gold: `gold.diabetes_prevalence_state_year`

One row per (`state_fips`, `survey_year`).

| Column | Definition |
|---|---|
| `state_fips`, `state_name`, `survey_year` | State name decoded from the codebook `_STATE` table |
| `valid_respondents` | Count of rows with `diabetes_code` in (1, 2, 3, 4) |
| `diabetes_yes` | Count of rows with `diabetes_code` = 1 |
| `prevalence_weighted_pct` | 100 × Σ`final_weight` where code = 1 ÷ Σ`final_weight` where code in (1, 2, 3, 4) |
| `prevalence_unweighted_pct` | 100 × `diabetes_yes` ÷ `valid_respondents` (shown so the effect of weighting is visible) |
| `excluded_dont_know_refused_blank` | Rows with `diabetes_code` 7, 9 or NULL, reported and not imputed |

Definition choices (ours, stated so they can be challenged): code 2 (pregnancy only) and code 4 (pre-diabetes) count as **not** diabetic but stay in the denominator. Weights are used within each year only, and years are never pooled.

Known caveat: 2011 has 1,126 blank `DIABETE3` values; 2012–2015 have between 0 and 7. Not yet explained.

## Open decisions
1. **R1 range** for BMI (proposed 12.00–70.00).
2. **Row-level quarantine for D3.** A bad date removes the whole respondent from gold (73 rows, 0.003%). The alternative is keeping the row with a NULL date. I followed the brief, which says ambiguous dates are quarantined.
3. **`dispcode` 110→1100.** The pattern looks obvious, but our only codebook is 2015, so the mapping is not documented. I kept the raw value and added a version column instead of correcting it.
4. **Guam (66) and Puerto Rico (72)** are kept in gold with the 50 states + DC.

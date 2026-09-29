# Diabetes Data Pipeline — Stakeholder Overview

**Status:** Databricks and Snowflake core builds complete, verified identical. Schema drift tests, external client test, and final report still open.
**Prepared:** 2026-09-29

---

## 1. What this is

Build the same pipeline on **Databricks** and **Snowflake**, using one real public health dataset, and prove both produce identical results from identical rules — evidence for a platform decision, not opinion.

**Dataset:** CDC's BRFSS 2015 phone survey — 441,456 people, 330 questions each.
**Question we built toward:** how does diabetes prevalence vary by US state, and what factors go with it?

---

## 2. What the raw data required us to handle

- **Codes, not numbers.** `7`=don't know, `9`=refused, etc. — never averaged as if real values.
- **Packed values.** BMI stored as an integer with 2 implied decimals (`2750` → `27.50`).
- **Corrupted-looking dates and codes** (`b'01292015'`, `_STATE` as `1.0`) from how the file was originally exported — fixed explicitly, not ignored.
- **Blank ≠ zero.** A blank means the question was skipped, not answered as "none."
- **Verified independently:** our filters reproduced a public reference notebook's exact row counts on the same file, confirming we read it correctly. We deliberately diverge from that notebook's approach — it silently drops 42% of rows (including 38% of diabetics) and discards the survey weight; ours keeps every row accounted for and preserves the weight, which weighted prevalence requires.

---

## 3. Architecture: bronze → silver → quarantine → gold

**Why this layered approach, not just "clean the file and load it":**
- **Nothing is trusted until it's proven.** Raw data lands untouched first; only data that passes explicit checks moves forward. If a number in a report is ever questioned, we can always go back to the untouched original and show exactly what changed and why.
- **Rules can change without redoing the expensive part.** If a validation rule needs adjusting, we rebuild the cleaned and final layers from the already-loaded raw data — no need to re-import from source again.
- **It's a proven, platform-independent pattern.** The same three-layer idea works identically whether the underlying engine is Databricks or Snowflake, which is exactly why it was the right choice for a project built to compare the two — a platform-specific shortcut wouldn't have transferred.

| Layer | Content | Rule |
|---|---|---|
| Bronze | All 330 columns, untouched text | Never modified — the audit trail |
| Silver | 18 typed, corrected columns | Only records that passed every rule |
| Quarantine | Failed records, with the exact reason | Nothing is ever silently dropped |
| Gold | Business-ready aggregates | Built only from silver |

**Governing rule:** every record ends in exactly one outcome (clean / corrected / quarantined / rejected), and the counts must sum to the input exactly — checked on every build, both platforms.

---

## 4. Quarantine rules — what we checked, what actually fired

We check 6 things per record: a valid date, a valid year, a real survey weight, a recognized state code, recognized answer codes, and a plausible BMI.

**Only one ever fires on this data: BMI outside 12.00–70.00 — 1,035 rows (0.23%), identical count on both platforms.** Predicted from raw-file profiling before any pipeline code existed, and the actual build matched it exactly.

Two corrections are applied to every row (stripping an export artifact from dates, zero-padding state codes) — deterministic fixes, not judgment calls, and the original value is never lost.

---

## 5. Gold tables and key findings

| Table | Key finding |
|---|---|
| **By state** | National weighted prevalence **10.5%**. Highest: Mississippi, West Virginia, Alabama. Lowest: Colorado, Utah, Minnesota — matches the published "diabetes belt" pattern. |
| **By age** | Rises with age, until the oldest bands |
| **By smoking status** | Former smokers highest (15.73%) — likely reverse causation (many quit *after* diagnosis), not smoking cessation causing diabetes |
| **By BMI category** | Clean gradient: underweight 3.21% → obese 19.14% (~6×) |
| **Comorbidity** (10 other conditions) | Kidney disease, heart disease, heart attack, stroke: **4.4–4.7× more common** in diabetics. One reversal: diabetics *less* likely to lack a personal doctor — a care-seeking pattern, not a protective effect |
| **Compounding risk** (obesity × smoking × inactivity) | **6.15% → 21.07% (3.4×)** from zero to three risk factors — the most actionable finding, since it identifies who to prioritize |

**Caveat covering the last two rows:** none of this controls for age, which independently drives several of the same conditions. The associations are real; causation isn't something this data settles alone.

---

## 6. Platform comparison

**Identical rules, identical data, identical output** — bronze, silver, quarantine, and gold row counts all match exactly between platforms, national prevalence matches to the decimal (10.5%).

**Real differences found, worth knowing:**
- **Cost visibility:** Snowflake showed real, enforced spending limits on a normal trial account. Databricks' free tier couldn't show real cost at all — only a paid trial exposed that.
- **Two SQL dialect gaps** that would have silently produced wrong data if untested: Snowflake's `CONCAT_WS` returns nothing if any input is missing (Databricks skips missing inputs); Snowflake has no `FILTER (WHERE...)` clause. Both caught by direct testing.
- **Databricks' Lakeflow** inferred the correct run order for a multi-step pipeline from the SQL alone — Snowflake has no exact equivalent.

---

## 7. Scope deviations from the original brief

- **2015 only**, not the full 5 years or the "100M+ rows" target (441,456 rows here) — a deliberate scope decision.
- **Region mismatch:** Databricks in AWS Ohio, Snowflake in AWS Mumbai — fixing it needed a new trial signup, not worth the time. Only in-platform query timing is directly comparable as a result.
- **Not sourced from either vendor's marketplace** — loaded from local files instead.
- **Power BI stays local**, not cloud-hosted — neither account qualifies for Power BI's hosting service.
- **One person built and measured both platforms**, not two independent engineers.

---

## 8. Still open

- Schema drift tests (rename / type change / dropped column)
- External client test (plain Python reading gold from both platforms)
- The short executive decision memo (this document is the detailed version)

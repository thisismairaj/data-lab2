# Learning log

Each concept in 2–3 lines. Newest at the bottom.

## Day 0 — dataset review

**Codes, not numbers.** In BRFSS, a column like `DIABETE3` holds *codes*: 1 = yes, 3 = no, 7 = don't know, 9 = refused. Averaging them is meaningless. Real-life example: a form where "Prefer not to say" is stored as 9 — an average age that includes 9s is wrong. The codebook (`docs/codebook15_llcp.md`) is the dictionary for every code.

**BLANK is not zero and not "no".** `BLANK` means the question was skipped or not asked (survey skip logic). Example: men are never asked pregnancy questions, so that column is blank for them. In silver we keep it as NULL, never as 0.

**Special numeric codes hide inside numeric columns.** `PHYSHLTH` is "days, 1–30", but 88 means "none" and 77/99 mean "don't know / refused". A range check like "1–30" would wrongly flag 88. The contract must list these codes per column.

**Implied decimals and packed units.** `_BMI5` is stored as an integer with 2 implied decimals (2750 means 27.50). `WEIGHT2` holds pounds *or* kilograms in one column (a leading 9 means kilograms). Example: it's like a price stored in cents. We must convert to real units in silver, and say so in the schema contract.

**A key can be unique only in combination.** `SEQNO` repeats across states, but `(_STATE, SEQNO)` is unique in all five files. I first read the repeats as duplicates. I checked the pair before calling it a problem. Lesson: test the real key before reporting duplicates.

**Byte-string artefacts (`b'01202011'`).** Some columns were exported from Python bytes and kept the `b'...'` wrapper. It is a fixable defect (strip the wrapper) because there is only one possible original value.

**Fixed-width origin.** The codebook's "Column" numbers are positions in the original fixed-width text file, not positions in our CSV. Ignore them for loading.

**Verifying a conversion.** When converting the PDF to Markdown, I did not trust it by eye. I checked that the variable count matched the CSV's 330 columns and that each variable's frequencies added up to 441,456 rows. The first two attempts failed those checks and revealed layout cases I would have missed.

## Day 1 — Databricks Phase 1

**Serverless cold start.** The SQL warehouse was STOPPED, so the first `SELECT 1` took 11.8 s on the server. The same query warm took 0.785 s. Real-life example: a taxi you have to call versus one already waiting. That gap is the "cold start penalty" the brief asks for. It costs the user waiting time, and it is billed compute time too.

**Server time vs client time.** The platform records how long a query ran (server time). Your script sees that plus network and tool overhead (client time). Server time is the fair number for comparing platforms. Client time depends on where your laptop is. Our first client timings came from the CLI wall clock, so they include process start-up and are marked PROVISIONAL.

**Free Edition limits are real deviations.** No clusters, no cluster policies, one warehouse that cannot be edited, and no `system.billing.usage` table. The brief assumes all of these exist. We record each as a gap, not a workaround.

**Cost can be unmeasurable.** Not every platform exposes its bill. "NOT MEASURED" means we haven't looked yet. "NOT MEASURABLE" means we looked and the data does not exist. The report must not blur the two.

## Day (2026-09-28) — Databricks Phase 2, sample load

**Unity Catalog volume.** A volume is a managed folder for raw files inside a catalog/schema, addressed like `/Volumes/workspace/bronze/landing/`. It's the Databricks equivalent of an S3 path, but access-controlled through Unity Catalog like a table.

**`read_files` needs a full struct, not a type name.** Passing `schema => 'STRING'` fails: Spark expects a struct definition (`STRUCT<col1 STRING, col2 STRING, ...>`), one entry per column. With 330 columns, this string was generated from the CSV header rather than typed by hand.

**Bronze stayed true to the contract.** Spot-checked after loading: `_STATE` reads `1.0`, `IDATE` still carries `b'01292015'`. Nothing was silently converted. That confirms bronze is doing its job (raw, unmodified) before silver does any cleaning.

## Day (2026-09-28) — Databricks Phase 3, silver/quarantine/gold on the sample

**Testing on a sample caught something the full-data profile didn't show: row order.** The 50,000-row sample only produced 6 states (Alabama through Colorado), because `2015.csv` turns out to be sorted by `_STATE`, not shuffled. A random sample would have hit all states; a "first N rows" sample does not. Good reason the contract calls this a "sample", not a proxy for the real distribution — it validates the pipeline logic, not the business answer.

**Multi-statement SQL over an HTTP API needs a real parser, not `.split(';')`.** A naive split breaks the moment a string literal (a reason message, a comment) contains a semicolon. Fixed by writing a small character-by-character splitter that tracks whether it's inside a quoted string before treating `;` as a statement boundary.

**Reconciliation as a habit, not a one-off.** After every table build: does clean + quarantine equal the input count? Does gold's sum of included and excluded equal silver's row count? Every check passed exactly on the first correct run, which is itself informative — it means the CASE WHEN logic doesn't have an off-by-one or an uncovered branch.

**Weighting changes the answer, and by different amounts per state.** Alabama: 13.46% weighted vs 17.14% unweighted. Colorado: 7.05% vs 9.28%. The survey oversamples some groups relative to the general population; the weight corrects for that. Reporting only the unweighted number would overstate prevalence here.

## Day (2026-09-28) — full-data build, silver/quarantine/gold proven on real data

**The sample test paid off before we even started.** Because the pipeline logic was already proven against the 50k sample, pointing it at the full 441,456-row table meant changing two table names and rerunning — no debugging. The 1,035-row quarantine count matched the prediction made on 2026-09-25 (before any pipeline SQL existed, just from profiling the raw CSV) exactly. That's a genuinely useful check: an *independent* prediction and the *built* result agreeing is stronger evidence than either alone.

**Reconciliation caught nothing wrong — and that's still worth checking.** Every gate passed on the first correct run: 440,421 + 1,035 = 441,456 (silver), 439,624 + 781 = 440,421 (gold), 0 duplicate keys. A pipeline that reconciles isn't proof of a *correct* business answer, only that no rows were lost or double-counted along the way.

**External plausibility as a cheap sanity check.** National weighted prevalence came out 10.5%, and the state ranking (Mississippi, West Virginia, Alabama highest) matched the well-known "diabetes belt" pattern from public health literature. This doesn't *prove* the pipeline is right — a consistently-biased pipeline could still look plausible — but a wildly implausible number (say, 60% or 0.5%) would have been a strong signal something was broken, worth checking before trusting anything downstream.

## Day (2026-09-28) — smoking and BMI category gold tables

Results, weighted % (matches published diabetes risk patterns, a useful sanity check):

| Smoking status | Weighted % |
|---|---|
| Never smoked | 8.73% (lowest) |
| Current smoker, some days | 8.95% |
| Current smoker, daily | 9.60% |
| Former smoker | **15.73%** (highest) |

**Former smokers having the highest rate is not "quitting causes diabetes."** This is a known trap called reverse causation: many people quit smoking *because* they were just diagnosed with diabetes or another condition, on doctor's orders - and former smokers also skew older on average, which independently raises diabetes risk. The data shows an association, and the pipeline correctly refuses to claim more than that (see docs/schema_contract.md's caution about correlation vs cause).

| BMI category | Weighted % |
|---|---|
| Underweight | 3.21% (lowest) |
| Normal weight | 4.52% |
| Overweight | 9.89% |
| Obese | **19.14%** (highest - about 6x underweight, 4x normal weight) |

This one is a clean, monotonic gradient exactly matching the well-known BMI-diabetes relationship - stronger external validation than the smoking table, precisely because there's no confound as obvious as reverse causation muddying it.

## Day (2026-09-28) — comorbidity table

Built by joining silver.brfss_clean back to bronze.brfss_2015 for 10 columns outside the
core contract (see sql/databricks/09_gold_comorbidity.sql for why - deliberately not
added to the contract, to avoid scope creep mid-project). Join verified 1:1 (440,421 rows,
matching silver exactly). Diabetic group: 57,116. Non-diabetic group: 378,911. The
remaining 4,394 (pregnancy-only, don't know, refused) are correctly excluded from both
groups - group membership has to be unambiguous.

Weighted %, diabetic vs non-diabetic, sorted by gap size:

| Condition | Diabetic | Non-diabetic | Ratio |
|---|---|---|---|
| Kidney disease | 9.02% | 1.93% | 4.67x |
| Coronary heart disease | 13.57% | 2.98% | 4.55x |
| Heart attack | 14.00% | 3.15% | 4.44x |
| Stroke | 8.71% | 2.37% | 3.68x |
| High blood pressure | 72.17% | 27.60% | 2.61x |
| High cholesterol | 64.97% | 32.37% | 2.01x |
| Depression | 25.40% | 16.62% | 1.53x |
| Asthma | 17.96% | 13.30% | 1.35x |
| Skipped care (cost) | 14.64% | 12.98% | 1.13x |
| **No personal doctor** | **6.56%** | **23.12%** | **0.28x (reversed)** |

**The interesting one is the reversal.** Every other condition is higher among diabetics -
except "no personal doctor," which is much LOWER. That's not diabetes protecting against
poor healthcare access; it's the opposite direction of causation from all the others -
managing diabetes requires ongoing care, so diagnosed diabetics are more likely to already
have a regular doctor relationship. Good example of why "compare the two groups" tables
need a human reading each row, not just the biggest number.

Same age-confound caveat as before: several of these (especially the top 4, all age-linked
conditions) are tangled with diabetics skewing somewhat older, not a clean diabetes-only effect.

## Day (2026-09-28) — Lakeflow Declarative Pipelines + Jobs, real (trial workspace)

**Pipeline vs Job, seen not just explained.** A Pipeline declares *what* tables should
exist; a Job decides *when* something runs and *what happens if it fails*. Proved this
concretely: creating the pipeline alone gave no scheduling at all - `databricks pipelines
run` even refused to run outside a bundle context. Wrapping it in a Job (one `pipeline_task`)
is what added a cron schedule, retry fields, and a `run-now` trigger. Confirmed working:
job run SUCCESS, 62s, correctly invoked the pipeline underneath.

**Declared logic reproduced the manual build exactly.** 441,456 -> 440,421 clean + 1,035
quarantined (all rule R1) -> 53 states. Same numbers as the hand-sequenced Free Edition
build, but the engine worked out bronze-before-silver-before-gold execution order from the
SQL itself (each CREATE statement's FROM clause names the table before it), not from me
running things in a specific order.

**Trial vs Free Edition, confirmed by actually trying it.** Free Edition refused to edit
the warehouse ("Editing warehouse is not available to you") and had zero clusters. Same
edit on the trial workspace succeeded immediately, and `databricks pipelines create`
(which needs its own serverless pipeline compute) worked without any block.

## Day (2026-09-28) — incremental load + a real bug caught by verification

**Adding a second year of data mid-pipeline is a genuinely different test than building
from scratch.** The pipeline's own schema-drift handling worked well without any help:
detected the change mid-flow, stopped that flow, skipped every downstream table rather
than cascade bad data, then auto-restarted itself. That's the engine doing exactly what
a hand-built pipeline would need explicit code to do.

**The bug was mine, not the engine's, and the habit of verifying caught it.** I'd
hardcoded `survey_year = 2015` when the pipeline was genuinely 2015-only; extending it to
two years without revisiting that line silently mislabeled every 2014 row as 2015. It
looked fine at a glance (pipeline succeeded, row counts summed correctly) - only the
gold-by-year breakdown exposed it, because "53 rows, not ~106" was the wrong shape for
two years of data. Lesson: a pipeline succeeding and totals reconciling is necessary but
not sufficient - the *shape* of the output also needs a sanity check, not just the count.

## Day (2026-09-28) — Snowflake Phase 1 + 2, no CLI needed

**Snowflake CLI (`snow`) broke on both my shell and the user's own PowerShell** - a real,
reproducible "Access is denied" writing `snow.exe`, not a sandbox quirk. Pivoted to the
Python connector (`snowflake-connector-python`, already installed from Phase 0) instead -
same SQL, same results, no CLI dependency at all. Worth remembering: a blocked CLI doesn't
mean blocked access, if a language driver exists for the same API.

**Snowflake's cost/governance tools are real on a normal trial - no upgrade needed.**
`CREATE RESOURCE MONITOR ... TRIGGERS ON 50 PERCENT DO NOTIFY ON 100 PERCENT DO SUSPEND`
gave a genuine, enforced credit ceiling immediately. Compare: Databricks Free Edition had
no equivalent at all; only the paid Trial exposed real cost data.

**The same splitter bug bit twice, in two different scripts.** Naive `.split(';')` breaks
the moment a string literal (a note field, a reason message) contains a semicolon - already
learned this building Databricks SQL, then rebuilt a naive version for Snowflake and hit
the identical failure. Fixed the same way: track whether you're inside a quote before
treating `;` as a statement boundary. Lesson: write the quote-aware splitter once, as a
shared utility, not per-platform from memory.

**Row-count parity, the brief's actual requirement, holds: 441,456 = 441,456.** Bronze on
Snowflake and Databricks now agree exactly, loaded via each platform's own named method
(`COPY INTO` vs `read_files`), same raw byte-for-byte values (`_STATE='1.0'`,
`IDATE="b'01292015'"` on both sides).

## Day (2026-09-28) — Snowflake Phase 3: full row-count and gold parity with Databricks

**Two real SQL dialect bugs found, both fixed and documented in the SQL comments:**
1. Snowflake has no `FILTER (WHERE ...)` clause on aggregates (Databricks/Spark supports
   it) - real syntax error, not a typo. Fixed with the portable `COUNT(CASE WHEN...THEN 1
   END)` / `SUM(CASE WHEN...THEN x END)` pattern instead.
2. Snowflake's `CONCAT_WS` returns NULL if ANY argument is NULL - Databricks/Spark's
   version skips NULLs. Tested directly: `CONCAT_WS(',', NULL, 'X', NULL)` gives NULL in
   Snowflake, would give `'X'` in Databricks. Fixed with `ARRAY_TO_STRING(
   ARRAY_CONSTRUCT_COMPACT(...), ',')`, which does drop NULLs.

Both are the kind of thing that looks like it should "just work" the same everywhere in
SQL and doesn't - worth remembering for any future cross-platform SQL work, not just this
project.

**The comparison the whole brief is actually about now has real numbers, and they match
exactly:** bronze 441,456=441,456, silver 440,421=440,421, quarantine 1,035=1,035 (all
rule R1 on both), gold 53=53 states, national weighted prevalence 10.5%=10.5%. Same rules,
same data, two different platforms, identical output - this is the actual proof the
pipeline logic is platform-independent, not an accident of one build happening to work.

## Day (2026-09-28) — compounding risk view

Collapsed BMI/smoking/exercise to binary flags on purpose (raw codes would give up to 80
tiny cells - the brief's own "small-cell suppression" concern, made concrete). Result: a
clean 2x2x2 = 8 cells, all large enough to trust (none needed suppression), rolling up to
a simple 0-3 risk factor count with a monotonic staircase: 6.15% -> 12.92% -> 18.60% ->
21.07%. The three-risk-factor group has 3.4x the zero-risk-factor group's prevalence -
the single most compelling number this project has produced, precisely because it
compounds three ordinary findings (obesity, smoking, inactivity) into one comparison
instead of showing each in isolation.

## Day (2026-09-29) — all 5 years, and a real validation gap found by testing at scale

**A shortcut taken "to keep the demo focused" turned into a real data-quality gap.**
Skipping rule C1 (code validity) in the first Lakeflow build seemed reasonable when only
2015 was loaded - nothing ever violated it. The moment 2013/2014 joined, corrupted values
(a BMI category of "2281", which looks exactly like a raw BMI value that landed in the
wrong column) started appearing, undetected, straight in gold. The lesson isn't "always
implement every rule from day one" - it's "know which shortcuts are safe only because the
current data happens not to exercise them, and revisit them the moment the data changes."

**Two independent bugs surfaced in the same debugging session, and it mattered to tell
them apart.** The C1 gap was mine, from an earlier explicit scope decision. The corrupted
`04_gold_state.sql` file was a separate, pre-existing issue that had nothing to do with
today's edits - it just never got exercised until a full refresh forced Databricks to
re-validate every file in the pipeline, not only the one just edited. Conflating the two
would have wasted time chasing the wrong fix.

**Testing at 5-year scale changed two conclusions from the single-year build.** BP/
cholesterol were assumed missing from just 2014 (found via a direct 2014-vs-2015 diff on
Free Edition) - turns out 2012 is missing them too, only visible once all 5 years were
actually loaded together. And the "flat, noisy" 3-year prevalence trend (2013-2015) turned
into a real, gradual 5-year rise once 2011-2012 were added - 3 data points weren't enough
to tell a trend from noise; 5 were.

## Day (2026-09-29) — Free Edition extended to 5 years, ANSI mode changes what "returns NULL" means

**A CLI I'd only used for workspace/pipeline management turned out to run SQL directly.**
`databricks api post /api/2.0/sql/statements` (the Statement Execution API) works from
the same OAuth-authenticated CLI already used all session for `workspace`/`pipelines`/
`jobs` commands - no separate SQL connector needed, unlike Snowflake (which needed
`snowflake-connector-python` because its CLI itself was broken). One real gotcha: Git
Bash rewrites any argument starting with `/` into a Windows path (`/api/2.0/...` became
`C:/Program Files/Git/api/2.0/...`), silently turning a valid API call into a 404.
`MSYS_NO_PATHCONV=1` disables that rewriting - worth remembering for any CLI argument
that looks like a Unix path but isn't a real filesystem path.

**`to_date()` and `try_to_date()` are not interchangeable, and the difference only shows
up with bad data.** The 2015-only build used `to_date()` and assumed it returns NULL for
an unparseable date, matching the docs at the time. That assumption was never actually
tested, because 2015 happens to have zero impossible dates. The moment 2011 (63 rows of
`09312011`-style dates) entered the build, `to_date()` under this runtime's ANSI SQL mode
**threw an error and crashed the whole `CREATE TABLE`** instead of returning NULL.
`try_to_date()` is the version that actually returns NULL on a bad date - the fix was a
one-word swap, but finding it required the exact bad data D3 was written to catch. Same
shape as the C1 gap on the Lakeflow build: a rule (or in this case, a function's assumed
behavior) that looked fine only because the data on hand never exercised the edge case.

**Result: two independently-built 5-year pipelines (Free Edition's hand-sequenced CTAS,
Trial's Lakeflow declarative pipeline) agree on the national prevalence trend to the
decimal** - 9.8% / 10.18% / 10.27% / 10.54% / 10.5% for 2011-2015, computed from
completely different code paths. That's the strongest evidence yet that the pipeline's
*logic* is what's being validated, not an artifact of one particular build method.

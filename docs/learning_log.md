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

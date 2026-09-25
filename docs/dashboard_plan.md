# Power BI dashboard plan

Status: PLAN, not built. Nothing here has been measured yet. Every number on the dashboard must come from a real run, or show "Not measured".

## What the dashboard must show (from the brief and your list)
- Row counts on both platforms
- Load times on both platforms
- Cost per platform
- Quarantine counts
- One business chart from the gold table (diabetes by state)

Power BI Desktop is installed on this machine (found `PBIDesktop.exe`). I cannot click inside it, so the build steps below are for you to do, and I will give exact clicks at each step.

## Words used in this plan
- **Semantic model**: the tables and rules Power BI holds behind the charts. Like a small database inside the file.
- **Measure**: a calculation Power BI runs on the fly, written in DAX (its formula language). Like a SQL aggregate that reacts to filters.
- **Import mode**: Power BI copies the data into the `.pbix` file. Fast, and it does not touch the warehouse while you click around.
- **DirectQuery mode**: Power BI asks the warehouse a new question on every click. It always shows fresh data, but every click starts compute and costs credits.

**Decision: Import mode.** The data is tiny (gold has about 53 rows). DirectQuery would wake the warehouse on every click, which costs trial credits and slows the demo. Trade-off: the dashboard shows data as of the last refresh, not live. We record that as a gap (the brief's "live metrics" is a Phase 6 goal).

## Pages

| Page | Question it answers | Main visuals |
|---|---|---|
| 1. Platform scorecard | Did both platforms do the same work, and how did they compare? | Row-count cards per layer per platform with a match check; load time bars; cost bars; drift test table; external client steps and seconds |
| 2. Data quality | What was wrong with the data, and what did we do about it? | Quarantine rows by rule; corrections by type; "don't know / refused" share per column |
| 3. Diabetes by state | What share of adults has diabetes in each state? | Map or ranked bars (weighted %); national card; sample size per state; caveat text box |
| 4. Who has diabetes | How does it vary by age, sex, income? | **Dropped.** Decision 2026-09-25: keep diabetes-by-state only (option A), no extra gold table. |

## Steps

### Step 1. Fix the shape of the data upstream (before opening Power BI)
Power BI is only as good as its tables. We agree three tables that look identical on both platforms:

| Table | What it holds |
|---|---|
| `gold.diabetes_prevalence_state` | One row per state (see the contract) |
| `ops.pipeline_metrics` | One row per measurement: `platform`, `phase`, `metric_name`, `value`, `unit`, `run_id`, `measured_at`, `method` |
| `ref.codebook_values` | Code to meaning lookup (shows "Yes" instead of 1) |

Why: Power BI stacks the two platforms' metric tables together. That only works if both have the same columns.

**Design point.** A percentage cannot be averaged. If Alabama is 12% and Alaska is 8%, the two-state rate is not 10%, because the states differ in size. So gold also stores the two sums behind each percentage: `weighted_yes_sum` and `weighted_valid_sum`. Power BI then divides the sums, which is correct at any level. This is added to the contract.

### Step 2. Connect Power BI to Databricks
Home, then Get data, then Databricks. It needs the workspace host and the SQL warehouse path. Both are already in `.env`, so I will read them out for you. Load only the three tables above. Sign-in method (browser login or access token) will be found out on the day.

You should see: the table list, then a preview of 53 state rows.

### Step 3. Connect Power BI to Snowflake
Same idea: Get data, then Snowflake. It needs the account address and the warehouse name. Load the same tables. Only the metrics table is needed from Snowflake for the scorecard. Gold from Snowflake is loaded once for the parity check.

### Step 4. Combine the two platforms' metrics
Append the two `ops.pipeline_metrics` tables into one, with `platform` as a column. Now one chart can show both platforms side by side.

### Step 5. Build the model and measures
- One relationship: `state_fips` between gold and a small state table.
- Measures (I will write the DAX for you to paste): `Rows`, `Quarantine rate`, `Weighted prevalence % = SUM(weighted_yes_sum) / SUM(weighted_valid_sum)`, `Parity check` (do the two platforms show the same row count?).
- **A measure that shows "Not measured" when a value is empty**, so blanks never look like zeros.

### Step 6. Build the pages
Page 1, then 2, then 3, in that order. The business page comes last because it depends on nothing but gold and can be built while metrics are still being collected.

### Step 7. Prove every number
Every card and chart gets a row in a table: `dashboard number | SQL that proves it | result | match?`. This follows the project rule "never mark done without verifying". A number with no proof query is removed.

### Step 8. Save and record
Save `dashboard/data_lab.pbix` in the repo. It contains only aggregated data (gold and metrics), never row-level data. Record the refresh date and the Import-mode gap in `scope_and_gaps.md`.

## When each step can happen
| Step | Needs | Earliest |
|---|---|---|
| 1 | Contract approved | Now (design only) |
| 2, 5, 6 (page 3) | Databricks gold built | End of Day 2 |
| 3, 4, 6 (pages 1, 2) | Both platforms' metrics measured | Day 3 morning |
| 7, 8 | Everything above | Day 3 |

Cost figures may lag. Both platforms publish usage numbers after a delay (Snowflake's usage views can be hours behind). So we run the measured loads on Day 2 and read cost on Day 3. Any cost still missing on the day shows "Not measured".

## Risks
1. Power BI's Databricks sign-in may not work with Free Edition. Fallback: export gold and metrics to CSV and load those, recorded as a deviation.
2. Cost data may not exist on Free Edition. Then cost shows "Not measured" for Databricks, and we say so.
3. Timings taken from your laptop include distance to each region (Mumbai and Ohio until the Snowflake move). They must be labelled "client side".
4. Time. About 2 hours is planned for the dashboard, which is tight for a first Power BI build. The buffer on Day 3 exists for this.

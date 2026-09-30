"""Phase 4 external client test: plain Python + pandas, no Databricks account, no
Spark - genuinely outside both platforms, reading BRFSS's shared gold table via the
open Delta Sharing protocol. Times connection, lists tables, reads data, checks type
fidelity against known-verified numbers from earlier in this project.
"""
import time, delta_sharing

CONFIG = r"C:\Users\muham\Downloads\config.share"

t0 = time.perf_counter()
client = delta_sharing.SharingClient(CONFIG)
tables = client.list_all_tables()
t_connect = time.perf_counter() - t0
print(f"Step 1 - connect + list tables: {t_connect:.2f}s")
print("Tables found:", [(t.share, t.schema, t.name) for t in tables])

t1 = time.perf_counter()
table_url = f"{CONFIG}#{tables[0].share}.{tables[0].schema}.{tables[0].name}"
df = delta_sharing.load_as_pandas(table_url)
t_read = time.perf_counter() - t1
print(f"Step 2 - first query (full table read): {t_read:.2f}s")
print(f"Rows: {len(df)}, Columns: {list(df.columns)}")

# Adversarial type-fidelity check: does the weighted sum stay a real double with
# decimal precision, does state_fips stay a zero-padded string, not become an int?
print("\n-- Type fidelity check --")
print("state_fips dtype:", df['state_fips'].dtype, "| sample:", df['state_fips'].iloc[0], "(zero-padded string?" , df['state_fips'].iloc[0].startswith('0') if df['state_fips'].iloc[0][0]=='0' else 'n/a - first row not 0-padded, check others', ")")
print("weighted_yes_sum dtype:", df['weighted_yes_sum'].dtype, "| sample:", df['weighted_yes_sum'].iloc[0])
print("prevalence_weighted_pct dtype:", df['prevalence_weighted_pct'].dtype, "| sample:", df['prevalence_weighted_pct'].iloc[0])

# Cross-check against the already-verified national prevalence trend (9.8/10.18/10.27/10.54/10.5)
national = df.groupby('survey_year').apply(
    lambda g: 100.0 * g['weighted_yes_sum'].sum() / g['weighted_valid_sum'].sum(), include_groups=False
).round(2)
print("\n-- National prevalence by year, recomputed from the EXTERNALLY-READ data --")
print(national)

print(f"\nTOTAL time to first usable result: {t_connect + t_read:.2f}s")

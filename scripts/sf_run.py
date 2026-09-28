"""Run one or more SQL statements against Snowflake via the Python connector.
Usage: python sf_run.py "<sql>;<sql>;..." — statements separated by ';' at line end.
Never prints the password (reads it from .env, only used to authenticate)."""
import sys, time
from dotenv import load_dotenv
import os, snowflake.connector

load_dotenv(r"D:\data-lab2\.env", override=True)
con = snowflake.connector.connect(
    account=os.environ["SNOWFLAKE_ACCOUNT"],
    user=os.environ["SNOWFLAKE_USER"],
    password=os.environ["SNOWFLAKE_PASSWORD"],
    warehouse=os.environ["SNOWFLAKE_WAREHOUSE"],
)
cur = con.cursor()

sql_text = open(sys.argv[1], encoding="utf-8").read() if sys.argv[1].endswith(".sql") else sys.argv[1]
# split on ';' (good enough for our files: no ';' inside string literals), then strip
# full-line comments from EACH chunk before deciding whether it has real SQL left -
# BUG FIX: previously filtered raw chunks by whether their first line was a comment,
# which dropped statements that legitimately start with a comment line above them.
raw_chunks = sql_text.split(";")
stmts = []
for s in raw_chunks:
    lines = [l for l in s.split("\n") if not l.strip().startswith("--")]
    s2 = "\n".join(lines).strip()
    if s2:
        stmts.append(s2)

for s2 in stmts:
    if not s2:
        continue
    t0 = time.perf_counter()
    try:
        cur.execute(s2)
        rows = cur.fetchall() if cur.description else []
        dt = time.perf_counter() - t0
        print(f"-- OK ({dt:.3f}s, qid={cur.sfqid}): {s2[:70].replace(chr(10),' ')}")
        for r in rows[:20]:
            print("   ", r)
    except Exception as e:
        dt = time.perf_counter() - t0
        print(f"-- FAILED ({dt:.3f}s): {s2[:70].replace(chr(10),' ')}")
        print("   ERROR:", e)

con.close()

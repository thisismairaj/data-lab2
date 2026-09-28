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

def strip_line_comment(line):
    in_str = False
    i = 0
    while i < len(line) - 1:
        if line[i] == "'":
            in_str = not in_str
        elif not in_str and line[i:i+2] == "--":
            return line[:i]
        i += 1
    return line

def split_statements(text):
    # quote-aware split on ';' - a semicolon inside a string literal (e.g. a note field
    # like '...; matches ...') must NOT end the statement. Same bug class hit twice now
    # with the naive .split(';') version - fixed once, properly, here.
    lines = [strip_line_comment(l) for l in text.split("\n")]
    text = "\n".join(lines)
    stmts, buf, in_str, i = [], [], False, 0
    while i < len(text):
        c = text[i]
        buf.append(c)
        if c == "'":
            in_str = not in_str
        elif c == ";" and not in_str:
            s = "".join(buf[:-1]).strip()
            if s:
                stmts.append(s)
            buf = []
        i += 1
    tail = "".join(buf).strip()
    if tail:
        stmts.append(tail)
    return stmts

stmts = split_statements(sql_text)

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

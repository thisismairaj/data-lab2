"""Uploads one or more local BRFSS CSVs to the Snowflake BRONZE.LANDING stage via PUT.
PUT is a client-side special command the Python connector handles natively (not regular
SQL) - same mechanism already used for 2015.csv (61.4s for 541MB, auto-gzipped).

Usage: python sf_upload_stage.py 2011 2012 2013 2014
"""
import sys, time
from dotenv import load_dotenv
import os, snowflake.connector

ARCHIVE = r"C:\Users\muham\Downloads\archive"

load_dotenv(r"D:\data-lab2\.env", override=True)
con = snowflake.connector.connect(
    account=os.environ["SNOWFLAKE_ACCOUNT"],
    user=os.environ["SNOWFLAKE_USER"],
    password=os.environ["SNOWFLAKE_PASSWORD"],
    warehouse=os.environ["SNOWFLAKE_WAREHOUSE"],
)
cur = con.cursor()
cur.execute("USE DATABASE BRFSS")

for year in sys.argv[1:]:
    local_path = os.path.join(ARCHIVE, f"{year}.csv").replace("\\", "/")
    t0 = time.perf_counter()
    cur.execute(f"PUT file://{local_path} @BRONZE.LANDING AUTO_COMPRESS=TRUE OVERWRITE=TRUE")
    row = cur.fetchone()
    dt = time.perf_counter() - t0
    print(f"-- {year}: {dt:.1f}s, status={row}")

con.close()

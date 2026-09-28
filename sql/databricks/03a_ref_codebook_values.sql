-- Databricks: ref.codebook_values - the code -> meaning lookup, generated from the codebook.
-- Run on 2026-09-28, before the silver build (03_silver_and_quarantine.sql uses this table's
-- valid-code lists as the source for rule C1 and S1; gold uses it to decode _STATE to a name).
--
-- This table is NOT typed by hand: its 1,882 rows are generated from
-- docs/codebook15_llcp.json (itself generated from the CDC's codebook PDF - see
-- scripts/pdf_to_md.py - and checked against 2015.csv: 330/330 variables matched, every
-- variable's Frequency column sums to 441,456). One INSERT statement, built by a small
-- Python script that walks the JSON and emits one row per (variable, code, label, frequency)
-- triple. That generator script is not checked in here (it's a few lines of json.load +
-- string-join); this file documents the table shape and how to re-derive it if needed.

CREATE OR REPLACE TABLE workspace.ref.codebook_values (
  variable          STRING,   -- source variable name, e.g. 'DIABETE3'
  code              STRING,   -- the code as printed in the codebook: '1', '77', 'BLANK', or a
                               -- range like '1 - 30' - kept as text because it isn't always a number
  label             STRING,   -- the meaning, e.g. 'Yes'
  source_frequency  BIGINT    -- how many 2015 respondents had this code, per the codebook (NULL if none given)
) COMMENT 'Code to meaning lookup, generated from docs/codebook15_llcp.json';

-- INSERT INTO workspace.ref.codebook_values VALUES (...), (...), ... ;
--   1,882 rows total - generated, not written by hand here. See the paragraph above.

-- ---- Verification ----
SELECT count(*) FROM workspace.ref.codebook_values;                 -- expect 1882
SELECT count(DISTINCT variable) FROM workspace.ref.codebook_values; -- expect 330 (every 2015.csv column)
SELECT * FROM workspace.ref.codebook_values WHERE variable = 'DIABETE3' ORDER BY code;

-- Gold: same table as the Lakeflow materialized view brfss.gold.diabetes_prevalence_state.
-- One row per state per year, survey-weighted. The only table dashboards and consumers query.
-- Snowflake has no FILTER (WHERE ...) on aggregates, so COUNT_IF and SUM(IFF(...)) do the same job.
-- TARGET_LAG = DOWNSTREAM: refreshed by the ingest task right after a file loads (04_ingest_task.sql).

CREATE OR REPLACE DYNAMIC TABLE BRFSS.GOLD.DIABETES_PREVALENCE_STATE
  TARGET_LAG = DOWNSTREAM
  WAREHOUSE = COMPUTE_WH
  COMMENT = 'One row per state per year. The only table dashboards/consumers should query.'
AS
SELECT
  s.state_fips,
  n.state_name,
  s.survey_year,
  COUNT_IF(s.diabetes_code IN (1,2,3,4))                         AS valid_respondents,
  COUNT_IF(s.diabetes_code = 1)                                  AS diabetes_yes,
  SUM(IFF(s.diabetes_code = 1, s.final_weight, NULL))            AS weighted_yes_sum,
  SUM(IFF(s.diabetes_code IN (1,2,3,4), s.final_weight, NULL))   AS weighted_valid_sum,
  100.0 * SUM(IFF(s.diabetes_code = 1, s.final_weight, NULL))
        / SUM(IFF(s.diabetes_code IN (1,2,3,4), s.final_weight, NULL)) AS prevalence_weighted_pct,
  COUNT_IF(s.diabetes_code IN (7,9) OR s.diabetes_code IS NULL)  AS excluded_dont_know_refused_blank
FROM BRFSS.SILVER.CLEAN s
LEFT JOIN (SELECT column1 AS state_fips, column2 AS state_name FROM (VALUES ('01','Alabama'),('02','Alaska'),('04','Arizona'),('05','Arkansas'),('06','California'),('08','Colorado'),('09','Connecticut'),('10','Delaware'),('11','District of Columbia'),('12','Florida'),('13','Georgia'),('15','Hawaii'),('16','Idaho'),('17','Illinois'),('18','Indiana'),('19','Iowa'),('20','Kansas'),('21','Kentucky'),('22','Louisiana'),('23','Maine'),('24','Maryland'),('25','Massachusetts'),('26','Michigan'),('27','Minnesota'),('28','Mississippi'),('29','Missouri'),('30','Montana'),('31','Nebraska'),('32','Nevada'),('33','New Hampshire'),('34','New Jersey'),('35','New Mexico'),('36','New York'),('37','North Carolina'),('38','North Dakota'),('39','Ohio'),('40','Oklahoma'),('41','Oregon'),('42','Pennsylvania'),('44','Rhode Island'),('45','South Carolina'),('46','South Dakota'),('47','Tennessee'),('48','Texas'),('49','Utah'),('50','Vermont'),('51','Virginia'),('53','Washington'),('54','West Virginia'),('55','Wisconsin'),('56','Wyoming'),('66','Guam'),('72','Puerto Rico'))) n
  ON s.state_fips = n.state_fips
GROUP BY s.state_fips, n.state_name, s.survey_year;

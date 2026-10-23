-- Gold: one row per state per year, survey-weighted. The only table dashboards and consumers
-- query. Same table as Snowflake's BRFSS.GOLD.DIABETES_PREVALENCE_STATE (snowflake/pipeline/03_gold.sql).
-- MATERIALIZED VIEW: an aggregate, so Lakeflow recomputes it over silver.clean on each update.
CREATE OR REFRESH MATERIALIZED VIEW gold.diabetes_prevalence_state
COMMENT 'One row per state per year. The only table dashboards/consumers should query.'
AS
SELECT
  s.state_fips,
  n.state_name,
  s.survey_year,
  count(*) FILTER (WHERE s.diabetes_code IN (1,2,3,4))            AS valid_respondents,
  count(*) FILTER (WHERE s.diabetes_code = 1)                     AS diabetes_yes,
  sum(s.final_weight) FILTER (WHERE s.diabetes_code = 1)          AS weighted_yes_sum,
  sum(s.final_weight) FILTER (WHERE s.diabetes_code IN (1,2,3,4)) AS weighted_valid_sum,
  100.0 * sum(s.final_weight) FILTER (WHERE s.diabetes_code = 1)
        / sum(s.final_weight) FILTER (WHERE s.diabetes_code IN (1,2,3,4))  AS prevalence_weighted_pct,
  count(*) FILTER (WHERE s.diabetes_code IN (7,9) OR s.diabetes_code IS NULL) AS excluded_dont_know_refused_blank
FROM silver.clean s
LEFT JOIN (VALUES ('01','Alabama'),('02','Alaska'),('04','Arizona'),('05','Arkansas'),('06','California'),('08','Colorado'),('09','Connecticut'),('10','Delaware'),('11','District of Columbia'),('12','Florida'),('13','Georgia'),('15','Hawaii'),('16','Idaho'),('17','Illinois'),('18','Indiana'),('19','Iowa'),('20','Kansas'),('21','Kentucky'),('22','Louisiana'),('23','Maine'),('24','Maryland'),('25','Massachusetts'),('26','Michigan'),('27','Minnesota'),('28','Mississippi'),('29','Missouri'),('30','Montana'),('31','Nebraska'),('32','Nevada'),('33','New Hampshire'),('34','New Jersey'),('35','New Mexico'),('36','New York'),('37','North Carolina'),('38','North Dakota'),('39','Ohio'),('40','Oklahoma'),('41','Oregon'),('42','Pennsylvania'),('44','Rhode Island'),('45','South Carolina'),('46','South Dakota'),('47','Tennessee'),('48','Texas'),('49','Utah'),('50','Vermont'),('51','Virginia'),('53','Washington'),('54','West Virginia'),('55','Wisconsin'),('56','Wyoming'),('66','Guam'),('72','Puerto Rico')) AS n(state_fips, state_name) ON s.state_fips = n.state_fips
GROUP BY s.state_fips, n.state_name, s.survey_year;

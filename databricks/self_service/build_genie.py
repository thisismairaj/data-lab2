"""Builds genie_agent.json (serialized_space v2) for the BRFSS Genie space."""
import json, pathlib
G = "brfss.gold.diabetes_prevalence_state"
Q = "brfss.silver.quarantine"
gold = G.split(".")[-1]

def cid(n): return f"{n:032x}"

PREV = f"ROUND(100.0 * SUM(g.weighted_yes_sum) / SUM(g.weighted_valid_sum), 2)"
examples = [
  ("What is the national diabetes prevalence by year?",
   f"SELECT g.survey_year, {PREV} AS prevalence_pct FROM {G} g GROUP BY g.survey_year ORDER BY g.survey_year"),
  ("Which 10 states have the highest diabetes prevalence?",
   f"SELECT g.state_name, g.survey_year, ROUND(g.prevalence_weighted_pct, 2) AS prevalence_pct, g.valid_respondents FROM {G} g ORDER BY g.prevalence_weighted_pct DESC LIMIT 10"),
  ("How many records were quarantined and why?",
   f"SELECT q.rule_id, COUNT(*) AS quarantined_rows FROM {Q} q GROUP BY q.rule_id ORDER BY quarantined_rows DESC"),
]
tests = [e[1] for e in examples]
if __name__ == "__main__" and pathlib.Path("tests.json").exists() is False:
    pathlib.Path("tests.json").write_text(json.dumps(tests))

space = {
 "version": 2,
 "config": {"sample_questions": [
   {"id": cid(i+1), "question": [q]} for i, q in enumerate([
     "Which states have the highest diabetes prevalence?",
     "What is the national diabetes prevalence by year?",
     "Compare diabetes prevalence in Texas and California",
     "Which states have the most survey respondents?",
     "How many records were quarantined, and why?"])]},
 "data_sources": {"tables": [
   {"identifier": G, "column_configs": sorted([
     {"column_name": "diabetes_yes", "description": ["Unweighted count of respondents who answered yes to diabetes."]},
     {"column_name": "excluded_dont_know_refused_blank", "description": ["Respondents excluded from prevalence because they answered don't know, refused, or left it blank."]},
     {"column_name": "prevalence_weighted_pct", "description": ["Survey-weighted diabetes prevalence for this state and year, as a percentage from 0 to 100. Do not average this across states; use the weighted_prevalence_pct measure instead."], "synonyms": ["prevalence", "diabetes rate", "diabetes percentage"]},
     {"column_name": "state_fips", "exclude": True},
     {"column_name": "state_name", "description": ["US state name (50 states, District of Columbia, Guam, Puerto Rico)."], "synonyms": ["state"], "enable_format_assistance": True, "enable_entity_matching": True},
     {"column_name": "survey_year", "description": ["Year of the CDC BRFSS survey file."], "synonyms": ["year"]},
     {"column_name": "valid_respondents", "description": ["Respondents with a valid yes/no diabetes answer. Use as the sample size."], "synonyms": ["respondents", "sample size"]},
     {"column_name": "weighted_valid_sum", "description": ["Sum of survey weights over valid respondents; the denominator of weighted prevalence."]},
     {"column_name": "weighted_yes_sum", "description": ["Sum of survey weights over respondents with diabetes; the numerator of weighted prevalence."]},
   ], key=lambda c: c["column_name"])},
   {"identifier": Q, "column_configs": sorted([
     {"column_name": "dataset_id", "exclude": True},
     {"column_name": "raw_payload", "exclude": True},
     {"column_name": "record_id", "description": ["Survey sequence number of the quarantined record."]},
     {"column_name": "reason", "exclude": True},
     {"column_name": "rule_id", "description": ["Quality rule(s) the record failed. D3 = impossible interview date, W1 = missing or non-positive survey weight, R1 = BMI outside 12 to 70, C1 = an answer code the codebook does not define. A record that failed several rules shows them comma-separated, e.g. R1,C1."], "synonyms": ["rule", "reason", "failure reason"], "enable_format_assistance": True},
     {"column_name": "severity", "exclude": True},
     {"column_name": "status", "exclude": True},
   ], key=lambda c: c["column_name"])},
 ]},
 "instructions": {
   "example_question_sqls": [{"id": cid(10+i), "question": [q], "sql": [s]} for i, (q, s) in enumerate(examples)],
   "sql_snippets": {"measures": [{"id": cid(20), "alias": "weighted_prevalence_pct", "display_name": "Weighted prevalence %",
        "sql": ["ROUND(100.0 * SUM(diabetes_prevalence_state.weighted_yes_sum) / SUM(diabetes_prevalence_state.weighted_valid_sum), 2)"],
        "synonyms": ["national prevalence", "diabetes prevalence", "overall rate"]}]},
   "text_instructions": [{"id": cid(30), "content": [
     "## Instructions you must follow when providing summaries\n",
     "- Always state which survey year or years the answer covers.\n",
     "- Round percentages to two decimal places.\n",
     "- Never average state prevalence values; combine weighted_yes_sum and weighted_valid_sum instead."]}],
 },
}
pathlib.Path("genie_agent.json").write_text(json.dumps(space, indent=2), encoding="utf-8")
print("wrote genie_agent.json", len(json.dumps(space)), "bytes")

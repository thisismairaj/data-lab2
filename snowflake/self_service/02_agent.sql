-- Self-service chat: a Snowflake Intelligence agent over the semantic view in 01_semantic_view.sql.
-- This is what a business user opens (Snowsight > AI & ML > Snowflake Intelligence) to ask
-- questions in plain English, like the Databricks Genie space. Same sample questions.
-- Snowflake Intelligence lists agents kept in SNOWFLAKE_INTELLIGENCE.AGENTS.

CREATE DATABASE IF NOT EXISTS SNOWFLAKE_INTELLIGENCE;
CREATE SCHEMA IF NOT EXISTS SNOWFLAKE_INTELLIGENCE.AGENTS;
GRANT USAGE ON DATABASE SNOWFLAKE_INTELLIGENCE TO ROLE PUBLIC;
GRANT USAGE ON SCHEMA SNOWFLAKE_INTELLIGENCE.AGENTS TO ROLE PUBLIC;

CREATE OR REPLACE AGENT SNOWFLAKE_INTELLIGENCE.AGENTS.BRFSS_DIABETES
  COMMENT = 'Ask about US diabetes prevalence (CDC BRFSS) and data-quality quarantine'
  PROFILE = '{"display_name": "Diabetes prevalence (CDC BRFSS)"}'
  FROM SPECIFICATION $$
models:
  orchestration: auto
instructions:
  response: "Answer in plain English for a business audience. Give prevalence as a percentage with two decimals and name the survey year. Prevalence is survey-weighted: never average state percentages; use the weighted_prevalence_pct metric at the level asked (state, year or national)."
  orchestration: "Use the brfss tool for every question about diabetes prevalence, respondents, states, years or quarantined records."
  sample_questions:
    - question: "Which states have the highest diabetes prevalence?"
    - question: "What is the national diabetes prevalence by year?"
    - question: "Compare diabetes prevalence in Texas and California"
    - question: "Which states have the most survey respondents?"
    - question: "How many records were quarantined, and why?"
tools:
  - tool_spec:
      type: "cortex_analyst_text_to_sql"
      name: "brfss"
      description: "Diabetes prevalence by US state and survey year, survey respondents, and quarantined records with the rule each failed."
tool_resources:
  brfss:
    semantic_view: "BRFSS.SEMANTIC.BRFSS_DIABETES"
    execution_environment:
      type: "warehouse"
      warehouse: "COMPUTE_WH"
$$;

GRANT USAGE ON AGENT SNOWFLAKE_INTELLIGENCE.AGENTS.BRFSS_DIABETES TO ROLE PUBLIC;

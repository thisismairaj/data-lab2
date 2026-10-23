"""BRFSS diabetes dashboard and self-service chat, running inside Snowflake (Streamlit in Snowflake).
Dashboard tab: the same KPIs, trend, quarantine and state ranking as the Databricks AI/BI dashboard.
Ask tab: plain-English questions answered by Cortex Analyst over the semantic view
BRFSS.GOLD.BRFSS_DIABETES (snowflake/self_service/01_semantic_view.sql), showing the SQL it ran."""
import json

import _snowflake
import pandas as pd
import streamlit as st
from snowflake.snowpark.context import get_active_session

SEMANTIC_VIEW = "BRFSS.GOLD.BRFSS_DIABETES"
session = get_active_session()

st.set_page_config(page_title="Diabetes prevalence (CDC BRFSS)", layout="wide")
st.title("Diabetes prevalence in the US (CDC BRFSS)")
st.caption("Survey-weighted share of adults reporting diabetes, by state and year. "
           "Every row that fails a quality rule is held in quarantine with a reason, never dropped.")


@st.cache_data(ttl=60)
def query(sql: str) -> pd.DataFrame:
    return session.sql(sql).to_pandas()


gold = query("""
    SELECT survey_year, state_name, valid_respondents, weighted_yes_sum, weighted_valid_sum,
           prevalence_weighted_pct
    FROM BRFSS.GOLD.DIABETES_PREVALENCE_STATE""")
quarantine = query("""
    SELECT survey_year, rule_id, COUNT(*) AS quarantined_rows
    FROM BRFSS.SILVER.QUARANTINE GROUP BY survey_year, rule_id""")

tab_dash, tab_ask = st.tabs(["Dashboard", "Ask a question"])

with tab_dash:
    years = sorted(gold["SURVEY_YEAR"].unique())
    picked = st.multiselect("Year", years, default=years)
    g = gold[gold["SURVEY_YEAR"].isin(picked)]
    q = quarantine[quarantine["SURVEY_YEAR"].isin(picked)]

    # National prevalence = weighted sums added up, never an average of state percentages.
    national = 100 * g["WEIGHTED_YES_SUM"].sum() / g["WEIGHTED_VALID_SUM"].sum() if len(g) else 0
    k1, k2, k3 = st.columns(3)
    k1.metric("National prevalence", f"{national:.2f}%")
    k2.metric("Valid respondents", f"{int(g['VALID_RESPONDENTS'].sum()):,}")
    k3.metric("Quarantined rows", f"{int(q['QUARANTINED_ROWS'].sum()):,}")

    c1, c2 = st.columns(2)
    with c1:
        st.subheader("National prevalence by year")
        by_year = (g.groupby("SURVEY_YEAR")[["WEIGHTED_YES_SUM", "WEIGHTED_VALID_SUM"]].sum()
                     .assign(prevalence_pct=lambda d: 100 * d.WEIGHTED_YES_SUM / d.WEIGHTED_VALID_SUM))
        by_year.index = by_year.index.astype(str)
        st.line_chart(by_year["prevalence_pct"])
    with c2:
        st.subheader("Quarantined rows by rule")
        st.bar_chart(q.groupby("RULE_ID")["QUARANTINED_ROWS"].sum())
        st.caption("D3 impossible interview date, W1 missing survey weight, "
                   "R1 BMI outside 12 to 70, C1 answer code not in the codebook.")

    st.subheader("States, highest prevalence first")
    by_state = (g.groupby("STATE_NAME")[["WEIGHTED_YES_SUM", "WEIGHTED_VALID_SUM", "VALID_RESPONDENTS"]].sum()
                  .assign(prevalence_pct=lambda d: 100 * d.WEIGHTED_YES_SUM / d.WEIGHTED_VALID_SUM)
                  .sort_values("prevalence_pct", ascending=False))
    st.bar_chart(by_state["prevalence_pct"])

    # Drill-down: pick a state to see it year by year.
    state = st.selectbox("Drill into a state", by_state.index.tolist())
    detail = gold[gold["STATE_NAME"] == state].sort_values("SURVEY_YEAR")
    st.dataframe(
        detail[["SURVEY_YEAR", "VALID_RESPONDENTS", "PREVALENCE_WEIGHTED_PCT"]]
        .rename(columns={"SURVEY_YEAR": "Year", "VALID_RESPONDENTS": "Respondents",
                         "PREVALENCE_WEIGHTED_PCT": "Prevalence %"})
        .round(2),
        hide_index=True, use_container_width=True)

with tab_ask:
    st.write("Ask about diabetes prevalence by state or year, respondents, or quarantined records.")
    st.caption("Try: Compare diabetes prevalence in Texas and California. "
               "Which states have the highest prevalence? How many records were quarantined, and why?")
    question = st.chat_input("Your question")
    if question:
        st.chat_message("user").write(question)
        body = {"messages": [{"role": "user", "content": [{"type": "text", "text": question}]}],
                "semantic_view": SEMANTIC_VIEW}
        resp = _snowflake.send_snow_api_request(
            "POST", "/api/v2/cortex/analyst/message", {}, {}, body, None, 50000)
        content = json.loads(resp["content"])
        with st.chat_message("assistant"):
            if resp["status"] >= 400:
                st.error(content.get("message", "Cortex Analyst returned an error."))
            else:
                for part in content["message"]["content"]:
                    if part["type"] == "text":
                        st.write(part["text"])
                    elif part["type"] == "suggestions":
                        st.write("Did you mean: " + "; ".join(part["suggestions"]))
                    elif part["type"] == "sql":
                        st.dataframe(session.sql(part["statement"]).to_pandas(),
                                     hide_index=True, use_container_width=True)
                        with st.expander("SQL that answered this"):
                            st.code(part["statement"], language="sql")

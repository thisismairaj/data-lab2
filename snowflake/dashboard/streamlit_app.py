"""BRFSS diabetes dashboard, running inside Snowflake (Streamlit in Snowflake).

Reads the gold star schema (snowflake/pipeline/03c_gold_star_schema.sql): one fact row per survey
response, joined to state, age, sex, income, education, smoking and BMI dimensions. Every number is
survey-weighted: sum of weights with diabetes / sum of weights with a valid answer. Filters are
applied in SQL, so Snowflake does the work and only small results come back.

Tabs: Dashboard (filters, KPIs, breakdowns), Ask a question (Cortex Analyst over the semantic
view BRFSS.SEMANTIC.BRFSS_DIABETES, showing the SQL it wrote), Data quality (quarantine by rule).
"""
import json

import _snowflake
import altair as alt
import pandas as pd
import streamlit as st
from snowflake.snowpark.context import get_active_session

SEMANTIC_VIEW = "BRFSS.SEMANTIC.BRFSS_DIABETES"
G = "BRFSS.GOLD."
session = get_active_session()

st.set_page_config(page_title="Diabetes in the US (CDC BRFSS)", layout="wide")
st.title("Diabetes in the US (CDC BRFSS)")
st.caption("Survey-weighted share of adults who report diabetes. Pick filters to focus on a group; "
           "every chart follows.")

FROM = f"""
FROM {G}FACT_SURVEY_RESPONSE f
JOIN {G}DIM_STATE s           ON s.state_fips = f.state_fips
JOIN {G}DIM_AGE_GROUP a       ON a.age_group_code = f.age_group_code
JOIN {G}DIM_SEX x             ON x.sex_code = f.sex_code
JOIN {G}DIM_INCOME i          ON i.income_code = f.income_code
JOIN {G}DIM_EDUCATION e       ON e.education_code = f.education_code
JOIN {G}DIM_SMOKING_STATUS k  ON k.smoker_status_code = f.smoker_status_code
JOIN {G}DIM_BMI_CATEGORY b    ON b.bmi_category_code = f.bmi_category_code
"""
PREV = "100 * SUM(f.diabetes_weight) / NULLIF(SUM(f.valid_answer_weight), 0)"


@st.cache_data(ttl=300)
def run(sql: str, params: tuple = ()) -> pd.DataFrame:
    return session.sql(sql, params=list(params)).to_pandas()


@st.cache_data(ttl=300)
def options(col: str, table: str, order: str) -> list:
    return run(f"SELECT DISTINCT {col} AS v, {order} AS o FROM {G}{table} ORDER BY o")["V"].tolist()


tab_dash, tab_ask, tab_dq = st.tabs(["Dashboard", "Ask a question", "Data quality"])

with tab_dash:
    years = run(f"SELECT DISTINCT survey_year AS y FROM {G}FACT_SURVEY_RESPONSE ORDER BY 1")["Y"].tolist()
    c1, c2, c3, c4, c5 = st.columns(5)
    f_year = c1.multiselect("Year", years, default=years)
    f_state = c2.selectbox("State", ["All states"] + options("state_name", "DIM_STATE", "state_name"))
    f_age = c3.selectbox("Age", ["All ages"] + options("age_band", "DIM_AGE_GROUP", "MIN(age_group_code) OVER (PARTITION BY age_band)"))
    f_sex = c4.selectbox("Sex", ["All"] + ["Male", "Female"])
    f_smoke = c5.selectbox("Smoking", ["All"] + options("smoking_status", "DIM_SMOKING_STATUS", "smoker_status_code"))

    # Build one WHERE clause with bound parameters (never string-pasted values).
    where, params = ["f.survey_year IN (" + ",".join("?" * len(f_year)) + ")"], list(f_year)
    if f_state != "All states":
        where.append("s.state_name = ?"); params.append(f_state)
    if f_age != "All ages":
        where.append("a.age_band = ?"); params.append(f_age)
    if f_sex != "All":
        where.append("x.sex = ?"); params.append(f_sex)
    if f_smoke != "All":
        where.append("k.smoking_status = ?"); params.append(f_smoke)
    W = "WHERE " + " AND ".join(where) if f_year else "WHERE FALSE"
    P = tuple(params)

    kpi = run(f"SELECT {PREV} AS prev, SUM(f.valid_answer) AS resp, SUM(f.survey_weight) AS adults {FROM} {W}", P)
    k1, k2, k3 = st.columns(3)
    k1.metric("Diabetes prevalence", f"{kpi['PREV'][0]:.2f}%" if pd.notna(kpi["PREV"][0]) else "n/a")
    k2.metric("Respondents", f"{int(kpi['RESP'][0] or 0):,}")
    k3.metric("Adults represented", f"{(kpi['ADULTS'][0] or 0) / 1e6:,.1f} million")

    def breakdown(label_col: str, order_col: str, title: str, sort_by_value: bool = False):
        df = run(f"SELECT {label_col} AS label, MIN({order_col}) AS o, {PREV} AS prevalence, "
                 f"SUM(f.valid_answer) AS respondents {FROM} {W} GROUP BY 1 HAVING SUM(f.valid_answer) >= 30", P)
        df = df.sort_values("PREVALENCE" if sort_by_value else "O", ascending=not sort_by_value)
        chart = alt.Chart(df).mark_bar().encode(
            x=alt.X("PREVALENCE:Q", title="Diabetes prevalence (%)"),
            y=alt.Y("LABEL:N", sort=df["LABEL"].tolist(), title=None),
            tooltip=[alt.Tooltip("LABEL:N", title="Group"),
                     alt.Tooltip("PREVALENCE:Q", title="Prevalence %", format=".2f"),
                     alt.Tooltip("RESPONDENTS:Q", title="Respondents", format=",")])
        st.subheader(title)
        st.altair_chart(chart, use_container_width=True)

    left, right = st.columns(2)
    with left:
        breakdown("a.age_group", "a.age_group_code", "By age group")
        breakdown("i.income_band", "i.sort_order", "By household income")
        breakdown("k.smoking_status", "k.smoker_status_code", "By smoking status")
    with right:
        breakdown("b.bmi_category", "b.bmi_category_code", "By BMI category")
        breakdown("e.education_level", "e.education_code", "By education")
        breakdown("x.sex", "x.sex_code", "By sex")

    breakdown("s.state_name", "s.state_name", "By state, highest first", sort_by_value=True)
    st.caption("Groups with fewer than 30 respondents are hidden, so small samples do not mislead.")

    st.subheader("Other conditions: adults with diabetes vs without")
    cond = run(f"""
        SELECT IFF(f.has_diabetes = 1, 'With diabetes', 'Without diabetes') AS grp,
          100 * SUM(IFF(f.had_heart_attack = 1, f.survey_weight, 0)) / NULLIF(SUM(IFF(f.had_heart_attack IS NOT NULL, f.survey_weight, 0)), 0) AS "Had a heart attack",
          100 * SUM(IFF(f.has_kidney_disease = 1, f.survey_weight, 0)) / NULLIF(SUM(IFF(f.has_kidney_disease IS NOT NULL, f.survey_weight, 0)), 0) AS "Kidney disease",
          100 * SUM(IFF(f.has_depression = 1, f.survey_weight, 0)) / NULLIF(SUM(IFF(f.has_depression IS NOT NULL, f.survey_weight, 0)), 0) AS "Depression",
          100 * SUM(IFF(f.had_stroke = 1, f.survey_weight, 0)) / NULLIF(SUM(IFF(f.had_stroke IS NOT NULL, f.survey_weight, 0)), 0) AS "Had a stroke"
        {FROM} {W} AND f.valid_answer = 1 GROUP BY 1""", P)
    if len(cond):
        long = cond.melt(id_vars="GRP", var_name="Condition", value_name="Percent")
        st.altair_chart(alt.Chart(long).mark_bar().encode(
            x=alt.X("Percent:Q", title="Share with the condition (%)"),
            y=alt.Y("GRP:N", title=None), color=alt.Color("GRP:N", legend=None),
            row=alt.Row("Condition:N", title=None),
            tooltip=["Condition", "GRP", alt.Tooltip("Percent:Q", format=".1f")]))

with tab_ask:
    # Follow-ups work because the whole conversation so far (questions and Cortex Analyst's
    # answers) is kept in session memory and sent with every new question. Streamlit reruns the
    # script on each interaction, so anything not in st.session_state would be forgotten.
    if "chat" not in st.session_state:
        st.session_state.chat = []      # messages in the Cortex Analyst API format
        st.session_state.results = {}   # index of an analyst message -> its result table

    st.write("Ask about diabetes in plain English: by state, age, sex, income, education, smoking, BMI "
             "or year. Follow-up questions build on the previous answer.")
    examples = ["Which income band has the highest diabetes prevalence?",
                "What is diabetes prevalence among adults aged 45 to 64 in Texas, by smoking status?",
                "Compare diabetes prevalence in Texas and California",
                "How many records were quarantined, and why?"]
    clicked = None
    cols = st.columns(len(examples) + 1)
    for col, ex in zip(cols, examples):
        if col.button(ex, use_container_width=True):
            clicked = ex
    if cols[-1].button("New conversation", use_container_width=True):
        st.session_state.chat, st.session_state.results = [], {}

    # The conversation area is reserved here, above the input box, and filled after the new
    # question is answered; so the newest answer appears just above where you type.
    history = st.container()
    question = st.chat_input("Your question, or a follow-up such as: now only in Texas") or clicked
    if question:
        # Cortex Analyst needs strict turn-taking: user, analyst, user, ... So a question joins the
        # history only together with its answer. If anything fails (an API error, a timeout while the
        # warehouse wakes up, a query error), the history is left exactly as it was.
        chat = st.session_state.chat
        while chat and chat[-1]["role"] == "user":   # never send two questions in a row
            chat.pop()
        new_q = {"role": "user", "content": [{"type": "text", "text": question}]}
        try:
            body = {"messages": chat + [new_q], "semantic_view": SEMANTIC_VIEW}
            resp = _snowflake.send_snow_api_request("POST", "/api/v2/cortex/analyst/message", {}, {}, body, None, 120000)
            content = json.loads(resp["content"])
            if resp["status"] >= 400:
                raise RuntimeError(content.get("message", "Cortex Analyst returned an error."))
            answer = {"role": "analyst", "content": content["message"]["content"]}
            table = None
            for part in answer["content"]:
                if part["type"] == "sql":
                    table = session.sql(part["statement"]).to_pandas()
            chat += [new_q, answer]
            if table is not None:
                st.session_state.results[len(chat) - 1] = table
        except Exception as err:
            st.warning(f"That question did not go through, please ask it again. ({err})")

    # Show the conversation oldest first, in the area above the input box.
    with history:
        chat = st.session_state.chat
        for i, msg in enumerate(chat):
            if msg["role"] == "user":
                st.chat_message("user").write(msg["content"][0]["text"])
                continue
            with st.chat_message("assistant"):
                for part in msg["content"]:
                    if part["type"] == "text":
                        st.write(part["text"])
                    elif part["type"] == "suggestions":
                        st.write("Did you mean: " + "; ".join(part["suggestions"]))
                    elif part["type"] == "sql":
                        if i in st.session_state.results:
                            st.dataframe(st.session_state.results[i], hide_index=True, use_container_width=True)
                        with st.expander("SQL that answered this"):
                            st.code(part["statement"], language="sql")

with tab_dq:
    st.write("Every row that breaks a rule is held in quarantine with the rule it broke. Nothing is dropped.")
    dq = run("""SELECT q.quarantined_rows, c.clean_rows FROM
                (SELECT COUNT(*) AS quarantined_rows FROM BRFSS.SILVER.QUARANTINE) q,
                (SELECT COUNT(*) AS clean_rows FROM BRFSS.SILVER.CLEAN) c""")
    d1, d2, d3 = st.columns(3)
    d1.metric("Clean rows", f"{int(dq['CLEAN_ROWS'][0]):,}")
    d2.metric("Quarantined rows", f"{int(dq['QUARANTINED_ROWS'][0]):,}")
    d3.metric("Quarantine rate", f"{100 * dq['QUARANTINED_ROWS'][0] / (dq['QUARANTINED_ROWS'][0] + dq['CLEAN_ROWS'][0]):.3f}%")
    rules = run("SELECT rule_id, survey_year, COUNT(*) AS n FROM BRFSS.SILVER.QUARANTINE GROUP BY 1, 2 ORDER BY 3 DESC")
    st.dataframe(rules.rename(columns={"RULE_ID": "Rule", "SURVEY_YEAR": "Year", "N": "Rows"}), hide_index=True)
    st.caption("D3 impossible interview date. W1 missing survey weight. R1 BMI outside 12 to 70. "
               "C1 answer code not in the codebook. The alert emails if the rate goes above 0.1%.")

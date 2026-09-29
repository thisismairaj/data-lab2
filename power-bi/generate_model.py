"""Generator 1 of 2: writes the semantic model (TMDL) for the diabetes dashboard.

Why this exists: Power BI's .pbip project format stores the data model as plain-text
TMDL files (Tabular Model Definition Language) instead of a binary blob. That means the
model can be *generated* instead of clicked together - this script writes one .tmdl file
per gold table, wires each one's Power Query (M) connection to the Trial Databricks
workspace, and defines the DAX measures every chart needs.

The one manual sample (gold_diabetes_prevalence_state.tmdl) was Power BI's own output
from Get Data -> Databricks -> Load. Every M-query shape below (DatabricksMultiCloud.Catalogs,
the Database/Schema/Table navigation steps) is copied from that real file, not guessed -
only the catalog/schema/table names change per table.

Run: python generate_model.py   (from the power-bi/ folder)
"""
import uuid, os

HOST = "dbc-93916528-90f8.cloud.databricks.com"
HTTP_PATH = "/sql/1.0/warehouses/6cd9ffe6ba1a7c82"
BASE = os.path.dirname(os.path.abspath(__file__))
TABLES_DIR = os.path.join(BASE, "diabetes_dashboard.SemanticModel", "definition", "tables")


def tag():
    return str(uuid.uuid4())


def m_block(steps, final_var):
    """Renders a full M `let ... in ...` block with UNIFORM tab indentation on every
    line - `let`/`in` at 3 tabs, each step at 4 tabs. This matters because TMDL parses
    by indentation depth: the first version of this script mixed tabs (from the outer
    template) with hand-copied spaces (from the one real sample file) on different
    lines, so `in` ended up shallower than `let` - Power BI's parser then read `in` as
    a new sibling property instead of a continuation of the expression, and refused to
    load ("the keyword 'in' is neither a property nor an object in the current
    context"). Every line here comes from one loop, so that can't happen again."""
    let_ind = "\t" * 3
    step_ind = "\t" * 4
    lines = [f"{let_ind}let"]
    for i, step in enumerate(steps):
        suffix = "," if i < len(steps) - 1 else ""
        lines.append(f"{step_ind}{step}{suffix}")
    lines.append(f"{let_ind}in")
    lines.append(f"{step_ind}{final_var}")
    return "\n".join(lines)


def m_source(schema, table, kind):
    """The Power Query (M) steps Power BI itself writes for Get Data -> Databricks.
    Copied verbatim in shape from gold_diabetes_prevalence_state.tmdl; only the
    schema/table/kind change. `kind` is "View" for Lakeflow streaming tables /
    materialized views, "Table" for plain managed Delta tables (confirmed via
    `databricks tables list` table-type column: MATERIALIZED_VIEW/STREAMING_TABLE
    show as View, MANAGED shows as Table in the connector's navigation tree)."""
    steps = [
        f'Source = DatabricksMultiCloud.Catalogs("{HOST}", "{HTTP_PATH}", [Catalog=null, Database=null, QueryTags=null, EnableAutomaticProxyDiscovery=null, Implementation="2.0", Protocol=null])',
        'workspace_Database = Source{[Name="workspace",Kind="Database"]}[Data]',
        f'{schema}_Schema = workspace_Database{{[Name="{schema}",Kind="Schema"]}}[Data]',
        f'{table}_View = {schema}_Schema{{[Name="{table}",Kind="{kind}"]}}[Data]',
    ]
    return m_block(steps, f"{table}_View")


def m_source_state_with_label():
    """gold_diabetes_prevalence_state, extended past the sample: merges in state_name
    from ref.codebook_values (variable='_STATE') so the bar chart can show real state
    names, not FIPS codes. state_fips is zero-padded text ('06'); codebook_values.code
    is unpadded text ('6') - same round-trip the SQL joins already use
    (CAST(CAST(x AS DOUBLE) AS INT)), done here in M instead of SQL."""
    steps = [
        f'Source = DatabricksMultiCloud.Catalogs("{HOST}", "{HTTP_PATH}", [Catalog=null, Database=null, QueryTags=null, EnableAutomaticProxyDiscovery=null, Implementation="2.0", Protocol=null])',
        'workspace_Database = Source{[Name="workspace",Kind="Database"]}[Data]',
        'lakeflow_demo_Schema = workspace_Database{[Name="lakeflow_demo",Kind="Schema"]}[Data]',
        'gold_diabetes_prevalence_state_View = lakeflow_demo_Schema{[Name="gold_diabetes_prevalence_state",Kind="View"]}[Data]',
        'ref_Schema = workspace_Database{[Name="ref",Kind="Schema"]}[Data]',
        'codebook_values_Table = ref_Schema{[Name="codebook_values",Kind="Table"]}[Data]',
        'state_labels = Table.SelectRows(codebook_values_Table, each [variable] = "_STATE")',
        'Added_join_key = Table.AddColumn(gold_diabetes_prevalence_state_View, "state_code_join", each Text.From(Number.From([state_fips])), type text)',
        'Merged_with_labels = Table.NestedJoin(Added_join_key, {"state_code_join"}, state_labels, {"code"}, "StateInfo", JoinKind.LeftOuter)',
        'Expanded_StateInfo = Table.ExpandTableColumn(Merged_with_labels, "StateInfo", {"label"}, {"state_name"})',
        'Removed_join_key = Table.RemoveColumns(Expanded_StateInfo, {"state_code_join"})',
    ]
    return m_block(steps, "Removed_join_key")


def col_block(name, dtype, is_numeric, summarize="sum", extra=""):
    fmt = "\n\t\tformatString: 0" if dtype == "int64" else ""
    ann = '\n\n\t\tannotation PBI_FormatHint = {"isGeneralNumber":true}' if dtype == "double" else ""
    return f'''	column {name}
		dataType: {dtype}{fmt}
		lineageTag: {tag()}
		summarizeBy: {summarize if is_numeric else "none"}
		sourceColumn: {name}
{extra}
		annotation SummarizationSetBy = Automatic{ann}
'''


# ---- 1. gold_diabetes_prevalence_state: extend the manual sample -------------------
state_tmdl = f'''table gold_diabetes_prevalence_state
	lineageTag: {tag()}

''' + col_block("state_fips", "string", False) + '''
''' + col_block("survey_year", "int64", True) + '''
''' + col_block("valid_respondents", "int64", True) + '''
''' + col_block("diabetes_yes", "int64", True) + '''
''' + col_block("weighted_yes_sum", "double", True) + '''
''' + col_block("weighted_valid_sum", "double", True) + '''
''' + col_block("prevalence_weighted_pct", "double", True) + '''
''' + col_block("excluded_dont_know_refused_blank", "int64", True) + f'''
	column state_name
		dataType: string
		lineageTag: {tag()}
		summarizeBy: none
		sourceColumn: state_name
		dataCategory: StateOrProvince

		annotation SummarizationSetBy = Automatic

	measure 'National Prevalence %' = ```
			DIVIDE(SUM(gold_diabetes_prevalence_state[weighted_yes_sum]), SUM(gold_diabetes_prevalence_state[weighted_valid_sum]))
			```
		formatString: 0.0%
		lineageTag: {tag()}

	measure 'States Covered' = DISTINCTCOUNT(gold_diabetes_prevalence_state[state_fips])
		formatString: 0
		lineageTag: {tag()}

	measure 'Years Covered' = DISTINCTCOUNT(gold_diabetes_prevalence_state[survey_year])
		formatString: 0
		lineageTag: {tag()}

	partition gold_diabetes_prevalence_state = m
		mode: import
		source =
{m_source_state_with_label()}

	annotation PBI_ResultType = Table
'''

with open(os.path.join(TABLES_DIR, "gold_diabetes_prevalence_state.tmdl"), "w", encoding="utf-8") as f:
    f.write(state_tmdl)

# ---- 2-6. the other five gold tables (all live in workspace.gold, all Kind="Table") -
def write_gold_table(table_name, columns, measure_name, measure_dax, measure_format,
                      sort_by=None, extra_measures=""):
    """columns: list of (name, dtype, is_numeric). sort_by: {label_col: sort_col} for
    ordinal axis locking (docs/dataviz skill: never let a categorical axis fall back
    to alphabetical order when a real order exists, e.g. age bands, BMI categories)."""
    sort_by = sort_by or {}
    body = f"table {table_name}\n\tlineageTag: {tag()}\n\n"
    for name, dtype, is_numeric in columns:
        extra = ""
        if name in sort_by:
            extra = f"\t\tsortByColumn: {sort_by[name]}\n"
        body += col_block(name, dtype, is_numeric, extra=extra) + "\n"
    body += (
        f"\tmeasure '{measure_name}' = ```\n\t\t\t{measure_dax}\n\t\t\t```\n"
        f"\t\tformatString: {measure_format}\n\t\tlineageTag: {tag()}\n\n"
    )
    if extra_measures:
        body += extra_measures + "\n"
    body += (
        f"\tpartition {table_name} = m\n\t\tmode: import\n\t\tsource =\n"
        f"{m_source('gold', table_name, 'Table')}\n\n"
        f"\tannotation PBI_ResultType = Table\n"
    )
    with open(os.path.join(TABLES_DIR, f"{table_name}.tmdl"), "w", encoding="utf-8") as fh:
        fh.write(body)


write_gold_table(
    "diabetes_prevalence_age_group",
    [("age_group_code", "double", True), ("survey_year", "int64", True),
     ("age_group_label", "string", False), ("valid_respondents", "int64", True),
     ("diabetes_yes", "int64", True), ("weighted_yes_sum", "double", True),
     ("weighted_valid_sum", "double", True), ("prevalence_weighted_pct", "double", True),
     ("excluded_dont_know_refused_blank", "int64", True)],
    "Age Prevalence %",
    "DIVIDE(SUM(diabetes_prevalence_age_group[weighted_yes_sum]), SUM(diabetes_prevalence_age_group[weighted_valid_sum]))",
    "0.0%",
    sort_by={"age_group_label": "age_group_code"},
)

write_gold_table(
    "diabetes_prevalence_smoking",
    [("smoker_status_code", "double", True), ("survey_year", "int64", True),
     ("smoking_label", "string", False), ("valid_respondents", "int64", True),
     ("diabetes_yes", "int64", True), ("weighted_yes_sum", "double", True),
     ("weighted_valid_sum", "double", True), ("prevalence_weighted_pct", "double", True)],
    "Smoking Prevalence %",
    "DIVIDE(SUM(diabetes_prevalence_smoking[weighted_yes_sum]), SUM(diabetes_prevalence_smoking[weighted_valid_sum]))",
    "0.0%",
    sort_by={"smoking_label": "smoker_status_code"},
)

write_gold_table(
    "diabetes_prevalence_bmi_category",
    [("bmi_category_code", "double", True), ("survey_year", "int64", True),
     ("bmi_category_label", "string", False), ("valid_respondents", "int64", True),
     ("diabetes_yes", "int64", True), ("weighted_yes_sum", "double", True),
     ("weighted_valid_sum", "double", True), ("prevalence_weighted_pct", "double", True)],
    "BMI Prevalence %",
    "DIVIDE(SUM(diabetes_prevalence_bmi_category[weighted_yes_sum]), SUM(diabetes_prevalence_bmi_category[weighted_valid_sum]))",
    "0.0%",
    sort_by={"bmi_category_label": "bmi_category_code"},
)

write_gold_table(
    "diabetes_comorbidity",
    [("survey_year", "int64", True), ("condition", "string", False),
     ("condition_label", "string", False), ("diabetes_group", "string", False),
     ("valid_respondents", "int64", True), ("condition_yes_n", "int64", True),
     ("weighted_yes_sum", "double", True), ("weighted_valid_sum", "double", True),
     ("condition_pct_weighted", "double", True)],
    "Condition %",
    "DIVIDE(SUM(diabetes_comorbidity[weighted_yes_sum]), SUM(diabetes_comorbidity[weighted_valid_sum]))",
    "0.0%",
)

risk_extra = f'''	measure 'Risk Factor Gap x' = ```
			DIVIDE(
			    CALCULATE([Risk Prevalence %], diabetes_risk_stacking[risk_factor_count] = 3),
			    CALCULATE([Risk Prevalence %], diabetes_risk_stacking[risk_factor_count] = 0)
			)
			```
		formatString: 0.0"x"
		lineageTag: {tag()}
'''
write_gold_table(
    "diabetes_risk_stacking",
    [("survey_year", "int64", True), ("obese_flag", "int64", True),
     ("smoker_flag", "int64", True), ("inactive_flag", "int64", True),
     ("risk_factor_count", "int64", True), ("valid_respondents", "int64", True),
     ("diabetes_yes", "int64", True), ("weighted_yes_sum", "double", True),
     ("weighted_valid_sum", "double", True), ("prevalence_weighted_pct", "double", True),
     ("small_cell_suppressed", "boolean", False)],
    "Risk Prevalence %",
    "DIVIDE(SUM(diabetes_risk_stacking[weighted_yes_sum]), SUM(diabetes_risk_stacking[weighted_valid_sum]))",
    "0.0%",
    extra_measures=risk_extra,
)

# ---- rewrite model.tmdl in full (not a patch) so re-running this script is safe ----
model_path = os.path.join(BASE, "diabetes_dashboard.SemanticModel", "definition", "model.tmdl")
all_tables = ["gold_diabetes_prevalence_state"] + [
    "diabetes_prevalence_age_group", "diabetes_prevalence_smoking",
    "diabetes_prevalence_bmi_category", "diabetes_comorbidity", "diabetes_risk_stacking",
]
order = "[" + ", ".join(f'"{t}"' for t in all_tables) + "]"
model = f'''model Model
	culture: en-US
	defaultPowerBIDataSourceVersion: powerBI_V3
	sourceQueryCulture: en-PK
	valueFilterBehavior: independent
	dataAccessOptions
		legacyRedirects
		returnErrorValuesAsNull

annotation __PBI_TimeIntelligenceEnabled = 1

annotation PBI_QueryOrder = {order}

annotation PBI_ProTooling = ["DevMode"]

''' + "".join(f"ref table {t}\n" for t in all_tables) + '''
ref cultureInfo en-US
'''
with open(model_path, "w", encoding="utf-8") as f:
    f.write(model)

print("Model generator done: 6 tables written, model.tmdl updated.")

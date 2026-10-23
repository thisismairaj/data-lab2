"""Builds diabetes_dashboard.lvdash.json (AI/BI dashboard) from the three dataset .sql files.
Run: python build_dashboard.py   (writes the JSON next to this script)."""
import json, pathlib

HERE = pathlib.Path(__file__).parent


def sql_lines(name, order_by=""):
    text = (HERE / name).read_text(encoding="utf-8").strip()
    lines = [l + "\n" for l in text.split("\n")]
    if order_by:
        lines.append(order_by)
    return lines


def pos(x, y, w, h):
    return {"x": x, "y": y, "width": w, "height": h}


def counter(name, ds, measure, title, fmt=None, x=0):
    value = {"fieldName": f"measure({measure})", "displayName": title}
    if fmt:
        value["format"] = fmt
    return {
        "widget": {
            "name": name,
            "queries": [{"name": "main_query", "query": {
                "datasetName": ds,
                "fields": [{"name": f"measure({measure})", "expression": f"MEASURE(`{measure}`)"}],
                "disaggregated": False}}],
            "spec": {"version": 2, "widgetType": "counter",
                     "encodings": {"value": value},
                     "frame": {"title": title, "showTitle": True}},
        },
        "position": pos(x, 3, 4, 3),
    }


PCT = {"type": "number-percent", "decimalPlaces": {"type": "max", "places": 2}}

datasets = [
    {"name": "ds_state", "displayName": "Diabetes prevalence by state",
     "queryLines": sql_lines("ds_state.sql", "ORDER BY survey_year DESC, prevalence_ratio DESC"),
     "columns": [
         {"displayName": "National Prevalence",
          "description": "Survey-weighted share of respondents with diabetes",
          "expression": "SUM(`weighted_yes_sum`) / SUM(`weighted_valid_sum`)"},
         {"displayName": "Valid Respondents",
          "description": "Respondents with a valid diabetes answer",
          "expression": "SUM(`valid_respondents`)"}]},
    {"name": "ds_quarantine", "displayName": "Quarantined rows by rule",
     "queryLines": sql_lines("ds_quarantine.sql"),
     "columns": [{"displayName": "Quarantined Rows",
                  "description": "Rows held back by the quality rules, each with a reason",
                  "expression": "SUM(`quarantined_rows`)"}]},
]

header = {"widget": {"name": "header", "multilineTextboxSpec": {"lines": [
    "# Diabetes prevalence in the US (CDC BRFSS)\n", "\n",
    "Survey-weighted share of adults reporting diabetes, by state and year. "
    "Every row that fails a quality rule is held in quarantine with a reason, never dropped."]}},
    "position": pos(0, 0, 12, 3)}

trend = {"widget": {
    "name": "trend-prevalence",
    "queries": [{"name": "main_query", "query": {
        "datasetName": "ds_state",
        "fields": [{"name": "survey_year", "expression": "`survey_year`"},
                   {"name": "measure(National Prevalence)", "expression": "MEASURE(`National Prevalence`)"}],
        "disaggregated": False}}],
    "spec": {"version": 3, "widgetType": "line",
             "encodings": {
                 "x": {"fieldName": "survey_year", "scale": {"type": "categorical"}, "displayName": "Survey year"},
                 "y": {"fieldName": "measure(National Prevalence)", "scale": {"type": "quantitative"},
                       "displayName": "National prevalence", "format": PCT}},
             "frame": {"title": "National prevalence by year", "showTitle": True}}},
    "position": pos(0, 6, 6, 5)}

quar_bar = {"widget": {
    "name": "quarantine-by-rule",
    "queries": [{"name": "main_query", "query": {
        "datasetName": "ds_quarantine",
        "fields": [{"name": "rule_id", "expression": "`rule_id`"},
                   {"name": "measure(Quarantined Rows)", "expression": "MEASURE(`Quarantined Rows`)"}],
        "disaggregated": False}}],
    "spec": {"version": 3, "widgetType": "bar",
             "encodings": {
                 "x": {"fieldName": "rule_id", "scale": {"type": "categorical"}, "displayName": "Rule failed"},
                 "y": {"fieldName": "measure(Quarantined Rows)", "scale": {"type": "quantitative"},
                       "displayName": "Rows"}},
             "frame": {"title": "Quarantined rows by rule", "showTitle": True}}},
    "position": pos(6, 6, 6, 5)}

choropleth = {"widget": {
    "name": "map-prevalence",
    "queries": [{"name": "main_query", "query": {
        "datasetName": "ds_state",
        "fields": [{"name": "state_name", "expression": "`state_name`"},
                   {"name": "measure(National Prevalence)", "expression": "MEASURE(`National Prevalence`)"}],
        "disaggregated": False}}],
    "spec": {"version": 1, "widgetType": "choropleth-map",
             "encodings": {
                 "region": {"regionType": "mapbox-v4-admin",
                            "admin0": {"type": "value", "value": "United States", "geographicRole": "admin0-name"},
                            "admin1": {"fieldName": "state_name", "type": "field", "geographicRole": "admin1-name"}},
                 "color": {"fieldName": "measure(National Prevalence)", "scale": {"type": "quantitative"},
                           "displayName": "Prevalence"}},
             "frame": {"title": "Prevalence by state", "showTitle": True}}},
    "position": pos(0, 11, 7, 7)}

table = {"widget": {
    "name": "table-states",
    "queries": [{"name": "main_query", "query": {
        "datasetName": "ds_state",
        "fields": [{"name": "survey_year", "expression": "`survey_year`"},
                   {"name": "state_name", "expression": "`state_name`"},
                   {"name": "valid_respondents", "expression": "`valid_respondents`"},
                   {"name": "prevalence_ratio", "expression": "`prevalence_ratio`"}],
        "disaggregated": True}}],
    "spec": {"version": 2, "widgetType": "table",
             "encodings": {"columns": [
                 {"fieldName": "survey_year", "displayName": "Year"},
                 {"fieldName": "state_name", "displayName": "State"},
                 {"fieldName": "valid_respondents", "displayName": "Respondents"},
                 {"fieldName": "prevalence_ratio", "displayName": "Prevalence", "format": PCT}]},
             "frame": {"title": "States, highest prevalence first", "showTitle": True}}},
    "position": pos(7, 11, 5, 7)}

year_filter = {"widget": {
    "name": "filter-year",
    "queries": [{"name": "ds_state_year", "query": {
        "datasetName": "ds_state",
        "fields": [{"name": "survey_year", "expression": "`survey_year`"}],
        "disaggregated": False}}],
    "spec": {"version": 2, "widgetType": "filter-multi-select",
             "encodings": {"fields": [{"fieldName": "survey_year", "displayName": "Year",
                                       "queryName": "ds_state_year"}]},
             "frame": {"showTitle": True, "title": "Year"}}},
    "position": pos(0, 0, 4, 2)}

dashboard = {
    "datasets": datasets,
    "pages": [
        {"name": "overview", "displayName": "Overview", "pageType": "PAGE_TYPE_CANVAS",
         "layoutVersion": "GRID_V1",
         "layout": [header,
                    counter("kpi-prevalence", "ds_state", "National Prevalence", "National prevalence", PCT, 0),
                    counter("kpi-respondents", "ds_state", "Valid Respondents", "Valid respondents", None, 4),
                    counter("kpi-quarantined", "ds_quarantine", "Quarantined Rows", "Quarantined rows", None, 8),
                    trend, quar_bar, choropleth, table]},
        {"name": "filters", "displayName": "Filters", "pageType": "PAGE_TYPE_GLOBAL_FILTERS",
         "layoutVersion": "GRID_V1", "layout": [year_filter]},
    ],
    "uiSettings": {"theme": {
        "canvasBackgroundColor": {"light": "#FCFCFC", "dark": "#1F272D"},
        "widgetBackgroundColor": {"light": "#FFFFFF", "dark": "#11171C"},
        "fontColor": {"light": "#11171C", "dark": "#E8ECF0"},
        "selectionColor": {"light": "#2272B4", "dark": "#8ACAFF"},
        "visualizationColors": ["#0072B2", "#E69F00", "#009E73", "#CC79A7", "#D55E00"],
        "widgetHeaderAlignment": "LEFT"}},
}

out = HERE / "diabetes_dashboard.lvdash.json"
out.write_text(json.dumps(dashboard, indent=2), encoding="utf-8")
print("wrote", out, out.stat().st_size, "bytes")

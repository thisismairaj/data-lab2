"""Generator 2 of 2: writes the report page (PBIR) - the ~13 real visuals that replace
the two throwaway sample charts (a Card and a Clustered column chart) Power BI wrote
when you did Get Data -> Load -> 2 sample charts -> Save As .pbip.

Every JSON shape below (visualContainer envelope, the Aggregation/Column field shape,
the sortDefinition shape) is copied from those two real sample visual.json files -
only the field names, visual types and positions change. The one genuinely new piece
per visual is the "Measure" field shape (a DAX measure reference has no Aggregation
wrapper, unlike a raw column) - not present in the samples because the 2 sample charts
used raw columns, not measures.

Run: python generate_report.py   (from the power-bi/ folder, after generate_model.py)
"""
import json, os, shutil, uuid

BASE = os.path.dirname(os.path.abspath(__file__))
PAGE_DIR = os.path.join(BASE, "diabetes_dashboard.Report", "definition", "pages", "088fe004e3007d66e09d")
VIS_DIR = os.path.join(PAGE_DIR, "visuals")

SCHEMA = "https://developer.microsoft.com/json-schemas/fabric/item/report/definition/visualContainer/2.12.0/schema.json"


def gid():
    return uuid.uuid4().hex[:20]


# ---- field shape helpers (copied shapes, only names/tables change) -----------------
def col_ref(table, col):
    return {"Column": {"Expression": {"SourceRef": {"Entity": table}}, "Property": col}}


def agg(table, col, func=0):
    """A raw column wrapped in an aggregation - the exact shape Power BI wrote for the
    sample Card (Sum of diabetes_yes). func 0 = Sum (confirmed from that sample)."""
    return {"Aggregation": {"Expression": col_ref(table, col), "Function": func}}


def measure_ref(table, measure):
    """A DAX measure reference - no Aggregation wrapper, the measure already aggregates
    itself. This is the one shape not present in the 2 samples (both used raw columns)."""
    return {"Measure": {"Expression": {"SourceRef": {"Entity": table}}, "Property": measure}}


def projection(field, query_ref, native_ref):
    return {"field": field, "queryRef": query_ref, "nativeQueryRef": native_ref}


def agg_projection(table, col, label=None, func=0, func_name="Sum"):
    return projection(agg(table, col, func), f"{func_name}({table}.{col})", label or f"{func_name} of {col}")


def measure_projection(table, measure):
    return projection(measure_ref(table, measure), f"{table}.{measure}", measure)


def category_projection(table, col):
    return projection(col_ref(table, col), f"{table}.{col}", col)


def sort_desc_by_measure(table, measure):
    return {
        "sort": [{
            "field": measure_ref(table, measure),
            "direction": "Descending",
        }],
        "isDefaultSort": True,
    }


def esc_dax_string(s):
    return s.replace("'", "''")


def set_title(visual_body, text):
    """Static visual title. `title` is NOT a direct property of `visual` (the schema
    validator rejected that: "An additional property 'title' was included in the
    /visual property") - it has to go under visual.objects.title[0].properties.text
    as a DAX string-literal expression, same shape as the slicer's objects.general
    already used for orientation. Merges into any existing `objects` dict rather than
    overwriting it (the slicer also sets objects.general)."""
    visual_body.setdefault("objects", {})["title"] = [{
        "properties": {
            "text": {"expr": {"Literal": {"Value": f"'{esc_dax_string(text)}'"}}}
        }
    }]
    return visual_body


def visual_json(name, x, y, w, h, z, tab_order, visual_body, filters=None):
    body = {
        "$schema": SCHEMA,
        "name": name,
        "position": {"x": x, "y": y, "z": z, "height": h, "width": w, "tabOrder": tab_order},
        "visual": visual_body,
    }
    if filters:
        body["filterConfig"] = {"filters": filters}
    return body


def write_visual(container_id, body):
    d = os.path.join(VIS_DIR, container_id)
    os.makedirs(d, exist_ok=True)
    with open(os.path.join(d, "visual.json"), "w", encoding="utf-8") as f:
        json.dump(body, f, indent=2)


# ---- clean out the 2 throwaway sample visuals --------------------------------------
if os.path.isdir(VIS_DIR):
    shutil.rmtree(VIS_DIR)
os.makedirs(VIS_DIR, exist_ok=True)

visuals = []  # (id, body) pairs, in draw order

# 1. Title textbox
title_id = gid()
title_body = {
    "visualType": "textbox",
    "objects": {
        "general": [{
            "properties": {
                "paragraphs": [{
                    "textRuns": [{
                        "value": "Diabetes Prevalence — BRFSS 2011-2015 (Trial workspace, 5-year Lakeflow build)",
                        "textStyle": {"fontWeight": "bold", "fontSize": "20px"},
                    }]
                }]
            }
        }]
    },
}
visuals.append((title_id, visual_json(title_id, 20, 8, 1880, 40, 0, 0, title_body)))

# Layout grid on a 1920x1080 page:
#   row 1 (y=60-190):   5 KPI cards
#   row 2 (y=210-770):  line chart | state ranking bar | 3 stacked breakdown charts
#   row 3 (y=790-1060): comorbidity | risk-stacking | year slicer + caveat text

# 2-6. KPI cards
card_specs = [
    ("National Prevalence %", "gold_diabetes_prevalence_state", "measure", "National Prevalence %"),
    ("Valid Respondents (5 yrs)", "gold_diabetes_prevalence_state", "column", "valid_respondents"),
    ("States Covered", "gold_diabetes_prevalence_state", "measure", "States Covered"),
    ("Years Covered", "gold_diabetes_prevalence_state", "measure", "Years Covered"),
    ("Risk Factor Gap (3 vs 0 factors)", "diabetes_risk_stacking", "measure", "Risk Factor Gap x"),
]
card_positions = [20, 400, 780, 1160, 1540]
for (title, table, kind, field_name), card_x in zip(card_specs, card_positions):
    cid = gid()
    if kind == "measure":
        proj = measure_projection(table, field_name)
        filt_field = measure_ref(table, field_name)
    else:
        proj = agg_projection(table, field_name)
        filt_field = agg(table, field_name)
    body = {
        "visualType": "cardVisual",
        "query": {"queryState": {"Data": {"projections": [proj]}}},
        "drillFilterOtherVisuals": True,
    }
    set_title(body, title)
    filters = [{"name": gid(), "field": filt_field, "type": "Advanced"}]
    visuals.append((cid, visual_json(cid, card_x, 60, 360, 130, 1, len(visuals), body, filters)))

# 7. Line chart: national trend by year (x=20, y=210, 600x560)
line_id = gid()
line_body = {
    "visualType": "lineChart",
    "query": {"queryState": {
        "Category": {"projections": [category_projection("gold_diabetes_prevalence_state", "survey_year")]},
        "Y": {"projections": [measure_projection("gold_diabetes_prevalence_state", "National Prevalence %")]},
    }},
    "drillFilterOtherVisuals": True,
}
set_title(line_body, "National weighted prevalence, 2011–2015")
visuals.append((line_id, visual_json(line_id, 20, 210, 600, 560, 1, len(visuals), line_body)))

# 8. Horizontal bar: all 53 states, sorted descending by prevalence (x=640, 600x560,
# tall on purpose - 53 categories scroll vertically in a bar chart)
bar_id = gid()
bar_body = {
    "visualType": "barChart",
    "query": {
        "queryState": {
            "Category": {"projections": [category_projection("gold_diabetes_prevalence_state", "state_name")]},
            "Y": {"projections": [measure_projection("gold_diabetes_prevalence_state", "National Prevalence %")]},
        },
        "sortDefinition": sort_desc_by_measure("gold_diabetes_prevalence_state", "National Prevalence %"),
    },
    "drillFilterOtherVisuals": True,
}
set_title(bar_body, "Prevalence by state, all years combined (highest → lowest)")
visuals.append((bar_id, visual_json(bar_id, 640, 210, 600, 560, 1, len(visuals), bar_body)))

# 9-11. Age / smoking / BMI category breakdowns, stacked in the right column
# (clustered column; ordinal axis order comes from sortByColumn already set in the
# TMDL, so no per-visual sort needed here - x=1260, 3 charts of 640x180, 10px gaps)
breakdown_specs = [
    ("Prevalence by age group", "diabetes_prevalence_age_group", "age_group_label", "Age Prevalence %"),
    ("Prevalence by smoking status", "diabetes_prevalence_smoking", "smoking_label", "Smoking Prevalence %"),
    ("Prevalence by BMI category", "diabetes_prevalence_bmi_category", "bmi_category_label", "BMI Prevalence %"),
]
bx, by, bw, bh = 1260, 210, 640, 180
for i, (title, table, cat_col, measure) in enumerate(breakdown_specs):
    vid = gid()
    body = {
        "visualType": "clusteredColumnChart",
        "query": {"queryState": {
            "Category": {"projections": [category_projection(table, cat_col)]},
            "Y": {"projections": [measure_projection(table, measure)]},
        }},
        "drillFilterOtherVisuals": True,
    }
    set_title(body, title)
    visuals.append((vid, visual_json(vid, bx, by + i * (bh + 10), bw, bh, 1, len(visuals), body)))

# 12. Comorbidity: grouped clustered column (condition x diabetic/non-diabetic)
# (x=20, y=790, 600x270)
comorbid_id = gid()
comorbid_body = {
    "visualType": "clusteredColumnChart",
    "query": {"queryState": {
        "Category": {"projections": [category_projection("diabetes_comorbidity", "condition_label")]},
        "Series": {"projections": [category_projection("diabetes_comorbidity", "diabetes_group")]},
        "Y": {"projections": [measure_projection("diabetes_comorbidity", "Condition %")]},
    }},
    "drillFilterOtherVisuals": True,
}
set_title(comorbid_body, "Comorbidity rate: diabetic vs non-diabetic")
visuals.append((comorbid_id, visual_json(comorbid_id, 20, 790, 600, 270, 1, len(visuals), comorbid_body)))

# 13. Risk stacking: prevalence by number of risk factors (0-3) (x=640, y=790, 600x270)
risk_id = gid()
risk_body = {
    "visualType": "clusteredColumnChart",
    "query": {"queryState": {
        "Category": {"projections": [category_projection("diabetes_risk_stacking", "risk_factor_count")]},
        "Y": {"projections": [measure_projection("diabetes_risk_stacking", "Risk Prevalence %")]},
    }},
    "drillFilterOtherVisuals": True,
}
set_title(risk_body, "Prevalence by number of risk factors (obesity + smoking + inactivity)")
visuals.append((risk_id, visual_json(risk_id, 640, 790, 600, 270, 1, len(visuals), risk_body)))

# 14. Slicer: survey_year (x=1260, y=790, 640x110)
slicer_id = gid()
slicer_body = {
    "visualType": "slicer",
    "query": {"queryState": {
        "Values": {"projections": [category_projection("gold_diabetes_prevalence_state", "survey_year")]},
    }},
    "objects": {"general": [{"properties": {"orientation": {"expr": {"Literal": {"Value": "1D"}}}}}]},
}
set_title(slicer_body, "Year")
visuals.append((slicer_id, visual_json(slicer_id, 1260, 790, 640, 110, 1, len(visuals), slicer_body)))

# 15. Caveat textbox (x=1260, y=910, 640x150)
caveat_id = gid()
caveat_body = {
    "visualType": "textbox",
    "objects": {
        "general": [{
            "properties": {
                "paragraphs": [{
                    "textRuns": [{
                        "value": (
                            "Weighted % = sum(weighted yes) / sum(weighted valid), never an average of "
                            "row-level percentages - correct at any grouping (state, year, or both). "
                            "Comorbidity and risk-factor associations are not adjusted for age, which "
                            "independently drives several of the same conditions."
                        ),
                        "textStyle": {"fontSize": "10px"},
                    }]
                }]
            }
        }]
    },
}
visuals.append((caveat_id, visual_json(caveat_id, 1260, 910, 640, 150, 0, len(visuals), caveat_body)))

for vid, body in visuals:
    write_visual(vid, body)

print(f"Report generator done: {len(visuals)} visuals written to page 088fe004e3007d66e09d.")

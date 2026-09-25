"""Convert BRFSS 2015 codebook PDF -> Markdown using word coordinates (tables are unruled, so no table finder)."""
import re, json
import pymupdf

SRC = r"D:\data-lab2\docs\codebook15_llcp.pdf"
DST = r"D:\data-lab2\docs\codebook15_llcp.md"
DUMP = r"D:\data-lab2\docs\codebook15_llcp.json"

NUM = re.compile(r"^[\d,]+(\.\d+)?$")
HDR_WORDS = {"Value", "Label", "Frequency", "Percentage", "Weighted"}


def page_lines(pg):
    """Group words into visual lines (y within 4pt). Returns list of (y, [(x0,x1,text)...])."""
    ws = sorted(pg.get_text("words"), key=lambda w: (w[1], w[0]))
    lines = []
    for x0, y0, x1, y1, t, *_ in ws:
        if y0 < 72 or y0 > 750:  # running page header / footer
            continue
        if lines and abs(lines[-1][0] - y0) <= 4:
            lines[-1][1].append((x0, x1, t))
        else:
            lines.append((y0, [(x0, x1, t)]))
    for _, ws_ in lines:
        ws_.sort()
    return lines


def join(words):
    return " ".join(w[2] for w in words)


doc = pymupdf.open(SRC)
vars_, cur = [], None
state = "idle"          # idle | title | prologue | desc | table
title_buf, prev_y, in_notes = [], None, False
pending_prefix = []      # label-only line above the numeric row it belongs to

flat = [(pno, y, ws) for pno in range(1, len(doc)) for y, ws in page_lines(doc[pno])]  # skip cover page
# header line = "<Kind>: <number> <name...> Type: <Num|Char>"; Kind is Section / Weighting / Calculated / ...
HDR = [len(ws) >= 3 and ws[-2][2] == "Type:" and ws[0][0] >= 20 for _, _, ws in flat]
# a title is a line at x<30 that is followed by a header line (or by another title line, if the title wraps).
# Checking the next line matters: wide values such as "9000 - 9998" also start left of x=30.
IS_TITLE = [False] * len(flat)
for i in range(len(flat) - 2, -1, -1):
    IS_TITLE[i] = flat[i][2][0][0] < 30 and not HDR[i] and (HDR[i + 1] or IS_TITLE[i + 1])

if True:
    for idx, (pno, y, ws) in enumerate(flat):
        text = join(ws)
        minx = ws[0][0]
        words0 = [w[2] for w in ws]
        is_hdr = HDR[idx]
        if IS_TITLE[idx]:
            if state != "title":
                title_buf = []
            state = "title"
            title_buf.append(text)
            continue
        if is_hdr:
            words = words0
            ti = words.index("Type:")
            cur = {"title": " ".join(title_buf), "section": " ".join(words[0:ti]),
                   "type": words[ti + 1] if ti + 1 < len(words) else "",
                   "column": "", "name": "", "prologue": "", "description": "", "rows": [], "page": pno + 1}
            vars_.append(cur)
            state = "section"
            continue
        if cur is None:
            continue
        if text.startswith("Column:"):
            words = [w[2] for w in ws]
            si = words.index("SAS")
            cur["column"] = " ".join(words[1:si])
            cur["name"] = words[-1] if words[-1] != "Name:" else ""
            continue
        if state == "section" and len(ws) == 1 and text.endswith(":") and cur["name"] == "":
            first, _, rest = cur["section"].partition(" ")   # wrapped kind label, e.g. ChildDemogra + phics:
            cur["section"] = f"{first}{text} {rest}".strip()
            continue
        if state == "section" and cur["name"] == "" and minx >= 400:
            cur["name"] = ws[-1][2]      # variable name landed on its own line
            continue
        if text.startswith("Prologue:"):
            cur["prologue"] = text[len("Prologue:"):].strip()
            state = "prologue"
            continue
        if text.startswith("Description:"):
            cur["description"] = text[len("Description:"):].strip()
            state = "desc"
            continue
        if state == "prologue":
            cur["prologue"] = (cur["prologue"] + " " + text).strip()
            continue
        if state == "desc":
            if set(t for _, _, t in ws) <= HDR_WORDS or "Frequency" in text:
                state = "table"; prev_y = None; pending_prefix = []
                continue
            cur["description"] = (cur["description"] + " " + text).strip()
            continue
        if state == "table":
            if set(t for _, _, t in ws) <= HDR_WORDS or "Frequency" in text:
                continue  # repeated table header
            val = [w for w in ws if w[0] < 90]
            lab = [w for w in ws if 90 <= w[0] < 410]
            nums = [w for w in ws if w[0] >= 410]
            if lab and lab[0][2] == "Notes:" and not val:   # a note about the variable, not a value label
                in_notes = True
                cur["notes"] = (cur.get("notes", "") + " " + " ".join(w[2] for w in lab[1:] )).strip()
                lab = []
            elif in_notes and lab and not val and not nums:  # wrapped note text
                cur["notes"] = (cur.get("notes", "") + " " + join(lab)).strip()
                continue
            if nums and not val and not lab and cur["rows"] and cur["rows"][-1][2] == "":
                # numbers printed below the row's notes (e.g. HIDDEN rows): belong to the last row
                freq = pct = wpct = ""
                for x0, x1, t in nums:
                    if x1 < 465: freq = t
                    elif x1 < 530: pct = t
                    else: wpct = t
                cur["rows"][-1][2:5] = [freq, pct, wpct]
                in_notes = False
                continue
            if nums:
                freq = pct = wpct = ""
                for x0, x1, t in nums:
                    if x1 < 465: freq = t
                    elif x1 < 530: pct = t
                    else: wpct = t
                label = " ".join(pending_prefix + ([join(lab)] if lab else []))
                pending_prefix = []
                in_notes = False
                cur["rows"].append([join(val), label, freq, pct, wpct])
            elif val or lab:
                in_notes = False
                if val:  # a value with no numbers on its line (label continues below)
                    cur["rows"].append([join(val), join(lab), "", "", ""])
                elif prev_y is not None and y - prev_y < 12 and cur["rows"]:
                    cur["rows"][-1][1] = (cur["rows"][-1][1] + " " + join(lab)).strip()
                else:
                    pending_prefix.append(join(lab))
            prev_y = y

# a table that continues on the next page can repeat the variable header: merge same-name neighbours
merged = []
for v in vars_:
    if merged and merged[-1]["name"] == v["name"]:
        merged[-1]["rows"] += v["rows"]
    else:
        merged.append(v)
vars_ = merged
json.dump(vars_, open(DUMP, "w"), indent=1)

# ---------------- write markdown ----------------
esc = lambda s: s.replace("|", "\\|")
out = ["# BRFSS 2015 Codebook (Land-Line and Cell-Phone data)", "",
       "Converted from `codebook15_llcp.pdf` (CDC, report dated August 23, 2016; 137 pages).",
       "Source of truth is the PDF. This file is a machine conversion. Checks run on 2026-09-25: 330 variables found, matching the 330 columns of `2015.csv` one-to-one; for every variable the Frequency column sums to 441,456 (the 2015 row count); 104 value rows across 10 variables (`_STATE`, `DIABETE3`, `SEX`, `_AGEG5YR`, `GENHLTH`, `_RFHYPE5`, `EXERANY2`, `SMOKE100`, `_BMI5CAT`, `EDUCA`) were compared to counts from `2015.csv` with 0 mismatches. Not checked: label text (copied as printed, so a few titles are cut off in the PDF itself) and Percentage columns. When a variable has several `Notes:` lines, they are joined into one Notes bullet.", "",
       "## How to read an entry", "",
       "- **Value** is the code stored in the CSV. **Value Label** is what the code means.",
       "- **Frequency** is the number of respondent records with that code. **Percentage** is that count divided by all 441,456 records. **Weighted Percentage** applies the survey weights, so it estimates the adult population, not just the sample.",
       "- `BLANK` means the field is empty (question not asked, or skipped by survey logic).",
       "- Codes like 7 / 77 / 777 (don't know), 9 / 99 / 999 (refused) and 88 (none) are **not real numbers**. Do not average them.",
       "- **Type:** `Num` or `Char`. **Column** is the position in the original fixed-width file, not in the CSV.", "",
       f"## Variable index ({len(vars_)} variables)", "",
       "| Variable | Title | Section | Type | Page |", "|---|---|---|---|---|"]
for v in vars_:
    out.append(f"| [{v['name']}](#{v['name'].lower().lstrip('_')}) | {esc(v['title'])} | {esc(v['section'])} | {v['type']} | {v['page']} |")
out.append("")
for v in vars_:
    out += [f"## {v['name']}", f"<a id=\"{v['name'].lower().lstrip('_')}\"></a>", "",
            f"**{v['title']}**", "",
            f"- {v['section']}", f"- Type: {v['type']}", f"- Column (fixed-width file): {v['column']}", f"- PDF page: {v['page']}"]
    if v["prologue"]: out.append(f"- Prologue: {v['prologue']}")
    out.append(f"- Description: {v['description']}")
    if v.get("notes"): out.append(f"- Notes: {v['notes']}")
    out.append("")
    if v["rows"]:
        out += ["| Value | Value Label | Frequency | Percentage | Weighted % |", "|---|---|--:|--:|--:|"]
        out += ["| " + " | ".join(esc(c) for c in r) + " |" for r in v["rows"]]
        out.append("")
open(DST, "w", encoding="utf-8").write("\n".join(out))
print("variables:", len(vars_), "| rows:", sum(len(v["rows"]) for v in vars_),
      "| no-name:", [v["title"] for v in vars_ if not v["name"]][:5])


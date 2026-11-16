#!/usr/bin/env python3
"""Central Business Requirement (BR) document builder.
WRITING STYLE: follow STRUCTURE.md § แนวการเขียนและภาษา when filling SPEC text.

Builder — structure copied from a real-world BR reference document
(see STRUCTURE.md for the why of every part).

    python3 build_br.py                       → ./BR-SKELETON.docx  (all placeholders, the blank template)
    python3 build_br.py spec.py OUT.docx      → spec.py defines SPEC = {...} in the same shape as SKELETON

Every section is always emitted in the fixed order. Empty lists fall back to placeholder text,
so a half-written spec still produces a complete, reviewable document.
"""
import json
import os
import re
import runpy
import subprocess
import sys
import tempfile
import zipfile

O = os.path.expanduser("~/.local/bin/officecli")
TH = "TH Sarabun New"      # Thai (complex-script) font used in the reference
LAT = TH                   # reference body renders Thai+Latin in TH Sarabun New (runs are 16pt)
COVER = "Calibri Light"    # cover page face
BLUE, NAVY, GREY = "2F5496", "1F3763", "44546A"
PH = "XXXXXXXXX"
TITLES = {"BR": "Business Requirement", "SRS": "Software Requirements Specification"}
STYLE_CS = [("Normal", 16, False), ("Heading1", 22, True), ("Heading2", 18, True), ("Heading3", 16, True),
            ("Heading4", 16, False), ("Heading5", 16, False), ("Caption", 14, False), ("ListParagraph", 16, False)]

SKELETON = {
    "doc_type": "BR",                           # "BR" หรือ "SRS" เปลี่ยนเฉพาะชื่อบนหน้าปก
    "company": "iBiztech Co., Ltd.",            # ผู้จัดทำ (บรรทัดเล็กบนหน้าปก)
    "system": "<ชื่อระบบ / ชื่อเว็บไซต์ของลูกค้า>",
    "author": "<ผู้จัดทำ>",
    "date": "<วันที่>",
    "subject": "<ผลิตภัณฑ์/ระบบ>",               # ใช้ในชื่อบทที่ 2
    "history": [("1.0.0", "<วันที่>", "<ผู้จัดทำ>", "เอกสารโครงร่าง ฉบับที่ 1")],
    "background": "",
    "scope": {"intro": "", "items": [], "focus": []},
    "benefits": "",
    "overview": {"intro": "", "figure": "แสดงภาพรวมของระบบ", "components": []},   # [(องค์ประกอบ, รายละเอียด)]
    "modules": [],                                                               # [(ชื่อโมดูล, รายละเอียด)]
    "journeys": [],       # [{"title", "intro", "subs": [{"title", "body", "subs": [...]}]}]
    "br_intro": "",
    "requirements": [],   # [{"title","objective","roles","screen","functions":[(h,[subs])],"conditions":[],"setup":[]}]
    "functions": [],      # [{"title","objective","roles","fields":[(name,desc,"M"/"O",cond)],"steps":[],"conditions":[]}]
    "screen_intro": "",
    "screens": [],        # [{"title","body","caption","image"}]
    "appendices": [],     # [{"title","intro","columns":[...],"rows":[[...]]}]
}


class Doc:
    def __init__(self):
        self.ops = []
        self.tables = 0
        self.table_weights = []
        self.fig = 0

    def p(self, text="", style=None, **props):
        pr = {"text": text, "font": props.pop("font", LAT), "font.cs": TH}
        if style:
            pr["style"] = style
        pr.update({k: str(v) for k, v in props.items()})
        for key in ("size", "bold", "italic"):  # Thai renders from the complex-script slots (szCs, bCs, iCs)
            if key in pr:
                pr[f"{key}.cs"] = pr[key]
        self.ops.append({"command": "add", "parent": "/body", "type": "paragraph", "props": pr})

    def h(self, level, text, **props):
        self.p(text, style=f"Heading{level}", **props)

    def blank(self):
        self.p("")

    def bullet(self, text):
        self.p(f"•  {text}", style="ListParagraph")

    def figure(self, caption, image=None):
        self.fig += 1
        if image and os.path.exists(image):
            self.ops.append({"command": "add", "parent": "/body", "type": "picture",
                             "props": {"src": os.path.abspath(image), "width": "15.24cm", "align": "center",
                                       "keepNext": "true"}})
        else:
            self.p("[ วางรูปภาพที่นี่ ]", align="center", color="A6A6A6", keepNext="true")
        self.p(f"รูปที่ {self.fig} {caption}", style="Caption", align="center")

    def journey_extras(self, node):
        if node.get("figure"):
            self.figure(node["figure"].get("caption", "____________________"), node["figure"].get("image"))
        if node.get("table"):
            self.table(node["table"]["columns"], [list(r) for r in node["table"].get("rows", [])])

    def table(self, header, rows, widths=None, title=None, weights=None):
        # สัดส่วนคอลัมน์สำหรับขั้น finish_tables: จาก weights, จาก widths เช่น "5cm" หรือให้คำนวณเอง
        self.table_weights.append(weights or ([float(x.rstrip("cm")) for x in widths] if widths else None))
        data = ([[title] + [""] * (len(header) - 1)] if title else []) + [header] + (rows or [[" "] * len(header)] * 2)
        esc = lambda c: '"' + str(c).replace('"', '""') + '"'  # noqa: E731
        pr = {"data": ";".join(",".join(esc(c) for c in r) for r in data), "style": "TableGrid"}
        if widths:
            pr["colWidths"] = ",".join(widths)
        self.ops.append({"command": "add", "parent": "/body", "type": "table", "props": pr})
        self.tables += 1
        row = f"/body/tbl[{self.tables}]/tr[{2 if title else 1}]"
        self.ops.append({"command": "set", "path": row, "props": {"header": "true"}})
        for ci in range(1, len(header) + 1):
            self.ops.append({"command": "set", "path": f"{row}/tc[{ci}]",
                             "props": {"bold": "true", "bold.cs": "true", "fill": "D9E2F3"}})
        self.blank()

    def page_break(self):
        self.ops.append({"command": "add", "parent": "/body", "type": "paragraph",
                         "props": {"text": "", "pageBreakBefore": "true"}})


def styles_ops():
    """Heading/caption look of the reference: blue headings, Thai 16pt body."""
    def st(sid, name, size, sizecs, color=None, bold=True, based="Normal", sb="12pt", sa="4pt"):
        pr = {"id": sid, "name": name, "type": "paragraph", "basedOn": based, "next": "Normal",
              "font": LAT, "font.cs": TH, "size": f"{size}pt", "qFormat": "true",
              "spaceBefore": sb, "spaceAfter": sa}
        if color:
            pr["color"] = color
        if bold:
            pr["bold"] = "true"
        return pr
    defs = [
        st("Heading1", "heading 1", 22, 22, BLUE, sb="18pt"),
        st("Heading2", "heading 2", 18, 18, BLUE),
        st("Heading3", "heading 3", 16, 16, NAVY),
        st("Heading4", "heading 4", 16, 16, BLUE, bold=False, sb="6pt"),
        st("Heading5", "heading 5", 16, 16, BLUE, bold=False, sb="4pt"),
        st("Caption", "caption", 14, 14, GREY, bold=False, sb="2pt", sa="10pt"),
        st("ListParagraph", "List Paragraph", 16, 16, None, bold=False, sb="0pt", sa="2pt"),
    ]
    ops = []
    for d in defs:
        ops.append({"command": "add", "parent": "/styles", "type": "style", "props": d})
    # Normal: Times New Roman + TH Sarabun New 16pt Thai (the reference body)
    ops.append({"command": "set", "path": "/styles/Normal",
                "props": {"font": LAT, "font.cs": TH, "size": "16pt"}})
    return ops


def or_ph(v, ph=PH):
    return v if v else ph


def build(spec, out):
    s = {**SKELETON, **spec}
    s["scope"] = {**SKELETON["scope"], **s["scope"]}
    s["overview"] = {**SKELETON["overview"], **s["overview"]}
    if s["doc_type"] not in TITLES:
        raise SystemExit(f"doc_type must be one of {list(TITLES)}, got {s['doc_type']!r}")
    d = Doc()

    # ── 0 · หน้าปก ─────────────────────────────────────────────────────────
    for _ in range(8):
        d.blank()
    rule = {"indent": "1.2cm", "pbdr.left": f"single;18;#{BLUE};12"}  # vertical rule left of the cover block
    d.p(s["company"], italic="true", size="16pt", **rule)
    d.p(TITLES[s["doc_type"]], size="30pt", font=COVER, color="1F1F1F", **rule)
    d.p(s["system"], size="18pt", **rule)
    d.p("", **rule)
    d.p(s["author"], italic="true", size="14pt", **rule)
    d.p(s["date"], italic="true", size="14pt", **rule)

    # ── 1 · ประวัติการจัดทำเอกสาร ──────────────────────────────────────────
    d.page_break()
    d.h(2, "ประวัติการจัดทำเอกสาร")
    hist = [list(r) for r in s["history"]] + [[" "] * 4 for _ in range(4)]
    d.table(["ฉบับที่", "วันที่จัดทำเอกสาร", "จัดทำเอกสารโดย", "รายละเอียด"], hist,
            ["2cm", "3.5cm", "3.5cm", "7.5cm"])
    for ci in range(1, 5):  # latest version in blue; tbl[1] is this table, tr[1] its header
        d.ops.append({"command": "set", "path": f"/body/tbl[1]/tr[{len(s['history']) + 1}]/tc[{ci}]",
                      "props": {"color": "0070C0"}})

    # ── 2 · สารบัญ ─────────────────────────────────────────────────────────
    d.page_break()
    d.ops.append({"command": "add", "parent": "/body", "type": "toc",
                  "props": {"title": "สารบัญ", "levels": "1-3", "hyperlinks": "true", "pageNumbers": "true"}})

    # ── 3 · บทนำ ───────────────────────────────────────────────────────────
    d.page_break()
    d.h(1, "บทนำ")
    d.h(2, "ที่มาและความสำคัญ")
    d.p(or_ph(s["background"], "<ที่มาของโครงการ: สภาพปัจจุบัน ปัญหา และเหตุผลที่ต้องทำ>"), firstLineIndent="1.27cm")
    d.h(2, "ขอบเขตการดำเนินงาน")
    d.p(or_ph(s["scope"]["intro"], "<ขอบเขตโดยรวม และกลุ่มผลิตภัณฑ์/ระบบที่อยู่ในโครงการ>"), firstLineIndent="1.27cm")
    for i, it in enumerate(s["scope"]["items"] or ["<กลุ่มที่ 1>", "<กลุ่มที่ 2>"], 1):
        d.p(f"{i}. {it}", indent="1.9cm")
    d.p("เพื่อให้การปรับปรุงและพัฒนาในโครงการนี้มีรูปแบบที่ชัดเจน จึงทำการเน้นในส่วนต่าง ๆ ดังนี้",
        firstLineIndent="1.27cm")
    for f in s["scope"]["focus"] or ["<ประเด็นที่เน้น 1 เช่น UX/UI>", "<ประเด็นที่เน้น 2 เช่น ระบบหลังบ้าน>"]:
        d.bullet(f)
    d.h(2, "ประโยชน์ที่คาดว่าจะได้รับ")
    d.p(or_ph(s["benefits"], "<ผลลัพธ์ทางธุรกิจที่คาดหวัง>"), firstLineIndent="1.27cm")

    # ── 4 · เข้าใจลักษณะ <subject> และความคาดหวังในการทำโครงการ ──────────────
    d.page_break()
    d.h(1, f"เข้าใจลักษณะ{s['subject']} และความคาดหวังในการทำโครงการ")
    ov = s["overview"]
    d.h(2, f"1. ภาพรวมสำหรับ{s['subject']} (Overview)")
    d.p(or_ph(ov["intro"], "<สรุปความต้องการที่รวบรวมจากทีมลูกค้า>"), firstLineIndent="1.27cm")
    d.figure(ov["figure"], ov.get("figure_image"))
    d.p(f"จากรูปที่ {d.fig} แสดงให้เห็นภาพรวมของระบบทั้งหมด ประกอบด้วยส่วนสำคัญดังต่อไปนี้")
    d.table(["องค์ประกอบ", "รายละเอียด"], [list(r) for r in ov["components"]], ["5cm", "11.5cm"])
    d.h(2, "2. โมดูล (Modules)")
    d.p("การทำงานของแต่ละส่วนที่ได้กล่าวไปแล้วนั้น จะต้องเกิดจากการติดต่อสื่อสารและส่งข้อมูลไปยังระบบต่าง ๆ "
        "ผ่านทางโมดูลที่ได้ทำการสร้างขึ้นไว้ ซึ่งประกอบด้วย")
    d.table(["ชื่อโมดูล", "รายละเอียด"], [list(r) for r in s["modules"]], ["5cm", "11.5cm"])
    journeys = s["journeys"] or [{"title": "<Journey หลักขั้นที่ 1 เช่น การแสดงรายละเอียดผลิตภัณฑ์>",
                                  "intro": "", "subs": [{"title": PH, "body": "", "subs": [{"title": PH, "body": ""}]}]}]
    for ji, j in enumerate(journeys, 3):
        d.h(2, f"{ji}. {j['title']}")
        if j.get("intro"):
            d.p(j["intro"], firstLineIndent="1.27cm")
        for si, sub in enumerate(j.get("subs", []), 1):
            d.h(3, f"{ji}.{si}) {sub['title']}")
            d.p(or_ph(sub.get("body"), "<รายละเอียด + รูปหน้าจอ/flow + ตารางเงื่อนไขถ้ามี>"))
            d.journey_extras(sub)
            for ti, t in enumerate(sub.get("subs", []), 1):
                d.h(4, f"{ji}.{si}.{ti}) {t['title']}")
                d.p(or_ph(t.get("body"), "<รายละเอียด>"))
                d.journey_extras(t)

    # ── 5 · บทวิเคราะห์ความต้องการ (Business Requirement) ────────────────────
    d.page_break()
    d.h(1, "บทวิเคราะห์ความต้องการ (Business Requirement)")
    d.p(or_ph(s["br_intro"], "หลังจากที่ได้ทราบและทำความเข้าใจเกี่ยวกับระบบแล้ว ในส่วนนี้จะเป็นการวิเคราะห์ข้อมูล"
              "ทั้งหมดให้เกิดความกระชับ พร้อมทั้งสรุปสิ่งที่จะเกิดขึ้นในโครงการ"), firstLineIndent="1.27cm")
    reqs = s["requirements"] or [{"title": PH}]
    for ri, r in enumerate(reqs, 1):
        d.h(2, f"{ri}. {r['title']}")
        d.h(3, "วัตถุประสงค์: ")
        d.p(or_ph(r.get("objective"), "_______"))
        d.h(3, "สิทธิผู้ใช้งาน: ")
        d.p(or_ph(r.get("roles"), "_______"))
        d.h(3, "หน้าจอ: ")
        d.p(or_ph(r.get("screen"), "<ชื่อหน้าจอ>"))
        d.figure(r.get("screen_caption", "____________________"), r.get("screen_image"))
        d.h(3, "ฟังก์ชันการทำงาน:")
        for fi, (fh, fsubs) in enumerate(r.get("functions") or [(PH, [PH, PH])], 1):
            d.h(4, f"{fi}) {fh}")
            for si, fs in enumerate(fsubs, 1):
                d.h(5, f"{fi}.{si}) {fs}")
        d.h(3, "เงื่อนไขการทำงานของระบบ:")
        for ci, c in enumerate(r.get("conditions") or [PH], 1):
            d.h(4, f"{ci}) {c}")
        d.h(3, "การจัดการข้อมูล Setup ที่เกี่ยวข้อง:")
        for ci, c in enumerate(r.get("setup") or [PH], 1):
            d.h(4, f"{ci}) {c}")

    # ── 6 · Functional Design และ System requirement ─────────────────────────
    d.page_break()
    d.h(1, "การออกแบบ Functional Design และ System requirement")
    d.p("การที่ระบบจะสามารถทำงานได้นั้น จำเป็นจะต้องมีส่วนของ Function ต่าง ๆ ในการ Support ซึ่งแสดงในรายละเอียดดังนี้")
    d.p("(Work together with SA and provide this section)", italic="true", color=GREY)
    for fi, f in enumerate(s["functions"] or [{"title": "ฟังก์ชันจัดการ " + PH}], 1):
        d.h(2, f"{fi}. {f['title']}")
        d.p(f"วัตถุประสงค์: {or_ph(f.get('objective'), '_______')}", bold="true")
        d.p(f"สิทธิผู้ใช้งาน: {or_ph(f.get('roles'), '_______')}", bold="true")
        d.p("รายละเอียดของข้อมูล", bold="true")
        rows = [[f"{i}.", *fld] for i, fld in enumerate(f.get("fields") or [], 1)]
        d.table(["No.", "Field Name", "Description", "M/O", "Condition/Comment"], rows,
                ["1.2cm", "4cm", "5.3cm", "1.5cm", "4.5cm"])
        d.p("ฟังก์ชันการทำงาน", bold="true")
        for i, st in enumerate(f.get("steps") or [PH], 1):
            d.p(f"{i}. {st}", indent="0.8cm")
        d.p("เงื่อนไข", bold="true")
        for i, c in enumerate(f.get("conditions") or [PH], 1):
            d.p(f"{i}. {c}", indent="0.8cm")
        d.p("หน้าจอ", bold="true")
        d.figure(f.get("screen_caption", "____________________"), f.get("screen_image"))

    # ── 7 · หน้าจอ (Screen) ────────────────────────────────────────────────
    d.page_break()
    d.h(1, "หน้าจอ (Screen)")
    d.p(or_ph(s["screen_intro"], "หลังจากทำการออกแบบระบบทั้งหมดเสร็จเรียบร้อยแล้ว ข้อมูลในส่วนนี้จะเป็นการแสดงหน้าจอ "
              "User Interface เพื่อให้เห็นภาพของระบบที่จะเกิดขึ้น"))
    d.p("(Work together with UX and provide this section)", italic="true", color=GREY)
    for i, sc in enumerate(s["screens"], 1):
        d.h(2, f"{i}. {sc['title']}")
        if sc.get("body"):
            d.p(sc["body"], firstLineIndent="1.27cm")
        d.figure(sc.get("caption", sc["title"]), sc.get("image"))

    # ── 8 · ภาคผนวก (own section, roman page numbers) ─────────────────────
    d.ops.append({"command": "add", "parent": "/", "type": "section", "props": {"type": "nextPage"}})
    d.ops.append({"command": "set", "path": "/", "props": {"pageNumFmt": "lowerRoman", "pageStart": "1"}})
    apps = s["appendices"] or [{"title": "<ชื่อตารางอ้างอิง>", "intro": "", "columns": ["No.", "รายการ", "รายละเอียด"],
                                 "rows": []}]
    thai_letters = "กขคงจฉชซฌญฎฏฐฑ"
    for ai, a in enumerate(apps):
        if ai:
            d.page_break()
        d.h(1, f"ภาคผนวก {thai_letters[ai]}.")
        d.h(2, a["title"])
        if a.get("intro"):
            d.p(a["intro"], firstLineIndent="1.27cm")
        d.table(a["columns"], [list(r) for r in a.get("rows", [])], weights=a.get("widths"))

    # ── write ─────────────────────────────────────────────────────────────
    subprocess.run([O, "close", out], capture_output=True)
    if os.path.exists(out):
        os.remove(out)
    subprocess.run([O, "create", out], check=True, capture_output=True)
    page = {"command": "set", "path": "/", "props": {  # Letter, 1" margins (officecli defaults to A4, 1.25")
        "pageWidth": "21.59cm", "pageHeight": "27.94cm", "marginTop": "2.54cm", "marginBottom": "2.54cm",
        "marginLeft": "2.54cm", "marginRight": "2.54cm"}}
    ops = styles_ops() + [page, {"command": "add", "parent": "/", "type": "footer",
                                 "props": {"type": "default", "field": "page", "align": "center"}}] + d.ops
    for k in ("font_cs",):
        for op in ops:
            if k in op.get("props", {}):
                op["props"]["font.cs"] = op["props"].pop(k)
    with tempfile.NamedTemporaryFile("w", suffix=".json", delete=False, encoding="utf-8") as f:
        json.dump(ops, f, ensure_ascii=False)
    r = subprocess.run([O, "batch", out, "--input", f.name], capture_output=True, text=True)
    os.unlink(f.name)
    # Word rebuilds the TOC (and page numbers) the first time the file is opened
    subprocess.run([O, "raw-set", out, "/settings", "--xpath", "/w:settings/w:compat", "--action", "insertbefore",  # CT_Settings order: after characterSpacingControl, before compat
                    "--xml", '<w:updateFields xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main" w:val="true"/>'],
                   capture_output=True)
    subprocess.run([O, "close", out], capture_output=True)
    if r.returncode or " 0 failed" not in r.stdout:
        fails = [l for l in r.stdout.splitlines() if "fail" in l.lower() or "error" in l.lower()]
        raise SystemExit("batch failed:\n" + "\n".join(fails[-15:]) + r.stderr[-800:])
    # officecli attaches the footer to the final section only; without this the body pages lose their numbers
    with zipfile.ZipFile(out) as z:
        rid = re.search(r'<w:footerReference[^>]*r:id="([^"]+)"', z.read("word/document.xml").decode()).group(1)
    ns = ('xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main" '
          'xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships"')
    f = subprocess.run([O, "raw-set", out, "/document", "--xpath", "//w:p/w:pPr/w:sectPr", "--action", "prepend",
                        "--xml", f'<w:footerReference {ns} w:type="default" r:id="{rid}"/>'],
                       capture_output=True, text=True)
    subprocess.run([O, "close", out], capture_output=True)
    if f.returncode:
        raise SystemExit("footer link failed:\n" + f.stdout + f.stderr)
    # officecli styles have no size.cs/bold.cs, so without these Thai falls back to the 11pt docDefaults, not bold
    w = 'xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"'
    for sid, pt, bold in STYLE_CS:
        edits = [("w:sz", f'<w:szCs {w} w:val="{pt * 2}"/>')] + ([("w:b", f"<w:bCs {w}/>")] if bold else [])
        for after, xml in edits:
            c = subprocess.run([O, "raw-set", out, "/styles", "--xpath",
                                f"//w:style[@w:styleId='{sid}']/w:rPr/{after}", "--action", "insertafter", "--xml", xml],
                               capture_output=True, text=True)
            if c.returncode:
                raise SystemExit(f"style {sid} failed:\n" + c.stdout + c.stderr)
    subprocess.run([O, "close", out], capture_output=True)
    # ล็อกความกว้างตารางและใส่จุดตัดคำไทย: ต้องทำหลังสุด และต้องล้มดังถ้าทำไม่ได้
    # หา python ที่มี python-docx + pythainlp: .venv ข้างไฟล์นี้ → .venv โฟลเดอร์แม่ → python ที่รันอยู่
    here = os.path.dirname(os.path.abspath(__file__))
    venv = next((c for c in (os.path.join(here, ".venv", "bin", "python"),
                             os.path.join(os.path.dirname(here), ".venv", "bin", "python"))
                 if os.path.exists(c)), sys.executable)
    with tempfile.NamedTemporaryFile("w", suffix=".json", delete=False, encoding="utf-8") as f:
        json.dump(d.table_weights, f)
    fin = subprocess.run([venv, os.path.join(os.path.dirname(os.path.abspath(__file__)), "finish_tables.py"), out, f.name], capture_output=True, text=True)
    os.unlink(f.name)
    if fin.returncode:
        raise SystemExit("finish_tables failed:\n" + fin.stdout + fin.stderr)
    v = subprocess.run([O, "validate", out], capture_output=True, text=True)
    subprocess.run([O, "close", out], capture_output=True)
    if v.returncode or "passed" not in v.stdout:
        raise SystemExit("validate FAILED:\n" + v.stdout + v.stderr)
    print(v.stdout.strip())
    print(out)


if __name__ == "__main__":
    if len(sys.argv) >= 3:
        build(runpy.run_path(sys.argv[1])["SPEC"], os.path.abspath(sys.argv[2]))
    else:
        build({}, os.path.abspath("BR-SKELETON.docx"))

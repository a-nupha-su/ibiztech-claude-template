#!/usr/bin/env python3
"""ตรวจว่าไฟล์ .docx เดินตามโครง SRS/BR 9 ส่วน

    python3 check_br.py OUT.docx            ตรวจโครง (ยังมีตัวแทนได้ แค่เตือน)
    python3 check_br.py OUT.docx --final    ตรวจก่อนส่งจริง (เหลือตัวแทน = ไม่ผ่าน)

exit 0 = ผ่าน · exit 1 = ไม่ผ่าน · exit 2 = เปิดไฟล์ไม่ได้
"""
import re
import sys

try:
    from docx import Document
    from docx.oxml.ns import qn
    from docx.shared import Inches
except ImportError:
    raise SystemExit("ต้องติดตั้ง python-docx ก่อน: pip install python-docx")

FONT = "TH Sarabun New"
LATEST_COLOR = "0070C0"
HEADER_FILL = "D9E2F3"
HEADER_FIRST_CELLS = ("ฉบับที่", "องค์ประกอบ", "ชื่อโมดูล")
COVER_TITLES = ("Software Requirements Specification", "Business Requirement")
CHAPTERS = [
    ("ประวัติการจัดทำเอกสาร", 2),
    ("บทนำ", 1),
    ("เข้าใจลักษณะ", 1),
    ("บทวิเคราะห์ความต้องการ", 1),
    ("การออกแบบ Functional Design", 1),
    ("หน้าจอ (Screen)", 1),
    ("ภาคผนวก ก.", 1),
]
INTRO_H2 = ["ที่มาและความสำคัญ", "ขอบเขตการดำเนินงาน", "ประโยชน์ที่คาดว่าจะได้รับ"]
REQ_H3 = ["วัตถุประสงค์:", "สิทธิผู้ใช้งาน:", "หน้าจอ:", "ฟังก์ชันการทำงาน:",
          "เงื่อนไขการทำงานของระบบ:", "การจัดการข้อมูล Setup ที่เกี่ยวข้อง:"]
PLACEHOLDER = re.compile(r"X{5,}|_{5,}|\[ วางรูปภาพที่นี่ \]|<[^<>\s][^<>\n]{0,79}(?<!\s)>|รอข้อมูลจากลูกค้า|ข้อเสนอ รอยืนยัน")
SPELLING = {"คำนวน": "คำนวณ", "อีเมล์": "อีเมล", "เช็คราคา": "เช็กราคา"}


def level(p):
    m = re.fullmatch(r"heading (\d)", (p.style.name or "").strip().lower())
    return int(m.group(1)) if m else 0


def lead_number(text):
    m = re.match(r"(\d+(?:\.\d+)*)[.)]\s", text)
    return tuple(int(x) for x in m.group(1).split(".")) if m else None


def check_sequence(headings, where, errors):
    """เลขที่พิมพ์ในหัวข้อต้องเดินทีละหนึ่ง ภายใต้หัวข้อแม่เดียวกัน (level -> เลขเต็ม)"""
    last = {}
    for lv, text in headings:
        num = lead_number(text)
        if num is None:
            errors.append(f"{where}: หัวข้อไม่มีเลข: {text!r}")
            continue
        last = {k: v for k, v in last.items() if len(k) < len(num) or k[:-1] == num[:-1]}
        prefix, cur = num[:-1], num[-1]
        expected = last.get(prefix, 0) + 1
        if cur != expected:
            errors.append(f"{where}: เลขกระโดด {text!r} (ควรเป็นเลข {expected})")
        last[prefix] = cur


def chapter_slices(paras, errors):
    """คืน {ชื่อบท: ย่อหน้าในบท} และตรวจลำดับบทไปพร้อมกัน"""
    positions = []
    pos = -1
    for name, lv in CHAPTERS:
        found = next((i for i in range(pos + 1, len(paras))
                      if level(paras[i]) == lv and paras[i].text.strip().startswith(name)), None)
        if found is None:
            errors.append(f"ไม่พบส่วน {name!r} (ขาด หรือเรียงผิดลำดับ)")
            continue
        positions.append((name, found))
        pos = found
    out = {}
    for i, (name, start) in enumerate(positions):
        end = positions[i + 1][1] if i + 1 < len(positions) else len(paras)
        out[name] = paras[start + 1:end]
    return out


def check_requirements(body, errors):
    blocks, cur = [], None
    for p in body:
        lv, text = level(p), p.text.strip()
        if lv == 2:
            cur = {"title": text, "h3": []}
            blocks.append(cur)
        elif lv == 3 and cur:
            cur["h3"].append(text)
    if not blocks:
        errors.append("บทวิเคราะห์ความต้องการ: ไม่มี requirement เลย")
    for b in blocks:
        if b["h3"] != REQ_H3:
            errors.append(f"requirement {b['title']!r}: ต้องมี 6 ส่วนตามลำดับ แต่เจอ {b['h3']}")
    check_sequence([(2, b["title"]) for b in blocks], "บทวิเคราะห์ความต้องการ", errors)
    for b_start in split_on_h2(body):
        check_sub_numbers(b_start, errors)


def split_on_h2(body):
    groups, cur = [], None
    for p in body:
        if level(p) == 2:
            cur = []
            groups.append(cur)
        elif cur is not None:
            cur.append(p)
    return groups


def check_sub_numbers(group, errors):
    """ใต้แต่ละ H3 ของ requirement เลข H4 `1)` และ H5 `1.1)` ต้องต่อเนื่อง"""
    run = []
    for p in group + [None]:
        if p is None or level(p) == 3:
            check_sequence(run, "บทวิเคราะห์ความต้องการ", errors)
            run = []
        elif level(p) in (4, 5):
            run.append((level(p), p.text.strip()))


def check_journey_numbers(body, errors):
    heads = [(level(p), p.text.strip()) for p in body if level(p) in (2, 3, 4)]
    check_sequence(heads, "เข้าใจลักษณะระบบ", errors)
    h2 = [t for lv, t in heads if lv == 2]
    if len(h2) < 2 or "ภาพรวม" not in h2[0] or "โมดูล" not in h2[1]:
        errors.append(f"เข้าใจลักษณะระบบ: หัวข้อแรกต้องเป็นภาพรวมและโมดูล แต่เจอ {h2[:2]}")


def check_format(doc, errors):
    sec = doc.sections[0]
    if abs(sec.page_width - Inches(8.5)) > 2000 or abs(sec.page_height - Inches(11)) > 2000:
        errors.append("กระดาษต้องเป็น Letter 8.5x11 นิ้ว")
    for side in ("left_margin", "right_margin", "top_margin", "bottom_margin"):
        if abs(getattr(sec, side) - Inches(1)) > 2000:
            errors.append(f"ขอบกระดาษ {side} ต้องเป็น 1 นิ้ว")
    fonts = doc.styles["Normal"].element.find(f"{qn('w:rPr')}/{qn('w:rFonts')}")
    if fonts is None or fonts.get(qn("w:cs")) != FONT:
        errors.append(f"ฟอนต์ไทยของ Normal ต้องเป็น {FONT}")
    for name, pt, bold in (("Normal", 16, False), ("Heading 1", 22, True), ("Heading 2", 18, True), ("Heading 3", 16, True)):
        rpr = doc.styles[name].element.find(qn("w:rPr"))
        size = rpr.find(qn("w:szCs")) if rpr is not None else None
        if size is None or size.get(qn("w:val")) != str(pt * 2):
            errors.append(f"ขนาดอักษรไทยของ {name} ต้องเป็น {pt}pt (szCs) ไม่งั้นอักษรไทยจะเล็กกว่าที่กำหนด")
        bcs = rpr.find(qn("w:bCs")) if rpr is not None else None
        if bold and (bcs is None or bcs.get(qn("w:val")) in ("0", "false")):
            errors.append(f"อักษรไทยของ {name} ต้องตัวหนา (bCs)")
    for run_fonts in doc.element.body.iter(qn("w:rFonts")):
        cs = run_fonts.get(qn("w:cs"))
        if cs and cs != FONT:
            errors.append(f"พบฟอนต์ไทยอื่น: {cs}")
            break
    if not any("TOC" in (i.text or "") for i in doc.element.body.iter(qn("w:instrText"))):
        errors.append("ไม่พบสารบัญอัตโนมัติ")


def check_table_headers(doc, errors):
    """ตรวจเฉพาะตารางของเทมเพลต ตารางที่ผู้ใช้เพิ่มเองใน Word ไม่ถูกบังคับ"""
    for t in doc.tables:
        cells = t.rows[0].cells
        names = [c.text.strip() for c in cells]
        if names[0] not in HEADER_FIRST_CELLS and "Field Name" not in names:
            continue
        fills = [c._tc.find(f"{qn('w:tcPr')}/{qn('w:shd')}") for c in cells]
        runs = [r for c in cells for p in c.paragraphs for r in p.runs if r.text.strip()]
        ok = (t.rows[0]._tr.find(f"{qn('w:trPr')}/{qn('w:tblHeader')}") is not None
              and all(f is not None and f.get(qn("w:fill")) == HEADER_FILL for f in fills)
              and all(r._element.find(f"{qn('w:rPr')}/{qn(tag)}") is not None
                      for r in runs for tag in ("w:b", "w:bCs")))
        if not ok:
            errors.append(f"หัวตาราง {names[0]!r}: ต้องตัวหนา พื้น {HEADER_FILL} และซ้ำเมื่อขึ้นหน้าใหม่")


def check_template_details(doc, paras, errors):
    title = next((p for p in paras[:20] if p.text.strip() in COVER_TITLES), None)
    if title is not None and title._element.find(f"{qn('w:pPr')}/{qn('w:pBdr')}/{qn('w:left')}") is None:
        errors.append("หน้าปกต้องมีเส้นแนวตั้งกั้นซ้ายของบล็อกข้อความ")
    history = next((t for t in doc.tables if t.rows[0].cells[0].text.strip() == "ฉบับที่"), None)
    filled = [r for r in history.rows[1:] if any(c.text.strip() for c in r.cells)] if history else []
    if filled:
        colors = {x.get(qn("w:val")) for x in filled[-1]._tr.iter(qn("w:color"))}
        if colors != {LATEST_COLOR}:
            errors.append(f"ประวัติเอกสาร: ฉบับล่าสุดต้องเป็นสี {LATEST_COLOR} แต่เจอ {sorted(c for c in colors if c)}")
    fmts = [(s._sectPr.find(qn("w:pgNumType")), s) for s in doc.sections]
    fmts = [n.get(qn("w:fmt")) if n is not None else None for n, _ in fmts]
    if len(fmts) < 2 or fmts[-1] != "lowerRoman" or "lowerRoman" in fmts[:-1]:
        errors.append(f"ภาคผนวกต้องอยู่คนละ section และใช้เลขหน้าโรมัน แต่เจอ {fmts}")
    if doc.sections[0].footer.is_linked_to_previous:
        errors.append("section แรกไม่มีท้ายกระดาษ เนื้อหาจะไม่มีเลขหน้า")
    elif not all("PAGE" in s.footer._element.xml for s in doc.sections):
        errors.append("ทุก section ต้องมีเลขหน้าท้ายกระดาษ")


def check_table_widths(doc, errors):
    """Word ขยายตารางที่ไม่ล็อกจนล้นกรอบ และ LibreOffice ไม่แสดงอาการ จึงต้องตรวจจากค่าในไฟล์"""
    sec = doc.sections[0]
    text_w = int((sec.page_width - sec.left_margin - sec.right_margin) / 635)
    for i, t in enumerate(doc.tables, 1):
        lay = t._tbl.tblPr.find(qn("w:tblLayout"))
        grid = sum(int(g.get(qn("w:w"))) for g in t._tbl.tblGrid.findall(qn("w:gridCol")))
        tcw = [c.find(qn("w:tcPr")) is not None and c.find(qn("w:tcPr")).find(qn("w:tcW")) is not None for c in t.rows[0]._tr.findall(qn("w:tc"))]
        if lay is None or lay.get(qn("w:type")) != "fixed":
            errors.append(f"ตารางที่ {i} ไม่ได้ล็อกความกว้าง (tblLayout fixed) Word จะขยายจนล้นกรอบ")
        if grid > text_w + 5:
            errors.append(f"ตารางที่ {i} กว้าง {grid} เกินพื้นที่ข้อความ {text_w}")
        if not all(tcw):
            errors.append(f"ตารางที่ {i} ไม่มีความกว้างรายเซลล์ (tcW)")


def check_figures(paras, errors):
    nums = [int(m.group(1)) for p in paras if (p.style.name or "").lower() == "caption"
            for m in [re.match(r"รูปที่ (\d+)", p.text.strip())] if m]
    if nums != list(range(1, len(nums) + 1)):
        errors.append(f"เลขรูปไม่ต่อเนื่อง: {nums}")


def main(argv):
    args = [a for a in argv if not a.startswith("--")]
    if len(args) != 1:
        print(__doc__)
        return 2
    final = "--final" in argv
    try:
        doc = Document(args[0])
    except Exception as e:
        print(f"เปิดไฟล์ไม่ได้: {e}")
        return 2

    errors, warnings = [], []
    paras = doc.paragraphs
    if not any(p.text.strip() in COVER_TITLES for p in paras[:20]):
        errors.append(f"หน้าปกต้องมีชื่อเอกสาร {COVER_TITLES}")
    if not any((p.text.strip() == "สารบัญ") for p in paras):
        errors.append("ไม่พบหัวข้อสารบัญ")

    chapters = chapter_slices(paras, errors)
    if "บทนำ" in chapters:
        h2 = [p.text.strip() for p in chapters["บทนำ"] if level(p) == 2]
        if h2 != INTRO_H2:
            errors.append(f"บทนำ: ต้องมี {INTRO_H2} แต่เจอ {h2}")
    if "เข้าใจลักษณะ" in chapters:
        check_journey_numbers(chapters["เข้าใจลักษณะ"], errors)
    if "บทวิเคราะห์ความต้องการ" in chapters:
        check_requirements(chapters["บทวิเคราะห์ความต้องการ"], errors)
    if "การออกแบบ Functional Design" in chapters:
        fn = [(2, p.text.strip()) for p in chapters["การออกแบบ Functional Design"] if level(p) == 2]
        if not fn:
            errors.append("Functional Design: ไม่มีฟังก์ชันเลย")
        check_sequence(fn, "Functional Design", errors)
        field_tables = [t for t in doc.tables if any(c.text.strip() == "Field Name" for c in t.rows[0].cells)]
        if len(field_tables) < len(fn):
            errors.append(f"Functional Design: มี {len(fn)} ฟังก์ชัน แต่มีตาราง Field Name {len(field_tables)} ตาราง")
    check_figures(paras, errors)
    check_format(doc, errors)
    check_template_details(doc, paras, errors)
    check_table_headers(doc, errors)

    check_table_widths(doc, errors)
    texts = [p.text for p in paras] + [c.text.replace("\u200b", "") for t in doc.tables for r in t.rows for c in r.cells]
    left = sorted({m.group(0) for t in texts for m in PLACEHOLDER.finditer(t)})
    if left:
        (errors if final else warnings).append(f"ยังมีตัวแทนที่ต้องเติม {len(left)} แบบ: {left[:12]}")
    history = next((t for t in doc.tables if t.rows[0].cells[0].text.strip() == "ฉบับที่"), None)
    if history is None:
        errors.append("ไม่พบตารางประวัติการจัดทำเอกสาร")
    elif len(history.rows) < 2 or not all(c.text.strip() for c in history.rows[1].cells):
        (errors if final else warnings).append("ประวัติการจัดทำเอกสาร: แถวแรกยังกรอกไม่ครบ")
    for wrong, right in SPELLING.items():
        if any(wrong in t for t in texts):
            warnings.append(f"สะกด {wrong!r} ควรเป็น {right!r}")

    for w in warnings:
        print("เตือน:", w)
    for e in errors:
        print("ผิด:", e)
    print(f"{'ไม่ผ่าน' if errors else 'ผ่าน'}: ผิด {len(errors)} เตือน {len(warnings)}")
    return 1 if errors else 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))

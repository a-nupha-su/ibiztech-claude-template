# ขั้นปิดท้ายของ build_br: ล็อกความกว้างทุกตารางให้พอดีหน้า และใส่จุดตัดคำไทยในเซลล์
# เหตุผล: Word ขยายตารางที่ไม่ล็อกจนล้นกรอบ (LibreOffice ไม่แสดงอาการ) และตัดข้อความไทยยาวกลางคำเมื่อล็อกแล้ว
# จุดตัดคำเป็น U+200B ซึ่งมองไม่เห็น ข้อเสีย: การค้นคำใน Word อาจไม่เจอข้อความที่ถูกแบ่งในตาราง
# รัน: finish_tables.py ไฟล์.docx น้ำหนัก.json   (น้ำหนัก.json = ลิสต์ตามลำดับตาราง ค่าเป็นสัดส่วนหรือ null)
import json
import re
import statistics
import sys

from docx import Document
from docx.oxml import OxmlElement
from docx.oxml.ns import qn
from docx.shared import Twips
from pythainlp.tokenize import word_tokenize

TOTAL = 9360  # Letter ขอบ 1 นิ้ว
ZWSP = "​"
THAI = re.compile(r"[฀-๿]{2,}")
KNOWN = {
    ("no.", "field name", "description", "m/o", "condition/comment"): [7, 24, 28, 8, 33],
    ("ฉบับที่", "วันที่จัดทำเอกสาร", "จัดทำเอกสารโดย", "รายละเอียด"): [10, 18, 18, 54],
}


def auto_weights(rows):
    """ไม่มีน้ำหนักระบุ: ให้สัดส่วนตามความยาวข้อความ และไม่ให้คอลัมน์ใดแคบเกิน"""
    out = []
    for c in range(len(rows[0])):
        lens = [len(r[c]) for r in rows]
        out.append(max(max(lens[:1]), statistics.quantiles(lens, n=4)[2] if len(lens) > 1 else lens[0], 4) ** 0.5)
    low = sum(out) * 0.08
    return [max(x, low) for x in out]


def tokens(run):
    """ตัวตัดคำแยก ผู้สนใจ เป็น ผู้ กับ สนใจ จึงรวมคำนำหน้า ผู้ เข้ากับคำถัดไป"""
    out = []
    for w in word_tokenize(run, engine="newmm", keep_whitespace=True):
        if out and out[-1] == "ผู้":
            out[-1] += w
        else:
            out.append(w)
    return out


def cut_thai(text):
    return THAI.sub(lambda m: ZWSP.join(tokens(m.group(0))), text.replace(ZWSP, ""))


def finish(path, weights):
    d = Document(path)
    if len(weights) != len(d.tables):
        sys.exit(f"จำนวนตาราง {len(d.tables)} ไม่ตรงกับน้ำหนัก {len(weights)}")
    for t, given in zip(d.tables, weights):
        texts = [[c.text.strip() for c in r.cells] for r in t.rows]
        w = given or KNOWN.get(tuple(x.lower() for x in texts[0])) or auto_weights(texts)
        n = len(t._tbl.tblGrid.findall(qn("w:gridCol")))
        if len(w) != n:
            sys.exit(f"น้ำหนัก {len(w)} ไม่ตรงกับคอลัมน์ {n}: {texts[0]}")
        s = sum(w)
        cols = [int(TOTAL * x / s) for x in w]
        cols[-1] += TOTAL - sum(cols)
        pr = t._tbl.tblPr
        for tag in ("w:tblW", "w:tblLayout", "w:tblCellMar"):
            for e in pr.findall(qn(tag)):
                pr.remove(e)
        tw = OxmlElement("w:tblW"); tw.set(qn("w:w"), str(TOTAL)); tw.set(qn("w:type"), "dxa")
        style = pr.find(qn("w:tblStyle"))
        pr.insert(list(pr).index(style) + 1 if style is not None else 0, tw)
        lay = OxmlElement("w:tblLayout"); lay.set(qn("w:type"), "fixed")
        mar = OxmlElement("w:tblCellMar")
        for side in ("left", "right"):
            m = OxmlElement("w:" + side); m.set(qn("w:w"), "70"); m.set(qn("w:type"), "dxa"); mar.append(m)
        look = pr.find(qn("w:tblLook"))
        for e in (lay, mar):
            look.addprevious(e) if look is not None else pr.append(e)
        for g, c in zip(t._tbl.tblGrid.findall(qn("w:gridCol")), cols):
            g.set(qn("w:w"), str(c))
        for ri, r in enumerate(t.rows):
            for c, cw in zip(r.cells, cols):
                c.width = Twips(cw)
                if ri == 0:  # หัวตารางสั้น และด่านใช้ข้อความนี้ระบุชนิดตาราง
                    continue
                for node in c._tc.iter(qn("w:t")):
                    if node.text:
                        node.text = cut_thai(node.text)
    rd = d.styles.element.find(qn("w:docDefaults")).find(qn("w:rPrDefault")).find(qn("w:rPr"))
    for e in rd.findall(qn("w:lang")):
        rd.remove(e)
    lang = OxmlElement("w:lang"); lang.set(qn("w:val"), "th-TH"); lang.set(qn("w:bidi"), "th-TH"); lang.set(qn("w:eastAsia"), "th-TH")
    rd.append(lang)
    d.save(path)
    print("ล็อกตาราง", len(d.tables))


if __name__ == "__main__":
    finish(sys.argv[1], json.load(open(sys.argv[2], encoding="utf-8")))

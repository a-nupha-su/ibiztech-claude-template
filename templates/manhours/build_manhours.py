# -*- coding: utf-8 -*-
"""
ตัวสร้างไฟล์ Manhours ตามเทมเพลตกลางของบริษัท

ใช้: เขียนไฟล์ชุดงานของโครงการ (ดู example_tasks.py) แล้วเรียก
    from build_manhours import build, HT, SA, PM, PO, SR, MD, JR
    build("ชื่อโครงการ", SECTIONS, "ออก.xlsx")

หลังสร้างเสร็จ ต้องรัน recalc ของ skill xlsx เสมอ แล้วต้องได้ total_errors = 0

รูปแบบทั้งหมดถอดมาจากเทมเพลตต้นฉบับของบริษัท ห้ามเปลี่ยนสี ฟอนต์
หรือโครงคอลัมน์ เพราะเป็นเทมเพลตที่ทีมและลูกค้าคุ้นเคยอยู่แล้ว
"""
from openpyxl import Workbook
from openpyxl.styles import Font, PatternFill, Alignment, Border, Side
from openpyxl.styles.colors import Color
from openpyxl.utils import get_column_letter as L, column_index_from_string as N

# ---------------------------------------------------------------- ตำแหน่งงาน
# เรตต่อชั่วโมง มาจากเรตการ์ดของบริษัท แก้ที่นี่ที่เดียว
HT, SA, PM, PO, SR, MD, JR = 'HT', 'SA', 'PM', 'PO', 'SR', 'MD', 'JR'

ROLES = [  # (คีย์, กลุ่ม, ชื่อที่แสดง, เรต/ชม., คอลัมน์ Hour)
    (HT, 'Management',  'Head of Technology',  2500, 'G'),
    (SA, 'Management',  'Solution Architect',  2500, 'I'),
    (PM, 'Management',  'Project Manager',     1000, 'K'),
    (PO, 'Management',  'Product Owner / AE',  1000, 'M'),
    (SR, 'Development', 'Senior Developer',    1500, 'O'),
    (MD, 'Development', 'Mid Developer',       1000, 'Q'),
    (JR, 'Development', 'Junior Developer',     700, 'S'),
]
RATE = {k: r for k, _, _, r, _ in ROLES}
GROUPS = [('Management', 'G', 'N'), ('Development', 'O', 'T')]

# ------------------------------------------------------------------- รูปแบบ
# ถอดจากเทมเพลตต้นฉบับ ห้ามแก้
FONT = 'Calibri'
ACC = '_(* #,##0_);_(* \\(#,##0\\);_(* "-"??_);_(@_)'
BLUE_HDR = 'FFB4C6E7'   # แถบหัวตาราง
BLUE_D   = 'FF9CC2E5'   # คอลัมน์ D
YELLOW   = 'FFFFFF00'   # แถวหัวข้อ
GREEN    = 'FFE2EFD9'   # แถวงาน
PURPLE   = 'FF7030A0'   # คอลัมน์ E
BLUE_TXT = 'FF0070C0'   # ตัวหนังสือคอลัมน์ C และ D
WIDTHS = {'A': 6.7, 'B': 69.0, 'C': 16.4, 'D': 13.0, 'E': 11.4, 'F': 3.0,
          'G': 8.7, 'H': 10.9, 'I': 8.7, 'J': 10.9, 'K': 8.7, 'L': 10.9,
          'M': 8.7, 'N': 10.9, 'O': 8.7, 'P': 10.9, 'Q': 8.7, 'R': 10.9,
          'S': 8.7, 'T': 10.9}

WHITE = Color(theme=0, type='theme')
BLACK = Color(theme=1, type='theme')
_thin = Side(style='thin', color='FFBFBFBF')
BOX = Border(_thin, _thin, _thin, _thin)


def _fill(hex_):
    return PatternFill('solid', fgColor=hex_)


def preview(sections):
    """พิมพ์สรุปชั่วโมงและราคาต่อขั้น ใช้เช็คก่อนสร้างไฟล์"""
    total_h = total_c = 0
    for title, tasks in sections:
        h = sum(v for _, _, a in tasks for v in a.values())
        c = sum(v * RATE[k] for _, _, a in tasks for k, v in a.items())
        total_h, total_c = total_h + h, total_c + c
        print(f'{title:<52}{h:>6,} ชม.{c:>13,.0f} บาท')
    print(f'{"รวมทั้งโครงการ":<52}{total_h:>6,} ชม.{total_c:>13,.0f} บาท')
    return total_h, total_c


def build(project, sections, outfile, notes=None):
    """สร้างไฟล์ Manhours  sections = [(ชื่อขั้น, [(เลขข้อ, ชื่องาน, {ROLE: ชม.})])]"""
    wb = Workbook()
    ws = wb.active
    ws.title = 'Manhours'
    cost_cols = [L(N(hc) + 1) for *_, hc in ROLES]

    # หัวตาราง
    ws['A3'] = project
    ws['A3'].font = Font(FONT, 10, bold=True, color=YELLOW)
    ws['A3'].fill = _fill('FF000000')
    ws['C3'] = 'SOW'
    ws['C3'].font = Font(FONT, 10, bold=True)
    ws['C3'].alignment = Alignment(horizontal='center')
    ws['D3'], ws['D4'] = 'Total cost', '(to client)'
    ws['E3'], ws['E4'] = 'Total cost', '(from hour)'
    for a in ('D3', 'E3', 'D4', 'E4'):
        ws[a].font = Font(FONT, 10, bold=True)
        ws[a].fill = _fill(BLUE_D)
        ws[a].alignment = Alignment(horizontal='center')

    for label, c1, c2 in GROUPS:
        ws.merge_cells(f'{c1}1:{c2}1')
        c = ws[f'{c1}1']
        c.value, c.font = label, Font(FONT, 11, bold=True, color=BLACK)
        c.fill, c.alignment = _fill(BLUE_HDR), Alignment(horizontal='center')

    for key, _grp, title, rate, hc in ROLES:
        cc = L(N(hc) + 1)
        ws.merge_cells(f'{hc}2:{cc}2')
        c = ws[f'{hc}2']
        c.value, c.font = title, Font(FONT, 8, color=BLACK)
        c.fill = _fill(BLUE_HDR)
        c.alignment = Alignment(horizontal='center', vertical='center', wrap_text=True)
        r = ws[f'{hc}3']
        r.value, r.font = rate, Font(FONT, 10, bold=True, color=BLACK)
        r.fill, r.number_format = _fill(BLUE_HDR), ACC
        ws[f'{cc}3'].fill = _fill(BLUE_HDR)
        for cl, lab in ((hc, 'Hour'), (cc, 'Cost')):
            x = ws[f'{cl}4']
            x.value, x.font = lab, Font(FONT, 10, bold=True, color=BLACK)
            x.alignment, x.fill = Alignment(horizontal='center'), _fill(BLUE_HDR)
    for a in ('A1', 'B1', 'C1', 'D1', 'E1', 'F1', 'A2', 'B2', 'C2', 'D2', 'E2', 'F2'):
        ws[a].fill = _fill(BLUE_HDR)

    # เนื้อตาราง
    row, section_rows = 5, []
    for title, tasks in sections:
        first, last = row + 1, row + len(tasks)
        h = ws.cell(row, 1)
        h.value, h.font = title, Font(FONT, 11, bold=True, color=BLACK)
        h.fill, h.alignment = _fill(YELLOW), Alignment(horizontal='left')
        t = ws.cell(row, 3)
        t.value, t.font = f'=SUM(D{first}:D{last})', Font(FONT, 11, bold=True, color=BLACK)
        t.fill, t.number_format = _fill(YELLOW), ACC
        for c in list(range(2, 3)) + list(range(4, N('T') + 1)):
            ws.cell(row, c).fill = _fill(YELLOW)
        section_rows.append(row)
        row += 1

        for no, name, alloc in tasks:
            a = ws.cell(row, 1)
            a.value, a.font = no, Font(FONT, 10, color=BLACK)
            a.fill, a.alignment = _fill(GREEN), Alignment(horizontal='center')
            b = ws.cell(row, 2)
            b.value, b.font, b.fill = name, Font(FONT, 11, color=BLACK), _fill(GREEN)
            c = ws.cell(row, 3)
            c.font, c.fill = Font(FONT, 11, color=BLUE_TXT), _fill(GREEN)
            d = ws.cell(row, 4)
            d.value, d.font = f'=E{row}', Font(FONT, 11, color=BLUE_TXT)
            d.fill, d.number_format = _fill(BLUE_D), ACC
            e = ws.cell(row, 5)
            e.value = '=' + '+'.join(f'{cc}{row}' for cc in cost_cols)
            e.font, e.fill = Font(FONT, 11, bold=True, color=WHITE), _fill(PURPLE)
            e.number_format, e.alignment = ACC, Alignment(horizontal='center')
            for key, _g, _t, _r, hc in ROLES:
                cc = L(N(hc) + 1)
                hv = ws[f'{hc}{row}']
                hv.value, hv.font = alloc.get(key, 0), Font(FONT, 11, color=BLACK)
                hv.number_format, hv.alignment, hv.border = ACC, Alignment(horizontal='center'), BOX
                cv = ws[f'{cc}{row}']
                cv.value, cv.font = f'={hc}{row}*${hc}$3', Font(FONT, 11, color=BLACK)
                cv.number_format, cv.alignment, cv.border = ACC, Alignment(horizontal='center'), BOX
            row += 1
        row += 1

    # แถวรวม
    tr = row
    g = ws.cell(tr, 2)
    g.value, g.font, g.fill = 'รวมทั้งโครงการ', Font(FONT, 12, bold=True, color=BLACK), _fill(YELLOW)
    ws.cell(tr, 1).fill = ws.cell(tr, 3).fill = _fill(YELLOW)
    d = ws.cell(tr, 4)
    d.value = '=' + '+'.join(f'C{r}' for r in section_rows)
    d.font, d.fill, d.number_format = Font(FONT, 12, bold=True, color=BLACK), _fill(YELLOW), ACC
    e = ws.cell(tr, 5)
    e.value, e.font = f'=D{tr}', Font(FONT, 12, bold=True, color=WHITE)
    e.fill, e.number_format, e.alignment = _fill(PURPLE), ACC, Alignment(horizontal='center')
    spans = [f'{{c}}{r + 1}:{{c}}{r + len(t)}' for r, (_, t) in zip(section_rows, sections)]
    for _k, _g, _t, _r, hc in ROLES:
        for cl in (hc, L(N(hc) + 1)):
            x = ws[f'{cl}{tr}']
            x.value = '=SUM(' + ','.join(s.format(c=cl) for s in spans) + ')'
            x.font, x.fill = Font(FONT, 12, bold=True, color=BLACK), _fill(YELLOW)
            x.number_format, x.alignment = ACC, Alignment(horizontal='center')

    # หมายเหตุ
    base = [
        'ช่อง Hour ของแต่ละตำแหน่ง คือช่องที่กรอกเอง  ช่อง Cost คำนวณอัตโนมัติจาก Hour x เรตในแถวที่ 3',
        'เรตต่อชั่วโมงในแถวที่ 3 มาจากเรตการ์ดของบริษัท แก้ที่แถวนั้นแล้วทั้งไฟล์คำนวณใหม่ทันที',
        'คอลัมน์ D และ E เป็นสูตร ห้ามพิมพ์ทับ  C ของแถวหัวข้อสีเหลืองคือผลรวมของขั้นนั้น',
        'ราคายังไม่รวมภาษีมูลค่าเพิ่ม และไม่รวมค่าใช้จ่ายรายเดือน เช่น เซิร์ฟเวอร์ และค่าส่งข้อความ',
    ]
    n = tr + 2
    ws.cell(n, 2).value = 'หมายเหตุ'
    ws.cell(n, 2).font = Font(FONT, 11, bold=True, color=BLACK)
    for i, txt in enumerate(base + list(notes or [])):
        ws.cell(n + 1 + i, 2).value = '- ' + txt
        ws.cell(n + 1 + i, 2).font = Font(FONT, 10, color=BLACK)

    for col, w in WIDTHS.items():
        ws.column_dimensions[col].width = w
    ws.row_dimensions[1].height = 15.75
    ws.row_dimensions[2].height = 32
    ws.row_dimensions[3].height = 14.25
    ws.row_dimensions[4].height = 14.25
    ws.freeze_panes = 'F5'
    ws.sheet_view.showGridLines = False
    wb.save(outfile)
    return outfile, tr

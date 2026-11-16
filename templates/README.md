# เทมเพลตเอกสาร — SRS/BR และ Manhours

| โฟลเดอร์ | ได้อะไร | ตัวสร้าง → ด่านตรวจ |
|---|---|---|
| [`business-requirement/`](business-requirement) | เอกสาร **SRS / BR** ภาษาไทย `.docx` โครง 9 ส่วน ลำดับตายตัว | `build_br.py` → `check_br.py` |
| [`manhours/`](manhours) | ใบประเมิน **Manhours / ราคา** `.xlsx` สูตรครบ แยกชั่วโมงตามตำแหน่ง | `build_manhours.py` → `recalc_check.py` |

> ตัวอย่างทั้งหมด (`example_spec.py`, `example_tasks.py`, `EXAMPLE-*`) เป็น **mockup** ของโครงการสมมติ
> "ระบบจองคิวร้านตัวอย่าง" ไม่ใช่ข้อมูลลูกค้าจริง

---

## 0. ติดตั้งของที่ต้องใช้ (ครั้งแรกครั้งเดียว)

```bash
bash scripts/check-requirements.sh srs manhours
```

script จะบอกว่าขาดอะไร แล้ว **ถามทีละตัวก่อนติดตั้ง** (ตอบ `y` ถึงจะติดตั้ง):

| ของที่ต้องมี | ใช้กับ | ติดตั้งให้ได้ไหม |
|---|---|---|
| OfficeCLI (`~/.local/bin/officecli`) | SRS | ได้ |
| `templates/.venv` (python-docx · pythainlp · openpyxl) | SRS + Manhours | ได้ |
| ฟอนต์ TH Sarabun New | SRS | ไม่ได้ — ดาวน์โหลดฟอนต์ SIPA แล้วติดตั้งเอง |
| LibreOffice | Manhours (คำนวณสูตร + ตรวจ error) | ได้ |
| Microsoft Word (macOS) | SRS ฉบับส่งจริง (ไม่บังคับ) | ไม่ได้ |

---

## 1. สั่งงานผ่าน Claude (แบบที่ใช้บ่อยที่สุด)

ก็อปไปวางใน Claude Code แล้วเติม `<...>`

**SRS / BR**
```
ทำ SRS ระบบ <ชื่อระบบ> ให้ลูกค้า <ชื่อลูกค้า> ด้วย templates/business-requirement
- role: <ลูกค้า / เจ้าหน้าที่ / ผู้ดูแล ...>
- journey หลัก: <ขั้นตอนที่ผู้ใช้เดิน เช่น เลือกบริการ → จอง → ชำระเงิน>
- เอกสารจากลูกค้า: <path หรือ docs/16-client-artifacts.md>
อ่าน STRUCTURE.md ก่อน · เขียน spec ตามรูปแบบ example_spec.py · build_br.py · check_br.py ต้อง exit 0
```

**Manhours / ใบเสนอราคา**
```
ประเมิน manhours โครงการ <ชื่อ> ด้วย templates/manhours จาก <docs/01-requirement.md หรือ SRS ที่ทำไว้>
- แตกงานเป็นขั้น กระจายชั่วโมงตามตำแหน่งจริงทุกข้อ
- ให้ดูยอดจาก preview() ก่อน แล้วค่อย build()
- recalc_check.py ต้องได้ total_errors 0 · ใส่ NOTES บอกขั้นที่ความมั่นใจต่ำ
```

ถ้าเครื่องขาด tool ตัวไหน Claude จะ **ถามก่อนติดตั้ง** (กติกาใน `CLAUDE.md`) ไม่ข้ามเงียบ ๆ

---

## 2. SRS / BR ทำเอง (`business-requirement/`)

1. อ่าน [`STRUCTURE.md`](business-requirement/STRUCTURE.md) — โครง 9 ส่วน กติกาเลขหัวข้อ แนวการเขียนภาษาไทย
2. คุยกับลูกค้าให้รู้ **journey** และ **role** ก่อน (บทที่ 4 และ 5 เขียนไม่ได้ถ้ายังไม่รู้)
3. ก็อป `example_spec.py` เป็น spec ของโครงการ แล้วเติม `SPEC = {...}`
   - `"doc_type": "SRS"` หรือ `"BR"` — เปลี่ยนแค่ชื่อบนหน้าปก
   - ช่องที่ยังไม่รู้ปล่อยว่างได้ ตัวสร้างใส่ตัวแทน `XXXXXXXXX` ให้เห็นว่าต้องเติม
   - ใส่รูปผ่าน `figure_image` · `screen_image` · `screens[].image`
4. สร้างไฟล์ (เก็บผลไว้ใน `docs/`)
   ```bash
   cd templates/business-requirement
   ../.venv/bin/python build_br.py spec.py ../../docs/<ลูกค้า>-<โครงการ>-SRS_v1.0.0.docx
   ```
5. ตรวจ — ต้อง exit 0
   ```bash
   ../.venv/bin/python check_br.py <ไฟล์>.docx           # ร่าง: เหลือตัวแทนได้ แค่เตือน
   ../.venv/bin/python check_br.py <ไฟล์>.docx --final   # ฉบับส่งจริง: เหลือตัวแทน = ไม่ผ่าน
   ```
6. (ฉบับส่งจริง บน macOS ที่มี Word) ตรวจตารางล้นและการตัดคำจาก Word จริง
   ```bash
   zsh word_pdf.sh <ไฟล์>.docx ผล.pdf
   python3 check_word_overflow.py ผล.pdf                  # ต้องได้ overflow_pages 0
   ../.venv/bin/python check_word_midword.py ผล.pdf       # อ่านรายการคำที่ถูกตัดกลางคำ
   ```

## 3. Manhours ทำเอง (`manhours/`)

1. ก็อป `example_tasks.py` แล้วเขียน `SECTIONS` — `("1.1", "ชื่องาน", {SA: 16, SR: 16})`
   - **ทุกงานย่อยกระจายชั่วโมงตามตำแหน่งจริง** ไม่ใส่ยอดรวมช่องเดียว
   - `HT` Head of Technology · `SA` Solution Architect · `PM` Project Manager · `PO` Product Owner/AE ·
     `SR` Senior Dev · `MD` Mid Dev · `JR` Junior Dev
2. ใส่ `NOTES` — ขั้นที่ความมั่นใจต่ำ และสิ่งที่ยังไม่ได้เห็นของจริง
3. ดูยอด แล้วสร้าง
   ```bash
   cd templates/manhours
   ../.venv/bin/python example_tasks.py        # preview() พิมพ์ยอด แล้ว build() → EXAMPLE-Manhours.xlsx
   ```
4. **คำนวณสูตรและตรวจ error** — ต้องได้ `total_errors: 0` (exit 0) ก่อนส่ง
   ```bash
   ../.venv/bin/python recalc_check.py <ไฟล์>.xlsx
   ```
   คำนวณบนสำเนาด้วย LibreOffice ไฟล์จริงไม่ถูกแก้

**เรตต่อชั่วโมง** แก้ที่ `ROLES` ใน `build_manhours.py` ที่เดียว:
Head of Technology 2,500 · Solution Architect 2,500 · Senior Developer 1,500 · Mid Developer 1,000 ·
Project Manager 1,000 · Product Owner/AE 1,000 · Junior Developer 700

**รูปแบบที่ห้ามเปลี่ยน:** Calibri ทั้งไฟล์ · แถบหัว `#B4C6E7` · แถวหัวข้อ `#FFFF00` · แถวงาน `#E2EFD9` ·
คอลัมน์ D `#9CC2E5` ตัวหนังสือ `#0070C0` · คอลัมน์ E พื้นม่วง `#7030A0` ตัวหนังสือขาวหนา · เลขแบบบัญชี ·
ตรึงที่ `F5` · แถว 3 = เรต · แถว 4 = Hour/Cost · คอลัมน์ D/E เป็นสูตร ห้ามพิมพ์ทับ

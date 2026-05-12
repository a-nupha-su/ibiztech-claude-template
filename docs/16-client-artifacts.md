# 16 — Client Artifacts (เอกสารจากลูกค้า)
**[Project Name]**

| เวอร์ชัน | วันที่ |
|---------|-------|
| v1.0 | YYYY-MM-DD |

> เก็บ **เอกสาร/ไฟล์/ข้อมูลทุกชิ้น** ที่ลูกค้าส่งให้ — เป็น **source of truth** ก่อนแตกเป็น Research / FR / Task
> ทุก artifact ต้องถูก **analyze** ก่อนแปลงเป็น RR / FR / Task ใน 10/01/07

---

## ทำไมต้องมี

| ปัญหาที่เคยเจอ | วิธีแก้ |
|---------------|--------|
| ลูกค้าส่ง requirement กระจาย หลายช่อง (email, chat, PDF, meeting) | รวมไว้ที่เดียว — folder + index |
| ทำไปแล้วลูกค้าบอก "ของเดิมส่งไปแล้วนะ" | มี timestamp + received-from |
| Requirement ฝังใน slide / Excel ที่หา target task ไม่เจอ | analyze + link → FR/Task ทันที |
| เปลี่ยน scope กลางทาง — หา reference ของเดิมไม่เจอ | artifact ห้ามลบ (archive เท่านั้น) |
| Audit ที่มาของ feature | trail: CA → RR → FR → Task → FB |

---

## Folder Layout

```
docs/
├── 16-client-artifacts.md        ← ไฟล์นี้ (index + analysis)
└── client-artifacts/             ← raw files (PDF/docx/png/xlsx/md)
    ├── 2026-05-13/               ← group by received date (YYYY-MM-DD)
    │   ├── CA-001-requirements-v1.pdf
    │   ├── CA-002-existing-flow.png
    │   └── CA-003-brand-guide.pdf
    ├── 2026-05-20/
    │   ├── CA-004-meeting-notes-kickoff.md
    │   └── CA-005-data-sample.xlsx
    └── meetings/                 ← transcripts / minutes (optional sub-folder)
        └── 2026-05-13-kickoff.md
```

> **Naming raw file:** `CA-{NNN}-{slug}.{ext}` เช่น `CA-001-requirements-v1.pdf`

---

## CA Code Convention

```
CA-{NNN}-{YYYYMMDD}
```

| ส่วน | ความหมาย | ตัวอย่าง |
|------|---------|---------|
| `CA` | Client Artifact (คงที่) | `CA` |
| `NNN` | running 3 หลัก (auto-increment ทั้งโปรเจกต์) | `001` |
| `YYYYMMDD` | วันที่ **ลูกค้าส่ง** (ไม่ใช่วันที่เรา upload) | `20260513` |

ตัวอย่าง: `CA-001-20260513` = artifact ชิ้นแรก ได้รับวันที่ 13 พ.ค. 2026

> 1 ไฟล์ที่ลูกค้าส่ง = 1 CA · ถ้าได้รับเป็น zip ที่มีหลายไฟล์ → 1 CA ต่อ 1 ไฟล์

---

## Status Lifecycle

| Status | ความหมาย | ต่อไปทำอะไร |
|--------|---------|-----------|
| `RECEIVED` | เพิ่งได้รับ — ยังไม่เปิดอ่าน | นัดอ่าน |
| `ANALYZING` | กำลังอ่าน/วิเคราะห์ | เติม Analysis section |
| `ANALYZED` | วิเคราะห์เสร็จ — รู้ว่าต้องสร้าง RR/FR/Task อะไรบ้าง | สร้าง outcome |
| `ACTIONED` | สร้าง RR/FR/Task ครบแล้ว | track outcome → ship |
| `OBSOLETE` | ล้าสมัยแล้ว ลูกค้าส่ง version ใหม่ | mark + link CA ใหม่ |
| `ARCHIVED` | ปิดเรื่องแล้ว (โปรเจกต์จบ / scope ตัด) | เก็บไว้อ้างอิง |

---

## Security & Privacy

| รายการ | กฎ |
|--------|-----|
| ข้อมูลส่วนตัวลูกค้า (PII) | **mask ก่อน commit** (`███████` แทน email/เบอร์/เลขบัตร) |
| Contract / NDA / SOW | ถ้าระบุ confidential → ใส่ `.gitignore` + share private |
| Data sample จริง | **ห้าม commit** ถ้ามี PII — ใช้ synthetic data แทน |
| Brand asset / logo (proprietary) | ตรวจ license ก่อน commit — บางที่ห้าม redistribute |
| Password / token / secret ในเอกสาร | **redact ทันที** + แจ้งลูกค้าให้ rotate |

### .gitignore แนะนำ (ถ้ามี confidential)

```
# Client confidential — ไม่ commit
docs/client-artifacts/**/*.confidential.*
docs/client-artifacts/_private/
```

---

## Artifact Index

> เพิ่มแถวทุกครั้งที่ได้รับ artifact ใหม่ · ใช้ `scripts/new-artifact.sh`

| CA Code | Received | From | Type | File | Status | Linked Outcomes |
|---------|----------|------|------|------|--------|-----------------|
| _ตัวอย่าง_ CA-001-20260513 | 2026-05-13 | คุณ Somchai (PM ลูกค้า) | Requirements PDF | `client-artifacts/2026-05-13/CA-001-requirements-v1.pdf` | ACTIONED | FR-001..005 · RR-AUTH-001 |
| CA-002-20260513 | 2026-05-13 | คุณ Somchai | Mockup PNG | `client-artifacts/2026-05-13/CA-002-existing-flow.png` | ANALYZED | FR-002, LAYOUT-001 |
| CA-003-YYYYMMDD | YYYY-MM-DD | — | Meeting notes | `client-artifacts/.../CA-003-...md` | RECEIVED | — |

### Type categories
- `Requirements` — spec doc, RFP, user stories
- `Mockup / Design` — wireframe, Figma export, UI mockup
- `Data sample` — Excel, CSV, JSON
- `Meeting notes` — transcript, minutes
- `Email / Chat` — paste-in conversation
- `Process doc` — flowchart, SOP, business process
- `Brand / Asset` — logo, brand guide, font
- `Legal` — contract, SOW, NDA (handle carefully)
- `Existing system` — screenshots, exported config

---

# ╔══════════════════════════════════════════════════╗
# ║   ANALYSIS ENTRY TEMPLATE (copy block ไปใช้)     ║
# ╚══════════════════════════════════════════════════╝

## CA-XXX-NNN-YYYYMMDD — [Artifact Title]

### 1. Document Control

| Field | Value |
|-------|-------|
| CA Code | `CA-NNN-YYYYMMDD` |
| File Path | `docs/client-artifacts/YYYY-MM-DD/CA-NNN-{slug}.{ext}` |
| Type | Requirements / Mockup / Data / Meeting / ... |
| Status | `RECEIVED` / `ANALYZING` / `ANALYZED` / `ACTIONED` / `OBSOLETE` / `ARCHIVED` |
| Received Date | YYYY-MM-DD |
| Received From | [ชื่อ + role + channel — เช่น "คุณ Somchai, PM, email"] |
| Received Via | Email / LINE / Drive link / Meeting / Slack |
| Analyzed By | [ชื่อทีม] |
| Analyzed Date | YYYY-MM-DD |
| Confidentiality | `PUBLIC` / `INTERNAL` / `CONFIDENTIAL` (กระทบการ commit) |

### 2. Summary (1 ย่อหน้า)

> ลูกค้าส่งอะไรมา · เพื่ออะไร · ครอบคลุมเรื่องอะไร

ตัวอย่าง: "PDF 12 หน้า สรุป requirement สำหรับระบบ login + dashboard + module ขาย ส่งโดย PM ลูกค้า รวมถึง mockup ของหน้า login และตัวอย่างข้อมูล user role 3 ประเภท"

### 3. Explicit Requirements (สิ่งที่ลูกค้าบอกตรง ๆ)

| # | สิ่งที่ลูกค้าต้องการ | อยู่หน้า / section ใน artifact |
|---|---------------------|------------------------------|
| 1 | ผู้ใช้ login ด้วย email + password | หน้า 3 §2.1 |
| 2 | Admin จัดการ user ได้ทั้งหมด | หน้า 5 §3 |

### 4. Implicit / Hidden Requirements (อ่านระหว่างบรรทัด)

| # | สิ่งที่ implicit | ความเชื่อมโยง |
|---|----------------|-------------|
| 1 | ต้องมี audit log (เพราะลูกค้าพูดถึง compliance) | หน้า 7 mention ISO 27001 |
| 2 | ต้องรองรับภาษาไทย (เพราะ mockup เป็นไทย) | mockup ไทย 100% |

### 5. Open Questions (ต้องถามลูกค้ากลับ)

| # | คำถาม | สำคัญแค่ไหน | ถามใคร |
|---|-------|:----------:|--------|
| 1 | "Session timeout กี่นาที?" | สูง | คุณ Somchai |
| 2 | "ต้องการ MFA ไหม?" | กลาง | Tech lead ลูกค้า |

### 6. Conflicts / Inconsistencies

| ขัดกับอะไร | ที่ไหน | วิธีแก้ |
|-----------|-------|--------|
| Mockup login มี "Forgot Password" แต่ spec ไม่ระบุ | mockup p.2 vs spec §2.1 | ถามกลับ + อาจ research |

### 7. Action Items → Outcomes

| Type | Code ที่จะสร้าง | Owner | Status |
|------|--------------|-------|--------|
| Research | **RR-AUTH-001** — Session timeout strategy | @anu | [ ] |
| FR | **FR-001** — Login email/password | @pm | [ ] |
| FR | **FR-002** — Admin manage users | @pm | [ ] |
| Task (07) | **AUTH-002** — Login API | @dev1 | [ ] |
| Task (07) | **LAYOUT-001** — App shell | @dev2 | [ ] |
| Question to client | "Session timeout?" | @pm | [ ] |

> ทุก action ที่ทำเสร็จ → mark `[x]` + link RR/FR/Task code

### 8. Risks / Notes

- ⚠️ ลูกค้าระบุ deadline 2 เดือน — scope ใหญ่ ต้อง MVP first
- ⚠️ Mockup ใช้ font proprietary — ต้องถาม license

### 9. Sign-off (ก่อน Status = ACTIONED)

| Role | ชื่อ | วันที่ | OK? |
|------|------|-------|:---:|
| Analyzer (BA / PM) | _____________ | YYYY-MM-DD | ⬜ |
| Tech Lead | _____________ | YYYY-MM-DD | ⬜ |
| (ถ้า PII/confidential) Compliance | _____________ | YYYY-MM-DD | ⬜ |

### 10. Related Documents

| Type | Link |
|------|------|
| Research (จาก artifact นี้) | `10-value-research.md#RR-XXX` |
| Requirements (จาก artifact นี้) | `01-requirement.md#FR-001..005` |
| Tasks (จาก artifact นี้) | `07-implement-plan.md` (AUTH-001 ฯลฯ) |
| Replaced by (ถ้า OBSOLETE) | CA-XXX-YYYYMMDD |
| Replaces (ของเก่า) | CA-XXX-YYYYMMDD |

---

```
╔══════════════════════════════════════════════════╗
║   ANALYSIS ENTRY TEMPLATE ENDS HERE              ║
╚══════════════════════════════════════════════════╝
```

---

## Workflow Integration

```
ลูกค้าส่งเอกสาร (email / chat / drive / meeting)
        │
        ▼
1. บันทึก raw file → docs/client-artifacts/YYYY-MM-DD/
   bash scripts/new-artifact.sh "<TYPE>" "<FROM>" "<FILE_PATH>"
        │
        ▼
2. ระบบสร้าง CA-NNN-YYYYMMDD + Index row ใน 16
   Status: RECEIVED
        │
        ▼
3. Analyzer (BA/PM/Tech Lead) เปิดอ่าน → Status: ANALYZING
        │
        ▼
4. copy 'ANALYSIS ENTRY TEMPLATE' → กรอก Section 1-10
   - Explicit requirements
   - Implicit / Hidden
   - Open questions (ถามกลับลูกค้า)
   - Conflicts
   - Action items → RR/FR/Task
        │
        ▼
5. Sign-off → Status: ANALYZED
        │
        ▼
6. ทำตาม Section 7 (Action Items):
   - สร้าง RR ใน 10-value-research → APPROVED
   - เพิ่ม FR ใน 01-requirement
   - เพิ่ม task ใน 07-implement-plan (Phase R/0/1...)
   - เพิ่ม TC ใน 11-test-cases
        │
        ▼
7. ทุก action [x] → Status: ACTIONED
        │
        ▼
8. (เมื่อ feature ที่มาจาก CA นี้ ship แล้ว → ตรวจสอบ traceability)
   CA → RR → FR → Task → TR → FB ครบ trail ใน Section 10
```

---

## กฎสำคัญ

1. **ห้ามทำงานจาก artifact ที่ยังไม่ ANALYZED** — ทุก plan ต้อง trace กลับมาที่ CA หรือ internal decision
2. **OBSOLETE ห้ามลบ** — mark Status + link CA ใหม่ที่แทน (audit trail)
3. **PII / Secret → redact + ห้าม commit** raw
4. **Confidentiality ระบุชัด** — กระทบว่า commit ได้/ไม่ได้
5. **Sign-off ครบก่อน ACTIONED** — Analyzer + Tech Lead (+ Compliance ถ้าจำเป็น)
6. **Action items บังคับ link code** — RR-XXX / FR-XXX / AUTH-001 ฯลฯ ไม่ใช่ free text
7. **1 file = 1 CA** — แม้ลูกค้าส่ง zip ก็แตกเป็น CA ละไฟล์
8. **Naming:** raw file `CA-{NNN}-{slug}.{ext}` · ส่วน entry ใน .md ใช้ `CA-{NNN}-{YYYYMMDD}`

---

## Best Practices

### ก่อนเริ่มโปรเจกต์ใหม่
ทุก artifact ที่มีอยู่แล้ว → upload + analyze ครบ **ก่อน** เริ่ม Phase 0 (Setup)

### ระหว่างโปรเจกต์
ลูกค้าส่งเอกสารใหม่ระหว่าง dev → analyze ภายใน **24-48 ชม.** + ประเมิน scope impact ก่อน commit task ใน sprint ถัดไป

### หลังโปรเจกต์
Archive ทุก CA ก่อน hand-off (Status: `ARCHIVED`) + รวม folder zip ส่ง customer

---

## Changelog

| เวอร์ชัน | วันที่ | รายละเอียด |
|---------|-------|-----------|
| v1.0 | YYYY-MM-DD | สร้าง template |

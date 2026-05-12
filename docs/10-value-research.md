# 10 — Value Research
**[Project Name]**

| เวอร์ชัน | วันที่ |
|---------|-------|
| v1.0 | YYYY-MM-DD |

> **บังคับ** เมื่อ requirement ยังไม่ชัด: ทำ research ก่อน → user approve → ค่อยเข้า `01-requirement.md` + `07-implement-plan.md`
> ใช้ **10-Value Framework** ประเมินทุก option ก่อนตัดสินใจ
> Research ที่ยังไม่ APPROVED → ห้ามเขียนโค้ดบรรทัดแรก

---

## กฎ Source Quality (บังคับทุก Research)

> Research ที่ไม่มี source ครบ / source ไม่น่าเชื่อถือ / ข้อมูลเก่า → **ห้าม APPROVED**

### 1. ต้องมี source ขั้นต่ำต่อ option

| ระดับ | ต้องมีขั้นต่ำ | รวมต่อ option |
|------|---------------|--------------|
| Official docs / spec / RFC | ≥ 1 | **≥ 3 sources** |
| Reputable secondary (blog by maintainer, vendor docs, conference talk) | ≥ 1 | |
| Comparison / benchmark (independent) | ≥ 1 | |

### 2. Source Tier (เรียงจากน่าเชื่อถือสูง → ต่ำ)

| Tier | ประเภท | ตัวอย่าง |
|------|--------|---------|
| **T1** (ดีที่สุด) | Official spec / docs ของ maintainer | RFC, MDN, React docs, Prisma docs |
| **T2** | Academic / peer-reviewed / standard body | IEEE, ACM, ISO, OWASP |
| **T3** | Vendor official + conference talk | AWS docs, Vercel blog, KubeCon talk |
| **T4** | Reputable blog by recognized maintainer | core dev blog, GitHub maintainer post |
| **T5** | Community + benchmark (peer review ได้) | GitHub Discussions, dev.to, RisingStack |
| **T6** (ใช้ระวัง) | Random blog / Medium / Reddit | ใช้ประกอบ ห้ามเป็น source หลัก |
| **❌** | AI-generated โดยไม่ verify · forum opinion · marketing page | **ห้ามใช้** |

> Option ที่ recommended ต้องมี **≥ 1 T1 source** เสมอ

### 3. Recency (ข้อมูลล่าสุด)

| ประเภทข้อมูล | อายุสูงสุดที่ยอมรับ |
|--------------|--------------------|
| Library / framework version / API | ≤ **12 เดือน** |
| Performance benchmark | ≤ **18 เดือน** |
| Architecture pattern / best practice | ≤ **24 เดือน** |
| Foundational standard (RFC, ISO, math) | ไม่จำกัด แต่ check ว่ายัง active |
| Security / CVE | **≤ 6 เดือน** (เปลี่ยนเร็ว) |

ถ้าจำเป็นต้องใช้ source เก่า → ต้องระบุเหตุผล + ตรวจสอบว่ายังเป็นจริง

### 4. Source Metadata บังคับ (ทุก link)

ทุก reference ต้องระบุ 5 field:
- **URL** (full, https)
- **Title** (ตามที่ต้นทาง)
- **Author / Organization**
- **Publish date** (YYYY-MM-DD หรือ "last updated")
- **Tier** (T1-T6 ตามตารางด้านบน)

### 5. ขั้นตอนตรวจ source

```
[ ] เช็ค publish date — อยู่ในช่วง recency ที่ยอมรับไหม?
[ ] เช็ค author/org — เป็น maintainer/official/expert จริง?
[ ] เช็ค URL ไม่ broken
[ ] เช็คว่าไม่ใช่ AI hallucinate (มี URL จริง + content ตรงกับที่อ้าง)
[ ] cross-reference อย่างน้อย 2 sources บอกเรื่องเดียวกัน
```

---

## เมื่อไรต้องทำ Research

| สถานการณ์ | ต้อง research? |
|-----------|:--------------:|
| FR ใหม่ที่ stakeholder ยังลังเล / ขัดแย้ง | ✅ |
| เลือกระหว่าง 2+ approach (lib/architecture/UX pattern) | ✅ |
| ใช้ third-party API / SaaS ใหม่ที่ทีมไม่เคยใช้ | ✅ |
| ต้องเปลี่ยน DB schema สำคัญ | ✅ |
| Feature ที่ส่งผลกระทบหลายโมดูล (≥ 3) | ✅ |
| FR ชัดเจน + 1 option แน่นอน + ไม่กระทบ scope | ❌ |
| Bug fix / refactor เล็ก | ❌ |

---

## RR Code Convention

```
RR-{TOPIC}-{NNN}-{YYYYMMDD}
```

| ส่วน | ความหมาย | ตัวอย่าง |
|------|---------|---------|
| `RR` | Research Report (คงที่) | `RR` |
| `TOPIC` | หัวข้อย่อ (uppercase, 2-6 ตัว) | `AUTH`, `PAY`, `UPLOAD` |
| `NNN` | running 3 หลัก ใน topic นั้น | `001` |
| `YYYYMMDD` | วันที่เริ่ม research | `20260513` |

ตัวอย่าง: `RR-AUTH-001-20260513` (research เรื่อง auth, ครั้งที่ 1, เริ่ม 13 พ.ค. 2026)

---

## Status Lifecycle

| Status | ความหมาย | ต่อไปทำอะไร |
|--------|---------|-----------|
| `DRAFT` | กำลังเขียน | ทำ research ให้เสร็จ |
| `REVIEW` | เสร็จแล้ว รอ stakeholder review | นัด review |
| `APPROVED` | ✅ user approve — feed เข้า 01-requirement | สร้าง FR + task ใน 07 |
| `REJECTED` | ❌ ไม่ผ่าน — กลับไปแก้หรือเลิก | iterate หรือ archive |
| `SUPERSEDED` | ถูก research ใหม่แทนที่ | reference อันใหม่ |

---

## Research Index

> ตารางสรุปทุก research ของโปรเจกต์ — เพิ่มแถวทุกครั้งที่สร้างใหม่

| RR Code | Topic | Question | Owner | Status | Approved Option | Date |
|---------|-------|----------|-------|--------|-----------------|------|
| _ตัวอย่าง_ RR-AUTH-001-20260513 | Auth | JWT vs Session cookie | [name] | APPROVED | Option B (Session) | 2026-05-13 |
| RR-PAY-001-YYYYMMDD | Payment Gateway | Stripe vs Omise vs 2C2P | — | DRAFT | — | — |

---

## 10-Value Framework (เกณฑ์ประเมินทุก option)

| # | Value | คำถาม | น้ำหนัก |
|---|-------|-------|---------|
| 1 | **User Value** | ผู้ใช้ได้อะไร? ปัญหาใหญ่/เล็กแค่ไหน? | ⭐⭐⭐ |
| 2 | **Business Value** | ROI / revenue / cost saving? | ⭐⭐⭐ |
| 3 | **Strategic Fit** | สอดคล้องเป้าหมายบริษัท / vision? | ⭐⭐ |
| 4 | **Technical Feasibility** | Stack ปัจจุบันรองรับ? ทำได้จริงไหม? | ⭐⭐⭐ |
| 5 | **Effort / Cost** | เวลา · คน · เงิน? | ⭐⭐ |
| 6 | **Risk** | อะไรพังได้บ้าง? mitigation? | ⭐⭐⭐ |
| 7 | **Time-to-Market** | เร่งด่วนไหม? blocker อื่นรอ? | ⭐⭐ |
| 8 | **Scalability** | รองรับ growth 10x ได้? | ⭐⭐ |
| 9 | **Maintainability** | ดูแลระยะยาวยาก/ง่าย? lock-in? | ⭐⭐ |
| 10 | **Dependencies** | ติด team อื่น / vendor / approval? | ⭐⭐ |

ให้คะแนน 1-5 ต่อ value แล้วรวม (max 50) — ใช้เป็นข้อมูลประกอบ ไม่ใช่ตัดสินอัตโนมัติ

---

# ╔══════════════════════════════════════════════════════╗
# ║   RESEARCH ENTRY TEMPLATE (copy block ด้านล่างไปใช้)   ║
# ╚══════════════════════════════════════════════════════╝

## RR-XXX-NNN-YYYYMMDD — [Title]

### 1. Document Control

| Field | Value |
|-------|-------|
| RR Code | `RR-XXX-NNN-YYYYMMDD` |
| Topic | [เช่น Auth, Payment, Upload] |
| Status | `DRAFT` / `REVIEW` / `APPROVED` / `REJECTED` / `SUPERSEDED` |
| Owner | [ชื่อคนทำ research] |
| Stakeholders | [คนที่ต้อง approve] |
| Created | YYYY-MM-DD |
| Approved Date | YYYY-MM-DD (เติมเมื่อ APPROVED) |
| Approved By | [ชื่อ] |

### 2. Research Question

> เขียนคำถามหลักให้ชัดเจน — 1-2 ประโยค

ตัวอย่าง: "ระบบ authentication ควรใช้ JWT bearer หรือ session cookie? ภายใต้ข้อจำกัด: SSR + multi-device + ต้อง revoke session ได้"

### 3. Context / Background

- Pain ปัจจุบัน:
- Constraint ที่ต้องเคารพ:
- Stakeholder ที่กระทบ:
- Out of scope (research นี้ไม่ตอบ):

### 4. Options

#### Option A — [ชื่อ]
- **คือ:** [อธิบาย 2-3 บรรทัด]
- **Pros:**
- **Cons:**
- **ค่าใช้จ่าย/effort:** (คน-วัน / บาท / ระยะเวลา)
- **References** (ขั้นต่ำ 3 — มี T1 ≥ 1):

| Tier | Title | Author / Org | URL | Date |
|:----:|-------|--------------|-----|------|
| T1 | [Official docs title] | [maintainer] | https://... | YYYY-MM-DD |
| T3 | [Vendor blog title] | [vendor] | https://... | YYYY-MM-DD |
| T5 | [Benchmark / comparison] | [author] | https://... | YYYY-MM-DD |

#### Option B — [ชื่อ]
- **คือ:**
- **Pros:**
- **Cons:**
- **ค่าใช้จ่าย:**
- **References** (≥ 3, T1 ≥ 1):

| Tier | Title | Author / Org | URL | Date |
|:----:|-------|--------------|-----|------|
| T1 | | | | |
| | | | | |
| | | | | |

#### Option C — [ชื่อ] (ถ้ามี)
- ...

#### Source Verification Checklist (ทำก่อน submit REVIEW)

- [ ] ทุก option มี references ≥ 3
- [ ] ทุก option มี T1 source ≥ 1
- [ ] ทุก source มี publish date และอยู่ในช่วง recency ที่ยอมรับ
- [ ] ทุก URL เปิดได้จริง (ไม่ broken / paywall blocking)
- [ ] cross-referenced ≥ 2 sources บอกตรงกัน (ไม่ใช่ใช้แหล่งเดียว)
- [ ] ไม่มี AI-generated content ที่ไม่ verify
- [ ] (Security topic) source อายุ ≤ 6 เดือน

### 5. 10-Value Scorecard

| # | Value | Option A | Option B | Option C |
|---|-------|:--------:|:--------:|:--------:|
| 1 | User Value | _/5 | _/5 | _/5 |
| 2 | Business Value | _/5 | _/5 | _/5 |
| 3 | Strategic Fit | _/5 | _/5 | _/5 |
| 4 | Technical Feasibility | _/5 | _/5 | _/5 |
| 5 | Effort / Cost (5=ถูก/เร็ว) | _/5 | _/5 | _/5 |
| 6 | Risk (5=ความเสี่ยงต่ำ) | _/5 | _/5 | _/5 |
| 7 | Time-to-Market | _/5 | _/5 | _/5 |
| 8 | Scalability | _/5 | _/5 | _/5 |
| 9 | Maintainability | _/5 | _/5 | _/5 |
| 10 | Dependencies (5=น้อย) | _/5 | _/5 | _/5 |
| **รวม** | | **_/50** | **_/50** | **_/50** |

### 6. Risk Analysis (Option ที่เด่น)

| ความเสี่ยง | โอกาส | ผลกระทบ | Mitigation |
|-----------|------|---------|-----------|
| | | | |

### 7. Recommendation

> 2-3 ประโยคชัดเจน — "เลือก Option X เพราะ ..."

**ตัวเลือก recommend:** Option [A/B/C]
**เหตุผลหลัก:**
1.
2.
3.

### 8. Decision Outcomes (ถ้า APPROVED → ส่งเข้า requirement/plan)

- FR ที่ต้องเพิ่มใน `01-requirement.md`:
- Task code ใน `07-implement-plan.md`:
- Doc อื่นที่ต้องอัพเดต: (เช่น 03-tech-stack, 04-db-schema, 05-api-spec)
- TC ใน `11-test-cases.md` ที่ต้องสร้าง:

### 9. Sign-off

| Role | ชื่อ | วันที่ | Approve? |
|------|------|-------|:--------:|
| Owner / Researcher | _____________ | YYYY-MM-DD | ✅ submit |
| Tech Lead | _____________ | YYYY-MM-DD | ⬜ |
| PM / Stakeholder | _____________ | YYYY-MM-DD | ⬜ |
| User / Customer | _____________ | YYYY-MM-DD | ⬜ |

> APPROVED ต้องผ่าน "User / Customer" + อย่างน้อย 1 ใน Tech Lead/PM

### 10. Appendix

- **Consolidated References** (รวมทุก option + ranking):

| # | Tier | Title | URL | Date | Used in Option(s) |
|---|:----:|-------|-----|------|-------------------|
| 1 | T1 | | | YYYY-MM-DD | A, B |
| 2 | T2 | | | YYYY-MM-DD | A |

- Test / POC code (ถ้ามี): [link repo / PR]
- Related research: RR-XXX (link)
- Date / data freshness notes:
  - Last verified URLs valid: YYYY-MM-DD
  - Oldest source used: YYYY-MM-DD (เหตุผล: ...)

---

## กฎสำคัญ

1. **ไม่ผ่าน APPROVED → ห้ามเขียนโค้ด** — เป็น quality gate ก่อน Phase 0 (Setup)
2. **ทุก option ต้องมี 10-Value Scorecard** — แม้มี option เดียวก็ต้อง score
3. **REJECTED ห้ามลบ** — เก็บไว้เป็น decision history (mark Status, ใส่เหตุผล)
4. **APPROVED แล้วเปลี่ยน scope?** → สร้าง RR ใหม่ (mark RR เก่าเป็น SUPERSEDED)
5. **References บังคับ ≥ 3/option + T1 ≥ 1** (ดู Source Quality ด้านบน) — ผ่าน Source Verification Checklist ก่อน submit
6. **Source ต้องล่าสุด** ตามตาราง Recency (lib ≤ 12mo · arch ≤ 24mo · security ≤ 6mo)
7. **Effort / Cost ใส่ตัวเลข** — ห้าม "small/medium/large" เท่านั้น — บอก คน-วัน หรือ บาท
8. **ห้าม AI-generated source ที่ไม่ verify** — ทุก URL ต้องเปิดได้จริง + content ตรงกับที่อ้าง

---

## Workflow Integration

```
[Unclear Requirement]
        │
        ▼
สร้าง RR-XXX-NNN ใน 10-value-research.md (Status: DRAFT)
        │
        ▼
   เติม Section 1-7 (Question, Options, Scorecard, Recommendation)
        │
        ▼
Status: REVIEW → ส่งให้ stakeholders ดู
        │
        ├─→ REJECTED → ปรับ option / scope / กลับไป DRAFT
        │
        └─→ APPROVED (sign-off ครบ)
              │
              ▼
        Decision Outcomes (Section 8):
        • เพิ่ม FR ใน 01-requirement.md
        • เพิ่ม task ใน 07-implement-plan.md (พร้อม Wave/Model/Agent)
        • อัพเดต doc 03/04/05/06 ถ้ามีผลกระทบ
        • สร้าง TC ใน 11-test-cases.md
              │
              ▼
        Phase 0 (Setup) → ทำตาม 07
```

---

## Changelog

| เวอร์ชัน | วันที่ | รายละเอียด |
|---------|-------|-----------|
| v1.0 | YYYY-MM-DD | สร้าง template (10-Value Framework) |

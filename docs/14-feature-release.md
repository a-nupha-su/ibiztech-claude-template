# 14 — Feature Release & Brief
**[Project Name]**

| เวอร์ชัน | วันที่ |
|---------|-------|
| v1.0 | YYYY-MM-DD |

> **บังคับ**: ทุก feature ที่ implement เสร็จ (mark `[x]` ใน 07) ต้องมี **Feature Brief** ที่นี่
> ใช้เป็น **เอกสารนำเสนอ stakeholder / user / sales** — เขียนภาษาผู้ใช้ ไม่ใช่ tech-jargon
> เมื่อถึงเวลา release → compile หลาย FB เป็น Release Notes (Section: Release Compilation)

---

## วัตถุประสงค์

| สำหรับใคร | ใช้ทำอะไร |
|----------|----------|
| Stakeholder / Owner | ดูว่า sprint นี้ส่งอะไร · impact วัดได้แค่ไหน |
| Sales / Marketing | เอาไปทำ slide / one-pager / social post |
| User / Customer | release notes / what's new |
| Internal team | onboarding คนใหม่ · context สำหรับ bug fix |
| ตัว AI Claude | search feature เก่าก่อนทำ feature ใหม่ที่อาจ overlap |

---

## FB Code Convention

```
FB-{MODULE}-{NNN}-{YYYYMMDD}
```

| ส่วน | ความหมาย | ตัวอย่าง |
|------|---------|---------|
| `FB` | Feature Brief (คงที่) | `FB` |
| `MODULE` | task module prefix | `AUTH`, `A`, `LAYOUT` |
| `NNN` | running 3 หลัก ใน module | `001` |
| `YYYYMMDD` | วันที่ release feature นี้ | `20260513` |

ตัวอย่าง: `FB-AUTH-001-20260513`

> 1 feature = 1 FB · ถ้า feature ปรับใหญ่ → FB ใหม่ (เก่า mark `SUPERSEDED`)

---

## Status Lifecycle

| Status | ความหมาย |
|--------|---------|
| `DRAFT` | feature เสร็จแล้ว — กำลังเขียน brief |
| `READY` | brief สมบูรณ์ — รอ release |
| `SHIPPED` | release แล้ว (อยู่ใน production) |
| `SUPERSEDED` | ถูก feature ใหม่แทน |
| `DEPRECATED` | ปลดออกจาก product แล้ว |

---

## Feature Index (สรุปทุก FB)

> เพิ่มแถวทุกครั้งที่ feature เสร็จ + mark `[x]` ใน 07

| FB Code | Feature | Module | Tasks | Status | Released | Version | Owner |
|---------|---------|--------|-------|--------|----------|---------|-------|
| _ตัวอย่าง_ FB-AUTH-001-20260513 | Email/Password Login | AUTH | AUTH-002, AUTH-005, AUTH-006 | SHIPPED | 2026-05-13 | v1.0.0 | [name] |
| FB-LAYOUT-001-YYYYMMDD | Dark Mode | LAYOUT | LAYOUT-004 | READY | — | — | — |

---

# ╔══════════════════════════════════════════════════════╗
# ║  FEATURE BRIEF TEMPLATE (copy block ด้านล่าง)         ║
# ╚══════════════════════════════════════════════════════╝

## FB-XXX-NNN-YYYYMMDD — [Feature Title (ภาษาผู้ใช้)]

### 1. Document Control

| Field | Value |
|-------|-------|
| FB Code | `FB-XXX-NNN-YYYYMMDD` |
| Feature Title | [ชื่อสั้น เข้าใจง่าย — ไม่ใช่ task code] |
| Module | AUTH / A / LAYOUT / ... |
| Linked Tasks | AUTH-002, AUTH-005 (จาก 07-implement-plan) |
| Linked Research | RR-AUTH-001-... (ถ้ามี) |
| Status | `DRAFT` / `READY` / `SHIPPED` / `SUPERSEDED` / `DEPRECATED` |
| Released Date | YYYY-MM-DD |
| Release Version | v1.0.0 |
| Owner | [ชื่อ — คนรับผิดชอบ feature] |

---

### 2. One-Line Pitch (≤ 100 ตัวอักษร)

> เขียน 1 ประโยคที่บอกได้ทันทีว่า feature นี้ทำอะไร — เอาไปขึ้น slide ได้เลย

ตัวอย่าง: "ระบบ login ด้วย email/password พร้อม session ที่ revoke ได้ทุก device"

---

### 3. The Problem (ปัญหาที่เคยมี)

> 2-3 ประโยค — เขียนจากมุมมอง user ไม่ใช่ developer

- ก่อนหน้านี้ ผู้ใช้ ___________________
- ทำให้เกิด pain: ___________________ (ใช้เวลานาน / สับสน / ทำผิดบ่อย / ฯลฯ)
- กระทบ ~ X% ของผู้ใช้ทั้งหมด / วันละ Y ครั้ง

---

### 4. The Solution (สิ่งที่เราทำ)

> 3-5 ประโยค — บอกว่า feature นี้แก้ปัญหายังไง · ใช้ภาษาผู้ใช้

- ผู้ใช้สามารถ ___________________
- ระบบจะ ___________________ อัตโนมัติ
- เพิ่มความสามารถ ___________________

---

### 5. Who Benefits (กลุ่มผู้ได้ประโยชน์)

| กลุ่ม | ประโยชน์หลัก |
|------|-------------|
| Admin | [เช่น จัดการ user ได้เร็วขึ้น 3x] |
| User ทั่วไป | [เช่น เข้าระบบได้ทุก device ไม่ต้อง re-login] |
| Viewer | [ถ้ามี] |

---

### 6. User Benefit (เน้นคุณค่า — เขียนเป็น bullet ที่เอาไป slide ได้)

- ✅ ___________________
- ✅ ___________________
- ✅ ___________________

> หลีกเลี่ยง tech term เช่น "JWT" / "Prisma" / "Zod" — แทนด้วย "เข้าสู่ระบบ" / "บันทึก" / "ตรวจ input"

---

### 7. Impact / Metrics

> ใส่ตัวเลขถ้าได้ · ใส่ baseline ก่อนเปรียบเทียบ

| Metric | Before | After | Δ |
|--------|--------|-------|---|
| เวลา onboarding user ใหม่ | 5 นาที | 30 วินาที | **-90%** |
| Error rate login | 12% | 1.5% | **-87%** |
| Support ticket / สัปดาห์ | 20 | 3 | **-85%** |
| Mobile session duration | 4 นาที | 18 นาที | **+350%** |

> ถ้ายังไม่มีข้อมูล → ระบุ "Metric ที่จะวัดหลัง ship" + นัดวัดเมื่อไร

---

### 8. Screenshots / Demo

> ใส่รูปจาก test-reports ได้เลย หรือถ่ายใหม่ที่สวยกว่า

| ภาพ | คำอธิบาย |
|-----|---------|
| `docs/feature-assets/FB-XXX-NNN/01-before.png` | สภาพก่อน (ถ้ามี) |
| `docs/feature-assets/FB-XXX-NNN/02-after-desktop.png` | หน้าใหม่ desktop |
| `docs/feature-assets/FB-XXX-NNN/03-after-mobile.png` | หน้าใหม่ mobile |
| Demo URL | https://[staging-or-prod] |
| Loom / video | https://... (optional) |

---

### 9. How to Use (สั้น ๆ สำหรับ user)

> 3-5 step ภาษาผู้ใช้

1. เข้า [URL หรือเมนู]
2. กด ___________________
3. กรอก ___________________
4. ระบบจะ ___________________

---

### 10. Technical Summary (1 ย่อหน้า · สำหรับ dev ที่จะ maintain)

> เขียนสั้น — รายละเอียดเต็มอยู่ใน 02/03/04/05

- Stack ที่เพิ่ม: [เช่น next-auth, bcryptjs]
- Endpoint ใหม่: `POST /api/auth/login`, `POST /api/auth/logout`
- DB schema เปลี่ยน: `+ User.email_verified_at`
- Migration: `20260513_add_email_verified`
- Config / env ใหม่: `NEXTAUTH_SECRET`

---

### 11. Known Limitations (กล้าบอก)

- ⚠️ ___________________ (เช่น ยังไม่รองรับ social login)
- ⚠️ ___________________
- จะแก้ใน: FB-XXX-NNN-XXX (ถ้ามีแผน) หรือ "TBD"

---

### 12. Related Documents

| Type | Link |
|------|------|
| Research (ถ้ามี) | `docs/10-value-research.md#RR-XXX-...` |
| Requirements | `docs/01-requirement.md#FR-XXX` |
| Tasks | `docs/07-implement-plan.md` (AUTH-002 ฯลฯ) |
| Test Cases | `docs/11-test-cases.md#TC-AUTH-001, TC-AUTH-002` |
| Test Reports | `docs/test-reports/TR-AUTH-001-YYYYMMDD.md` |
| Issues (ถ้ามี) | `docs/12-log-issues.md#ISS-XXX` |
| PR / Commit | [link] |

---

### 13. Sign-off (ก่อน Status = SHIPPED)

| Role | ชื่อ | วันที่ | OK? |
|------|------|-------|:---:|
| Owner | _____________ | YYYY-MM-DD | ⬜ |
| QA / Tester | _____________ | YYYY-MM-DD | ⬜ |
| PM / Stakeholder | _____________ | YYYY-MM-DD | ⬜ |
| (Optional) Marketing | _____________ | YYYY-MM-DD | ⬜ |

> SHIPPED ต้องผ่าน Owner + QA + PM

---

### Document Changelog

| เวอร์ชัน | วันที่ | ผู้แก้ | รายละเอียด |
|---------|-------|------|-----------|
| v1.0 | YYYY-MM-DD HH:MM | [name] | สร้าง FB |

```
╔══════════════════════════════════════════════════════╗
║   FEATURE BRIEF TEMPLATE ENDS HERE                    ║
╚══════════════════════════════════════════════════════╝
```

---

# Product Roadmap (Long-term)

> ภาพรวม release ในอนาคต — ใช้คุย stakeholder + ทีมขาย
> ทุก release ต้อง link FB ที่อยู่ในนั้น (filled เมื่อ feature READY/SHIPPED)

| Release | Target Date | Status | Theme | Features (FB) | KPI หลัก |
|---------|------------|:------:|-------|--------------|---------|
| _ตัวอย่าง_ v1.0.0 | 2026-06-30 | 🟢 ON TRACK | Foundation | FB-AUTH-001, FB-LAYOUT-001 | TTM ≤ 60 วัน |
| v1.1.0 | 2026-08-15 | 🟡 AT RISK | Payments | FB-PAY-001, FB-PAY-002 | Conversion +20% |
| v2.0.0 | 2026-12-01 | ⚪ PLANNED | Multi-tenant | FB-TEN-001, FB-TEN-002 | New segment B2B |
| v2.1.0 | TBD | ⚪ IDEA | AI Assistant | (TBD) | DAU +30% |

> **Status icons:** 🟢 ON TRACK · 🟡 AT RISK · 🔴 BLOCKED · ⚪ PLANNED/IDEA

### Roadmap Rules

1. **Quarter granularity** สำหรับ release ปลายปี — month สำหรับ next 2 release
2. **KPI หลัก** บังคับมี — ไม่งั้นวัด success ไม่ได้
3. **Status update ทุก sprint review** (ใน 15-sprint.md)
4. **เลื่อน release > 2 สัปดาห์** = ต้อง update stakeholder + log เหตุผล

---

# Release Compilation (Group ตามเวอร์ชัน)

> เมื่อ ship release → compile FB ที่อยู่ในช่วงนั้นเป็น release notes

## v1.0.0 — YYYY-MM-DD

**Theme:** [เช่น "Foundation Release — Authentication & Dashboard"]

### Features
- **FB-AUTH-001** Email/Password Login — _one-line pitch_
- **FB-LAYOUT-001** Dark Mode — _one-line pitch_

### Impact Highlights
- ⏱️ Onboarding เร็วขึ้น 90%
- 📉 Support tickets ลด 85%

### Known Issues
- (จาก 12-log-issues.md severity ≥ Medium ที่ยังไม่ปิด)

### Migration / Breaking Changes
- ต้อง re-login ทุก user (session ใหม่)

---

## Export → Slide / PDF / Word

```bash
# Export FB เดี่ยว → .docx (ส่ง stakeholder)
pandoc -f markdown -t docx \
  --extract-media=docs/feature-assets/FB-AUTH-001-20260513 \
  -o FB-AUTH-001-20260513.docx \
  <(awk '/^## FB-AUTH-001-20260513/,/^## FB-/' docs/14-feature-release.md | sed '$d')

# Export Release Compilation v1.0.0 → .pdf
pandoc -f markdown -t pdf \
  -o release-v1.0.0.pdf \
  <(awk '/^## v1.0.0/,/^## v[0-9]/' docs/14-feature-release.md | sed '$d')

# Export ทุก FB → .pptx (สำหรับ slide deck)
pandoc -f markdown -t pptx -o all-features.pptx docs/14-feature-release.md
```

---

## กฎสำคัญ

1. **Feature เสร็จ (mark [x] ใน 07) → ต้องมี FB ภายใน 24 ชม.** — ไม่งั้น ถือว่า feature ยังไม่ปิด
2. **เขียนเป็นภาษาผู้ใช้** ใน Section 2-9 — tech detail อยู่ Section 10 เท่านั้น
3. **Impact ต้องมีตัวเลข** — ห้าม "ดีขึ้นมาก" — ใส่ baseline + after
4. **Screenshots บังคับ ≥ 2 ภาพ** (desktop + mobile ถ้ามี UI)
5. **Linked Tasks ต้องครบ** — ทุก task code ที่ contribute feature นี้
6. **SHIPPED ต้องผ่าน sign-off** Owner + QA + PM
7. **Limitations กล้าบอก** — Section 11 ห้ามว่าง (เขียน "ไม่มีข้อจำกัดที่ทราบ" ก็ได้)
8. **ห้ามลบ FB เก่า** — feature ถูกแทนที่ → mark `SUPERSEDED` + link FB ใหม่

---

## Workflow Integration

```
Task [x] ใน 07-implement-plan.md
        │
        ▼
bash scripts/new-feature-brief.sh AUTH-002 "Email/Password Login"
        │
        ▼
สร้าง FB entry ใน 14-feature-release.md (Status: DRAFT)
        │
        ▼
กรอก Section 2-12 (Pitch · Problem · Solution · Benefit · Impact · Screenshots · ...)
        │
        ▼
Status: READY → รอ release
        │
        ▼
release ship → Status: SHIPPED + เพิ่มใน Release Compilation
        │
        ▼
(เมื่อจำเป็น) pandoc → .docx / .pdf / .pptx สำหรับนำเสนอ
```

---

## Changelog

| เวอร์ชัน | วันที่ | รายละเอียด |
|---------|-------|-----------|
| v1.0 | YYYY-MM-DD | สร้าง template |

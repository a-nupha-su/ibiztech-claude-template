# 11 — Test Case Catalog
**[Project Name]**

| เวอร์ชัน | วันที่ |
|---------|-------|
| v1.0 | YYYY-MM-DD |

> **ลิสต์ test case ทั้งหมดของโปรเจกต์** — AI ไล่ตามลิสต์นี้ตอนทดสอบ
> ความสัมพันธ์ของไฟล์ test:
> - **`11-test-cases.md` (ไฟล์นี้)** = catalog ของ test case (re-usable spec) ← ไล่ตามนี้
> - **`docs/09-testing.md (Section 6)`** = master form (copy ไปใช้)
> - **`docs/test-reports/{TR-XXX}.md`** = report เฉพาะ session (ผลการ run)
> - **`13-testcase-log.md`** = log สรุป 1 บรรทัด/case + ผูก TR

---

## วิธีใช้ (สำหรับ AI)

```
ก่อนทดสอบ task
   1. อ่านไฟล์นี้หา TC ที่ผูกกับ task code (เช่น AUTH-001 → TC-AUTH-001, TC-AUTH-002 ...)
   2. ถ้ายังไม่มี TC → เพิ่มลงในไฟล์นี้ก่อน (กรอกครบทุก field)
   3. ดู "Issue History" ของ TC นั้น — มีปัญหาเดิมไหม จะได้ไม่ทำผิดซ้ำ

ตอนทดสอบ
   4. ทำตาม Steps ใน TC แต่ละข้อ → ใช้ MCP Playwright (ดู 09-testing.md)
   5. capture screenshot ทุก step สำคัญ

หลังทดสอบ
   6. copy test-report-form.md → docs/test-reports/{TR-XXX}.md กรอกผลละเอียด
   7. กลับมาอัพเดต TC ในไฟล์นี้:
      - Last Run = YYYY-MM-DD HH:MM
      - Last Result = ✅ / ❌ / ⏸
      - Last Report = TR-XXX-NNN-YYYYMMDD
      - ถ้าเจอ bug → เพิ่มแถวใน "Issue History" ของ TC พร้อม ISS-XXX
   8. log สรุปใน 13-testcase-log.md
```

---

## TC Code Convention

```
TC-{MODULE}-{NNN}
```

| ส่วน | ความหมาย | ตัวอย่าง |
|------|---------|---------|
| `TC` | Test Case (คงที่) | `TC` |
| `MODULE` | module prefix (ตรงกับ task) | `AUTH`, `A`, `LAYOUT`, `QA` |
| `NNN` | running 3 หลัก ใน module | `001`, `002`, `015` |

ตัวอย่าง: `TC-AUTH-001`, `TC-A-003`, `TC-LAYOUT-007`

> 1 task อาจมีหลาย TC (เช่น `AUTH-002 login` มี `TC-AUTH-001 happy path`, `TC-AUTH-002 wrong password`, `TC-AUTH-003 no body` ...)

---

## Test Case Index (catalog หลัก)

> ตารางสรุปสำหรับ grep / scan เร็ว — รายละเอียดเต็มแต่ละ TC อยู่ section ถัดไป

| TC | Title | Module | Task | Type | Priority | Status | Last Run | Last Result | Last Report |
|----|-------|--------|------|------|----------|--------|----------|-------------|-------------|
| TC-AUTH-001 | Login happy path (valid email + password) | AUTH | AUTH-002 | Smoke + E2E | P0 | ACTIVE | YYYY-MM-DD | ✅ | TR-AUTH-001-YYYYMMDD |
| TC-AUTH-002 | Login wrong password | AUTH | AUTH-002 | Smoke | P0 | ACTIVE | — | ⬜ | — |
| TC-AUTH-003 | Login no body / missing field | AUTH | AUTH-002 | Smoke | P1 | ACTIVE | — | ⬜ | — |
| TC-AUTH-004 | Login form responsive mobile 375 | AUTH | AUTH-005 | Browser | P1 | ACTIVE | — | ⬜ | — |
| TC-AUTH-005 | Logout invalidate session | AUTH | AUTH-003 | Smoke + E2E | P0 | ACTIVE | — | ⬜ | — |
| TC-LAYOUT-001 | Sidebar collapse desktop | LAYOUT | LAYOUT-002 | Browser | P2 | ACTIVE | — | ⬜ | — |
| TC-LAYOUT-002 | Sidebar drawer close on overlay tap (mobile) | LAYOUT | LAYOUT-002 | Browser | P0 | ACTIVE | — | ❌ | TR-LAYOUT-002-YYYYMMDD |

> **Status**: `ACTIVE` (ใช้อยู่) / `DEPRECATED` (เลิกใช้) / `BLOCKED` (รอ dependency)
> **Priority**: `P0` (critical, ต้องผ่านทุก deploy) / `P1` (สำคัญ) / `P2` (เสริม)
> **Last Result**: ✅ pass / ❌ fail / ⏸ blocked / ⬜ ยังไม่ได้ run

---

# ── รายละเอียด Test Case ──

## TC-AUTH-001 — Login happy path

| Field | Value |
|-------|-------|
| Title | Login happy path (valid email + password) |
| Module | AUTH |
| Linked Task | AUTH-002 (Login API), AUTH-005 (Login UI) |
| Type | Smoke + E2E Local |
| Priority | P0 |
| Status | ACTIVE |
| Created | YYYY-MM-DD |
| Last Updated | YYYY-MM-DD |

### Pre-conditions
- Server running `localhost:3000` (Fullstack) / `localhost:3001` (Separated API)
- Seed admin user มีอยู่: `admin@test.local` / `Test1234!`
- DB อยู่ใน state ปกติ

### Steps
1. `browser_navigate` → `/login`
2. `browser_resize` → 1440×900
3. `browser_snapshot` → assert: เห็น form (email, password, submit)
4. `browser_type` email = `admin@test.local`
5. `browser_type` password = `Test1234!`
6. `browser_click` submit
7. `browser_network_requests` → assert: `POST /api/auth/login` status 200, มี `data.token`
8. `browser_snapshot` → assert: redirect ไป `/dashboard`, มี toast "เข้าสู่ระบบสำเร็จ"
9. `browser_console_messages` → assert: ไม่มี error

### Expected
- Status code 200 จาก login API
- Token เก็บใน httpOnly cookie (Fullstack: NextAuth session / Separated: JWT)
- Redirect ไป `/dashboard` ภายใน 2s
- ไม่มี console error

### Test Data
- valid email: `admin@test.local`
- valid password: `Test1234!`

### Issue History
| Date | Report | Result | ISS | Note |
|------|--------|--------|-----|------|
| YYYY-MM-DD | TR-AUTH-001-YYYYMMDD | ✅ | — | first pass |

---

## TC-AUTH-002 — Login wrong password

| Field | Value |
|-------|-------|
| Title | Login wrong password → 401 |
| Module | AUTH |
| Linked Task | AUTH-002 |
| Type | Smoke |
| Priority | P0 |
| Status | ACTIVE |

### Pre-conditions
- เหมือน TC-AUTH-001

### Steps
1. `curl -X POST /api/auth/login` body `{ email: 'admin@test.local', password: 'WRONG' }`
2. capture response status + body

### Expected
- HTTP 401
- body: `{ statusCode: 401, message: 'Invalid credentials' }` (generic, ห้าม leak "user not found")

### Issue History
| Date | Report | Result | ISS | Note |
|------|--------|--------|-----|------|
| — | — | ⬜ | — | ยังไม่ได้ run |

---

## TC-LAYOUT-002 — Sidebar drawer close on overlay tap

| Field | Value |
|-------|-------|
| Title | Mobile sidebar drawer ปิดเมื่อแตะ overlay |
| Module | LAYOUT |
| Linked Task | LAYOUT-002 |
| Type | E2E |
| Priority | P0 |
| Status | ACTIVE |

### Pre-conditions
- เข้าสู่ระบบแล้ว (session valid)
- Viewport 375×667

### Steps
1. `browser_navigate` → `/dashboard`
2. `browser_resize` → 375×667
3. `browser_click` hamburger icon (เปิด sidebar)
4. `browser_snapshot` → assert: sidebar เปิด + overlay มา
5. `browser_click` overlay (จุดนอก sidebar)
6. `browser_snapshot` → assert: sidebar ปิด + overlay หาย

### Expected
- Sidebar slide-out ลื่น
- overlay tap → drawer ปิดทันที (ภายใน 300ms)

### Issue History
| Date | Report | Result | ISS | Note |
|------|--------|--------|-----|------|
| YYYY-MM-DD | TR-LAYOUT-002-YYYYMMDD | ❌ | ISS-005 | overlay click event ไม่ fire |
| YYYY-MM-DD | TR-LAYOUT-002-YYYYMMDD+1 | ✅ | — | fix แล้วใน commit a3f2bcd |

---

# ── Templates ──

## TC ใหม่ — copy block นี้

```markdown
## TC-XXX-NNN — [Title]

| Field | Value |
|-------|-------|
| Title | [ชื่อ test case 1 ประโยค] |
| Module | XXX |
| Linked Task | XXX-NNN |
| Type | Unit / Smoke / E2E Local / E2E Prod |
| Priority | P0 / P1 / P2 |
| Status | ACTIVE |
| Created | YYYY-MM-DD |
| Last Updated | YYYY-MM-DD |

### Pre-conditions
- [...]

### Steps
1. [...]
2. [...]

### Expected
- [...]

### Test Data
- [...]

### Issue History
| Date | Report | Result | ISS | Note |
|------|--------|--------|-----|------|
| — | — | ⬜ | — | ยังไม่ได้ run |
```

---

# ── กฎสำคัญ ──

1. **AI ต้องไล่ตามลิสต์นี้** — ห้าม improvise test ใหม่โดยไม่บันทึก TC ก่อน
2. **เจอ bug → เพิ่มใน Issue History ของ TC นั้น** + อ้างอิง `12-log-issues.md#ISS-XXX`
3. **TC เดิม fail ซ้ำ** → ดู Issue History ก่อน fix — อาจเป็น regression
4. **เพิ่ม TC** เมื่อ:
   - มี task ใหม่ใน `07-implement-plan.md`
   - เจอ bug ที่ไม่มี TC ครอบ → สร้าง TC สำหรับ regression test
   - PM/QA ขอเพิ่ม edge case
5. **เลิกใช้ TC** → mark `Status: DEPRECATED` (อย่าลบ — เก็บ history) + เขียนเหตุผล
6. **Priority P0** ทุกตัวต้อง ✅ ก่อน deploy prod

---

## Coverage Summary

| Module | TC ทั้งหมด | P0 | P1 | P2 | ผ่าน (✅) | % P0 ผ่าน |
|--------|-----------|----|----|----|----------|-----------|
| AUTH | 5 | 3 | 2 | 0 | 1 | 33% |
| LAYOUT | 2 | 1 | 0 | 1 | 0 | 0% |
| **รวม** | **7** | **4** | **2** | **1** | **1** | — |

> อัพเดตตารางนี้ทุกครั้งที่เพิ่ม/run TC

---

## Changelog

| เวอร์ชัน | วันที่ | รายละเอียด |
|---------|-------|-----------|
| v1.0 | YYYY-MM-DD | สร้าง template (ตัวอย่าง 7 TC) |

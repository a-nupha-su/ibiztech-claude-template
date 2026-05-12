# 09 — Testing (Process · Standards · Report Form)
**[Project Name]**

| เวอร์ชัน | วันที่ |
|---------|-------|
| v2.0 | YYYY-MM-DD |

> ไฟล์เดียวครอบทุกเรื่อง test: **process · standards · MCP tools · folder rules · form template**
> คู่ทำงานกับ `11-test-cases.md` (TC catalog) และ `13-testcase-log.md` (log)

---

## Quick Map

| Section | เนื้อหา |
|---------|--------|
| 1 | Testing Layers (Unit · Smoke · E2E) |
| 2 | Standards & Methodology |
| 3 | MCP Tools (for E2E) |
| 4 | Process per Task |
| 5 | Folder & Naming (Report + Screenshots) |
| 6 | **Test Report Form Template** (copy section นี้) |
| 7 | Definition of Done |

---

## 1. Testing Layers

| ชั้น | ประเภท | เครื่องมือ | เมื่อไหร่ |
|-----|--------|----------|---------|
| 1 | **Unit Test** | Vitest / Jest | logic, util, validator, service method |
| 2 | **Smoke Test** | curl / fetch | API ใหม่ทุก endpoint |
| 3 | **E2E Test (Local)** | **MCP Playwright** | UI ใหม่ ก่อน mark `[x]` |
| 4 | **E2E Smoke (Prod)** | **MCP Playwright** (read-only) | ก่อน + หลัง deploy |

> ถ้า MCP Playwright ไม่ available — ระบุชัดใน 13 ว่า "ทดสอบ browser ไม่ได้รอบนี้" + Report Status = `BLOCKED` — **ห้าม mark `[x]`**

---

## 2. Standards & Methodology

### 2.1 Unit Test — `AAA + F.I.R.S.T`

| รายการ | ค่า |
|-------|-----|
| **Standard** | ISO/IEC/IEEE 29119-4 |
| **Pattern** | AAA — Arrange · Act · Assert |
| **Principles** | F.I.R.S.T — Fast · Independent · Repeatable · Self-validating · Timely |
| **Coverage target** | ≥ 70% statements (100% บน critical business logic) |
| **Pass criteria** | ทุก assertion ผ่าน + ไม่มี flaky / no `.only` / no `.skip` |

```typescript
test('calculateTax — 1000 บาท → 70 บาท', () => {
  // Arrange
  const amount = 1000;
  // Act
  const tax = calculateTax(amount);
  // Assert
  expect(tax).toBe(70);
});
```

### 2.2 Smoke Test — `API Contract 4-Case Matrix`

| รายการ | ค่า |
|-------|-----|
| **Standard** | HTTP RFC 7231 + OpenAPI 3.x |
| **Methodology** | 4-Case Matrix ต่อ 1 endpoint |
| **Pass criteria** | ครบ 4 case + response shape ตรง spec ใน `05-api-spec.md` |

| Case | Input | Expected | ตรวจ |
|------|-------|----------|------|
| 1. No auth | ไม่มี Bearer token | 401 | reject ก่อนถึง handler |
| 2. Wrong role | role ไม่พอ | 403 | RolesGuard ทำงาน |
| 3. Valid | token + body ถูก | 200 / 201 | `{ data, meta, message }` shape |
| 4. Invalid body | body fail | 400 | error format + ระบุ field |

### 2.3 E2E Test — `ISTQB User Journey`

| รายการ | ค่า |
|-------|-----|
| **Standard** | ISTQB Foundation + ISO/IEC/IEEE 29119 |
| **Methodology** | User Journey Testing (flow-based, ไม่ใช่ component-based) |
| **Viewports** | Desktop 1440×900 + Tablet 768×1024 + Mobile 375×667 |
| **A11y** | WCAG 2.1 AA (keyboard nav + ARIA + contrast) |
| **Pass criteria** | ทุก step ✅ + console no error + network 2xx + screenshots ครบ |

### 2.4 Security (cross-cutting)

- **Standard**: OWASP ASVS Level 1 + OWASP Top 10
- **Checks**: AuthN · AuthZ · Input validation · Sensitive data · Error handling
- ดู `08-performance-security.md`

### 2.5 Performance (cross-cutting)

- **Standard**: Web Vitals (Google) + Lighthouse
- **Targets**: LCP < 2.5s · INP < 200ms · CLS < 0.1 · Lighthouse Perf ≥ 80

---

## 3. MCP Tools (for E2E)

| Tool | ใช้กับ |
|------|--------|
| `mcp__playwright__browser_navigate` | เปิดหน้า (ทุก test เริ่มที่นี่) |
| `mcp__playwright__browser_snapshot` | DOM/accessibility tree (assert) |
| `mcp__playwright__browser_click` | กด button/link |
| `mcp__playwright__browser_type` | กรอก form (ทีละ field) |
| `mcp__playwright__browser_fill_form` | กรอก form หลายช่องทีเดียว |
| `mcp__playwright__browser_resize` | เปลี่ยน viewport |
| `mcp__playwright__browser_take_screenshot` | capture PNG |
| `mcp__playwright__browser_console_messages` | ดู JS error (บังคับเช็คทุกหน้า) |
| `mcp__playwright__browser_network_requests` | ดู API call + status |
| `mcp__playwright__browser_evaluate` | run JS (edge cases เท่านั้น) |
| `mcp__playwright__browser_close` | ปิด session |

---

## 4. Process per Task

### Step 0 — เปิด TC Catalog
```
อ่าน docs/11-test-cases.md หา TC ที่ผูกกับ task code
- มี TC อยู่แล้ว → ไล่ตาม Steps ของ TC + ดู Issue History (กัน regression)
- ไม่มี TC → สร้าง TC ใหม่ใน 11 ก่อน (Type, Priority, Steps, Expected)
```

### Step 1 — Local Setup
```bash
pnpm dev          # หรือ start ทั้ง web + api
# เช็ค http://localhost:3000 พร้อม
```

### Step 2 — Run Test ตาม Type

**Unit** (ถ้ามี logic):
```bash
pnpm test --coverage
```

**Smoke** (ถ้ามี API):
```bash
# 4-case matrix ต่อ endpoint
curl -i http://localhost:3001/api/[r]                                # 1. no auth → 401
curl -i http://localhost:3001/api/[r] -H "Authorization: Bearer [viewer]" # 2. wrong role → 403
curl -i http://localhost:3001/api/[r] -H "Authorization: Bearer [admin]"  # 3. valid → 200
curl -i -X POST http://localhost:3001/api/[r] \
  -H "Authorization: Bearer [admin]" -H "Content-Type: application/json" -d '{}' # 4. invalid → 400
```

**E2E** (MCP — ทำตามลำดับ):
```
1. browser_navigate → URL
2. browser_resize → desktop 1440×900
3. browser_snapshot → assert: เห็น element หลัก
4. browser_console_messages → assert: ไม่มี error
5. [run flow] click → type → submit
6. browser_network_requests → assert: API status 2xx
7. browser_snapshot → assert: state ใหม่ (toast/redirect)
8. browser_take_screenshot → ทุก state สำคัญ
9. browser_resize → tablet 768 → mobile 375 → run flow ซ้ำ
10. browser_close
```

**E2E Matrix** (UI task ทุกตัวต้องครอบ):

| สิ่งที่ตรวจ | Desktop 1440 | Tablet 768 | Mobile 375 |
|------------|:------------:|:----------:|:----------:|
| Layout ไม่ overflow | ✅ | ✅ | ✅ |
| Click button หลัก | ✅ | — | ✅ |
| Form submit → toast | ✅ | — | ✅ |
| Form validation error | ✅ | — | ✅ |
| Delete → confirm → ลบจริง | ✅ | — | ✅ |
| Console ไม่มี error | ✅ | ✅ | ✅ |
| Network 2xx | ✅ | — | ✅ |
| Dark mode (ถ้ามี) | ✅ | — | ✅ |

### Step 3 — Report + Catalog + Log

1. copy **Section 6 Form Template** (ในไฟล์นี้) → `docs/test-reports/{TR-XXX}.md` กรอกผลละเอียด + screenshots
2. กลับมา `11-test-cases.md` อัพเดต TC: `Last Run`, `Last Result`, `Last Report` + เพิ่ม Issue History ถ้าเจอ bug
3. log สรุปใน `13-testcase-log.md` 1 บรรทัด (link → TC + Report)

### เมื่อ Test Fail

1. screenshot ทันที (`browser_take_screenshot`)
2. capture `browser_console_messages`
3. log `12-log-issues.md` (ISS-XXX + Root Cause + Fix + บทเรียน)
4. เพิ่ม Issue History ใน TC (`11-test-cases.md`)
5. Report Status = `FAILED`
6. mark task `[!]` ใน `07-implement-plan.md`
7. fix → re-run cycle เต็ม (ห้าม spot fix)

---

## 5. Folder & Naming

```
docs/
├── 09-testing.md                              ← ไฟล์นี้
├── 11-test-cases.md                           ← TC catalog
├── 13-testcase-log.md                         ← log
└── test-reports/
    ├── TR-AUTH-001-20260512.md                ← report 1 รอบ test
    ├── TR-LAYOUT-002-20260514.md
    └── screenshots/
        ├── TR-AUTH-001-20260512/
        │   ├── step01-login-render.png
        │   ├── step04-after-login.png
        │   └── step07-mobile.png
        └── TR-LAYOUT-002-20260514/
            └── step03-drawer-bug.png
```

### TR Code Convention (Report)
```
TR-{MODULE}-{NNN}-{YYYYMMDD}
```
ตัวอย่าง: `TR-AUTH-001-20260512` (Test Report, module AUTH, run #001, 12 พ.ค. 2026)

### Status
`DRAFT` → `IN_PROGRESS` → `PASSED` / `FAILED` / `BLOCKED` / `RETIRED`

### Screenshot Naming
- `step{NN}-{kebab-description}.png`
- ตัวอย่าง: `step01-login-render.png`, `step07-mobile.png`, `step03-drawer-bug.png`

### Screenshot Capture (ขั้นต่ำ)

| When | Naming |
|------|--------|
| Initial state หลัง navigate | `stepNN-initial-{view}.png` |
| Mid flow หลัง interaction | `stepNN-{action}.png` |
| Success/error state | `stepNN-final-{result}.png` |
| Mobile viewport หลัง resize 375 | `stepNN-mobile-{view}.png` |
| Bug found | `stepNN-bug-{symptom}.png` |

### Quick Commands
```bash
# สร้าง report ใหม่
DATE=$(TZ='Asia/Bangkok' date '+%Y%m%d')
INDEX="TR-AUTH-001-${DATE}"
mkdir -p docs/test-reports/screenshots/${INDEX}
# copy Section 6 ในไฟล์นี้ → docs/test-reports/${INDEX}.md

# Export → .docx (ส่ง stakeholder)
pandoc docs/test-reports/${INDEX}.md -o docs/test-reports/${INDEX}.docx

# ค้น Report ที่ fail
grep -l "Status.*FAILED" docs/test-reports/*.md
```

---

## 6. Test Report Form Template

> **วิธีใช้:** copy ตั้งแต่บรรทัด `## 1. Document Control` ลงไปจนจบ section 13 → ไปไว้ที่ `docs/test-reports/{INDEX_CODE}.md`
> ห้ามแก้ template ในไฟล์ 09 — เป็น master form

```
╔════════════════════════════════════════════════╗
║   FORM TEMPLATE (copy ตั้งแต่บรรทัดล่างนี้)    ║
╚════════════════════════════════════════════════╝
```

---

## 1. Document Control

| Field | Value |
|-------|-------|
| **Index Code** | `TR-XXX-NNN-YYYYMMDD` |
| **Project** | [Project Name] |
| **Task Reference** | `AUTH-001` (↔ 07-implement-plan.md) |
| **Document Version** | v1.0 |
| **Status** | `DRAFT` / `IN_PROGRESS` / `PASSED` / `FAILED` / `BLOCKED` / `RETIRED` |
| **Created** | YYYY-MM-DD HH:MM (Asia/Bangkok) |
| **Last Updated** | YYYY-MM-DD HH:MM |
| **Tester** | [ชื่อ] |
| **Reviewer** | [ชื่อ] |
| **Sign-off Date** | YYYY-MM-DD |

## 2. Test Scope

| รายการ | ค่า |
|-------|-----|
| **Test Type** | ☐ Unit  ☐ Smoke  ☐ E2E Local  ☐ E2E Prod Smoke |
| **TC Reference** | `TC-XXX-NNN` (จาก `11-test-cases.md`) |
| **Module** | AUTH / A / LAYOUT / ... |
| **Feature / Flow** | เช่น "Login + Redirect Dashboard" |
| **Build / Commit** | `a3f2bcd` (short SHA) |
| **Environment** | Local `localhost:3000` / Staging / Production |
| **MCP Tool Used** | `mcp__playwright__*` (สำหรับ E2E) |

## 2.1 Testing Standards & Methodology

### Unit (ถ้ามี)
| รายการ | ค่า |
|-------|-----|
| Standard | ISO/IEC/IEEE 29119-4 |
| Pattern | AAA |
| Principles | F.I.R.S.T |
| Tool / Version | Vitest 1.x / Jest 29.x |
| Coverage target | ≥ 70% statements |
| Coverage achieved | __% statements / __% branches |

### Smoke (ถ้ามี API)
| รายการ | ค่า |
|-------|-----|
| Standard | HTTP RFC 7231 + OpenAPI 3.x |
| Methodology | 4-Case Matrix |
| Endpoints | `POST /api/auth/login`, ... |

### E2E (ถ้ามี UI)
| รายการ | ค่า |
|-------|-----|
| Standard | ISTQB + ISO/IEC/IEEE 29119 |
| Methodology | User Journey Testing |
| Viewports | 1440×900 + 768×1024 + 375×667 |
| A11y | WCAG 2.1 AA |

### Security
| รายการ | ค่า |
|-------|-----|
| Standard | OWASP ASVS L1 + OWASP Top 10 |
| Checks done | ☐ AuthN ☐ AuthZ ☐ Input ☐ Sensitive data ☐ Errors |

### Performance (ถ้ามี UI)
| Metric | Target | Actual |
|--------|--------|--------|
| LCP | < 2500ms | __ |
| CLS | < 0.1 | __ |
| INP | < 200ms | __ |
| Lighthouse Perf | ≥ 80 | __ |

## 3. Test Environment

| รายการ | ค่า |
|-------|-----|
| OS | macOS 14.x / Windows 11 / Ubuntu 22.04 |
| Browser | Chromium (MCP Playwright) |
| Viewport(s) | 1440×900 / 768×1024 / 375×667 |
| Node.js | v20.x |
| Database | PostgreSQL 16 |

## 4. Pre-conditions

- [ ] Server พร้อม `http://localhost:3000`
- [ ] Seed admin user มีอยู่: `admin@test.local`
- [ ] DB ใน state ที่กำหนด
- [ ] Migration ล่าสุด apply แล้ว
- [ ] MCP Playwright พร้อมใช้งาน

## 5. Test Data

| รายการ | ค่า | หมายเหตุ |
|-------|-----|---------|
| Test admin | `admin@test.local / Test1234!` | seed |
| Test viewer | `viewer@test.local / Test1234!` | seed |

> ห้ามใช้ข้อมูลจริงของลูกค้า — mask ก่อน

## 6. Test Details (per Type)

### 6.A Unit Test Details (ถ้ามี)
| Test File | Test Name | AAA? | Result | Time |
|-----------|-----------|------|--------|------|
| `tax.service.spec.ts` | `calculateTax — 1000 → 70` | ✅ | ✅ | 4ms |

**Coverage:**
```
Statements: __%   Branches: __%   Functions: __%   Lines: __%
```

### 6.B Smoke Test Details (ถ้ามี API)
| # | Case | Method | URL | Body | Expected | Actual | Result |
|---|------|--------|-----|------|----------|--------|--------|
| 1 | No auth | POST | `/api/auth/login` | valid | 401 | — | ⬜ |
| 2 | Wrong role | GET | `/api/admin/users` | — | 403 | — | ⬜ |
| 3 | Valid | POST | `/api/auth/login` | `{...}` | 200 + token | — | ⬜ |
| 4 | Invalid body | POST | `/api/auth/login` | `{}` | 400 + errors | — | ⬜ |

### 6.C E2E Test Steps (ถ้ามี UI)
| # | MCP Action | Expected | Actual | Result | Screenshot |
|---|-----------|----------|--------|--------|-----------|
| 1 | `browser_navigate` → `/login` | render form ครบ | — | ⬜ | `step01-login.png` |
| 2 | `browser_resize` → 1440×900 | layout desktop ถูก | — | ⬜ | `step02-desktop.png` |
| 3 | `browser_type` email + password | filled | — | ⬜ | — |
| 4 | `browser_click` submit | redirect `/dashboard` + toast | — | ⬜ | `step04-after.png` |
| 5 | `browser_network_requests` | `POST /api/auth/login` 200 | — | ⬜ | — |
| 6 | `browser_console_messages` | no error | — | ⬜ | — |
| 7 | `browser_resize` → 375×667 | mobile ไม่ overflow | — | ⬜ | `step07-mobile.png` |
| 8 | `browser_close` | session ปิด | — | ⬜ | — |

> Legend: ✅ Pass · ❌ Fail · ⬜ Pending · ⏭ Skipped (เขียนเหตุผล)

## 7. Network Trace

| # | Method | URL | Status | Time (ms) | OK? |
|---|--------|-----|--------|-----------|-----|
| 1 | POST | `/api/auth/login` | 200 | 145 | ✅ |
| 2 | GET | `/api/auth/me` | 200 | 32 | ✅ |

## 8. Console Messages

```
[INFO] Login successful
[WARN] (none)
[ERROR] (none)
```

> ถ้ามี ERROR แม้ 1 บรรทัด → ❌ ห้าม Pass — log ISS-XXX

## 9. Screenshots

> Path: `docs/test-reports/screenshots/{INDEX_CODE}/`

| File | Step | Description |
|------|------|-------------|
| `step01-login.png` | 1 | Login page rendered desktop |
| `step04-after.png` | 4 | Dashboard + success toast |
| `step07-mobile.png` | 7 | Mobile 375 — sidebar drawer |

## 10. Issues Found

| ISS Code | Severity | Description | Linked Step |
|----------|----------|-------------|-------------|
| — | — | — | — |

> ผูกกับ `12-log-issues.md` — สร้าง ISS-XXX ทันทีเมื่อพบ

## 11. Overall Result

- [ ] **PASSED** — ทุก step ✅ + console/network clean + reviewer ผ่าน
- [ ] **FAILED** — มี step ❌ → ผูก ISS-XXX
- [ ] **BLOCKED** — เหตุผล: ________________

**สรุป:**
> [2-3 บรรทัดสรุปผล + ข้อเสนอแนะ]

## 12. Sign-off

| Role | ชื่อ | วันที่ |
|------|------|-------|
| Tester | _____________ | YYYY-MM-DD HH:MM |
| Reviewer | _____________ | YYYY-MM-DD HH:MM |
| (Optional) PM/Lead | _____________ | YYYY-MM-DD HH:MM |

## 13. Appendix

### A. Re-test History
| Date | Index Code | Result | Note |
|------|-----------|--------|------|
| — | — | — | — |

### B. Related Documents
- Task: `docs/07-implement-plan.md#AUTH-001`
- TC: `docs/11-test-cases.md#TC-AUTH-001`
- API spec: `docs/05-api-spec.md`
- Issues: `docs/12-log-issues.md`

### C. Notes
> เขียนสิ่งที่ tester อยากให้ผู้อ่านในอนาคตรู้

### Document Changelog
| เวอร์ชัน | วันที่ | ผู้แก้ | รายละเอียด |
|---------|-------|------|-----------|
| v1.0 | YYYY-MM-DD HH:MM | [name] | สร้าง report |

```
╔════════════════════════════════════════════════╗
║   FORM TEMPLATE ENDS HERE                      ║
╚════════════════════════════════════════════════╝
```

---

## 7. Definition of Done (ทุก task)

```
[ ] TC      → 11-test-cases.md มี TC + ไล่ตาม Steps แล้ว
[ ] UNIT    → AAA + F.I.R.S.T pass (ถ้ามี logic)
[ ] SMOKE   → 4-Case Matrix pass (ถ้ามี API)
[ ] E2E     → MCP desktop + tablet + mobile + no console error
[ ] REPORT  → test-reports/{TR-XXX}.md + screenshots + Standards ครบ + sign-off
[ ] CATALOG → 11 อัพเดต Last Run/Result/Report (+ Issue History ถ้ามี bug)
[ ] LOG     → 13-testcase-log.md 1 บรรทัด link TC + Report
[ ] DOC     → doc อื่นที่เกี่ยวข้องอัพเดต
[ ] STATUS  → mark [x] ใน 07-implement-plan.md
```

**ขาดข้อใดข้อหนึ่ง → mark `[!]` ไม่ใช่ `[x]`** + log ISS ใน `12-log-issues.md` + Report Status = `FAILED`/`BLOCKED`

---

## Changelog

| เวอร์ชัน | วันที่ | รายละเอียด |
|---------|-------|-----------|
| v1.0 | YYYY-MM-DD | สร้าง template |
| v2.0 | YYYY-MM-DD | รวบ 09-testing-mcp + templates/test-report-form + test-reports/README → ไฟล์เดียว |

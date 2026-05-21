# [Project Name] — AI Guide (Fullstack)
> Next.js App Router · Prisma · Vercel

| เวอร์ชัน | วันที่ |
|---------|-------|
| v1.0 | YYYY-MM-DD |

> อ่านไฟล์นี้ก่อนเริ่มทำงานทุกครั้ง

---

## Doc Map

| ไฟล์ | เนื้อหา | อ่านเมื่อ |
|-----|--------|---------|
| `01-requirement.md` | FR/NFR/roles/permissions | ก่อนสร้าง feature ใหม่ |
| `02-architecture.md` | folder structure, route, API convention | ก่อนสร้างไฟล์/route ใหม่ |
| `03-tech-stack.md` | versions, install commands, naming | ก่อนติดตั้ง package |
| `04-database-schema.md` | Prisma schema ทุก model | ก่อนเขียน query / migration |
| `05-datadictionary.md` | ทุก field พร้อมคำอธิบาย | ก่อนสร้าง Zod schema / form |
| `06-ux-ui-design.md` | design tokens, components, responsive | ก่อนสร้าง UI component |
| `07-implement-plan.md` | task list + status | ดู task ที่ต้องทำ |
| `08-performance-security.md` | security rules, perf targets | ก่อนเขียน API / deploy |
| `09-testing.md` | **MCP test process + tools** | **ก่อนเขียน test / mark [x]** |
| `10-value-research.md` | **Research (unclear requirement)** | **ก่อนเขียน FR ใน 01 — gate ก่อน Phase 0** |
| `11-test-cases.md` | **Test Case Catalog (TC list)** | **ก่อนเริ่มทดสอบทุกครั้ง** |
| `12-log-issues.md` | bug/error/config log | ทุกครั้งที่เจอ error |
| `13-testcase-log.md` | test log สรุป (link TC + Report) | ทุกครั้งที่ทดสอบ |
| `14-feature-release.md` | **Feature Brief / Release notes (presentation)** | **ทุก feature mark [x] → สร้าง FB ภายใน 24 ชม.** |
| `15-sprint.md` | **Sprint Planning / Review / Retro** | **ทุก sprint เริ่ม + จบ** |
| `16-client-artifacts.md` | **เอกสารจากลูกค้า — index + analysis** | **ก่อนสร้าง RR/FR/Task ใหม่ — เช็คก่อนว่ามี artifact ที่ overlap ไหม** |
| `19-engineering-discipline.md` | **Debug Mantra · Scrutinize · Post-mortem gates · Tone rules** | **เจอ bug / ก่อน mark [x] / ก่อน close ISS / ทุก doc + commit** |

---

## Engineering Discipline (บังคับ — ดู `19-engineering-discipline.md`)

ทุก dev/AI ในโปรเจกต์นี้ยึด 4 หลัก:

1. **Debug Mantra (4 step)** — เจอ bug → reproduce reliably → fail path → falsify hypothesis → breadcrumb ledger · ห้าม fix ก่อนมี reliable repro
2. **Scrutinize (outsider review)** — ก่อน mark `[x]` → intent → trace → verify → report · ห้าม "LGTM" · cite file:line ทุก finding · verdict: ship/fix-then-ship/rework/reject
3. **Post-mortem gates** — ISS → `CLOSED` ต้องผ่าน 4 input: reliable repro + root cause + fix + validation · blameless · honest validation scope
4. **Tone rules** — active voice · no hedging · cite file:line · blameless · distinguish "code says X" vs "I verified X"

---

## Client Artifact Rule (บังคับ)

**ก่อนสร้าง RR / FR / Task ใหม่ทุกครั้ง:**
1. รัน `bash scripts/check-artifacts.sh` (auto run ทุก SessionStart)
2. ถ้ามี artifact Status = `RECEIVED` หรือ `ANALYZING` → **วิเคราะห์ก่อน** (อาจมี requirement overlap)
3. ถ้ามี artifact `ANALYZED` แต่ Action Items ยังไม่ครบ [x] → ทำให้ครบก่อน
4. AI **ห้าม improvise** requirement — ทุก FR/Task ต้อง trace กลับ CA หรือ internal decision

ตอน user สั่ง "ทำ feature X" → AI ตรวจก่อน: feature นี้มาจาก CA ไหน? ถ้าไม่มี → ถาม user ว่ามี artifact ที่เกี่ยวข้องไหม

---

## Architecture Rules

- ทุก API route ต้องมี session check + role check ก่อน logic
- ทุก input ผ่าน Zod validation (ทั้ง body + query params)
- ห้าม hardcode ค่าที่ควรมาจาก DB หรือ env
- ห้าม return field ที่ sensitive (password, token, secret)
- Server Component = default / Client Component = เมื่อต้องการ state/event เท่านั้น

---

## กฎ Security (ห้ามข้าม)

```
✅ verify session ทุก route
✅ check role ก่อน mutate
✅ Zod parse ทุก input
✅ parameterized query (Prisma จัดการให้)
❌ ห้าม console.log(user) / console.log(token)
❌ ห้าม hardcode secret ในโค้ด
```

---

## Task Status

```
[ ] ยังไม่เริ่ม
[~] กำลังทำ
[x] เสร็จแล้ว
[!] ติดปัญหา / รอ
```

---

## Testing Strategy — 3 ประเภท (Unit / Smoke / E2E)

> ดูรายละเอียด standards + methodology ทุกประเภทที่ `09-testing.md`

### ชั้น 1 — Unit Test (Vitest / Jest)
**Standard:** ISO/IEC/IEEE 29119-4 · Pattern **AAA** · Principles **F.I.R.S.T**
**เมื่อไหร่:** ฟังก์ชัน business logic, validator, utility ที่ซับซ้อน
**Coverage target:** ≥ 70% statements (100% บน critical logic)
**ไม่จำเป็น:** simple UI component, route handler ที่แค่ call service
**command:** `pnpm test`

```
ตัวอย่างที่ต้อง unit test:
- calculateTax(amount) → edge cases
- parseThaiDate(str) → format ต่าง ๆ
- hasPermission(role, action) → ทุก combination
```

### ชั้น 2 — Smoke Test (curl / fetch)
**Standard:** HTTP RFC 7231 + OpenAPI 3.x · Methodology **4-Case Matrix**
**เมื่อไหร่:** หลัง implement API endpoint ใหม่ทุกตัว
**สิ่งที่ตรวจ:** 4 case บังคับ — no auth (401), wrong role (403), valid (200), invalid body (400)

```bash
# ตัวอย่าง smoke test pattern
curl -X POST http://localhost:3000/api/income \
  -H "Content-Type: application/json" \
  -d '{"amount": 1000}' \
  # expect: 401 (no session)

curl -X GET http://localhost:3000/api/income?page=1 \
  -H "Cookie: session=..." \
  # expect: 200 { data: [], meta: {} }
```

### ชั้น 3 — E2E Test (MCP Playwright) — **บังคับ**
**Standard:** ISTQB Foundation + ISO/IEC/IEEE 29119 · Methodology **User Journey**
**Viewports:** Desktop 1440 + Tablet 768 + Mobile 375 · **A11y:** WCAG 2.1 AA
**เมื่อไหร่:** ก่อน mark task [x] ทุก UI task + ก่อน/หลัง deploy
**Local:** `http://localhost:3000` — ทดสอบ CRUD ครบ
**Prod:** `https://[domain]` — smoke only (อ่านอย่างเดียว ห้าม mutate data จริง)

> ดู process + รายชื่อ MCP tools ละเอียดที่ `09-testing.md`

**กระบวนการมาตรฐาน** (process เต็มอยู่ใน `09-testing.md`):
```
1. browser_navigate → URL
2. browser_resize → desktop 1440 → run flow → mobile 375 → run flow
3. browser_snapshot ทุก state สำคัญ (assert)
4. browser_console_messages → ต้องไม่มี error สีแดง
5. browser_network_requests → assert API call ถูก
6. log ทุก step ลง 13-testcase-log.md
```

**สิ่งที่ต้องตรวจ:**
```
✅ desktop 1440px / mobile 375px
✅ form submit → success toast
✅ form validation error แสดงถูกต้อง
✅ delete → confirm dialog → ลบจริง
✅ console ไม่มี error
✅ network: API ถูกเรียก status 200
✅ dark mode (ถ้ามี)
```

**ถ้า MCP Playwright ไม่ available:** ระบุชัดใน 13-testcase-log.md ว่า "ทดสอบ browser ไม่ได้รอบนี้" — **ห้าม mark [x]**

### Test Documentation บังคับ — 2 ระดับ

**1. Test Report Form (เอกสารเต็ม)** — `docs/test-reports/{INDEX_CODE}.md`
- 1 ไฟล์ต่อ 1 รอบ test
- Template: `docs/09-testing.md (Section 6)` (มี Index Code, Status, Date, Steps, Screenshots, Sign-off)
- Index Code: `TR-{MODULE}-{NNN}-{YYYYMMDD}` เช่น `TR-AUTH-001-20260512`
- Screenshots: `docs/test-reports/screenshots/{INDEX_CODE}/step{NN}-{desc}.png` — บังคับ capture
- Status: `DRAFT` → `IN_PROGRESS` → `PASSED` / `FAILED` / `BLOCKED`

**2. Sรุปใน 13-testcase-log.md** — 1 บรรทัดต่อ test case + link Report

| วันที่ | Task | สิ่งที่ทดสอบ | ชั้น | Report | ผล |
|--------|------|------------|------|--------|-----|
| 2026-01-01 | AUTH-001 | POST /api/login → 200 + token | Smoke | TR-AUTH-001-20260101 | ✅ |
| 2026-01-01 | FIN-003 | income form submit บน mobile 375px | Browser | TR-FIN-003-20260101 | ✅ |
| 2026-01-01 | FIN-003 | delete income → confirm → ลบจริง | Browser | TR-FIN-003-20260101 | ❌ |

---

## บังคับก่อนบอกว่า Task เสร็จ (7 ข้อ — ขาดข้อใดข้อหนึ่ง = ห้าม mark [x])

```
1. TC       → เพิ่ม/อัพเดต TC ใน 11-test-cases.md (ก่อน + หลัง run)
2. TEST     → ไล่ตาม Steps ของ TC — ผ่าน Unit + Smoke + E2E (MCP)
3. REPORT   → สร้าง docs/test-reports/{TR-XXX}.md + screenshots ครบ
              Status = PASSED + Tester/Reviewer sign-off
4. LOG      → 13-testcase-log.md เพิ่มแถว + link TC + Report
5. FB       → สร้าง Feature Brief ใน 14-feature-release.md (ถ้า task ปิด feature)
              Pitch + Problem + Solution + Benefit + Impact + Screenshots
6. DOC      → อัพเดต doc อื่นที่เกี่ยวข้อง
7. STATUS   → mark [x] ใน 07-implement-plan.md + แจ้งผลสรุป
```

> FB ทำเฉพาะ task ที่ปิด feature (เช่น AUTH-005 = Login UI = ปิด login feature) — task ภายใน feature (เช่น AUTH-001 User model) ไม่ต้อง FB

**ถ้าทดสอบ browser ไม่ได้ในรอบนี้:** สร้าง Report Status = `BLOCKED` + log ใน 13 — อย่า mark [x]

---

## Version Tracking — ทุก doc ที่แก้ต้องทำครบ

1. อัพเดต `| เวอร์ชัน | วันที่ |` header ของไฟล์ที่แก้
2. เพิ่ม entry ใน Changelog ท้ายไฟล์
3. ใช้ Bangkok time: `TZ='Asia/Bangkok' date '+%Y-%m-%d %H:%M'`

---

## Issue Logging — บังคับทุก error

เมื่อเจอ error / config ผิด / ต้องเปลี่ยน approach กลางทาง:
1. log ใน `12-log-issues.md` ทันที (ไม่รอหลัง task เสร็จ)
2. ระบุ Root Cause + Fix + บทเรียน

---

## Changelog

| เวอร์ชัน | วันที่ | รายละเอียด |
|---------|-------|-----------|
| v1.0 | YYYY-MM-DD | สร้าง template ครั้งแรก |

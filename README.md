# iBizTech Claude Template

Template สำหรับทุกโปรเจกต์ของทีม — ให้ได้ pattern การทำงานกับ Claude เหมือนกัน

## วิธีใช้

### 1. สร้างโปรเจกต์ใหม่จาก template นี้
กด **"Use this template"** บน GitHub แล้วสร้าง repo ใหม่
(หรือ clone แล้วลบ git history เอง)

### 2. รัน setup script
```bash
bash setup.sh
```
Script จะถามชื่อโปรเจกต์ + ประเภท แล้วสร้างไฟล์ให้อัตโนมัติ

### 3. เขียน docs ก่อนโค้ด (สำคัญมาก)
```
(ถ้า requirement ยังไม่ชัด)
docs/10-value-research.md  ← ทำ research ก่อน user APPROVED ค่อยเข้า FR
                              (มี 10-Value Framework + Source Quality T1-T6)

docs/01-requirement.md     ← เขียน FR ทั้งหมด (ถ้ามี research ให้อ้าง RR-XXX)
docs/07-implement-plan.md  ← แตก FR เป็น task code (มี Wave/Model/Agent)
```

### 4. บอก Claude เริ่มงาน
```
"อ่าน CLAUDE.md แล้วเริ่ม SETUP-001"
```

---

## โครงสร้างไฟล์หลังรัน setup

```
my-project/
├── CLAUDE.md                    ← AI guide (สร้างจาก variant ที่เลือก)
├── .claude/
│   └── settings.json            ← permission allowlist + hooks (ลด "Allow?" prompts)
├── scripts/                     ← workflow automation
│   ├── find-next.sh             ← หา task ถัดไป (พร้อมทำ + deps พร้อม)
│   ├── new-task.sh              ← เริ่ม task: mark [~] + reserve TC code
│   ├── new-report.sh            ← สร้าง Test Report จาก 09 §6 + screenshots/
│   ├── log-test.sh              ← append log ใน 13 + อ้าง TC + Report
│   ├── log-issue.sh             ← สร้าง ISS-XXX ใน 12 (auto-increment)
│   ├── new-research.sh          ← สร้าง RR-XXX entry ใน 10-value-research
│   ├── new-feature-brief.sh     ← สร้าง FB-XXX ใน 14-feature-release + assets dir
│   ├── new-sprint.sh            ← สร้าง SP-XXX ใน 15-sprint (PLANNING status)
│   ├── new-artifact.sh          ← register CA + copy raw file ไป client-artifacts/
│   ├── check-artifacts.sh       ← scan artifacts ค้าง (auto run SessionStart)
│   ├── check-dod.sh             ← verify 7 DoD ก่อน mark [x] (exit 1 ถ้าไม่ครบ)
│   └── progress.sh              ← recalc Summary Progress ใน 07
├── docs/
│   ├── 01-requirement.md        ← FR/NFR/roles
│   ├── 02-architecture.md       ← structure, conventions
│   ├── 03-tech-stack.md         ← versions, packages
│   ├── 04-database-schema.md    ← DB schema
│   ├── 05-api-spec.md           ← (เฉพาะ Separated)
│   ├── 05-datadictionary.md     ← (เฉพาะ Fullstack) Zod/form fields
│   ├── 06-ux-ui-design.md       ← design tokens, components
│   ├── 07-implement-plan.md     ← task list + status
│   ├── 08-performance-security.md
│   ├── 09-testing.md            ← test process + standards + Report form (Section 6)
│   ├── 10-value-research.md     ← Research (10-Value Framework) — gate ก่อน FR
│   ├── 11-test-cases.md         ← Test Case Catalog (AI ไล่ตามลิสต์นี้)
│   ├── 12-log-issues.md         ← error log บังคับ
│   ├── 13-testcase-log.md       ← test log summary (link → TC + reports)
│   ├── 14-feature-release.md    ← Feature Brief + Roadmap (เอกสารนำเสนอ)
│   ├── 15-sprint.md             ← Sprint planning / review / retrospective
│   ├── 16-client-artifacts.md   ← Index + analysis เอกสารจากลูกค้า
│   ├── client-artifacts/{DATE}/ ← raw files จากลูกค้า (PDF/png/xlsx/md)
│   ├── feature-assets/{FB}/     ← screenshots/demo สำหรับ FB
│   └── test-reports/
│       ├── {TR-XXX-NNN-YYYYMMDD}.md   ← 1 ไฟล์ต่อ 1 รอบ test
│       └── screenshots/{INDEX_CODE}/  ← screenshots ของรอบนั้น
└── setup.sh
```

---

## 2 Variants

| | Fullstack | Separated API |
|-|-----------|--------------|
| **Stack** | Next.js only | Next.js + NestJS |
| **API** | Next.js route handlers | NestJS controllers |
| **Validation** | Zod | Zod (FE) + class-validator (BE) |
| **Auth** | Session/cookie | JWT Bearer |
| **05-api-spec.md** | ไม่มี | บังคับ |

---

## Testing Strategy — Unit · Smoke · E2E (ตาม Standards)

| ประเภท | เครื่องมือ | Standard / Methodology | เมื่อไหร่ |
|--------|----------|----------------------|---------|
| **Unit** | Jest/Vitest | ISO/IEC/IEEE 29119-4 · AAA · F.I.R.S.T · cov ≥ 70% | ทุก logic/service/validator |
| **Smoke** | curl/fetch | HTTP RFC 7231 · OpenAPI 3.x · **4-Case Matrix** | ทุก API endpoint ใหม่ |
| **E2E** | **MCP Playwright** (บังคับ) | ISTQB · User Journey · WCAG 2.1 AA · 3 viewports | UI ก่อน mark `[x]` + ก่อน/หลัง deploy |
| **Security** | grep + `pnpm audit` | OWASP ASVS L1 + OWASP Top 10 | pre-deploy |
| **Performance** | Lighthouse | Web Vitals (LCP/INP/CLS) | pre-deploy |

- รายละเอียด standards ทุกประเภทอยู่ใน `docs/09-testing.md`
- ทุก Test Report ต้องระบุ **Standard ที่ใช้** + **Test Details ตามประเภท** (Section 2.1 + 6 ของ form)
- ทดสอบ **local** (CRUD ครบ) และ **prod** (read-only smoke test) แยกกัน
- **MCP ไม่ available → ห้าม mark `[x]`** (log ว่ารอทดสอบใน 13-testcase-log.md)

---

## Automation (ลด manual + ลด "Allow?" prompts)

### `.claude/settings.json` — pre-authorized operations

ไฟล์นี้บอก Claude Code ว่างานไหน "ทำได้เลยไม่ต้องถาม" / "ต้องถามก่อน" / "ห้ามทำ"

| กลุ่ม | ตัวอย่าง | สถานะ |
|------|---------|------|
| **Allow** (ทำเลย) | Read, Grep, pnpm test, curl, git status, MCP Playwright, edit `test-reports/`, edit `11/12/13/07` | ✅ ไม่ถาม |
| **Ask** (ถามก่อน) | Edit `src/`, `apps/`, doc 01-08, install package, git commit/checkout | 🟡 ขออนุญาต |
| **Deny** (ห้าม) | อ่าน `.env`, `rm -rf`, `git push --force`, `prisma migrate reset` | ❌ block |

### Hooks (auto run script)

| Event | Script | ทำอะไร |
|-------|--------|--------|
| SessionStart | `find-next.sh` | แสดง task ถัดไปทันทีเปิด Claude |
| PostToolUse (Edit/Write) | `progress.sh --silent` | recalc Summary Progress |

### Workflow ใช้ scripts (1 command แทน manual เดิม 5-10 ขั้น)

```bash
# 1. ดู task ถัดไป
bash scripts/find-next.sh

# 2. เริ่ม task
bash scripts/new-task.sh AUTH-002

# 3. (เขียนโค้ด + run unit/smoke tests)

# 4. สร้าง Test Report
bash scripts/new-report.sh AUTH-002
# → docs/test-reports/TR-AUTH-001-{DATE}.md
# → docs/test-reports/screenshots/TR-AUTH-001-{DATE}/

# 5. (กรอก Report + capture screenshots + sign-off)

# 6. Log test result
bash scripts/log-test.sh AUTH-002 PASS TR-AUTH-001-{DATE}

# 7. ถ้าเจอ bug
bash scripts/log-issue.sh "Sidebar drawer ไม่ปิด" "LAYOUT-002" "event ไม่ fire บน mobile"

# 8. Verify DoD ครบก่อน mark [x]
bash scripts/check-dod.sh AUTH-002
# exit 0 = ผ่าน · exit 1 = ขาดข้อไหน
```

---

## กฎสำคัญ

- เขียน doc ก่อนโค้ดเสมอ
- ทุก task ต้องมี task code (AUTH-001, FIN-001 ฯลฯ)
- log ทุก error ใน 12-log-issues.md ทันที
- **ก่อนทดสอบ** = อ่าน/สร้าง **TC** ใน `11-test-cases.md` (ไล่ตาม Steps + ดู Issue History)
- **ทุกรอบ test** = สร้าง **Test Report form** ใน `docs/test-reports/{TR-XXX}.md` + screenshots
- **หลัง test** = อัพเดต TC (Last Run/Result/Report) + log สรุปใน 13-testcase-log.md
- **ปิด feature** = สร้าง **Feature Brief** ใน `14-feature-release.md` ภายใน 24 ชม. (มี impact + screenshots)
- mark [x] เมื่อผ่าน 7 ข้อ: **TC + TEST + REPORT + LOG + FB + DOC + STATUS**

---

*ดูตัวอย่าง project ที่ใช้ pattern นี้: [iboon-system/iboon-rebuild]*

# 12 — Issue & Error Log
**[Project Name]**

| เวอร์ชัน | วันที่ |
|---------|-------|
| v1.0 | YYYY-MM-DD |

> บันทึกทุก error, config ผิด, scope เปลี่ยน, approach เปลี่ยน
> วัตถุประสงค์: ไม่ทำผิดซ้ำ + ประเมินความเสี่ยงโปรเจกต์ถัดไป

---

## ISS Code Convention

```
ISS-{NNN}
```

- `NNN` = running 3 หลัก (auto-increment) — ใช้ `scripts/log-issue.sh` สร้างให้

## Status Lifecycle

| Status | ความหมาย |
|--------|---------|
| `OPEN` | เพิ่งบันทึก ยังไม่วิเคราะห์ |
| `INVESTIGATING` | กำลังหา root cause |
| `FIXED` | แก้แล้ว pending verification |
| `CLOSED` | verify แล้ว ปิดสนิท |
| `WONTFIX` | ตัดสินใจไม่แก้ (เหตุผลบังคับ) |
| `DUPLICATE` | ซ้ำกับ ISS-XXX อื่น (link) |

## Severity

| Level | ใช้เมื่อ |
|-------|---------|
| `CRITICAL` | block production / data loss / security |
| `HIGH` | feature สำคัญใช้ไม่ได้ + ไม่มี workaround |
| `MEDIUM` | มี workaround หรือกระทบ user บางส่วน |
| `LOW` | cosmetic / minor UX |

## Debug Discipline (บังคับ — ดู `19-engineering-discipline.md` §A)

ก่อนเสนอ fix ใด ๆ ต้องผ่าน **4-Step Debug Mantra**:
1. **Reliable repro** ก่อน — flaky → เพิ่ม rate ก่อน · no repro → หยุด ขอ env/artifact
2. **Fail path** — debugger → source trace + knob → in-code instrumentation
3. **Falsify hypothesis** — disproof first, 3-5 hypotheses เรียง rank
4. **Breadcrumb ledger** — cross-ref ทุก run

ห้าม mark **CLOSED** ถ้าไม่ผ่าน Post-mortem Gates (`19-engineering-discipline.md` §C):
```
[ ] Reliable repro    [ ] Root cause known
[ ] Fix identified    [ ] Fix validated
```

## วิธี log

```markdown
### ISS-XXX — [ชื่อปัญหาสั้น ๆ]

#### Document Control
- **วันที่:** YYYY-MM-DD
- **Status:** OPEN / INVESTIGATING / FIXED / CLOSED / WONTFIX / DUPLICATE
- **Severity:** CRITICAL / HIGH / MEDIUM / LOW
- **Task:** [task code ที่เกี่ยวข้อง]
- **TC / TR:** [TC-XXX-NNN, TR-XXX-NNN-YYYYMMDD] (ถ้าเจอตอน test)

#### Reproducer (Mantra step 1)
- **Repro reliability:** RELIABLE / FLAKY (X%) / NONE
- **Steps:** [exact steps · failing test name · curl · CLI · ฯลฯ]
- **Environment:** [OS · runtime · DB version · config]

#### Symptom
[สิ่งที่สังเกตจริง — concrete identifier · error msg · log line · perf number — ห้าม paraphrase]

#### Breadcrumb Ledger (Mantra step 2-4)
| # | What changed | Result | Ruled in / out |
|---|--------------|--------|---------------|
| 1 |              |        |               |
| 2 |              |        |               |

#### Hypotheses (3-5 ranked — Mantra step 3)
1. [hypothesis A] — disproved by [run #X] / confirmed by [run #Y]
2. [hypothesis B] — ...

#### Root Cause _(บังคับก่อน CLOSED)_
[mechanism จริง — code identifier welcome: function name · file:line · SHA · branch condition]
[walk cause chain end-to-end]

#### Why it produced the symptom
[link cause → visible failure (อาจ non-obvious)]

#### Fix _(บังคับก่อน CLOSED)_
- **PR / Commit:** [link / SHA]
- **What changed:** [สั้น]
- **Why this addresses root cause:** [ไม่ใช่บังอาการ]
- **Prior fix attempt** (ถ้ามี): [link + อะไรผิด]

#### Why it slipped through _(บังคับ — blameless)_
- [ ] CI gap (no test for this path/config)
- [ ] Latent code (correct when written, broken by later change)
- [ ] Workload gap (no real workload reached this code path)
- [ ] Incomplete prior fix (hid symptom, root cause untouched)
- [ ] Review miss (reviewable but implication missed)
- [ ] Other: [ระบุ]

#### Validation _(บังคับก่อน CLOSED — honest scope)_
- **Original repro now passes:** [test name / link / output]
- **Customer workload sucess:** [workload id / run link]
- **Other configurations tested:** [ระบุ — ถ้าทดสอบแค่ config เดียว ระบุชัด "not retested on X"]

#### Action Items
- [ ] [Regression test added at <seam>] — Owner: [name] · [test name]
- [ ] [CI gap closed: <check>] — Owner · PR
- [ ] [Doc / runbook updated] — Owner · link
- [ ] [Related ticket filed] — Owner · key

> ไม่มี action items = ระบุชัด "None — fix is sufficient" (อย่าแต่งให้ดู thorough)

#### บทเรียน
[ป้องกันครั้งต่อไป — describe gap, ไม่ใช่คน]

- **Closed Date:** YYYY-MM-DD (เติมเมื่อ CLOSED)
- **Closed by:** [name]
```

---

## Issues

### ISS-001 — [ตัวอย่าง: Prisma migration failed on prod]

#### Document Control
- **วันที่:** YYYY-MM-DD
- **Status:** CLOSED
- **Severity:** HIGH
- **Task:** SETUP-003
- **TC / TR:** —

#### Reproducer
- **Repro reliability:** RELIABLE (every deploy ของ migration 0042)
- **Steps:** `pnpm dlx prisma migrate deploy` บน prod DB
- **Environment:** PostgreSQL 16 (prod), SQLite (local)

#### Symptom
`Error: P3009 migrate found failed migration in P3009 ALTER TABLE "user" ADD COLUMN "tier" — at migration 0042_add_user_tier`

#### Breadcrumb Ledger
| # | What changed | Result | Ruled in / out |
|---|--------------|--------|---------------|
| 1 | Re-run migrate บน fresh prod copy | same error | ไม่ใช่ state issue |
| 2 | Compare migration .sql กับ Postgres syntax | found `DEFAULT (datetime())` (SQLite-only) | confirm dialect mismatch |

#### Root Cause
Migration `0042_add_user_tier.sql` ใช้ `DEFAULT (datetime('now'))` (SQLite syntax) บน `created_at` column. local dev ใช้ SQLite ที่ Prisma `migrate dev` accept ได้ แต่ Postgres ใน prod reject syntax นี้ → migration apply ค้าง state `failed`.

#### Why it produced the symptom
P3009 = Prisma เห็น migration ใน `_prisma_migrations` table มี `finished_at = NULL` (apply ครึ่งทาง) → block migrate command ถัดไป

#### Fix
- **PR:** org/web#142
- **What changed:** เปลี่ยน `DEFAULT (datetime('now'))` → `DEFAULT CURRENT_TIMESTAMP` (cross-dialect)
- **Why:** `CURRENT_TIMESTAMP` เป็น standard SQL — รองรับทั้ง Postgres + SQLite

#### Why it slipped through
- [x] CI gap (CI run บน SQLite — ไม่เคย apply migration บน Postgres ก่อน deploy)

#### Validation
- Original repro: `prisma migrate deploy` บน fresh Postgres → ผ่าน
- Tested on: Postgres 16 + SQLite (local) — both pass
- Not retested on: MySQL (ไม่ใช้ใน project นี้)

#### Action Items
- [x] CI: เพิ่ม step ที่ run migration บน Postgres container ก่อน merge — Owner: @anu, PR #143

#### บทเรียน
dev env ต้องใช้ DB ชนิดเดียวกับ prod (Postgres) — SQLite divergence ทำให้ migration ที่ผ่าน local fail บน prod

- **Closed Date:** YYYY-MM-DD
- **Closed by:** @anu

---

## Risk Register

| ความเสี่ยง | โอกาส | ผลกระทบ | วิธีป้องกัน |
|-----------|------|---------|-----------|
| DB schema เปลี่ยนกลางทาง | สูง | สูง | ออกแบบ schema ให้นิ่งก่อนเริ่ม phase 3+ |
| Third-party API down | กลาง | กลาง | มี fallback + retry + error boundary |
| Env var หายบน prod | ต่ำ | สูง | ทำ checklist DEPLOY-001 ทุกครั้ง |

---

## Changelog

| เวอร์ชัน | วันที่ | รายละเอียด |
|---------|-------|-----------|
| v1.0 | YYYY-MM-DD | สร้าง template |

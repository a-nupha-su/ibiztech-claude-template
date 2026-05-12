# 07 — Implementation Plan
**[Project Name]**

| เวอร์ชัน | วันที่ |
|---------|-------|
| v3.0 | YYYY-MM-DD |

> Plan แตก task พร้อมระบุ **Phase · Wave · Priority · Assignee · Estimate · Labels · Model · Agent**
> AI ที่รับ plan รู้ทันทีว่า: ทำอันไหนก่อน · ใคร · ใหญ่แค่ไหน · ใช้ model/agent อะไร

---

## Execution Notation

| สัญลักษณ์ | ความหมาย |
|-----------|---------|
| **Phase** | ขั้นใหญ่ — sequential (R → 0 → 1 → 2 → ...) |
| **Wave (W1, W2...)** | ภายใน phase — ใน wave เดียวกัน = **parallel** · ต่าง wave = **sequential** |
| **Pri** | Priority — `P0` critical / `P1` high / `P2` medium / `P3` low |
| **Asg** | Assignee — ชื่อคนรับผิดชอบ (เช่น `@anu`, `@dev1`) |
| **Est** | Estimate — `XS` (≤2h) · `S` (≤1d) · `M` (≤3d) · `L` (≤1w) · `XL` (≤2w) |
| **Labels** | tag — `feature` `bug` `tech-debt` `customer-req` `security` `perf` `ui` `infra` `qa` `compliance` `release` `refactor` |
| **Model** | Haiku 4.5 / Sonnet 4.6 / Opus 4.7 |
| **Agent** | type จาก CLAUDE.md routing หรือ `tool-only` |
| **N** | จำนวน agent spawn (0 = tool-only) |
| **Deps** | task code ที่ต้องเสร็จก่อน |

---

## Task Status Legend

```
[ ] ยังไม่เริ่ม (Backlog / Ready)
[~] กำลังทำ (In Progress)
[x] เสร็จแล้ว (ผ่าน DoD ครบ 7 ข้อ)
[!] ติดปัญหา / รอ — ผูก ISS-XXX ใน 12-log-issues.md
```

---

## Definition of Ready (DoR) — ก่อน `[ ]` → `[~]`

ก่อนเริ่ม task ใดก็ตาม ต้องผ่าน DoR ทั้ง 5 ข้อ:

```
[ ] 1. Requirement ชัด (มี FR หรือ RR APPROVED) — ดู 01/10
[ ] 2. Dependencies ทุกตัวใน Deps column = [x]
[ ] 3. Estimate กรอกแล้ว (Est column ≠ —)
[ ] 4. Assignee กำหนดแล้ว (Asg column ≠ —)
[ ] 5. Test approach ตกลงแล้ว (TC draft ใน 11-test-cases.md อย่างน้อย stub)
```

> ขาดข้อใดข้อหนึ่ง → task ยัง **ไม่พร้อมเริ่ม** — กลับไปเติมให้ครบ

---

## Definition of Done (DoD) — ก่อน `[~]` → `[x]`

ต้องผ่าน **7 ข้อ** (ดูรายละเอียดใน CLAUDE.md):
```
TC · TEST · REPORT · LOG · FB (ถ้าปิด feature) · DOC · STATUS
```

---

## 3-Tier Model Routing

| Tier | Model | ใช้กับ |
|------|-------|--------|
| 1 | **Haiku 4.5** | rename, format, simple edit, config, scaffold, seed |
| 2 | **Sonnet 4.6** | feature impl, refactor, test writing, bug fix, integration |
| 3 | **Opus 4.7** | architecture, security design, complex reasoning, deep debug |

---

## Agent Routing

| Task type | Agents | Count | Topology |
|-----------|--------|-------|----------|
| Simple edit | tool-only | 0 | — |
| Bug fix | researcher → coder → tester | 3 | hierarchical |
| Feature ใหม่ | architect → coder → tester → reviewer | 4 | hierarchical |
| Refactor | architect → coder → reviewer | 3 | hierarchical |
| Performance | perf-engineer + coder | 2 | hierarchical |
| Security audit | security-architect + security-auditor | 2 | hierarchical |
| Research / Spike | researcher | 1 | — |
| Test writing | tester | 1 | — |
| Code review | reviewer | 1 | — |
| Complex (≥ 3 modules) | architect + 2× coder + tester + reviewer | 5 | hierarchical-mesh |

---

## Task Code Prefix

| Phase | Prefix | ตัวอย่าง |
|-------|--------|---------|
| Research (optional) | RR | RR-AUTH-001-20260513 (ดู `10-value-research.md`) |
| Backlog | BL | BL-001 |
| Setup & Config | SETUP | SETUP-001 |
| Authentication | AUTH | AUTH-001 |
| Layout & Nav | LAYOUT | LAYOUT-001 |
| [Module A] | [A] | A-001 |
| Reports | RPT | RPT-001 |
| Admin & Settings | ADMIN | ADMIN-001 |
| QA & Testing | QA | QA-001 |
| Deploy | DEPLOY | DEPLOY-001 |
| Feature Brief | FB | FB-AUTH-001-20260513 (ดู `14-feature-release.md`) |

---

## 📥 Backlog (Unprioritized Ideas)

> ที่เก็บ idea / request ที่ยังไม่จัด Phase + Wave — ทำ triage แล้วค่อยย้ายไป Phase ที่เหมาะ
> รูปแบบ: `BL-NNN` (running) · กรอก Pri/Est/Labels ตอน triage

| Task | งาน | Pri | Est | Labels | แหล่งที่มา | Note |
|------|-----|-----|-----|--------|-----------|------|
| BL-001 | _ตัวอย่าง: Export ข้อมูลเป็น Excel_ | P2 | M | feature customer-req | คุณ X (2026-05-10) | รอ research format |
| BL-002 | _ตัวอย่าง: Refactor logger ใช้ pino_ | P3 | S | tech-debt refactor | tech-debt review | — |

---

## Phase R — Research (Optional, ถ้า requirement ไม่ชัด)

| Wave | Task | งาน | Pri | Asg | Est | Labels | Model | Agent | N | Deps | สถานะ |
|------|------|-----|-----|-----|-----|--------|-------|-------|---|------|-------|
| W1 | **RR-XXX-001** | Research [topic 1] (10-Value + 3 src/option) | P0 | — | M | research | Opus | researcher | 1 | — | [ ] |
| W1 | **RR-YYY-001** | Research [topic 2] | P0 | — | M | research | Opus | researcher | 1 | — | [ ] |
| W2 | **RR-REVIEW** | Stakeholder review → APPROVED | P0 | — | S | research | — | (manual) | 0 | RR-XXX-001, RR-YYY-001 | [ ] |

> ทุก RR ต้องผ่าน Source Verification (T1 ≥ 1 · ≥3 refs · recency) ก่อน APPROVED
> `RR-REVIEW` = gate — ห้ามเริ่ม Phase 0 ก่อน APPROVED

---

## Phase 0 — Setup & Config

| Wave | Task | งาน | Pri | Asg | Est | Labels | Model | Agent | N | Deps | สถานะ |
|------|------|-----|-----|-----|-----|--------|-------|-------|---|------|-------|
| W1 | **SETUP-001** | Init repo + install deps | P0 | — | XS | infra | Haiku | tool-only | 0 | — | [ ] |
| W1 | **SETUP-002** | Config env (.env.example ครบ) | P0 | — | XS | infra security | Haiku | tool-only | 0 | — | [ ] |
| W2 | **SETUP-003** | Prisma schema + initial migration | P0 | — | S | infra | Sonnet | backend-dev | 1 | SETUP-001 | [ ] |
| W2 | **SETUP-004** | ESLint + Prettier + TS strict | P1 | — | XS | infra | Haiku | tool-only | 0 | SETUP-001 | [ ] |
| W3 | **SETUP-005** | Config Jest / Vitest | P1 | — | XS | qa infra | Haiku | tool-only | 0 | SETUP-001 | [ ] |
| W3 | **SETUP-006** | Seed data (admin + sample) | P1 | — | S | infra | Sonnet | backend-dev | 1 | SETUP-003 | [ ] |

---

## Phase 1 — Authentication

| Wave | Task | งาน | Pri | Asg | Est | Labels | Model | Agent | N | Deps | สถานะ |
|------|------|-----|-----|-----|-----|--------|-------|-------|---|------|-------|
| W1 | **AUTH-001** | User model + migration | P0 | — | S | security feature | Sonnet | backend-dev | 1 | SETUP-003 | [ ] |
| W2 | **AUTH-002** | Login API (POST /auth/login) | P0 | — | M | security feature | Sonnet | backend-dev + tester | 2 | AUTH-001 | [ ] |
| W2 | **AUTH-003** | Logout API (POST /auth/logout) | P0 | — | S | security feature | Sonnet | backend-dev + tester | 2 | AUTH-001 | [ ] |
| W2 | **AUTH-004** | Session / JWT middleware | P0 | — | L | security | Opus | security-architect + backend-dev | 2 | AUTH-001 | [ ] |
| W3 | **AUTH-005** | Login page (UI) | P0 | — | M | feature ui | Sonnet | coder + tester | 2 | AUTH-002 | [ ] |
| W4 | **AUTH-006** | Route protection (redirect) | P0 | — | S | security | Sonnet | coder | 1 | AUTH-004, AUTH-005 | [ ] |
| W4 | **AUTH-007** | RBAC (admin/user/viewer) | P0 | — | M | security | Opus | security-architect + coder | 2 | AUTH-004 | [ ] |

---

## Phase 2 — Layout & Navigation

| Wave | Task | งาน | Pri | Asg | Est | Labels | Model | Agent | N | Deps | สถานะ |
|------|------|-----|-----|-----|-----|--------|-------|-------|---|------|-------|
| W1 | **LAYOUT-001** | App shell (sidebar + header + main) | P1 | — | M | feature ui | Sonnet | coder | 1 | AUTH-006 | [ ] |
| W2 | **LAYOUT-002** | Responsive sidebar | P1 | — | M | feature ui | Sonnet | coder + tester | 2 | LAYOUT-001 | [ ] |
| W2 | **LAYOUT-003** | Navigation items ตาม role | P1 | — | S | feature ui security | Sonnet | coder | 1 | LAYOUT-001, AUTH-007 | [ ] |
| W3 | **LAYOUT-004** | Dark mode toggle | P2 | — | XS | feature ui | Haiku | tool-only | 0 | LAYOUT-001 | [ ] |
| W3 | **LAYOUT-005** | Loading skeleton | P2 | — | XS | ui | Haiku | coder | 1 | — | [ ] |
| W3 | **LAYOUT-006** | Toast notification | P2 | — | XS | ui | Haiku | tool-only | 0 | — | [ ] |

---

## Phase 3 — [Module A]
> แทนที่ด้วย module จริง

| Wave | Task | งาน | Pri | Asg | Est | Labels | Model | Agent | N | Deps | สถานะ |
|------|------|-----|-----|-----|-----|--------|-------|-------|---|------|-------|
| W1 | **A-001** | API: GET /api/[r] (list+page+filter) | P1 | — | M | feature | Sonnet | backend-dev + tester | 2 | AUTH-007 | [ ] |
| W1 | **A-002** | API: POST /api/[r] (create+validate) | P1 | — | M | feature | Sonnet | backend-dev + tester | 2 | AUTH-007 | [ ] |
| W2 | **A-003** | API: PUT /api/[r]/:id (update) | P1 | — | S | feature | Sonnet | backend-dev + tester | 2 | A-002 | [ ] |
| W2 | **A-004** | API: DELETE /api/[r]/:id (soft) | P1 | — | S | feature | Sonnet | backend-dev + tester | 2 | A-002 | [ ] |
| W3 | **A-005** | List page (DataTable+filter+page) | P1 | — | M | feature ui | Sonnet | coder + tester | 2 | A-001 | [ ] |
| W3 | **A-006** | Form component (create+edit) | P1 | — | M | feature ui | Sonnet | coder + tester | 2 | A-002, A-003 | [ ] |
| W4 | **A-007** | Unit test: [resource]Service | P1 | — | S | qa | Sonnet | tester | 1 | A-004 | [ ] |

---

## Phase QA — Testing

> 3 ประเภท (Unit · Smoke · E2E) ตาม standards ใน `09-testing.md`

| Wave | Task | งาน | Pri | Asg | Est | Labels | Model | Agent | N | Deps | สถานะ |
|------|------|-----|-----|-----|-----|--------|-------|-------|---|------|-------|
| W1 | **QA-001** | Unit Test ทุก service (≥70% cov) | P0 | — | M | qa | Sonnet | tester | 1 | Phase 3 | [ ] |
| W1 | **QA-002** | Smoke Test API — 4-case matrix | P0 | — | M | qa | Sonnet | tester | 1 | Phase 3 | [ ] |
| W2 | **QA-003** | E2E: login flow | P0 | — | S | qa | Sonnet | tester | 1 | QA-002 | [ ] |
| W2 | **QA-004** | E2E: CRUD ทุก module | P0 | — | M | qa | Sonnet | tester | 1 | QA-002 | [ ] |
| W2 | **QA-005** | E2E: form validation errors | P0 | — | S | qa | Sonnet | tester | 1 | QA-002 | [ ] |
| W3 | **QA-006** | E2E: responsive 375/768/1440 | P0 | — | M | qa ui | Sonnet | tester | 1 | QA-003, QA-004 | [ ] |
| W3 | **QA-007** | E2E: dark mode ทุกหน้า | P2 | — | S | qa ui | Haiku | tester | 1 | QA-003, QA-004 | [ ] |
| W3 | **QA-008** | E2E: console + network clean | P0 | — | S | qa | Sonnet | tester | 1 | QA-003, QA-004 | [ ] |
| W4 | **QA-009** | E2E Prod Smoke (read-only) | P0 | — | S | qa | Sonnet | tester | 1 | DEPLOY-005 | [ ] |
| W4 | **QA-010** | Lighthouse ≥ 80 | P1 | — | S | perf | Sonnet | perf-engineer | 1 | QA-006 | [ ] |
| W4 | **QA-011** | Security: OWASP ASVS L1 + audit | P0 | — | M | security compliance | Opus | security-auditor | 1 | QA-008 | [ ] |

---

## Phase Deploy

| Wave | Task | งาน | Pri | Asg | Est | Labels | Model | Agent | N | Deps | สถานะ |
|------|------|-----|-----|-----|-----|--------|-------|-------|---|------|-------|
| W1 | **DEPLOY-001** | ตรวจ env vars ครบทุก env | P0 | — | XS | infra release | Haiku | tool-only | 0 | QA-011 | [ ] |
| W1 | **DEPLOY-002** | Run migration บน prod DB | P0 | — | S | infra release | Sonnet | backend-dev | 1 | DEPLOY-001 | [ ] |
| W2 | **DEPLOY-003** | Build + typecheck | P0 | — | XS | release | Haiku | tool-only | 0 | DEPLOY-001 | [ ] |
| W3 | **DEPLOY-004** | Deploy staging + smoke | P0 | — | S | release qa | Sonnet | tester | 1 | DEPLOY-003 | [ ] |
| W4 | **DEPLOY-005** | Deploy production | P0 | — | S | release | Sonnet | backend-dev | 1 | DEPLOY-004 | [ ] |
| W5 | **DEPLOY-006** | Prod smoke (QA-009) | P0 | — | XS | release qa | Sonnet | tester | 1 | DEPLOY-005 | [ ] |
| W6 | **DEPLOY-007** | Monitor logs 30 นาที | P0 | — | XS | release | Haiku | tool-only | 0 | DEPLOY-006 | [ ] |
| W6 | **DEPLOY-008** | Update README + notify | P1 | — | XS | release | Haiku | tool-only | 0 | DEPLOY-006 | [ ] |

---

## วิธีใช้ตาราง (สำหรับ AI ที่รับ plan)

```
1. ตรวจ DoR ครบ 5 ข้อก่อน (req + deps + est + asg + TC)
2. หา task [ ] + deps พร้อม + DoR ผ่าน → mark [~]
3. set Model + spawn Agent ตาม Count
   - N=0 → ใช้ Bash/Edit/Write ตรง
   - N=1 → Agent({ subagent_type })
   - N≥2 → spawn parallel ในข้อความเดียว + SendMessage instruction
4. ทำงานตาม Wave (parallel ภายใน wave / sequential ระหว่าง wave)
5. ทำเสร็จ → check DoD 7 ข้อ (bash scripts/check-dod.sh)
6. mark [x] + แจ้งสรุป
```

### ตัวอย่าง: AUTH-002 (P0 · M · backend-dev + tester · 2)

```javascript
Agent({
  subagent_type: "backend-dev",
  name: "auth-impl",
  prompt: "Implement POST /auth/login per 05-api-spec.md. SendMessage to 'auth-test' when done.",
  run_in_background: true
})
Agent({
  subagent_type: "tester",
  name: "auth-test",
  prompt: "Wait for 'auth-impl'. Create TC-AUTH-001 in 11-test-cases.md (Smoke + E2E). Run 4-case matrix + E2E flow. Create Test Report.",
  run_in_background: true
})
SendMessage({ to: "auth-impl", summary: "Start", message: "AUTH-002 — implement login API" })
```

---

## Summary Progress

| Phase | Waves | Tasks | Agents (spawn) | เสร็จ | % |
|-------|-------|-------|---------------|------|---|
| Backlog | — | varies | — | — | — |
| R — Research (optional) | 2 | varies | varies | 0 | 0% |
| 0 — Setup | 3 | 6 | 2 | 0 | 0% |
| 1 — Auth | 4 | 7 | 11 | 0 | 0% |
| 2 — Layout | 3 | 6 | 5 | 0 | 0% |
| 3 — Module A | 4 | 7 | 13 | 0 | 0% |
| QA | 4 | 11 | 11 | 0 | 0% |
| Deploy | 6 | 8 | 4 | 0 | 0% |
| **รวม (non-backlog)** | **26** | **45** | **46** | **0** | **0%** |

---

## Changelog

| เวอร์ชัน | วันที่ | รายละเอียด |
|---------|-------|-----------|
| v1.0 | YYYY-MM-DD | สร้าง template |
| v2.0 | YYYY-MM-DD | เพิ่ม Wave/Model/Agent/Count/Deps + 3-Tier Routing |
| v3.0 | YYYY-MM-DD | เพิ่ม Priority + Assignee + Estimate + Labels + DoR + Backlog (PM-tool concepts) |

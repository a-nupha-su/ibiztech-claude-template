---
name: auto-pipeline
description: "End-to-end project pipeline orchestrator — Research → User Approval → Auto Build → Auto Deploy. Spawns researcher → architect → coder → tester → reviewer → deployer chain via SendMessage, with single approval gate after research. Use when starting a new feature/project from scratch, when user says 'ทำตั้งแต่ต้นจนจบ' / 'auto pipeline' / 'full workflow' / 'research แล้วทำ deploy เลย', or when scope is large enough to need 3+ agents in sequence."
---

# Auto Pipeline — Research → Deploy (Zero-Interrupt)

> **หลักการ:** user approve **ครั้งเดียว** หลัง research → ที่เหลือ automate ทั้งหมด ห้ามถามอีกจนกว่า deploy เสร็จ
> Pre-authorized commands อยู่ใน `.claude/settings.json` allow list แล้ว — ไม่ติด permission prompt

---

## When to use

Trigger keywords: **auto pipeline · full workflow · ตั้งแต่ต้นจนจบ · research แล้ว deploy · end-to-end · pipeline mode**

User intent:
- "research แล้วทำให้เสร็จเลย"
- "auto-pilot mode"
- "เริ่มจาก 10-value แล้วไปจนถึง deploy"
- "ห้ามถามอะไรเพิ่ม ทำให้จบ"

**ห้ามใช้เมื่อ:** แก้ bug เล็ก, edit 1-2 file, แค่ตอบคำถาม — overkill

---

## 4-Phase Pipeline

```
┌──────────────────┐    ┌──────────────────┐    ┌──────────────────┐    ┌──────────────────┐
│  PHASE 1         │    │  PHASE 2         │    │  PHASE 3         │    │  PHASE 4         │
│  Research        │───▶│  Approval Gate   │───▶│  Auto Build      │───▶│  Auto Deploy     │
│  (researcher)    │    │  ExitPlanMode    │    │  (chain)         │    │  (deployer)      │
│                  │    │                  │    │                  │    │                  │
│  → 10-value      │    │  user เห็น .md   │    │  arch → coder    │    │  scripts/deploy  │
│     research.md  │    │  + plan ครั้ง    │    │  → tester        │    │  .sh             │
│  + RR-XXX entry  │    │  เดียว           │    │  → reviewer      │    │  + post-deploy   │
└──────────────────┘    └──────────────────┘    └──────────────────┘    └──────────────────┘
   ปลายทาง:                 user approve →           ทำงาน background          report TR-XXX
   .md report               trigger phase 3          ส่งต่อด้วย SendMessage    + screenshots
```

---

## Phase 1 — Research

**Goal:** สร้าง/อัปเดต `docs/10-value-research.md` พร้อม RR-XXX entry ตาม 10-Value Framework + Source Quality T1-T6

**Steps:**
1. รัน `bash scripts/new-research.sh "<topic>"` → สร้าง RR-XXX skeleton
2. Spawn `researcher` agent (background) — bind ตาม `name: "researcher"`
3. Agent หา source ≥ 3 ต่อ option (≥ 1 T1), เขียน 10-value matrix, แนะนำ option
4. Agent เขียน entry กลับเข้า `docs/10-value-research.md`
5. Agent SendMessage กลับมา lead พร้อม path + summary

**Acceptance:** Entry มีครบ 10 values, source tier + recency ผ่าน, มี Recommendation + Rationale

```javascript
Agent({
  prompt: `อ่าน docs/10-value-research.md และ docs/01-requirement.md
  ทำ research สำหรับ <TOPIC> ตาม 10-Value Framework
  - หา ≥3 sources/option (≥1 T1)
  - เขียน RR-XXX entry กลับเข้า 10-value-research.md
  - เสร็จแล้ว SendMessage to 'lead' พร้อม path + 5-line summary`,
  subagent_type: "researcher",
  name: "researcher",
  run_in_background: true
})
```

---

## Phase 2 — Approval Gate (จุดเดียวที่ถาม user)

หลัง `researcher` ส่งสรุปกลับมา → ใช้ `ExitPlanMode` ครั้งเดียว
- แสดง: link RR-XXX + recommended option + implementation outline (จาก `07-implement-plan.md`)
- User approve → phase 3 เริ่มทันที (ห้ามถามอีก)
- User reject → loop phase 1 พร้อม feedback

**ห้าม:**
- ถาม "do you want to proceed?" หลังจุดนี้
- ถามรายละเอียดทีละไฟล์
- ขอ confirm command ทุกตัว (allowlist ใน settings.json จัดการแล้ว)

---

## Phase 3 — Auto Build (Chain, Background)

Spawn **ทั้ง chain ใน 1 message** หลัง approve:

```javascript
// All in ONE message
Agent({ prompt: "Wait for SendMessage from 'lead'. อ่าน RR-XXX + 01/02/03/04. ออกแบบ + อัปเดต 07-implement-plan.md. แตกเป็น tasks. SendMessage to 'coder'.",
  subagent_type: "system-architect", name: "architect", run_in_background: true })

Agent({ prompt: "Wait for 'architect'. ทำ tasks ตาม 07-implement-plan.md. รัน bash scripts/new-task.sh + check-dod.sh. SendMessage to 'tester' เมื่อเสร็จแต่ละ task.",
  subagent_type: "coder", name: "coder", run_in_background: true })

Agent({ prompt: "Wait for 'coder'. เขียน + รัน tests ตาม 09-testing.md + 11-test-cases.md. รัน bash scripts/new-report.sh + log-test.sh. SendMessage to 'reviewer'.",
  subagent_type: "tester", name: "tester", run_in_background: true })

Agent({ prompt: "Wait for 'tester'. ใช้ skill sonar-quality-gate ตรวจ. ถ้าผ่าน SendMessage to 'deployer'. ถ้าไม่ผ่าน SendMessage to 'coder' พร้อม fix list.",
  subagent_type: "reviewer", name: "reviewer", run_in_background: true })

Agent({ prompt: "Wait for 'reviewer' (PASS). รัน bash scripts/deploy.sh. รายงาน deploy URL + health check กลับ 'lead'.",
  subagent_type: "coder", name: "deployer", run_in_background: true })

// Kick off
SendMessage({ to: "architect", summary: "Start build", message: "RR-XXX approved. Begin." })
```

**กฎ:**
- ทุก agent `run_in_background: true`
- ทุก agent ต้อง `name:` ให้ addressable
- ทุก prompt ต้องระบุ "SendMessage to '<next>'" — chain ไม่ขาด
- Lead **หยุดรอ** หลัง spawn — ห้าม poll

---

## Phase 4 — Auto Deploy

`deployer` agent รัน `bash scripts/deploy.sh` — script จะ dispatch ตาม target ใน `.env.deploy`:

| Target | Command (in deploy.sh) |
|--------|------------------------|
| Vercel | `vercel deploy --prod --yes` |
| Docker | `docker build && docker push && kubectl rollout` |
| GH Actions | `gh workflow run deploy.yml --ref main` |
| SSH | `rsync + systemctl restart` |

**Post-deploy:**
1. Health check (curl deploy URL → 200)
2. รัน `bash scripts/new-report.sh deploy` → สร้าง TR-deploy entry
3. Update `docs/14-feature-release.md` (FB status → SHIPPED)
4. SendMessage to 'lead' พร้อม URL + report path

---

## Permission ที่ต้อง pre-authorize

ทั้งหมดอยู่ใน `.claude/settings.json` แล้ว (allow):
- All `bash scripts/*` (lifecycle scripts)
- `pnpm test/lint/build/typecheck`
- `git status/log/diff/branch/show`
- `mcp__playwright__*` (E2E)
- Edit `docs/10-XX.md` (research/test logs)
- `sonar-scanner`, `jmeter`, `jq`, `curl`

**Still asks (ตั้งใจ):**
- Edit `src/**`, `apps/**`, `packages/**` (code) → reviewer gate
- `git commit/push/checkout` → human decision
- `pnpm add/install` → dependency change
- `prisma migrate` → DB change

---

## Failure Modes & Recovery

| ขั้น | ถ้าพัง | Recovery |
|------|--------|----------|
| Phase 1 (research) | source ไม่พอ T1 / recency เก่า | researcher loop หาใหม่ ไม่กลับมาหา lead จนครบ |
| Phase 2 (approval) | user reject | feedback ส่งกลับ researcher → phase 1 ใหม่ |
| Phase 3 (build) | test fail | tester SendMessage to 'coder' พร้อม fail log → fix → re-test |
| Phase 3 (review) | quality gate fail | reviewer SendMessage to 'coder' พร้อม issue list |
| Phase 4 (deploy) | health check fail | deployer รัน rollback script + SendMessage to 'lead' พร้อม error |

**Lead intervention:** เฉพาะ phase 2 (approval) เท่านั้น — ขั้นอื่นห้าม interrupt

---

## Quick Start

```bash
# 1. Setup project (ครั้งเดียว)
bash setup.sh
bash scripts/setup-sonar.sh
bash scripts/setup-jmeter.sh
cp .env.deploy.example .env.deploy   # ระบุ target

# 2. เรียก pipeline
# ใน Claude Code:
"/auto-pipeline <topic หรือ FR>"
# หรือบอกตรง ๆ:
"ทำ auto pipeline เรื่อง <topic> ตั้งแต่ research จนถึง deploy"
```

Lead จะ:
1. Spawn researcher → รอ
2. แสดง research summary + ExitPlanMode
3. หลัง approve → spawn 5-agent chain
4. รอ deployer report → แสดง deploy URL ให้ user

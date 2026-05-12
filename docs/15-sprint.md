# 15 — Sprint Planning, Review & Retrospective
**[Project Name]**

| เวอร์ชัน | วันที่ |
|---------|-------|
| v1.0 | YYYY-MM-DD |

> ใช้คู่กับ `07-implement-plan.md` — แบ่ง task ใน 07 เป็น sprint (time-boxed iteration)
> เก็บ velocity + retrospective เพื่อปรับปรุงรอบถัดไป
> ทำต่อรอบ — 1 sprint = 1-2 สัปดาห์ตามที่ team ตกลง

---

## Sprint Convention

```
SP-{NNN}-{YYYYMMDD}
```

| ส่วน | ความหมาย | ตัวอย่าง |
|------|---------|---------|
| `SP` | Sprint (คงที่) | `SP` |
| `NNN` | running 3 หลัก | `001`, `002` |
| `YYYYMMDD` | วันที่เริ่ม sprint | `20260513` |

ตัวอย่าง: `SP-001-20260513` = Sprint #1 เริ่ม 13 พ.ค. 2026

---

## Sprint Status

| Status | ความหมาย |
|--------|---------|
| `PLANNING` | กำลังวาง sprint goal + เลือก task |
| `IN_PROGRESS` | sprint active |
| `REVIEW` | ทำ demo / showcase |
| `RETRO` | ทำ retrospective |
| `CLOSED` | ปิด sprint แล้ว |

---

## Sprint Index

| Sprint | Goal | Status | Start | End | Committed | Done | Velocity |
|--------|------|--------|-------|-----|-----------|------|----------|
| _ตัวอย่าง_ SP-001-20260513 | Foundation (Auth + Layout) | CLOSED | 2026-05-13 | 2026-05-26 | 13 pts | 11 pts | 11 pts |
| SP-002-YYYYMMDD | [Module A CRUD] | PLANNING | — | — | — | — | — |

> **Velocity** = sum of Estimates ที่ Done ใน sprint (เปลี่ยน T-shirt → points: XS=1 · S=2 · M=3 · L=5 · XL=8)

---

# ╔════════════════════════════════════════════════╗
# ║   SPRINT TEMPLATE (copy block ด้านล่างไปใช้)    ║
# ╚════════════════════════════════════════════════╝

## SP-XXX-YYYYMMDD — [Sprint Name / Theme]

### 1. Sprint Info

| Field | Value |
|-------|-------|
| Sprint Code | `SP-XXX-YYYYMMDD` |
| Sprint Name | [เช่น "Foundation — Auth + Layout"] |
| Status | `PLANNING` / `IN_PROGRESS` / `REVIEW` / `RETRO` / `CLOSED` |
| Start Date | YYYY-MM-DD |
| End Date | YYYY-MM-DD |
| Duration | 2 weeks |
| Team Capacity | __ คน × __ วัน = __ คน-วัน |

### 2. Sprint Goal

> 1-2 ประโยคที่สรุปว่า sprint นี้ต้องส่งอะไร (outcome ไม่ใช่ task list)

ตัวอย่าง: "ผู้ใช้สามารถ login + เข้าหน้า dashboard ที่มี layout + navigation ครบ พร้อม responsive ทั้ง desktop + mobile"

### 3. Committed Tasks (จาก 07-implement-plan.md)

> ทุก task ต้องผ่าน **DoR 5 ข้อ** ก่อน commit เข้า sprint

| Task | งาน | Pri | Asg | Est (pts) | Status |
|------|-----|-----|-----|-----------|--------|
| AUTH-001 | User model + migration | P0 | @anu | 2 (S) | [ ] |
| AUTH-002 | Login API | P0 | @anu | 3 (M) | [ ] |
| AUTH-005 | Login page UI | P0 | @dev2 | 3 (M) | [ ] |
| LAYOUT-001 | App shell | P1 | @dev2 | 3 (M) | [ ] |
| LAYOUT-002 | Responsive sidebar | P1 | @dev2 | 3 (M) | [ ] |
| **รวม** | | | | **14 pts** | |

> Capacity check: 14 pts vs team velocity ที่ผ่านมา (~11 pts) → **stretch** (อาจไม่จบ 100%)

### 4. Stretch Tasks (ทำถ้าเวลาเหลือ)

| Task | งาน | Pri | Asg | Est |
|------|-----|-----|-----|-----|
| LAYOUT-004 | Dark mode | P2 | @dev2 | 1 (XS) |

### 5. Risk / Dependencies

| ความเสี่ยง / dependency | Mitigation |
|----------------------|-----------|
| [เช่น รอ design review LAYOUT-001] | นัด review วัน 2 ของ sprint |
| [vendor API down เป็นบางครั้ง] | mock + retry |

### 6. Daily Tracking (optional — ใช้ standup)

| Date | Done yesterday | Today | Blocker |
|------|---------------|-------|---------|
| YYYY-MM-DD | @anu: AUTH-001 [x] | @anu: AUTH-002 | — |
| YYYY-MM-DD | @anu: AUTH-002 [~] | @anu: AUTH-002 | API spec ยังไม่เคลียร์ → @lead |

### 7. Sprint Review (Demo)

**Date:** YYYY-MM-DD

| Feature | Demo OK? | Stakeholder feedback |
|---------|:--------:|---------------------|
| Login flow (AUTH-002, AUTH-005) | ✅ | "form ดูสะอาด" |
| App shell (LAYOUT-001) | ✅ | "sidebar เกะกะตอน mobile — แก้ใน sprint หน้า" |

**Demo URL / Recording:** [link]

### 8. Sprint Outcome

| Metric | Planned | Actual | Δ |
|--------|---------|--------|---|
| Committed pts | 14 | 14 | 0 |
| Completed pts | — | 11 | **-3 (78%)** |
| Carry-over | — | LAYOUT-002 | — |
| Bugs found (ISS) | — | 2 | — |
| Features shipped (FB) | — | 1 (FB-AUTH-001) | — |

### 9. Retrospective (Start / Stop / Continue)

**🟢 Start (เริ่มทำ — improvement ใหม่):**
-
-

**🔴 Stop (เลิก — สิ่งที่ไม่ work):**
-
-

**🟡 Continue (ทำต่อ — สิ่งที่ work):**
-
-

**Action Items (ต้องทำใน sprint หน้า):**
| Action | Owner | Due |
|--------|-------|-----|
| | | |

### 10. Sign-off

| Role | ชื่อ | วันที่ |
|------|------|-------|
| Scrum Master / Lead | _____________ | YYYY-MM-DD |
| Team (consensus) | _____________ | YYYY-MM-DD |
| PO / Stakeholder | _____________ | YYYY-MM-DD |

---

```
╔════════════════════════════════════════════════╗
║   SPRINT TEMPLATE ENDS HERE                     ║
╚════════════════════════════════════════════════╝
```

---

## Estimate → Story Points Mapping

| T-shirt | Story Points | คน-วัน (ประมาณ) |
|---------|:------------:|----------------|
| XS | 1 | ≤ 0.25 |
| S | 2 | ≤ 1 |
| M | 3 | ≤ 3 |
| L | 5 | ≤ 7 |
| XL | 8 | ≤ 14 |

> เกิน XL → ต้องแตก task ก่อนเข้า sprint

---

## Velocity Tracking

| Sprint | Committed | Done | Velocity (rolling avg 3) |
|--------|:---------:|:----:|:------------------------:|
| SP-001 | 14 | 11 | 11 |
| SP-002 | 13 | 12 | 11.5 |
| SP-003 | 12 | 12 | 11.67 |

ใช้ rolling 3-sprint avg เป็น baseline ตอน plan sprint ถัดไป

---

## กฎสำคัญ

1. **DoR ก่อน commit เข้า sprint** — task ที่ DoR ไม่ครบ ห้ามใส่ใน Committed list
2. **Committed ≤ velocity × 1.1** — ห้าม over-commit เกิน 10% ของ baseline
3. **Carry-over ลด priority sprint ถัดไป** — แก้ root cause ใน retro
4. **Retro action items บังคับมี owner + due** — ไม่งั้นไม่เกิดผล
5. **Sign-off ครบ 3 ก่อน CLOSED** — Lead + Team + PO
6. **ห้ามแก้ Committed กลาง sprint** — ใช้ Stretch แทน + ปรับ next sprint

---

## Workflow Integration

```
07-implement-plan.md (task pool)
        │
        ▼
Sprint Planning meeting → เลือก task ที่ DoR ครบ + priority สูง
        │
        ▼
SP-XXX-YYYYMMDD (Status: PLANNING → IN_PROGRESS)
        │
        ▼
Daily standup → update Section 6
        │
        ▼
รัน task ตาม Wave ใน 07 → mark [~] → DoD → [x]
        │
        ▼
Sprint Review (demo) → Section 7
        │
        ▼
Retrospective → Section 9 (Start/Stop/Continue)
        │
        ▼
Sign-off → CLOSED → Plan SP-(XXX+1)
```

---

## Changelog

| เวอร์ชัน | วันที่ | รายละเอียด |
|---------|-------|-----------|
| v1.0 | YYYY-MM-DD | สร้าง template (Sprint Planning + Review + Retro) |

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

## วิธี log

```markdown
### ISS-XXX — [ชื่อปัญหาสั้น ๆ]
- **วันที่:** YYYY-MM-DD
- **Status:** OPEN / INVESTIGATING / FIXED / CLOSED / WONTFIX / DUPLICATE
- **Severity:** CRITICAL / HIGH / MEDIUM / LOW
- **Task:** [task code ที่เกี่ยวข้อง]
- **TC / TR:** [TC-XXX-NNN, TR-XXX-NNN-YYYYMMDD] (ถ้าเจอตอน test)
- **อาการ:** [error message หรืออาการที่เห็น]
- **Root Cause:** [สาเหตุแท้จริง — เติมเมื่อ INVESTIGATING/FIXED]
- **Fix:** [วิธีแก้ที่ใช้ — เติมเมื่อ FIXED]
- **บทเรียน:** [ป้องกันครั้งต่อไปยังไง]
- **Closed Date:** YYYY-MM-DD (เติมเมื่อ CLOSED)
```

---

## Issues

### ISS-001 — [ตัวอย่าง: Prisma migration failed on prod]
- **วันที่:** YYYY-MM-DD
- **Status:** CLOSED
- **Severity:** HIGH
- **Task:** SETUP-003
- **TC / TR:** —
- **อาการ:** `Error: P3009 migrate found failed migration`
- **Root Cause:** migration บน local ใช้ SQLite แต่ prod ใช้ PostgreSQL — syntax ต่างกัน
- **Fix:** ลบ migration ที่ fail + สร้างใหม่ด้วย postgres dialect
- **บทเรียน:** dev env ต้องใช้ DB ชนิดเดียวกับ prod เสมอ
- **Closed Date:** YYYY-MM-DD

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

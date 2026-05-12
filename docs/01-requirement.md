# 01 — Requirement
**[Project Name]**

| เวอร์ชัน | วันที่ |
|---------|-------|
| v1.0 | YYYY-MM-DD |

> เขียนไฟล์นี้ให้ครบก่อน `07-implement-plan.md`
> ทุก FR ที่อยู่ในนี้ต้องมี task code คู่กันใน 07

---

## Overview

| รายการ | รายละเอียด |
|-------|-----------|
| ชื่อโปรเจกต์ | [Project Name] |
| ลูกค้า / เจ้าของ | — |
| Stakeholders | — |
| Deadline | YYYY-MM-DD |
| Variant | Fullstack / Separated API |

---

## Roles & Permissions

| Role | ทำอะไรได้ | ห้ามทำ |
|------|----------|--------|
| `admin` | จัดการ user + module ทั้งหมด | — |
| `user` | CRUD ข้อมูลของตัวเอง | แก้ของคนอื่น |
| `viewer` | อ่านอย่างเดียว | mutate ทุกอย่าง |

> ใช้ matrix นี้เป็น single source สำหรับ `RolesGuard` / route protection

---

## Functional Requirements (FR)

> รูปแบบ: FR-XXX — สิ่งที่ระบบต้องทำได้ (ผูกกับ task code ใน 07)

### FR-001 — [ตัวอย่าง: User Authentication]
- ผู้ใช้ login ด้วย email + password ได้
- ระบบสร้าง session/JWT ที่หมดอายุ X ชม.
- ผูกกับ task: `AUTH-001 ... AUTH-007`

### FR-002 — [Module ตัวอย่าง]
- ผู้ใช้ role `admin` สร้าง/แก้/ลบ [resource] ได้
- ผู้ใช้ role `user` ดูได้เฉพาะของตัวเอง
- ผูกกับ task: `A-001 ... A-007`

---

## Non-Functional Requirements (NFR)

| ด้าน | เป้าหมาย |
|------|---------|
| Performance | First Contentful Paint < 1.5s บน 4G |
| Lighthouse | ≥ 80 ทุก category |
| Security | ผ่าน checklist ใน `08-performance-security.md` |
| Availability | uptime ≥ 99% (ไม่นับ planned maintenance) |
| Browser support | Chrome / Safari / Edge 2 รุ่นล่าสุด |
| Mobile support | iOS 15+ / Android 10+ |
| Accessibility | WCAG 2.1 AA (form labels + keyboard navigation) |

---

## Out of Scope (v1)

- [ระบุสิ่งที่ "ไม่ทำ" รอบนี้ — กัน scope creep]
- ตัวอย่าง: real-time notification, multi-tenant, audit log UI

---

## Acceptance Criteria (รวม)

ก่อน hand-off ให้ลูกค้า ต้องผ่าน:
- [ ] ทุก FR มี task code `[x]` ครบใน 07
- [ ] QA-001 ถึง QA-008 ผ่านทั้งหมด
- [ ] Prod smoke test ผ่าน (QA-007)
- [ ] README + user manual อัพเดต
- [ ] 12-log-issues.md ไม่มี issue ค้างที่ severity สูง

---

## Changelog

| เวอร์ชัน | วันที่ | รายละเอียด |
|---------|-------|-----------|
| v1.0 | YYYY-MM-DD | สร้าง template |

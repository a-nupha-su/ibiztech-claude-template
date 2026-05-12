# 13 — Test Case Log
**[Project Name]**

| เวอร์ชัน | วันที่ |
|---------|-------|
| v1.0 | YYYY-MM-DD |

> บันทึก **สรุป** ทุกครั้งที่ทดสอบ — รายละเอียดเต็มอยู่ใน `test-reports/{INDEX_CODE}.md`
> ใช้เป็น audit trail ก่อน deploy และหลัง hotfix
> **บังคับ:** ทุกแถวต้องผูก `Report` index code (ดู `docs/09-testing.md (Section 6)`)

---

## Testing Layers

| ชั้น | เครื่องมือ | เมื่อไหร่ |
|-----|----------|---------|
| **Unit** | Jest / Vitest | ทุก service/util ที่มี logic |
| **Smoke** | curl / fetch | หลัง implement API ทุกตัว |
| **E2E Local** | MCP Playwright | ก่อน mark [x] ทุก UI task |
| **E2E Prod** | MCP Playwright | ก่อน + หลัง deploy (read-only) |

---

## ✅ ผ่าน

| วันที่ | TC | Task | สิ่งที่ทดสอบ | ชั้น | Report | หมายเหตุ |
|--------|-----|------|------------|------|--------|---------|
| YYYY-MM-DD | TC-AUTH-001 | AUTH-002 | POST /api/auth/login → 200 + token | Smoke | `TR-AUTH-001-YYYYMMDD` | — |
| YYYY-MM-DD | TC-AUTH-003 | AUTH-002 | POST /api/auth/login no body → 400 | Smoke | `TR-AUTH-003-YYYYMMDD` | — |
| YYYY-MM-DD | TC-AUTH-004 | AUTH-005 | Login page render desktop 1440px | E2E Local | `TR-AUTH-004-YYYYMMDD` | — |
| YYYY-MM-DD | TC-AUTH-001 | AUTH-005 | Login form submit → redirect dashboard | E2E Local | `TR-AUTH-001-YYYYMMDD` | — |

---

## ❌ ไม่ผ่าน / พบ Bug

| วันที่ | TC | Task | สิ่งที่ทดสอบ | ชั้น | Report | ISS | แก้ใน |
|--------|-----|------|------------|------|--------|-----|------|
| YYYY-MM-DD | TC-LAYOUT-002 | LAYOUT-002 | Mobile sidebar drawer ปิดเมื่อกด overlay | E2E Local | `TR-LAYOUT-002-YYYYMMDD` | ISS-005 | LAYOUT-002 fix |

---

## รอทดสอบ (ทดสอบ browser ไม่ได้ในรอบนี้)

| Task | สิ่งที่ยังไม่ได้ทดสอบ | เหตุผล |
|------|------------------|------|
| — | — | — |

---

## Prod Smoke Test Log

| วันที่ | Deploy version | ผลการทดสอบ | Report | ผู้ทดสอบ |
|--------|--------------|-----------|--------|---------|
| YYYY-MM-DD | v1.0.0 | ✅ login, dashboard, logout ผ่าน | `TR-QA-008-YYYYMMDD` | [ชื่อ] |

---

## Changelog

| เวอร์ชัน | วันที่ | รายละเอียด |
|---------|-------|-----------|
| v1.0 | YYYY-MM-DD | สร้าง template |

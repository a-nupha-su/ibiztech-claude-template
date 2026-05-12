# 05 — Data Dictionary
**[Project Name]** · Fullstack variant เท่านั้น

| เวอร์ชัน | วันที่ |
|---------|-------|
| v1.0 | YYYY-MM-DD |

> อ่านก่อนสร้าง Zod schema หรือ form
> ทุก field ใน DB + ทุก field บน form ต้องมีบรรทัดในไฟล์นี้

---

## Convention

| รายการ | ค่า |
|-------|-----|
| Required mark | ✅ บังคับ / ⬜ optional |
| Date format | ISO 8601 (`2026-01-31T10:00:00Z`) |
| Money | int (เก็บเป็นสตางค์/cent — หลีกเลี่ยง float) |
| Empty | `""` ห้าม — ใช้ `null` แทน |

---

## User

| Field | Type | Required | Validation (Zod) | หมายเหตุ |
|-------|------|----------|-----------------|---------|
| `email` | string | ✅ | `z.string().email().toLowerCase()` | unique |
| `password` | string | ✅ | `z.string().min(8).max(72)` | hash ก่อนเก็บ |
| `name` | string | ✅ | `z.string().min(2).max(100)` | — |
| `role` | enum | ✅ | `z.enum(['ADMIN','USER','VIEWER'])` | default `USER` |
| `is_active` | boolean | ✅ | `z.boolean()` | default `true` |

> ห้าม return `password` field ใน API response — strip ออกใน service layer

---

## [Resource] (template)

| Field | Type | Required | Validation (Zod) | หมายเหตุ |
|-------|------|----------|-----------------|---------|
| `name` | string | ✅ | `z.string().min(2).max(100).trim()` | — |
| `description` | string | ⬜ | `z.string().max(500).nullable()` | — |
| `status` | enum | ✅ | `z.enum(['ACTIVE','INACTIVE'])` | default `ACTIVE` |
| `user_id` | int | ✅ | `z.number().int().positive()` | FK → user |

---

## Common Zod Patterns

```typescript
// Pagination query
const paginationSchema = z.object({
  page: z.coerce.number().int().positive().default(1),
  limit: z.coerce.number().int().min(1).max(100).default(20),
});

// Thai phone
const phoneSchema = z.string().regex(/^0[0-9]{8,9}$/, 'เบอร์ไม่ถูกต้อง');

// Thai ID
const thaiIdSchema = z.string().length(13).regex(/^\d{13}$/);

// Money (เก็บเป็นสตางค์)
const moneySchema = z.number().int().min(0);  // 100 บาท = 10000
```

---

## Form ↔ DB Mapping

| Form field | DB column | Transform |
|-----------|-----------|-----------|
| `email` (lowercase auto) | `email` | `.toLowerCase()` |
| `password` (plain) | `password` | `bcrypt.hash(_, 10)` ก่อนบันทึก |
| `amount_baht` (number, บาท) | `amount` (int, สตางค์) | `× 100` ตอนเซฟ / `÷ 100` ตอนแสดง |

---

## Changelog

| เวอร์ชัน | วันที่ | รายละเอียด |
|---------|-------|-----------|
| v1.0 | YYYY-MM-DD | สร้าง template |

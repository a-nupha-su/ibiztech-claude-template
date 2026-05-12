# 05 — API Specification
**[Project Name]** · Separated API variant เท่านั้น

| เวอร์ชัน | วันที่ |
|---------|-------|
| v1.0 | YYYY-MM-DD |

> **API Contract First** — อัพเดตไฟล์นี้ก่อนเขียนโค้ด controller หรือ fetch เสมอ
> Frontend + Backend ต้อง agree บน spec นี้ก่อน implement

---

## Convention

| รายการ | ค่า |
|--------|-----|
| Base URL | `/api/v1` |
| Auth | `Authorization: Bearer <jwt>` |
| Content-Type | `application/json` |
| Date format | ISO 8601 `2026-01-31T10:00:00Z` |
| Pagination | `?page=1&limit=20` |

### Response Format (Success)
```json
{
  "data": { ... },
  "meta": { "total": 100, "page": 1, "limit": 20, "totalPages": 5 },
  "message": "success"
}
```

### Response Format (Error)
```json
{
  "statusCode": 400,
  "message": "Validation failed",
  "errors": ["field is required"]
}
```

---

## Auth Endpoints

| Method | Path | Auth | Body | Response | Note |
|--------|------|------|------|---------|------|
| POST | `/auth/login` | ❌ | `{ email, password }` | `{ data: { token, user } }` | — |
| POST | `/auth/logout` | ✅ | — | `{ message }` | invalidate token |
| GET | `/auth/me` | ✅ | — | `{ data: UserDto }` | current user |
| POST | `/auth/refresh` | ✅ | `{ refreshToken }` | `{ data: { token } }` | — |

---

## [Module A] Endpoints

> แทนที่ด้วย module จริง

| Method | Path | Auth | Role | Body | Response |
|--------|------|------|------|------|---------|
| GET | `/[resource]` | ✅ | any | — | `{ data: Dto[], meta }` |
| GET | `/[resource]/:id` | ✅ | any | — | `{ data: Dto }` |
| POST | `/[resource]` | ✅ | admin | `CreateDto` | `{ data: Dto }` |
| PUT | `/[resource]/:id` | ✅ | admin | `UpdateDto` | `{ data: Dto }` |
| DELETE | `/[resource]/:id` | ✅ | admin | — | `{ message }` |

### DTOs

```typescript
// CreateDto
{
  name: string;          // required, min 2, max 100
  description?: string;  // optional, max 500
  status: 'active' | 'inactive';  // required
}

// ResponseDto
{
  id: number;
  name: string;
  description: string | null;
  status: string;
  createdAt: string;  // ISO 8601
  updatedAt: string;
}
```

---

## Public Endpoints (ไม่ต้อง Auth)

| Method | Path | Body | Response | Note |
|--------|------|------|---------|------|
| GET | `/health` | — | `{ status: "ok" }` | health check |

---

## Error Codes

| Status | เมื่อไหร่ |
|--------|---------|
| 400 | Validation failed / Bad request |
| 401 | No token / Token expired |
| 403 | Insufficient role |
| 404 | Resource not found |
| 409 | Duplicate (unique constraint) |
| 500 | Internal server error |

---

## Changelog

| เวอร์ชัน | วันที่ | รายละเอียด |
|---------|-------|-----------|
| v1.0 | YYYY-MM-DD | สร้าง template |

# 08 — Performance & Security
**[Project Name]**

| เวอร์ชัน | วันที่ |
|---------|-------|
| v1.0 | YYYY-MM-DD |

> อ่านก่อนเขียน API หรือก่อน deploy

---

## Performance Targets

| Metric | Target | เครื่องมือ |
|--------|--------|----------|
| LCP (Largest Contentful Paint) | < 2.5s | Lighthouse |
| FID / INP | < 200ms | Lighthouse |
| CLS | < 0.1 | Lighthouse |
| Lighthouse Performance | ≥ 80 | Chrome DevTools |
| Lighthouse Accessibility | ≥ 90 | Chrome DevTools |
| Lighthouse SEO | ≥ 90 | Chrome DevTools |
| API response (p95) | < 500ms | log/APM |
| DB query (p95) | < 100ms | Prisma log |

---

## Frontend Performance Rules

- ✅ ใช้ Server Component เป็น default — Client Component เมื่อจำเป็นเท่านั้น
- ✅ `next/image` ทุก image (ห้าม `<img>` ตรง ๆ)
- ✅ `next/font` สำหรับ font (preload + ไม่ FOUT)
- ✅ dynamic import component ใหญ่ (เช่น chart, editor) ที่ไม่ใช่ above-the-fold
- ✅ `loading.tsx` ทุก route ที่ fetch
- ✅ React Query: stale time ≥ 30s สำหรับข้อมูลที่ไม่เปลี่ยนบ่อย
- ❌ ห้าม fetch ใน `useEffect` ถ้าใช้ได้ใน Server Component / loader

---

## Backend Performance Rules

- ✅ Prisma: ใช้ `select` เลือก field ที่ต้องใช้เท่านั้น
- ✅ Prisma: ใช้ `include` แทน N+1 query
- ✅ pagination บังคับ (default limit 20, max 100)
- ✅ index ทุก column ที่ใช้ใน WHERE / JOIN / ORDER BY (ดู 04-database-schema.md)
- ✅ cache response ที่อ่านอย่างเดียว (เช่น dropdown list)
- ❌ ห้าม `findMany()` ไม่มี `take`

---

## Security Rules (เพิ่มจาก CLAUDE.md)

### Authentication & Session

- ✅ password hash ด้วย `bcrypt` (cost ≥ 10)
- ✅ JWT expire ≤ 24 ชม.
- ✅ refresh token rotation (ถ้ามี)
- ✅ logout = blacklist token / revoke session
- ❌ ห้าม store JWT ใน `localStorage` — ใช้ httpOnly cookie

### Input Validation

- ✅ Zod / class-validator ทุก input — บังคับ
- ✅ sanitize HTML ทุกที่ที่ render user input (`DOMPurify` ถ้าจำเป็น)
- ✅ rate limit ทุก endpoint ที่ login/register/forgot-password (≤ 5 req/min)
- ❌ ห้าม trust query string โดยไม่ parse

### Authorization

- ✅ role check **หลัง** auth check
- ✅ ownership check สำหรับ resource ของ user (`WHERE user_id = req.user.id`)
- ✅ admin endpoint ต้องมี audit log
- ❌ ห้าม trust role จาก request body — เอาจาก JWT/session เท่านั้น

### Data Exposure

- ❌ ห้าม return `password`, `password_hash`, `secret`, `token`, `refresh_token`, `private_key`
- ❌ ห้าม log object ที่มี field ข้างบน (`console.log(user)` = ห้าม)
- ✅ error message: generic บน prod (`"Login failed"` ไม่ใช่ `"User not found"`)

### Secrets & Config

- ❌ ห้าม commit `.env` (real values)
- ✅ commit `.env.example` ครบทุก var (ใส่ placeholder)
- ✅ rotate JWT_SECRET / API_KEY ทุก 90 วัน
- ✅ ใช้ secret manager บน prod (Vercel env / 1Password / AWS SM)

### HTTP Headers

- ✅ `Content-Security-Policy` ตั้งให้แคบ
- ✅ `X-Frame-Options: DENY`
- ✅ `Strict-Transport-Security: max-age=31536000`
- ✅ CORS allow-list (ห้าม `*` บน prod)

---

## Pre-Deploy Security Checklist

- [ ] ไม่มี `console.log` ที่ leak user/token (grep `console.log`)
- [ ] ไม่มี hardcoded secret (grep `password|secret|api_key` ใน source)
- [ ] `.env` ไม่อยู่ใน git (`git ls-files | grep .env`)
- [ ] ทุก mutating route มี auth + role + Zod check
- [ ] rate limit ที่ login/register
- [ ] CORS allow-list ตรง prod domain
- [ ] Lighthouse Performance ≥ 80
- [ ] Prisma migration apply สำเร็จบน staging
- [ ] error message บน prod ไม่ leak schema/path
- [ ] dependency audit ผ่าน (`pnpm audit --prod`)

---

## Monitoring (หลัง deploy)

| สิ่งที่ดู | เครื่องมือ | alert ถ้า |
|---------|----------|----------|
| Error rate | Sentry / log | > 1% req |
| Response time p95 | APM | > 1s |
| 4xx rate | log | > 5% (อาจมีการโจมตี) |
| DB connection | Prisma metric | > 80% pool |

---

## Changelog

| เวอร์ชัน | วันที่ | รายละเอียด |
|---------|-------|-----------|
| v1.0 | YYYY-MM-DD | สร้าง template |

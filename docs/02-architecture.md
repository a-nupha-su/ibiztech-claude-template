# 02 — Architecture
**[Project Name]**

| เวอร์ชัน | วันที่ |
|---------|-------|
| v1.0 | YYYY-MM-DD |

> อ่านก่อนสร้างไฟล์/folder/route ใหม่ทุกครั้ง

---

## System Flow Diagrams (สร้างด้วย skill `archify`)

> บังคับ — ดูกติกาเต็มใน `CLAUDE.md` หัวข้อ *System Flow Diagram Rule*

| Diagram | type | ไฟล์ | สถานะ |
|---------|------|-----|------|
| ภาพรวมระบบ | `architecture` | `docs/diagrams/system.architecture.html` | [ ] |
| [critical flow เช่น login] | `sequence` | `docs/diagrams/[flow].sequence.html` | [ ] |
| [pipeline / report] | `dataflow` | `docs/diagrams/[pipeline].dataflow.html` | [ ] |
| [entity หลัก] | `lifecycle` | `docs/diagrams/[entity].lifecycle.html` | [ ] |

สร้าง/อัปเดต:
```bash
node .claude/skills/archify/bin/archify.mjs deliver architecture docs/diagrams/system.architecture.json docs/diagrams/system.architecture.html --quality showcase --json
```
ต้อง exit 0 + 9 checks + 0 error/warning · architecture เปลี่ยน → regenerate + `archify compare` แนบใน PR

**User journey ต่อ role อยู่ใน `06-ux-ui-design.md`**

---

## Folder Structure

### Fullstack (Next.js App Router)

```
src/
├── app/                      # Next.js App Router
│   ├── (auth)/               # route group — login, register
│   ├── (dashboard)/          # route group — protected pages
│   │   ├── layout.tsx        # session check + sidebar shell
│   │   └── [module]/
│   │       ├── page.tsx
│   │       └── [id]/page.tsx
│   ├── api/
│   │   └── [resource]/
│   │       └── route.ts      # GET/POST/PUT/DELETE
│   └── layout.tsx            # root layout
├── components/
│   ├── ui/                   # shadcn primitives
│   └── [domain]/             # feature-scoped components
├── lib/
│   ├── auth/                 # session helpers
│   ├── db/                   # Prisma client
│   ├── validators/           # Zod schemas
│   └── utils/
├── server/
│   └── services/             # business logic — เรียกจาก route handlers
└── types/                    # shared TS types
```

### Separated API (Monorepo)

```
apps/
├── web/                      # Next.js — UI เท่านั้น
│   └── src/
│       ├── app/
│       ├── components/
│       └── lib/
│           └── api/          # ทุก fetch ผ่านที่นี่ ห้าม fetch ตรงใน component
├── api/                      # NestJS
│   └── src/
│       ├── modules/
│       │   └── [feature]/
│       │       ├── [feature].controller.ts
│       │       ├── [feature].service.ts
│       │       ├── [feature].module.ts
│       │       └── dto/
│       ├── auth/             # JwtAuthGuard, RolesGuard
│       ├── common/           # interceptors, filters
│       └── prisma/
packages/
└── shared/                   # type ที่ใช้ทั้ง FE + BE — ห้าม duplicate
    └── src/
        ├── types/
        └── constants/
```

---

## Naming Conventions

| ประเภท | รูปแบบ | ตัวอย่าง |
|--------|--------|---------|
| File / folder | kebab-case | `user-profile.tsx`, `auth-guard.ts` |
| React component | PascalCase | `UserCard`, `LoginForm` |
| Function / variable | camelCase | `getUser`, `isActive` |
| TS type / interface | PascalCase | `UserDto`, `LoginRequest` |
| Constant | UPPER_SNAKE | `MAX_PAGE_SIZE`, `JWT_EXPIRES_IN` |
| DB table | snake_case (singular) | `user`, `order_item` |
| API path | kebab-case (plural) | `/api/users`, `/api/order-items` |
| Env var | UPPER_SNAKE | `DATABASE_URL`, `JWT_SECRET` |

---

## Route Conventions

### Fullstack
- Server Component = default, ใช้ `'use client'` เมื่อต้องการ state/event เท่านั้น
- API routes อยู่ใน `src/app/api/[resource]/route.ts`
- ทุก mutate route ต้องมี session check + role check + Zod parse
- Business logic อยู่ใน `src/server/services/` — ห้ามเขียนใน route handler ตรง ๆ

### Separated API
- Frontend ห้าม fetch ตรง — ผ่าน `src/lib/api/[resource].ts` เท่านั้น
- Backend controller รับ/ส่ง อย่างเดียว — logic อยู่ใน service
- ทุก controller ต้องมี `@UseGuards(JwtAuthGuard, RolesGuard)` ยกเว้น public route
- DTO ใช้ `class-validator` + `class-transformer`

---

## Module Pattern (Separated API)

```
[feature].module.ts        # @Module({ controllers, providers, imports })
[feature].controller.ts    # @Controller('feature') — รับ HTTP
[feature].service.ts       # business logic + Prisma call
dto/
  create-[feature].dto.ts  # class-validator
  update-[feature].dto.ts
  [feature]-response.dto.ts
```

---

## Import Boundaries

ห้าม import ข้าม boundary:
- `components/` ห้าม import จาก `server/`
- `server/services/` ห้าม import React component
- Frontend (apps/web) ห้าม import Prisma type ตรง — ใช้ `packages/shared` แทน

---

## Changelog

| เวอร์ชัน | วันที่ | รายละเอียด |
|---------|-------|-----------|
| v1.0 | YYYY-MM-DD | สร้าง template |

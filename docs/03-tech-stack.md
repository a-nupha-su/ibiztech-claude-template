# 03 — Tech Stack
**[Project Name]**

| เวอร์ชัน | วันที่ |
|---------|-------|
| v1.0 | YYYY-MM-DD |

> ยึดเวอร์ชันในไฟล์นี้เป็น single source — ห้าม install นอกตารางนี้โดยไม่อัพเดตก่อน

---

## Runtime

| รายการ | เวอร์ชัน | หมายเหตุ |
|-------|---------|---------|
| Node.js | 20.x LTS | ใช้ `.nvmrc` |
| Package manager | pnpm 9.x | `corepack enable && corepack prepare pnpm@latest --activate` |
| Database | PostgreSQL 16 | dev + prod ต้องเวอร์ชันเดียวกัน |

---

## Frontend (apps/web)

| Package | เวอร์ชัน | ใช้ทำอะไร |
|---------|---------|----------|
| next | 15.x | App Router |
| react | 19.x | — |
| typescript | 5.x | strict mode |
| tailwindcss | 4.x | styling |
| shadcn/ui | latest | component primitives |
| zod | 3.x | validation |
| react-hook-form | 7.x | form state |
| @tanstack/react-query | 5.x | server state (Separated) |
| sonner | 1.x | toast |
| lucide-react | latest | icon |

---

## Backend

### Fullstack (Next.js route handlers)

| Package | เวอร์ชัน | ใช้ทำอะไร |
|---------|---------|----------|
| @prisma/client | 5.x | ORM |
| prisma | 5.x | migration tool |
| next-auth | 5.x (beta) | session/auth |
| bcryptjs | 2.x | password hash |

### Separated API (NestJS)

| Package | เวอร์ชัน | ใช้ทำอะไร |
|---------|---------|----------|
| @nestjs/core | 10.x | framework |
| @nestjs/common | 10.x | — |
| @nestjs/jwt | 10.x | JWT issue/verify |
| @nestjs/passport | 10.x | guards |
| passport-jwt | 4.x | strategy |
| class-validator | 0.14.x | DTO validation |
| class-transformer | 0.5.x | DTO transform |
| @prisma/client | 5.x | ORM |
| bcrypt | 5.x | password hash |

---

## Testing

| Package | เวอร์ชัน | ชั้น |
|---------|---------|-----|
| vitest | 1.x | Unit (Frontend) |
| jest | 29.x | Unit (Backend NestJS) |
| @playwright/test | 1.x | (ใช้ผ่าน MCP เป็นหลัก) |

---

## Dev Tools

| Package | เวอร์ชัน | ใช้ทำอะไร |
|---------|---------|----------|
| eslint | 9.x | lint |
| prettier | 3.x | format |
| husky | 9.x | git hooks |
| lint-staged | 15.x | pre-commit |
| typescript-eslint | 8.x | TS lint rules |

---

## Install Commands

### Fullstack
```bash
pnpm create next-app@latest . --typescript --tailwind --app --no-src-dir=false
pnpm add @prisma/client zod react-hook-form sonner bcryptjs
pnpm add -D prisma vitest @types/bcryptjs
pnpm dlx prisma init --datasource-provider postgresql
```

### Separated API
```bash
# Monorepo root
pnpm init
echo "packages: ['apps/*', 'packages/*']" > pnpm-workspace.yaml

# Frontend
pnpm create next-app@latest apps/web --typescript --tailwind --app

# Backend
pnpm dlx @nestjs/cli new apps/api --package-manager pnpm
cd apps/api && pnpm add @nestjs/jwt @nestjs/passport passport passport-jwt class-validator class-transformer @prisma/client bcrypt
pnpm add -D prisma @types/passport-jwt @types/bcrypt
```

---

## Package Rules

- ห้าม install package ที่ไม่ได้ list ที่นี่โดยไม่อัพเดตไฟล์นี้ก่อน
- เลือก package ที่: maintained 6 เดือนล่าสุด + TypeScript native + license MIT/Apache
- ห้ามใช้ deprecated package (เช่น `request`, `moment`)

---

## Environment Variables

ดู `.env.example` (must commit) — ห้าม commit `.env` (real)

| ตัวแปร | ตัวอย่าง | บังคับ |
|--------|---------|--------|
| `DATABASE_URL` | `postgresql://...` | ✅ |
| `JWT_SECRET` | random ≥ 32 chars | ✅ Separated |
| `NEXTAUTH_SECRET` | random ≥ 32 chars | ✅ Fullstack |
| `NEXTAUTH_URL` | `http://localhost:3000` | ✅ Fullstack |

---

## Changelog

| เวอร์ชัน | วันที่ | รายละเอียด |
|---------|-------|-----------|
| v1.0 | YYYY-MM-DD | สร้าง template |

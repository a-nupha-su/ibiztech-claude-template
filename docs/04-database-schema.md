# 04 — Database Schema
**[Project Name]**

| เวอร์ชัน | วันที่ |
|---------|-------|
| v1.0 | YYYY-MM-DD |

> ทุก query ใน code ต้อง match schema ในไฟล์นี้
> Schema เปลี่ยน → อัพเดตไฟล์นี้ + run migration + log ใน 12-log-issues.md

---

## Conventions

| รายการ | กฎ |
|-------|-----|
| Table name | snake_case singular (`user`, `order_item`) |
| Column name | snake_case (`created_at`, `user_id`) |
| Primary key | `id Int @id @default(autoincrement())` |
| Timestamp | ทุก table ต้องมี `created_at` + `updated_at` |
| Soft delete | `deleted_at DateTime?` (ถ้าต้องเก็บประวัติ) |
| Foreign key | suffix `_id` (`user_id`, `category_id`) |
| Boolean | prefix `is_` หรือ `has_` (`is_active`, `has_paid`) |
| Enum | UPPER_SNAKE values (`ACTIVE`, `INACTIVE`) |

---

## Models

### User (ตัวอย่าง — ลบ/แก้ตามจริง)

```prisma
model User {
  id           Int      @id @default(autoincrement())
  email        String   @unique
  password     String   // bcrypt hash — ห้าม return ใน response
  name         String
  role         Role     @default(USER)
  is_active    Boolean  @default(true)
  created_at   DateTime @default(now())
  updated_at   DateTime @updatedAt
  deleted_at   DateTime?

  // relations
  // posts        Post[]

  @@map("user")
  @@index([email])
}

enum Role {
  ADMIN
  USER
  VIEWER
}
```

### [Resource] (template)

```prisma
model [Resource] {
  id           Int      @id @default(autoincrement())
  name         String
  description  String?
  status       Status   @default(ACTIVE)
  user_id      Int
  user         User     @relation(fields: [user_id], references: [id])
  created_at   DateTime @default(now())
  updated_at   DateTime @updatedAt

  @@map("[resource]")
  @@index([user_id])
  @@index([status])
}

enum Status {
  ACTIVE
  INACTIVE
}
```

---

## ER Diagram (อธิบายความสัมพันธ์)

```
User 1 ─── n [Resource]
 │
 └── role: ADMIN | USER | VIEWER
```

> วาดด้วย Mermaid หรือเครื่องมืออื่นและฝังลิงก์ที่นี่ ถ้าโปรเจกต์ใหญ่

---

## Index Strategy

ทุก column ที่ใช้ใน:
- `WHERE` ตัวกรองหลัก → ต้องมี index
- `JOIN` (foreign key) → ต้องมี index
- `ORDER BY` ที่ใช้บ่อย → พิจารณา composite index

ตัวอย่าง:
```prisma
@@index([user_id, created_at])  // list ของ user เรียงเวลา
@@index([status])                // filter ตาม status
```

---

## Migration Commands

```bash
# สร้าง migration ใหม่
pnpm dlx prisma migrate dev --name [migration_name]

# apply บน prod
pnpm dlx prisma migrate deploy

# reset (DEV only — ลบข้อมูลทั้งหมด)
pnpm dlx prisma migrate reset

# generate client หลังแก้ schema
pnpm dlx prisma generate

# seed
pnpm dlx prisma db seed
```

---

## กฎ Migration

- ห้ามแก้ migration file เก่าหลังจาก commit (สร้างใหม่ทับเสมอ)
- prod migration ต้องผ่าน staging ก่อน
- breaking change (เปลี่ยน column type, drop column) → ทำ 2 ขั้น:
  1. deploy ใหม่ที่ tolerant ทั้งของเก่า/ใหม่
  2. data migration
  3. deploy ที่ลบของเก่า
- ทุก migration ที่ fail ต้อง log ใน `12-log-issues.md`

---

## Seed Data

ใช้ `prisma/seed.ts` สร้าง:
- admin user เริ่มต้น (email/password จาก env)
- ข้อมูลตัวอย่าง 1 ชุดต่อ module หลัก (สำหรับ dev/QA)

```typescript
// prisma/seed.ts
import { PrismaClient } from '@prisma/client';
const prisma = new PrismaClient();

async function main() {
  await prisma.user.upsert({
    where: { email: process.env.SEED_ADMIN_EMAIL! },
    update: {},
    create: {
      email: process.env.SEED_ADMIN_EMAIL!,
      password: await hash(process.env.SEED_ADMIN_PASSWORD!, 10),
      name: 'Admin',
      role: 'ADMIN',
    },
  });
}

main().finally(() => prisma.$disconnect());
```

---

## Changelog

| เวอร์ชัน | วันที่ | รายละเอียด |
|---------|-------|-----------|
| v1.0 | YYYY-MM-DD | สร้าง template |

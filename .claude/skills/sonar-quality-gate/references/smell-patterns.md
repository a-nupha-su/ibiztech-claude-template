# Code Smell Patterns — Refactor Guide

> โหลดเมื่อต้อง refactor / ลด tech debt (Maintainability dimension)
> หลักการ: code ทำงานถูก แต่ดูยาก/แก้ยาก/ขยายยาก

---

## S-001: Long Method (> 50 lines)

**Severity:** MAJOR
**Fix time:** ~30 min

**Detect:**
```bash
# Methods ที่ยาวกว่า 50 lines
awk '/^(function|const \w+\s*=|async function|export function)/,/^}/' src/**/*.ts \
  | awk 'length > 1' | wc -l
```

**Refactor: Extract Method**
```typescript
// ❌ 80 lines
async function processOrder(order) {
  // validate (15 lines)
  if (!order.items.length) throw new Error('empty');
  ...

  // calculate price (20 lines)
  let total = 0;
  for (const item of order.items) { ... }

  // apply discount (15 lines)
  ...

  // save (15 lines)
  ...

  // send email (15 lines)
  ...
}

// ✅ < 20 lines + 4 helpers
async function processOrder(order) {
  validateOrder(order);
  const total = calculateTotal(order.items);
  const discounted = applyDiscount(total, order.user);
  const saved = await saveOrder(order, discounted);
  await sendConfirmation(saved);
}
```

---

## S-002: Cognitive Complexity > 15

**Severity:** MAJOR
**Fix time:** ~30 min

Cognitive complexity = สนับสนุน readability ของมนุษย์ — เพิ่มน้ำหนัก nested control flow

**Detect:** ดู `cognitive-complexity.md`

**Refactor: Guard Clauses + Extract**
```typescript
// ❌ complexity 12
function process(user) {
  if (user) {
    if (user.active) {
      if (user.role === 'admin') {
        if (!user.banned) {
          return doStuff(user);
        }
      }
    }
  }
}

// ✅ complexity 4 (Guard Clauses)
function process(user) {
  if (!user) return;
  if (!user.active) return;
  if (user.role !== 'admin') return;
  if (user.banned) return;
  return doStuff(user);
}
```

---

## S-003: Duplicate Code

**Severity:** MAJOR
**Fix time:** ~30 min per duplicate

**Detect:**
```bash
# ใช้ jscpd (best)
npx jscpd src/ --threshold 3 --min-lines 10

# หรือ basic regex
grep -rn '<unique pattern>' src/ | wc -l
```

**Refactor: Extract Function / Constant**
```typescript
// ❌ duplicated 3 places
const taxA = price * 0.07;
const taxB = item.cost * 0.07;
const taxC = subtotal * 0.07;

// ✅
const VAT_RATE = 0.07;
const calculateVAT = (amount: number) => amount * VAT_RATE;

const taxA = calculateVAT(price);
const taxB = calculateVAT(item.cost);
const taxC = calculateVAT(subtotal);
```

---

## S-004: Long Parameter List (> 5)

**Severity:** MINOR
**Fix time:** ~15 min

**Refactor: Parameter Object**
```typescript
// ❌
function createUser(name, email, phone, address, city, zip, country) { ... }

// ✅
interface UserInput {
  name: string;
  email: string;
  phone: string;
  address: { line1: string; city: string; zip: string; country: string };
}
function createUser(input: UserInput) { ... }
```

---

## S-005: God Class (> 500 lines)

**Severity:** CRITICAL
**Fix time:** ~4 hours

**Detect:**
```bash
find src/ -name '*.ts' -exec wc -l {} + | awk '$1 > 500'
```

**Refactor: Split by Responsibility (SRP)**
```typescript
// ❌ UserService.ts (1200 lines)
class UserService {
  createUser() { ... }
  authenticateUser() { ... }
  sendEmail() { ... }
  generateReport() { ... }
  ...
}

// ✅ แยกเป็น 4 services
class UserCrudService { create() / read() / update() / delete() }
class AuthService { login() / logout() / verify() }
class EmailService { send() / template() }
class UserReportService { generate() / export() }
```

---

## S-006: Magic Number

**Severity:** MINOR
**Fix time:** ~5 min

**Detect:**
```bash
# Numeric literals 2+ digits ที่ไม่ใช่ 0/1/2/-1
grep -rnE '\b([3-9]|[1-9][0-9]+)\b' src/ | grep -vE '//.*|0x|\.[0-9]'
```

**Refactor: Named Constant**
```typescript
// ❌
if (age > 18) { ... }
setTimeout(callback, 3600000);
if (retries < 3) { ... }

// ✅
const LEGAL_ADULT_AGE = 18;
const HOUR_MS = 60 * 60 * 1000;
const MAX_RETRIES = 3;

if (age > LEGAL_ADULT_AGE) { ... }
setTimeout(callback, HOUR_MS);
if (retries < MAX_RETRIES) { ... }
```

---

## S-007: Dead Code

**Severity:** MINOR
**Fix time:** ~5 min

**Detect:**
```bash
# Unused exports
npx ts-unused-exports tsconfig.json

# Unused imports/vars
pnpm eslint src/ --rule 'no-unused-vars: error'
```

**Fix:** ลบทิ้ง (git history เก็บไว้แล้ว — ไม่ต้องคอมเมนต์)

```typescript
// ❌
// import { oldFunction } from './old';  // not used
function unusedHelper() { ... }

// ✅ ลบทั้งสองบรรทัด
```

---

## S-008: Commented-out Code

**Severity:** MINOR
**Fix time:** ~2 min

**Detect:**
```bash
grep -rnE '^\s*//.*[;{}]\s*$' src/
```

**Fix:** ลบทิ้ง (git blame ดูได้ถ้าจำเป็น)

---

## S-009: Deep Nesting (> 4 levels)

**Severity:** MAJOR
**Fix time:** ~30 min

**Refactor:** Guard Clauses + Extract Method (เหมือน S-002)

---

## S-010: Inconsistent Return (sometimes value, sometimes throw, sometimes null)

**Severity:** MAJOR
**Fix time:** ~30 min

**Refactor: Result type หรือชัดเจน**
```typescript
// ❌
function findUser(id) {
  const user = db.get(id);
  if (!user) return null;  // sometimes null
  if (user.banned) throw new Error('banned');  // sometimes throw
  return user;
}

// ✅ — explicit Result
type Result<T> = { ok: true; data: T } | { ok: false; error: string };

function findUser(id): Result<User> {
  const user = db.get(id);
  if (!user) return { ok: false, error: 'not_found' };
  if (user.banned) return { ok: false, error: 'banned' };
  return { ok: true, data: user };
}
```

---

## S-011: Empty Catch Block

**Severity:** MAJOR
**Fix time:** ~15 min

**Detect:**
```bash
grep -rnE 'catch.*\{\s*\}|catch.*\{\s*//' src/
```

**Refactor:** Log หรือ rethrow ทุกครั้ง
```typescript
// ❌
try { risky(); } catch (e) {}

// ✅
try { risky(); } catch (e) {
  logger.error('risky failed', e);
  throw e;  // หรือ return fallback ที่ชัดเจน
}
```

---

## S-012: TODO / FIXME Comments

**Severity:** INFO
**Fix time:** depends

**Detect:**
```bash
grep -rnE 'TODO|FIXME|XXX|HACK' src/
```

**Fix:**
- TODO ที่ track ได้ → สร้าง task ใน `07-implement-plan.md`
- TODO เก่า > 30 วัน → review ตัดสินใจ (delete หรือ promote เป็น task)
- ห้ามใช้ TODO เป็น "I'll fix later" ที่ไม่มีกำหนด

---

## Refactor Process (สำหรับ AI)

```
1. ระบุ smell + severity
2. คำนวณ fix time
3. ก่อนแก้ — write/update test ครอบ behavior เดิม (กัน regression)
4. apply refactor pattern
5. run test → pass = ปลอดภัย
6. commit แยกตาม refactor (1 commit ต่อ 1 smell ถ้าเป็นไปได้)
7. log ใน 12 ถ้าเป็น refactor ใหญ่ (S-005 god class, S-002 complexity > 25)
```

---

## Anti-Refactor Patterns (อย่าทำ)

| ❌ | ✅ |
|----|----|
| refactor + add feature ใน commit เดียวกัน | แยก commit |
| ลด complexity แต่ break test | ห้าม — test ผ่านก่อน refactor |
| extract method ที่ใช้ครั้งเดียว | ปล่อยไว้ — ไม่เพิ่ม indirection ฟรี |
| rename ทั้งโปรเจกต์เพื่อ "consistency" | ทำเฉพาะใน scope ที่ทำงาน |
| over-engineer — split class เกินจำเป็น | ทำเมื่อ god class จริง ๆ (> 500 lines) |

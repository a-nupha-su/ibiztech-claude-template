# Bug Patterns — Detection & Fix

> โหลดเมื่อต้องหา bug ใน code (Reliability dimension)

---

## TypeScript / JavaScript

### B-001: Null / Undefined Access
**Severity:** CRITICAL
**Detect:**
```bash
# TypeScript strict mode จะจับให้
pnpm tsc --noEmit --strict

# Manual: หา `.foo` ที่ไม่มี optional chaining หรือ null check
grep -nE '\w+\.\w+\(' src/ | grep -v '\?\.'
```
**Fix:**
```typescript
// ❌
const name = user.profile.name;

// ✅
const name = user?.profile?.name ?? 'unknown';
```

---

### B-002: Unhandled Promise Rejection
**Severity:** MAJOR
**Detect:**
```bash
grep -rnE '\.then\([^)]+\)\s*$' src/ | grep -v '\.catch'
grep -rnE 'await [^;]+;' src/ | xargs # check ว่าอยู่ใน try-catch ไหม
```
**Fix:**
```typescript
// ❌
fetchData().then(handle);

// ✅
fetchData().then(handle).catch(logError);
// or
try { await fetchData(); } catch (e) { logError(e); }
```

---

### B-003: Missing `await`
**Severity:** MAJOR
**Detect:** ESLint `@typescript-eslint/no-floating-promises`
**Fix:**
```typescript
// ❌
async function save() {
  db.write(data);  // missing await
}

// ✅
async function save() {
  await db.write(data);
}
```

---

### B-004: Equality `==` vs `===`
**Severity:** MAJOR
**Detect:** ESLint `eqeqeq`
**Fix:**
```typescript
// ❌
if (value == null) { ... }  // matches both null and undefined

// ✅ (intentional)
if (value === null || value === undefined) { ... }
// or
if (value == null) { ... }  // accept ถ้าตั้งใจ — add comment
```

---

### B-005: useEffect Missing Dependencies
**Severity:** MINOR (อาจกลายเป็น MAJOR ถ้ากระทบ logic)
**Detect:** ESLint `react-hooks/exhaustive-deps`
**Fix:**
```typescript
// ❌
useEffect(() => {
  fetchUser(userId);
}, []); // missing userId

// ✅
useEffect(() => {
  fetchUser(userId);
}, [userId]);
```

---

### B-006: Off-by-One Error
**Severity:** MAJOR
**Detect:** Manual review of loop bounds
**Fix:**
```typescript
// ❌
for (let i = 0; i <= arr.length; i++) { arr[i]; }  // crashes on last iteration

// ✅
for (let i = 0; i < arr.length; i++) { arr[i]; }
```

---

### B-007: Resource Leak
**Severity:** MAJOR
**Detect:** Manual review — file handles, DB connections, event listeners
**Fix:**
```typescript
// ❌
const fd = fs.openSync(path);
processFile(fd);
// never closes

// ✅
const fd = fs.openSync(path);
try {
  processFile(fd);
} finally {
  fs.closeSync(fd);
}
```

---

### B-008: Race Condition (Async State)
**Severity:** CRITICAL
**Detect:** Manual review of async + shared state
**Fix:**
```typescript
// ❌ (race)
async function increment() {
  const v = await db.get('counter');
  await db.set('counter', v + 1);
}

// ✅ (atomic)
await db.increment('counter', 1);
```

---

### B-009: Type Coercion Bug
**Severity:** MAJOR
**Detect:** TS strict mode
**Fix:**
```typescript
// ❌
function sum(a: number, b: number) {
  return a + b;
}
sum('1' as any, 2);  // returns '12', not 3

// ✅ — ไม่ใช้ as any + validate at boundary (Zod)
const schema = z.object({ a: z.number(), b: z.number() });
const input = schema.parse(rawInput);
sum(input.a, input.b);
```

---

### B-010: Dead Store
**Severity:** MINOR
**Detect:** ESLint `no-unused-vars`
**Fix:**
```typescript
// ❌
let result = computeExpensive();
result = simpleValue;  // first result never used

// ✅
const result = simpleValue;
```

---

## Detection Commands (รวม)

```bash
# TS strict errors (bugs ที่ type ระบบจับได้)
pnpm tsc --noEmit --strict 2>&1 | grep error

# ESLint with error level
pnpm eslint src/ --quiet

# Floating promises
pnpm eslint src/ --rule '@typescript-eslint/no-floating-promises: error'
```

---

## Output Format

```
🐛 Bug at <file>:<line>
   Pattern: B-XXX (description)
   Severity: BLOCKER / CRITICAL / MAJOR / MINOR
   Code:
     [snippet]
   Fix:
     [fix snippet]
   Test required: yes / no
```

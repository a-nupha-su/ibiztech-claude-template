# Vulnerability Patterns — Detection & Fix

> โหลดเมื่อต้องตรวจ security issue (Security dimension)
> อ้างอิง: OWASP Top 10 2021

---

## V-001: SQL Injection (OWASP A03)
**Severity:** BLOCKER
**Detect:**
```bash
# Raw SQL with string concat
grep -rnE 'query\(`[^`]*\$\{|query\(["\047][^"\047]*\+' src/

# Prisma raw bypass
grep -rn '\$queryRawUnsafe\|\$executeRawUnsafe' src/
```
**Fix:**
```typescript
// ❌
await db.query(`SELECT * FROM user WHERE id = ${userId}`);

// ✅ — parameterized
await db.query('SELECT * FROM user WHERE id = $1', [userId]);

// ✅ — Prisma ORM
await prisma.user.findUnique({ where: { id: userId } });
```

---

## V-002: XSS (OWASP A03)
**Severity:** CRITICAL
**Detect:**
```bash
# dangerouslySetInnerHTML without sanitize
grep -rn 'dangerouslySetInnerHTML' src/

# v-html / innerHTML
grep -rnE 'innerHTML\s*=' src/
```
**Fix:**
```typescript
// ❌
<div dangerouslySetInnerHTML={{ __html: userInput }} />

// ✅
import DOMPurify from 'isomorphic-dompurify';
<div dangerouslySetInnerHTML={{ __html: DOMPurify.sanitize(userInput) }} />

// ✅✅ (best) — render as text
<div>{userInput}</div>
```

---

## V-003: Hardcoded Secret (OWASP A02)
**Severity:** BLOCKER
**Detect:**
```bash
# Common patterns
grep -rE '(password|secret|api[_-]?key|token|private[_-]?key)\s*[:=]\s*["\047][^"\047]{8,}' src/

# AWS / GitHub tokens
grep -rE 'AKIA[0-9A-Z]{16}|ghp_[0-9a-zA-Z]{36}|gho_[0-9a-zA-Z]{36}' src/ .env*

# Bearer token literal
grep -rnE 'Bearer\s+[A-Za-z0-9_\-\.]{20,}' src/
```
**Fix:**
```typescript
// ❌
const apiKey = 'sk_live_abc123def456';

// ✅
const apiKey = process.env.STRIPE_API_KEY;
if (!apiKey) throw new Error('STRIPE_API_KEY required');
```

---

## V-004: Weak Crypto (OWASP A02)
**Severity:** CRITICAL
**Detect:**
```bash
grep -rE 'createHash\(["\047](md5|sha1)["\047]\)' src/
grep -rE 'createCipher\(["\047](des|rc4)' src/
```
**Fix:**
```typescript
// ❌
crypto.createHash('md5').update(password).digest('hex');

// ✅ — สำหรับ password
import bcrypt from 'bcryptjs';
await bcrypt.hash(password, 12);

// ✅ — สำหรับ general hash
crypto.createHash('sha256').update(data).digest('hex');
```

---

## V-005: Insecure Deserialization / eval (OWASP A08)
**Severity:** CRITICAL
**Detect:**
```bash
grep -rnE '\beval\(|new Function\(' src/
grep -rn 'execSync\|exec(' src/
```
**Fix:**
```typescript
// ❌
const config = eval(userInput);

// ✅
const config = JSON.parse(userInput);  // + validate with Zod
```

---

## V-006: Open Redirect (OWASP A01)
**Severity:** MAJOR
**Detect:**
```bash
grep -rnE 'res\.redirect\([^)]*req\.|router\.push\([^)]*req\.' src/
```
**Fix:**
```typescript
// ❌
res.redirect(req.query.next);  // attacker → ?next=https://evil.com

// ✅
const allowed = ['/dashboard', '/profile', '/settings'];
const target = allowed.includes(req.query.next) ? req.query.next : '/dashboard';
res.redirect(target);
```

---

## V-007: Insecure Cookie (OWASP A05)
**Severity:** MAJOR
**Detect:**
```bash
grep -rnE 'res\.cookie\(' src/ | grep -v 'httpOnly.*true'
```
**Fix:**
```typescript
// ❌
res.cookie('session', token);

// ✅
res.cookie('session', token, {
  httpOnly: true,
  secure: process.env.NODE_ENV === 'production',
  sameSite: 'lax',
  maxAge: 60 * 60 * 1000,
});
```

---

## V-008: CORS Misconfig (OWASP A05)
**Severity:** MAJOR
**Detect:**
```bash
grep -rnE 'Access-Control-Allow-Origin.*\*' src/ apps/
```
**Fix:**
```typescript
// ❌
res.header('Access-Control-Allow-Origin', '*');

// ✅
const allowed = ['https://app.example.com', 'https://staging.example.com'];
const origin = req.headers.origin;
if (allowed.includes(origin)) {
  res.header('Access-Control-Allow-Origin', origin);
}
```

---

## V-009: Missing Authentication (OWASP A01)
**Severity:** BLOCKER
**Detect:**
```bash
# Next.js: route handler ไม่มี session check
for f in src/app/api/**/*.ts; do
  if ! grep -q 'session\|getServerSession\|auth' "$f"; then
    echo "⚠️ $f — no auth check"
  fi
done

# NestJS: controller ไม่มี @UseGuards
grep -L 'UseGuards' apps/api/src/**/*.controller.ts
```
**Fix:**
```typescript
// ❌ Next.js
export async function POST(req: Request) {
  return updateUser(await req.json());
}

// ✅
export async function POST(req: Request) {
  const session = await getServerSession(authOptions);
  if (!session) return new Response('Unauthorized', { status: 401 });
  return updateUser(await req.json(), session.user.id);
}

// ❌ NestJS
@Controller('users')
export class UsersController {
  @Post() create(@Body() dto: CreateUserDto) { ... }
}

// ✅
@Controller('users')
@UseGuards(JwtAuthGuard, RolesGuard)
export class UsersController {
  @Post() @Roles('admin') create(@Body() dto: CreateUserDto) { ... }
}
```

---

## V-010: Path Traversal (OWASP A01)
**Severity:** CRITICAL
**Detect:**
```bash
grep -rnE 'fs\.(read|write)File\(.*req\.|path\.join\(.*req\.' src/
```
**Fix:**
```typescript
// ❌
const content = fs.readFileSync(path.join(uploadDir, req.query.file));
// attacker: ?file=../../../etc/passwd

// ✅
const filename = path.basename(req.query.file);  // strip path
const safePath = path.resolve(uploadDir, filename);
if (!safePath.startsWith(path.resolve(uploadDir))) throw new Error('Invalid path');
const content = fs.readFileSync(safePath);
```

---

## Dependency Vulnerabilities

```bash
# ตรวจ deps
pnpm audit --prod --json

# Fix อัตโนมัติเฉพาะ minor/patch
pnpm audit --prod --fix

# ถ้ามี high/critical จาก deps → upgrade เอง + test
```

---

## Output Format

```
🔓 Vulnerability at <file>:<line>
   OWASP: A02 (Cryptographic Failures)
   Pattern: V-003 (Hardcoded Secret)
   Severity: BLOCKER
   Code:
     const apiKey = 'sk_live_abc123';
   Fix:
     const apiKey = process.env.STRIPE_API_KEY;
   Test: add env validation test
   Rotation needed: ✅ yes — secret อยู่ใน git history แล้ว rotate ทันที
```

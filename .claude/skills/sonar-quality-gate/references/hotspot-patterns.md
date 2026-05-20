# Security Hotspot Patterns

> โหลดเมื่อตรวจ Security Hotspot — code ที่ใช้ feature ที่ **อาจ** เสี่ยง
> Hotspot = **ต้อง human review เสมอ** — ห้าม auto-fix
> หลัก: hotspot อาจ "safe by design" ขึ้นกับ context

---

## H-001: Cookie Configuration

**Pattern:** ใช้ cookie สำหรับ session/auth
**Risk:** session theft · CSRF · MITM

```bash
grep -rn 'res\.cookie\(\|setCookie\|Set-Cookie' src/
```

**Review checklist:**
- [ ] `httpOnly: true` — กัน JavaScript access (XSS-resistant)
- [ ] `secure: true` (in prod) — HTTPS only
- [ ] `sameSite: 'lax'` หรือ `'strict'` — กัน CSRF
- [ ] `maxAge` ตั้งให้สั้น (ไม่ใช่ session = forever)
- [ ] `path` แคบ (ไม่ใช่ `/` ถ้าไม่จำเป็น)
- [ ] `domain` ระบุ (ไม่ leak ไป subdomain)

**Decision:**
- ผ่าน checklist หมด → `SAFE`
- ขาด → fix → `FIXED`

---

## H-002: Regular Expression (ReDoS risk)

**Pattern:** regex ที่ใช้กับ user input
**Risk:** Regex Denial of Service (catastrophic backtracking)

```bash
# Regex ที่อาจมี nested quantifier
grep -rnE '\([^)]*[*+][^)]*\)[*+]' src/

# Examples ที่เสี่ยง
# (a+)+ , (a|a)+ , (.*)*
```

**Review checklist:**
- [ ] input ถูก length-limit ก่อน match ไหม?
- [ ] regex มี nested quantifier `(x+)+` หรือไม่?
- [ ] ใช้ atomic group / possessive ได้ไหม?
- [ ] timeout / abort logic ถ้า regex รันนาน?

**Test ReDoS:**
```bash
node -e "
const start = Date.now();
new RegExp('^(a+)+\$').test('aaaaaaaaaaaaaaaaaaaaaX');
console.log('elapsed:', Date.now() - start, 'ms');
"
# > 1000ms = vulnerable
```

---

## H-003: Random Number Generator

**Pattern:** ใช้ `Math.random()` หรือ insecure random
**Risk:** predictable values ใน security context (token, OTP)

```bash
grep -rn 'Math\.random()' src/
```

**Review checklist:**
- [ ] ใช้สำหรับ **non-security** context (UI animation, sample data) → SAFE
- [ ] ใช้สำหรับ **security** (token/OTP/session-id) → **FIX** ใช้ `crypto.randomBytes()`

```typescript
// ❌ Security context
const otp = Math.floor(Math.random() * 1000000);

// ✅
import { randomInt } from 'crypto';
const otp = randomInt(100000, 1000000);

// ✅✅ token
const token = crypto.randomBytes(32).toString('hex');
```

---

## H-004: File Path from User Input

**Pattern:** file path ที่มาจาก user input
**Risk:** path traversal (อ่าน/เขียนไฟล์นอก scope)

```bash
grep -rnE 'fs\.\w+\(.*\b(req\.|input\.|params\.)' src/
grep -rnE 'path\.(join|resolve)\(.*\b(req\.|input\.|params\.)' src/
```

**Review checklist:**
- [ ] basename ก่อน (strip directory parts)?
- [ ] whitelist filename pattern?
- [ ] resolve path + verify ยังอยู่ใน safe dir?
- [ ] ไม่อนุญาต `..`, absolute path?

```typescript
// ✅ safe pattern
const safeName = path.basename(req.body.file);
const safePath = path.resolve(UPLOAD_DIR, safeName);
if (!safePath.startsWith(path.resolve(UPLOAD_DIR))) throw new Error('Invalid');
```

---

## H-005: HTTP Redirect

**Pattern:** redirect ไป URL ที่ user ส่งมา
**Risk:** open redirect (phishing)

```bash
grep -rnE 'res\.redirect\([^)]*\b(req\.|input\.|params\.|query\.)' src/
grep -rnE 'router\.push\([^)]*\b(req\.|input\.|params\.|query\.)' src/
```

**Review checklist:**
- [ ] URL match whitelist (allowed origins/paths)?
- [ ] relative URL only (ไม่ใช่ external URL)?

---

## H-006: Cross-Origin Resource Sharing (CORS)

**Pattern:** CORS configuration
**Risk:** unauthorized cross-origin access

```bash
grep -rn 'Access-Control-Allow-Origin\|cors(' src/ apps/
```

**Review checklist:**
- [ ] origin = whitelist (ไม่ใช่ `*`)?
- [ ] credentials เปิดเฉพาะ origin ที่ trusted?
- [ ] preflight cache (max-age) เหมาะสม?

---

## H-007: CSRF Token

**Pattern:** route ที่ mutate state ไม่มี CSRF token
**Risk:** CSRF attack ถ้าใช้ session cookie

```bash
# Forms / mutating routes
grep -rn '@Post\|@Put\|@Delete\|method: ["\047](POST|PUT|DELETE|PATCH)' src/ apps/
```

**Review checklist:**
- [ ] ถ้าใช้ session cookie → ต้องมี CSRF token / SameSite cookie
- [ ] ถ้าใช้ Bearer token → CSRF ไม่จำเป็น
- [ ] check Origin/Referer header?

---

## H-008: Disabled SSL/TLS Verification

**Pattern:** `rejectUnauthorized: false` หรือ `NODE_TLS_REJECT_UNAUTHORIZED=0`
**Risk:** MITM attack

```bash
grep -rn 'rejectUnauthorized:\s*false\|NODE_TLS_REJECT_UNAUTHORIZED.*0' src/ .env*
```

**Review checklist:**
- [ ] เป็น production code ไหม? → **fix ทันที**
- [ ] เป็น dev/test against self-signed cert → mark SAFE + comment

---

## H-009: `dangerouslySetInnerHTML` (React)

**Pattern:** ใช้ raw HTML in React
**Risk:** XSS

```bash
grep -rn 'dangerouslySetInnerHTML' src/
```

**Review checklist:**
- [ ] content จาก trusted source (static / sanitized) → SAFE
- [ ] content จาก user → ต้องผ่าน DOMPurify / sanitize-html

---

## H-010: `eval` / `new Function`

**Pattern:** dynamic code execution
**Risk:** RCE if input controlled by attacker

```bash
grep -rnE '\beval\(|new Function\(' src/
```

**Review checklist:**
- [ ] input controlled? (constant string vs user input)
- [ ] มีทางอื่นไหม? (JSON.parse, lookup table)
- [ ] ถ้าจำเป็นจริง — sandbox + strict input validation

---

## Hotspot Report Format

```
🔥 Hotspot at src/auth/cookie.ts:18
   Pattern: H-001 (Cookie Configuration)
   Context:
     res.cookie('session', token, { httpOnly: true });

   Review checklist:
   ✅ httpOnly: true
   ❓ secure: missing (production?)
   ❓ sameSite: missing
   ✅ httpOnly mitigates XSS cookie theft

   Decision required:
   - [ ] SAFE  (เพราะ ...)
   - [x] FIX   (add secure + sameSite)
   - [ ] WONTFIX (เพราะ ...)

   Recommended fix:
     res.cookie('session', token, {
       httpOnly: true,
       secure: process.env.NODE_ENV === 'production',
       sameSite: 'lax',
       maxAge: 60 * 60 * 1000,
     });
```

---

## Hotspot Tracking

ใช้ field พิเศษใน `12-log-issues.md`:

```markdown
### ISS-XXX — Cookie missing secure flag
- **Type:** Security Hotspot (H-001)
- **Status:** REVIEW_PENDING / SAFE / FIXED / WONTFIX
- **Reviewer:** [name]
- **Decision:** [reason]
```

หรือใน Test Report Section 2.1:
```
Security checks done:
[x] AuthN [x] AuthZ [x] Input validation [x] Sensitive data
[x] Hotspots reviewed: 8/8 (3 FIXED, 5 SAFE, 0 pending)
```

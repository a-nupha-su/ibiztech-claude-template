# Issue Types — Detail Reference

> โหลดเมื่อ AI ต้องแยกประเภท issue หรือสงสัยว่าควรจัดเป็น Bug / Vuln / Hotspot / Smell

---

## 🐛 Bug — Code ที่ผิดหรือทำงานไม่ถูก

### Definition
Code ที่ทำให้ระบบทำงานผิดจาก behavior ที่คาดหวัง (functional defect)

### Common patterns
| Pattern | Severity | Detect how |
|---------|:--------:|-----------|
| Null pointer / undefined access | CRITICAL | `x.foo` without null check, TS strict |
| Off-by-one / boundary error | MAJOR | manual review loop conditions |
| Unhandled promise rejection | MAJOR | `.then()` without `.catch()`, async without try |
| Missing await on async | MAJOR | `async fn()` called without `await` |
| Equality check `==` instead of `===` | MAJOR | ESLint `eqeqeq` |
| useEffect missing dependencies | MINOR | ESLint `react-hooks/exhaustive-deps` |
| Resource leak (file/connection not closed) | MAJOR | manual review |
| Race condition | CRITICAL | manual review async state |
| Type coercion bug (string vs number) | MAJOR | TS strict |
| Dead store (assign never read) | MINOR | ESLint `no-unused-vars` |

### How to fix
- write **regression test ก่อน** (red), แล้วแก้ (green) — TDD style
- log ใน `12-log-issues.md` ถ้า severity ≥ MAJOR
- update `13-testcase-log.md` หลังแก้

---

## 🔓 Vulnerability — Exploitable Security Defect

### Definition
Code ที่ผู้โจมตี exploit ได้จริง (verified attack vector)

### Common patterns (OWASP Top 10)

| Vuln | OWASP | Pattern | Severity |
|------|:-----:|---------|:--------:|
| SQL Injection | A03 | string concat ใน query, raw SQL | BLOCKER |
| XSS | A03 | render user input โดยไม่ sanitize | CRITICAL |
| Hardcoded secret | A02 | API key / password ใน code | BLOCKER |
| Weak crypto | A02 | MD5, SHA1, DES | CRITICAL |
| Insecure deserialization | A08 | `eval()`, unsafe JSON | CRITICAL |
| Open redirect | A01 | redirect to user-provided URL | MAJOR |
| Insecure cookie | A05 | no `httpOnly` / `secure` flag | MAJOR |
| CORS misconfig | A05 | `Access-Control-Allow-Origin: *` | MAJOR |
| Missing auth check | A01 | route ที่ไม่ verify session | BLOCKER |
| Path traversal | A01 | `../` ใน user-supplied path | CRITICAL |

### Detection
```bash
# Hardcoded secret
grep -rE '(password|secret|api[_-]?key|token)\s*[:=]\s*["\047][^"\047]{8,}' src/

# Weak crypto
grep -rE 'createHash\(["\047](md5|sha1)["\047]\)' src/

# SQL injection risk
grep -rE 'query\(`[^`]*\$\{' src/

# Dangerous functions
grep -rE 'eval\(|new Function\(|exec\(' src/

# pnpm audit for dep vulnerabilities
pnpm audit --prod --json
```

### How to fix
- **fix ก่อน merge เสมอ** (BLOCKER/CRITICAL)
- log ใน `12-log-issues.md` (Severity: HIGH หรือ CRITICAL)
- เพิ่ม regression test
- check ทุก path ที่อาจมี vuln เดียวกัน (ไม่ใช่แค่จุดที่เจอ)

---

## 🔥 Security Hotspot — Needs Human Review

### Definition
Code ที่ **ใช้ feature ที่อาจเสี่ยง** — แต่อาจถูกหรือผิดก็ได้ ขึ้นกับ context → ต้องมนุษย์ review

> Hotspot ≠ Vulnerability — hotspot อาจ "safe by design"

### Common patterns

| Hotspot | ทำไมเสี่ยง | Review checklist |
|---------|----------|-----------------|
| Cookie usage | session theft, CSRF | `httpOnly`? `secure`? `sameSite`? |
| RegExp | ReDoS attack | input controlled? complexity? |
| Random number | predictable | use `crypto.randomBytes` ถ้า security-critical? |
| File path from input | path traversal | sanitize? whitelist? |
| HTTP redirect | open redirect | URL validated? |
| CORS | data leak | whitelist origins? |
| Disabled CSRF | depends on auth | API uses Bearer token? |
| `dangerouslySetInnerHTML` | XSS | content sanitized? |
| `eval` / `new Function` | code injection | input controlled? |

### Process
1. **อย่า auto-fix** — ถามมนุษย์เสมอ
2. ให้ออกเป็น "Hotspot Report" สำหรับ reviewer
3. reviewer mark: `SAFE` (ปลอดภัยใน context นี้) หรือ `FIXED` (แก้แล้ว)
4. record ใน Test Report Section 2.1 (Security)

### Output รูปแบบ
```
🔥 Hotspot at src/auth/cookie.ts:18
   Pattern: Cookie usage
   Context: res.cookie('session', token, { httpOnly: true })
   Review: httpOnly ✅ · secure ❓ (no `secure` flag — local dev only?)
   Action: Add `secure: process.env.NODE_ENV === 'production'`
```

---

## 👃 Code Smell — Maintainability Issue

### Definition
ไม่ใช่ bug — code ทำงานถูก แต่ **ดูยาก / แก้ยาก / ขยายยาก**

### Common smells

| Smell | Severity | Detect |
|-------|:--------:|--------|
| **Long method** (> 50 lines) | MAJOR | line count |
| **Cognitive complexity > 15** | MAJOR | calc ตาม `cognitive-complexity.md` |
| **Duplicate code** (≥ 10 lines × 2 places) | MAJOR | jscpd |
| **Long parameter list** (> 5 params) | MINOR | function signature |
| **God class** (> 500 lines) | CRITICAL | line count |
| **Magic number** | MINOR | grep `[0-9]{2,}` (exclude obvious) |
| **Dead code** (unused export/function) | MINOR | ESLint, ts-unused-exports |
| **Commented-out code** | MINOR | grep `^\s*//` blocks |
| **Deep nesting** (> 4 levels) | MAJOR | manual or AST |
| **Inconsistent return** (sometimes value, sometimes throw) | MAJOR | manual review |
| **Empty catch** | MAJOR | grep `catch.*\{\s*\}` |
| **TODO/FIXME comments** | INFO | grep `TODO\|FIXME` |

### How to refactor

| Smell | Refactor |
|-------|---------|
| Long method | Extract Method (แตก function ย่อย) |
| Duplicate | Extract Function/Constant |
| Long parameter | Introduce Parameter Object (object destructure) |
| God class | Split Class / Single Responsibility |
| Magic number | Replace Magic Number with Symbolic Constant |
| Deep nesting | Guard Clauses + Early Return |
| Cognitive complexity | Extract Method + Simplify Conditionals |

### Tech Debt calculation
```
tech_debt_minutes = sum(time-to-fix per smell)

ratio = tech_debt_minutes / total_dev_minutes

Rating:
  ≤ 5%   = A
  6-10%  = B
  11-20% = C
  21-50% = D
  > 50%  = E
```

---

## Decision Tree: นี่คือ issue ประเภทไหน?

```
code ทำให้ระบบทำงานผิด?
  Yes → 🐛 Bug
  No  ↓
  
code ที่ผู้โจมตี exploit ได้แน่ ๆ?
  Yes → 🔓 Vulnerability
  No  ↓
  
code ใช้ security-sensitive feature ที่อาจเสี่ยง?
  Yes → 🔥 Security Hotspot
  No  ↓
  
code ทำงานถูกแต่ดูยาก/แก้ยาก?
  Yes → 👃 Code Smell
  No  → ไม่ใช่ issue
```

# Rules Catalog — All Rules in One Place

> โหลดเมื่อต้องดู rule ID + rationale + ตัวอย่าง

ทุก rule มี ID เป็น `<Type>-<NNN>` เพื่อ trace + log ใน Test Report

| Type | Prefix | Reference |
|------|:------:|----------|
| Bug | B- | `bug-patterns.md` |
| Vulnerability | V- | `vuln-patterns.md` |
| Security Hotspot | H- | `hotspot-patterns.md` |
| Code Smell | S- | `smell-patterns.md` |

---

## Quick Index

### 🐛 Bugs
- B-001 Null/Undefined Access (CRITICAL)
- B-002 Unhandled Promise Rejection (MAJOR)
- B-003 Missing `await` (MAJOR)
- B-004 `==` instead of `===` (MAJOR)
- B-005 useEffect Missing Deps (MINOR)
- B-006 Off-by-One (MAJOR)
- B-007 Resource Leak (MAJOR)
- B-008 Race Condition (CRITICAL)
- B-009 Type Coercion Bug (MAJOR)
- B-010 Dead Store (MINOR)

### 🔓 Vulnerabilities
- V-001 SQL Injection (BLOCKER)
- V-002 XSS (CRITICAL)
- V-003 Hardcoded Secret (BLOCKER)
- V-004 Weak Crypto (CRITICAL)
- V-005 Insecure Deserialization / `eval` (CRITICAL)
- V-006 Open Redirect (MAJOR)
- V-007 Insecure Cookie (MAJOR)
- V-008 CORS Misconfig (MAJOR)
- V-009 Missing Authentication (BLOCKER)
- V-010 Path Traversal (CRITICAL)

### 🔥 Security Hotspots
- H-001 Cookie Configuration
- H-002 Regular Expression (ReDoS)
- H-003 Random Number Generator
- H-004 File Path from User Input
- H-005 HTTP Redirect
- H-006 CORS Configuration
- H-007 CSRF Token
- H-008 Disabled SSL/TLS
- H-009 `dangerouslySetInnerHTML`
- H-010 `eval` / `new Function`

### 👃 Code Smells
- S-001 Long Method (MAJOR)
- S-002 Cognitive Complexity > 15 (MAJOR)
- S-003 Duplicate Code (MAJOR)
- S-004 Long Parameter List (MINOR)
- S-005 God Class (CRITICAL)
- S-006 Magic Number (MINOR)
- S-007 Dead Code (MINOR)
- S-008 Commented-out Code (MINOR)
- S-009 Deep Nesting (MAJOR)
- S-010 Inconsistent Return (MAJOR)
- S-011 Empty Catch Block (MAJOR)
- S-012 TODO / FIXME (INFO)

---

## Adding Custom Rules

โครงสร้าง rule ใหม่:
```markdown
## <PREFIX>-<NNN>: <Title>
**Severity:** BLOCKER / CRITICAL / MAJOR / MINOR / INFO
**Fix time:** <minutes>
**Detect:** <bash command or pattern>
**Fix:** <code example>
```

เพิ่มใน reference file ตาม type + update Index ด้านบน

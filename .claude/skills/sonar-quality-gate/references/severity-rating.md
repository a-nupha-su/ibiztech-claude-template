# Severity & Rating Calculator

> โหลดเมื่อต้องคำนวณ rating A-E จาก issue list

---

## Severity Levels (ตาม Sonar)

| Level | คำอธิบาย | ตัวอย่าง | Block PR? |
|:-----:|---------|---------|:---------:|
| 🔴 **BLOCKER** | high probability of impact in production · security exploit · data loss · system crash | SQL injection · hardcoded password · null pointer ใน hot path | ✅ ใช่ |
| 🟠 **CRITICAL** | impact production · functionality broken · security risk | weak crypto · race condition · cognitive complexity > 25 | ✅ ใช่ |
| 🟡 **MAJOR** | meaningful impact on quality | duplicate code · long method · missing dependency in useEffect (ที่กระทบ logic) | ⚠️ ขึ้นกับนโยบาย |
| 🔵 **MINOR** | low impact | magic number · long param list · unused import | ❌ ไม่ block |
| ⚪ **INFO** | informational / recommendation | naming convention · prefer-const | ❌ ไม่ block |

---

## Severity Decision Tree

```
issue นี้ทำให้:
  ├─ ระบบล่ม / data loss / exploit ได้แน่ ๆ
  │       → 🔴 BLOCKER
  │
  ├─ functionality บางอย่างใช้ไม่ได้ / security risk
  │       → 🟠 CRITICAL
  │
  ├─ quality ลด แต่ระบบยังทำงานได้
  │       → 🟡 MAJOR
  │
  ├─ ใช้ได้แต่ดูไม่สวย / micro-inefficiency
  │       → 🔵 MINOR
  │
  └─ แค่ recommendation
          → ⚪ INFO
```

---

## Rating A-E

### Reliability Rating (Bugs)
| Rating | Condition |
|:------:|-----------|
| **A** | 0 bug |
| **B** | ≥ 1 MINOR bug |
| **C** | ≥ 1 MAJOR bug |
| **D** | ≥ 1 CRITICAL bug |
| **E** | ≥ 1 BLOCKER bug |

> Worst severity wins — มี 1 CRITICAL + 100 MINOR ก็ rating D

### Security Rating (Vulnerabilities)
| Rating | Condition |
|:------:|-----------|
| **A** | 0 vulnerability |
| **B** | ≥ 1 MINOR vuln |
| **C** | ≥ 1 MAJOR vuln |
| **D** | ≥ 1 CRITICAL vuln |
| **E** | ≥ 1 BLOCKER vuln |

### Security Review Rating (Hotspots)
| Rating | % Reviewed |
|:------:|:----------:|
| **A** | 100% |
| **B** | 80-99% |
| **C** | 50-79% |
| **D** | 30-49% |
| **E** | < 30% |

### Maintainability Rating (Code Smells)
ใช้ **Technical Debt Ratio** (sum of fix time / total dev time):
| Rating | Ratio |
|:------:|:-----:|
| **A** | ≤ 5% |
| **B** | 6-10% |
| **C** | 11-20% |
| **D** | 21-50% |
| **E** | > 50% |

**Approximate fix time** (ใช้ตอนคำนวณ tech debt):
| Smell | Fix time |
|-------|---------|
| Magic number | 5 min |
| Long method (> 50 lines) | 30 min |
| Duplicate code (10-20 lines) | 30 min |
| God class (> 500 lines) | 4 hours |
| Cognitive complexity > 15 | 30 min |
| Cognitive complexity > 25 | 2 hours |
| Deep nesting | 30 min |
| Empty catch | 15 min |

---

## Calculator (pseudocode)

```typescript
function reliabilityRating(bugs: Issue[]): 'A' | 'B' | 'C' | 'D' | 'E' {
  const worst = bugs.reduce((max, b) => severityRank(b.severity) > severityRank(max) ? b.severity : max, 'NONE');
  return {
    NONE: 'A',
    INFO: 'A',
    MINOR: 'B',
    MAJOR: 'C',
    CRITICAL: 'D',
    BLOCKER: 'E',
  }[worst];
}

function maintainabilityRating(smells: Issue[], totalDevMinutes: number): Rating {
  const debtMinutes = smells.reduce((sum, s) => sum + s.fixTimeMinutes, 0);
  const ratio = debtMinutes / totalDevMinutes;
  if (ratio <= 0.05) return 'A';
  if (ratio <= 0.10) return 'B';
  if (ratio <= 0.20) return 'C';
  if (ratio <= 0.50) return 'D';
  return 'E';
}

function hotspotsReviewRating(hotspots: Hotspot[]): Rating {
  const reviewed = hotspots.filter(h => h.status === 'SAFE' || h.status === 'FIXED').length;
  const pct = (reviewed / hotspots.length) * 100;
  if (pct >= 100) return 'A';
  if (pct >= 80) return 'B';
  if (pct >= 50) return 'C';
  if (pct >= 30) return 'D';
  return 'E';
}
```

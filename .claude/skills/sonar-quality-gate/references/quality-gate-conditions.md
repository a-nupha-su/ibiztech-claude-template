# Quality Gate Conditions

> โหลดเมื่อตรวจ "ผ่าน Quality Gate ไหม"

---

## Default: "Sonar Way" Quality Gate

> Focus on **NEW CODE** (diff against base branch / last release)
> Principle: **Clean as You Code** — เก่าไม่ต้องแก้หมด แต่ห้ามทำให้ใหม่แย่ลง

### Pass Conditions (ทุกข้อต้องครบ)

```
ON NEW CODE:
  [ ] Reliability Rating       = A          (no new bugs)
  [ ] Security Rating          = A          (no new vulnerabilities)
  [ ] Security Hotspots Review = 100%
  [ ] Maintainability Rating   = A          (tech debt ratio ≤ 5%)
  [ ] Coverage                 ≥ 80%
  [ ] Duplicated Lines         ≤ 3%

OVERALL (optional, less strict):
  [ ] Reliability Rating ≥ A
  [ ] Security Rating    ≥ A
```

---

## Verdict Logic

```
all PASS → ✅ Quality Gate PASSED
any FAIL → ❌ Quality Gate FAILED
```

> FAIL = **block merge** (ใน CI workflow `quality-pipeline.yml` Job A)

---

## Custom Presets (ใช้ตาม project)

### Strict (production-grade)
```
[ ] Reliability NEW       = A
[ ] Security NEW          = A
[ ] Hotspots Reviewed     = 100%
[ ] Maintainability NEW   = A
[ ] Coverage NEW          ≥ 90%
[ ] Duplication NEW       ≤ 1%
[ ] Coverage OVERALL      ≥ 80%
```

### Relaxed (early-stage / prototype)
```
[ ] Reliability NEW       ≥ B  (no CRITICAL/BLOCKER bugs)
[ ] Security NEW          = A  (security ไม่ผ่อนเด็ดขาด)
[ ] Hotspots Reviewed     ≥ 80%
[ ] Maintainability NEW   ≥ B
[ ] Coverage NEW          ≥ 60%
[ ] Duplication NEW       ≤ 5%
```

### Legacy-friendly (รับ inherited codebase)
```
ON NEW CODE: เหมือน Strict
OVERALL: ไม่ตรวจ (legacy debt ปล่อยไว้)
```

---

## Configuration

อ่าน threshold จาก `sonar-project.properties` (template มีให้):

```properties
# Quality Gate thresholds (custom — override default)
sonar.qualitygate.condition.coverage_new=80
sonar.qualitygate.condition.duplication_new=3
sonar.qualitygate.condition.reliability_new=A
sonar.qualitygate.condition.security_new=A
sonar.qualitygate.condition.maintainability_new=A
sonar.qualitygate.condition.hotspots_reviewed=100
```

---

## Dashboard Output

รูปแบบ output มาตรฐาน:

```
╭──────────────────────────────────────────────────────╮
│  Quality Gate: ❌ FAILED                              │
│  Scope: NEW CODE (main...HEAD, 12 files, +340 lines) │
├──────────────────────────────────────────────────────┤
│  Reliability      A  ✅  (0 new bugs)                 │
│  Security         B  ❌  (1 MINOR vulnerability)      │
│  Hotspots Review  60% ❌ (3/5 reviewed)               │
│  Maintainability  A  ✅  (tech debt 2.1%)             │
│  Coverage         72% ❌ (target ≥ 80%)               │
│  Duplication      1.8% ✅ (target ≤ 3%)               │
├──────────────────────────────────────────────────────┤
│  Failed conditions: 3                                 │
│  Issues to fix before merge:                          │
│    🟡 MINOR  src/auth/login.ts:42  [Vuln]            │
│    🔥 review src/utils/cookie.ts:18 [Hotspot]        │
│    🔥 review src/api/upload.ts:55  [Hotspot]         │
│    📊 add coverage for 3 uncovered files              │
╰──────────────────────────────────────────────────────╯
```

---

## Integration กับ DoD

ใน `scripts/check-dod.sh` เพิ่ม check ที่ 8 (optional):

```bash
# 8. Quality Gate on new code (optional but recommended)
if command -v sonar-scanner >/dev/null 2>&1; then
  # ใช้ Sonar server ถ้าตั้งไว้
  sonar-scanner ... && QG_OK=true || QG_OK=false
else
  # ใช้ skill local
  echo "Run sonar-quality-gate skill on new code manually"
  QG_OK=true  # ถือว่าผ่าน (manual)
fi
check "8. Quality Gate on new code" "$QG_OK"
```

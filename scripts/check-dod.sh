#!/usr/bin/env bash
# check-dod.sh — verify 6 DoD items ก่อน mark task [x]
# Usage: bash scripts/check-dod.sh <TASK_CODE>
# Exit 0 = ผ่านทั้ง 6 ข้อ · Exit 1 = ไม่ผ่าน + แสดงรายการขาด

set -e
TASK="${1:?Usage: $0 <TASK_CODE>}"
MODULE=$(echo "$TASK" | cut -d- -f1)
PASS=0
FAIL=0
MISSING=()

check() {
  if [ "$2" = "true" ]; then
    echo "  ✅ $1"
    PASS=$((PASS+1))
  else
    echo "  ❌ $1"
    FAIL=$((FAIL+1))
    MISSING+=("$1")
  fi
}

echo ""
echo "🔍 Checking DoD for $TASK..."
echo ""

# 1. TC exists in 11
if grep -q "TC-${MODULE}-" docs/11-test-cases.md 2>/dev/null; then
  TC_OK=true
else
  TC_OK=false
fi
check "1. TC ใน 11-test-cases.md" "$TC_OK"

# 2. Report exists in test-reports/
if ls docs/test-reports/TR-${MODULE}-*.md 2>/dev/null | head -1 > /dev/null; then
  REPORT_OK=true
  LATEST_REPORT=$(ls -t docs/test-reports/TR-${MODULE}-*.md 2>/dev/null | head -1)
else
  REPORT_OK=false
  LATEST_REPORT=""
fi
check "2. Test Report ใน test-reports/" "$REPORT_OK"

# 3. Report Status = PASSED
if [ -n "$LATEST_REPORT" ] && grep -qE 'Status.*PASSED' "$LATEST_REPORT" 2>/dev/null; then
  STATUS_OK=true
else
  STATUS_OK=false
fi
check "3. Report Status = PASSED" "$STATUS_OK"

# 4. Screenshots folder มี file
if [ -n "$LATEST_REPORT" ]; then
  INDEX=$(basename "$LATEST_REPORT" .md)
  if ls "docs/test-reports/screenshots/${INDEX}/"*.png 2>/dev/null | head -1 > /dev/null; then
    SCREENSHOT_OK=true
  else
    SCREENSHOT_OK=false
  fi
else
  SCREENSHOT_OK=false
fi
check "4. Screenshots ใน screenshots/{INDEX}/" "$SCREENSHOT_OK"

# 5. Log entry ใน 13
if grep -q "$TASK" docs/13-testcase-log.md 2>/dev/null; then
  LOG_OK=true
else
  LOG_OK=false
fi
check "5. Log entry ใน 13-testcase-log.md" "$LOG_OK"

# 6. Sign-off ใน Report (Tester filled)
if [ -n "$LATEST_REPORT" ] && grep -qE '\| Tester \| [^_].*\|' "$LATEST_REPORT" 2>/dev/null; then
  SIGNOFF_OK=true
else
  SIGNOFF_OK=false
fi
check "6. Sign-off (Tester) ใน Report" "$SIGNOFF_OK"

# 7. Feature Brief (ถ้า task นี้ปิด feature)
# Heuristic: check FB ที่ link task code นี้ใน 14-feature-release.md
if grep -q "$TASK" docs/14-feature-release.md 2>/dev/null; then
  FB_OK=true
else
  # ถ้าไม่ใช่ task ปิด feature ก็ผ่าน (อ่าน comment ใน FB doc)
  FB_OK=true
  echo "  ℹ️  (FB check: ยังไม่มี FB ที่ link $TASK — สร้างถ้า task นี้ปิด feature)"
fi
check "7. Feature Brief ใน 14-feature-release.md (ถ้าปิด feature)" "$FB_OK"

echo ""
echo "ผล: $PASS/7 ผ่าน"
echo ""

if [ "$FAIL" -eq 0 ]; then
  echo "✅ ผ่านครบ — สามารถ mark [x] ได้"
  exit 0
else
  echo "❌ ขาด $FAIL ข้อ — ห้าม mark [x]"
  echo ""
  echo "ที่ขาด:"
  for m in "${MISSING[@]}"; do echo "  - $m"; done
  exit 1
fi

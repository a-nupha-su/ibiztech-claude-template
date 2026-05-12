#!/usr/bin/env bash
# log-test.sh — append แถวใน 13-testcase-log.md + update TC ใน 11
# Usage: bash scripts/log-test.sh <TASK_CODE> <PASS|FAIL|BLOCK> <REPORT_INDEX> [TC_CODE] [LAYER]
# ตัวอย่าง: bash scripts/log-test.sh AUTH-002 PASS TR-AUTH-001-20260513 TC-AUTH-001 E2E

set -e
TASK="${1:?Usage: $0 <TASK> <PASS|FAIL|BLOCK> <REPORT> [TC] [LAYER]}"
RESULT="${2:?Result required}"
REPORT="${3:?Report index required}"
TC="${4:-TC-${TASK}}"
LAYER="${5:-E2E}"
DATE=$(TZ='Asia/Bangkok' date '+%Y-%m-%d')

case "$RESULT" in
  PASS) ICON="✅"; SECTION="ผ่าน" ;;
  FAIL) ICON="❌"; SECTION="ไม่ผ่าน" ;;
  BLOCK) ICON="⏸"; SECTION="ไม่ผ่าน" ;;
  *) echo "Result ต้องเป็น PASS / FAIL / BLOCK"; exit 1 ;;
esac

LOG="docs/13-testcase-log.md"
TC_FILE="docs/11-test-cases.md"

# Append row to 13
NEW_ROW="| $DATE | $TC | $TASK | (อธิบายสั้น ๆ) | $LAYER | \`$REPORT\` | $ICON |"
if [ "$SECTION" = "ผ่าน" ]; then
  # Insert before "## ❌ ไม่ผ่าน"
  awk -v row="$NEW_ROW" '
    /^## ❌ ไม่ผ่าน/ { print row; print ""; print; next }
    { print }
  ' "$LOG" > "${LOG}.tmp" && mv "${LOG}.tmp" "$LOG"
else
  # Insert before "## รอทดสอบ"
  awk -v row="$NEW_ROW" '
    /^## รอทดสอบ/ { print row; print ""; print; next }
    { print }
  ' "$LOG" > "${LOG}.tmp" && mv "${LOG}.tmp" "$LOG"
fi

# Update TC Last Run/Result/Report ใน 11 (best-effort)
if grep -q "$TC " "$TC_FILE" 2>/dev/null; then
  echo "ℹ️  พบ $TC ใน $TC_FILE — กรุณาอัพเดต Last Run/Result/Report ใน Index table + รายละเอียดด้วยตนเอง"
else
  echo "⚠️  ยังไม่มี $TC ใน $TC_FILE — สร้าง TC ก่อนตาม template ใน 11-test-cases.md"
fi

echo ""
echo "✅ Log appended ใน $LOG: $NEW_ROW"

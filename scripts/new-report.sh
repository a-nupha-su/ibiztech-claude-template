#!/usr/bin/env bash
# new-report.sh — สร้าง Test Report ใหม่จาก 09-testing.md Section 6
# Usage: bash scripts/new-report.sh <TASK_CODE> [MODULE]
# ตัวอย่าง: bash scripts/new-report.sh AUTH-002 AUTH

set -e
TASK_CODE="${1:?Usage: $0 <TASK_CODE> [MODULE]}"
MODULE="${2:-$(echo "$TASK_CODE" | cut -d- -f1)}"
DATE=$(TZ='Asia/Bangkok' date '+%Y%m%d')
TIME=$(TZ='Asia/Bangkok' date '+%Y-%m-%d %H:%M')

# Find next NNN for this module today
EXISTING=$(ls docs/test-reports/ 2>/dev/null | grep -oE "TR-${MODULE}-[0-9]{3}-${DATE}" | wc -l | tr -d ' ')
NNN=$(printf "%03d" $((EXISTING + 1)))
INDEX="TR-${MODULE}-${NNN}-${DATE}"

REPORT="docs/test-reports/${INDEX}.md"
SCREENSHOTS="docs/test-reports/screenshots/${INDEX}"

mkdir -p "$SCREENSHOTS"

# Extract Section 6 form template from 09-testing.md
awk '/^## 1\. Document Control$/,/^## 7\. Definition of Done/' docs/09-testing.md | \
  sed '$d' | sed 's|`TR-XXX-NNN-YYYYMMDD`|`'"$INDEX"'`|' > "$REPORT"

# Pre-fill known fields
sed -i.bak \
  -e "s|\\*\\*Task Reference\\*\\* \\| \`AUTH-001\`|\\*\\*Task Reference\\*\\* \\| \`${TASK_CODE}\`|" \
  -e "s|\\*\\*Created\\*\\* \\| YYYY-MM-DD HH:MM (Asia/Bangkok)|\\*\\*Created\\*\\* \\| ${TIME} (Asia/Bangkok)|" \
  -e "s|\\*\\*Last Updated\\*\\* \\| YYYY-MM-DD HH:MM|\\*\\*Last Updated\\*\\* \\| ${TIME}|" \
  -e "s|\\*\\*Status\\*\\* \\| \`DRAFT\`|\\*\\*Status\\*\\* \\| \`DRAFT\` (← เปลี่ยนเป็น IN_PROGRESS ตอนเริ่ม)|" \
  "$REPORT"
rm -f "${REPORT}.bak"

echo ""
echo "✅ สร้าง Test Report แล้ว:"
echo "   Report:      $REPORT"
echo "   Screenshots: $SCREENSHOTS/"
echo "   Index Code:  $INDEX"
echo ""
echo "ขั้นต่อไป:"
echo "  1. เปิด $REPORT แล้วกรอก Section 2 → 12"
echo "  2. capture screenshots ลง $SCREENSHOTS/"
echo "  3. รัน bash scripts/log-test.sh $TASK_CODE PASS $INDEX ตอนเสร็จ"

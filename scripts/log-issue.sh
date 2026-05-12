#!/usr/bin/env bash
# log-issue.sh — สร้าง ISS-XXX entry ใน 12-log-issues.md
# Usage: bash scripts/log-issue.sh "<TITLE>" "<TASK_CODE>" "<SYMPTOM>"

set -e
TITLE="${1:?Usage: $0 \"<title>\" \"<task>\" \"<symptom>\"}"
TASK="${2:-}"
SYMPTOM="${3:-}"
DATE=$(TZ='Asia/Bangkok' date '+%Y-%m-%d')
LOG="docs/12-log-issues.md"

# Find next ISS number
LAST=$(grep -oE 'ISS-[0-9]{3}' "$LOG" 2>/dev/null | sort -u | tail -1 | sed 's/ISS-//')
NEXT=$(printf "%03d" $((10#${LAST:-0} + 1)))
ISS="ISS-${NEXT}"

ENTRY="
### $ISS — $TITLE
- **วันที่:** $DATE
- **Status:** OPEN
- **Severity:** [CRITICAL / HIGH / MEDIUM / LOW — เลือก]
- **Task:** $TASK
- **TC / TR:** [ผูก ถ้าเจอตอน test]
- **อาการ:** $SYMPTOM
- **Root Cause:** [เติมหลังวิเคราะห์]
- **Fix:** [เติมหลังแก้]
- **บทเรียน:** [เติม]
- **Closed Date:** —
"

# Insert before "## Risk Register"
awk -v entry="$ENTRY" '
  /^## Risk Register/ { print entry; print "---"; print ""; print; next }
  { print }
' "$LOG" > "${LOG}.tmp" && mv "${LOG}.tmp" "$LOG"

echo ""
echo "✅ สร้าง $ISS แล้วใน $LOG"
echo "   เปิด $LOG → แก้ Root Cause / Fix / บทเรียน ให้สมบูรณ์"

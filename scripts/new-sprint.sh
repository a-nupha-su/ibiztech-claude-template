#!/usr/bin/env bash
# new-sprint.sh — สร้าง Sprint entry ใหม่ใน 15-sprint.md
# Usage: bash scripts/new-sprint.sh "<SPRINT_NAME>"
# ตัวอย่าง: bash scripts/new-sprint.sh "Foundation — Auth + Layout"

set -e
NAME="${1:?Usage: $0 \"<sprint_name>\"}"
DATE_FULL=$(TZ='Asia/Bangkok' date '+%Y-%m-%d')
DATE_COMPACT=$(TZ='Asia/Bangkok' date '+%Y%m%d')
SPRINT_DOC="docs/15-sprint.md"

# Find next NNN
LAST=$(grep -oE 'SP-[0-9]{3}' "$SPRINT_DOC" 2>/dev/null | sort -u | tail -1 | sed 's/SP-//')
NNN=$(printf "%03d" $((10#${LAST:-0} + 1)))
SP="SP-${NNN}-${DATE_COMPACT}"

# Append Index row (before "## Sprint Status")
INDEX_ROW="| $SP | $NAME | PLANNING | $DATE_FULL | — | — | — | — |"
awk -v row="$INDEX_ROW" '
  /^# ╔══.*SPRINT TEMPLATE/ { print row; print ""; print; next }
  { print }
' "$SPRINT_DOC" > "${SPRINT_DOC}.tmp" && mv "${SPRINT_DOC}.tmp" "$SPRINT_DOC"

cat <<EOF

✅ สร้าง Sprint แล้ว:
   Sprint Code: $SP
   Name:        $NAME
   Status:      PLANNING
   Start:       $DATE_FULL

📝 ขั้นต่อไป:
   1. เปิด $SPRINT_DOC
   2. copy 'SPRINT TEMPLATE' block ไปวางใต้ Index table
   3. เปลี่ยน header เป็น: ## $SP — $NAME
   4. กรอก Section 1-5 (Sprint Goal, Committed Tasks, Risk)
   5. เปิด Status → IN_PROGRESS เมื่อ planning เสร็จ

📊 หลัง sprint:
   - Section 7: Sprint Review (demo)
   - Section 8: Sprint Outcome (Velocity)
   - Section 9: Retrospective (Start/Stop/Continue)
   - Sign-off → CLOSED

EOF

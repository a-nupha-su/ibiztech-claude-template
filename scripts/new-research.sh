#!/usr/bin/env bash
# new-research.sh — append Research Entry stub ใน 10-value-research.md
# Usage: bash scripts/new-research.sh <TOPIC> "<TITLE>"
# ตัวอย่าง: bash scripts/new-research.sh AUTH "JWT vs Session cookie"

set -e
TOPIC="${1:?Usage: $0 <TOPIC> \"<title>\"}"
TITLE="${2:?Title required}"
TOPIC_UPPER=$(echo "$TOPIC" | tr '[:lower:]' '[:upper:]')
DATE_FULL=$(TZ='Asia/Bangkok' date '+%Y-%m-%d')
DATE_COMPACT=$(TZ='Asia/Bangkok' date '+%Y%m%d')
RESEARCH="docs/10-value-research.md"

# Find next NNN for this topic
LAST=$(grep -oE "RR-${TOPIC_UPPER}-[0-9]{3}" "$RESEARCH" 2>/dev/null | sort -u | tail -1 | sed "s/RR-${TOPIC_UPPER}-//")
NNN=$(printf "%03d" $((10#${LAST:-0} + 1)))
RR="RR-${TOPIC_UPPER}-${NNN}-${DATE_COMPACT}"

# Append Index row (ก่อน "## 10-Value Framework")
INDEX_ROW="| $RR | $TOPIC_UPPER | $TITLE | [ใส่ชื่อ] | DRAFT | — | $DATE_FULL |"
awk -v row="$INDEX_ROW" '
  /^## 10-Value Framework/ { print row; print ""; print; next }
  { print }
' "$RESEARCH" > "${RESEARCH}.tmp" && mv "${RESEARCH}.tmp" "$RESEARCH"

cat <<EOF

✅ สร้าง Research Entry แล้ว:
   RR Code: $RR
   Topic:   $TOPIC_UPPER
   Title:   $TITLE
   Status:  DRAFT

📝 ขั้นต่อไป:
   1. เปิด $RESEARCH
   2. copy "RESEARCH ENTRY TEMPLATE" (block ✦) ไปวางใต้ Index table
   3. เปลี่ยน header เป็น: ## $RR — $TITLE
   4. กรอก Section 1-10 (Question, Options, Scorecard, Recommendation, Sign-off)
   5. ส่ง review → APPROVED → feed เข้า 01-requirement.md + 07-implement-plan.md

EOF

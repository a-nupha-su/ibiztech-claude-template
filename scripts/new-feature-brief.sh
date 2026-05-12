#!/usr/bin/env bash
# new-feature-brief.sh — สร้าง Feature Brief entry ใน 14-feature-release.md
# Usage: bash scripts/new-feature-brief.sh <TASK_CODE> "<FEATURE_TITLE>" [MODULE]
# ตัวอย่าง: bash scripts/new-feature-brief.sh AUTH-002 "Email/Password Login"

set -e
TASK="${1:?Usage: $0 <TASK_CODE> \"<title>\" [MODULE]}"
TITLE="${2:?Title required}"
MODULE="${3:-$(echo "$TASK" | cut -d- -f1)}"
DATE_FULL=$(TZ='Asia/Bangkok' date '+%Y-%m-%d')
DATE_COMPACT=$(TZ='Asia/Bangkok' date '+%Y%m%d')
FB_DOC="docs/14-feature-release.md"
ASSETS_DIR="docs/feature-assets"

# Find next NNN for this module
LAST=$(grep -oE "FB-${MODULE}-[0-9]{3}" "$FB_DOC" 2>/dev/null | sort -u | tail -1 | sed "s/FB-${MODULE}-//")
NNN=$(printf "%03d" $((10#${LAST:-0} + 1)))
FB="FB-${MODULE}-${NNN}-${DATE_COMPACT}"

# Create assets folder
mkdir -p "$ASSETS_DIR/$FB"

# Append Index row (ก่อน "## Status Lifecycle" หมดท้าย table — actually before the template marker)
INDEX_ROW="| $FB | $TITLE | $MODULE | $TASK | DRAFT | — | — | [ใส่ชื่อ] |"
awk -v row="$INDEX_ROW" '
  /^# ╔══.*FEATURE BRIEF TEMPLATE/ { print row; print ""; print; next }
  { print }
' "$FB_DOC" > "${FB_DOC}.tmp" && mv "${FB_DOC}.tmp" "$FB_DOC"

cat <<EOF

✅ สร้าง Feature Brief แล้ว:
   FB Code:     $FB
   Feature:     $TITLE
   Module:      $MODULE
   Task:        $TASK
   Status:      DRAFT
   Assets dir:  $ASSETS_DIR/$FB/

📝 ขั้นต่อไป:
   1. เปิด $FB_DOC
   2. copy 'FEATURE BRIEF TEMPLATE' block ไปวางใต้ Index table
   3. เปลี่ยน header เป็น: ## $FB — $TITLE
   4. กรอก Section 2-12 (Pitch / Problem / Solution / Benefit / Impact / Screenshots)
   5. ใส่ screenshot ลง $ASSETS_DIR/$FB/
   6. Status: DRAFT → READY → SHIPPED (sign-off ครบ)

🎨 Export นำเสนอ:
   pandoc -f markdown -t docx -o $FB.docx ...
   pandoc -f markdown -t pptx -o $FB.pptx ...

EOF

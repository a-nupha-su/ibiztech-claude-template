#!/usr/bin/env bash
# new-task.sh — mark task [~] (in-progress) + reserve TC stub ใน 11
# Usage: bash scripts/new-task.sh <TASK_CODE>

set -e
TASK="${1:?Usage: $0 <TASK_CODE>}"
MODULE=$(echo "$TASK" | cut -d- -f1)
DATE=$(TZ='Asia/Bangkok' date '+%Y-%m-%d')
PLAN="docs/07-implement-plan.md"
TC_FILE="docs/11-test-cases.md"

# Mark [~] in 07 — change "**$TASK**" line from [ ] to [~]
sed -i.bak "/\\*\\*${TASK}\\*\\*.*\\[ \\]/ s/\\[ \\]/\\[~\\]/" "$PLAN"
rm -f "${PLAN}.bak"

# Find next TC NNN for this module
LAST_TC=$(grep -oE "TC-${MODULE}-[0-9]{3}" "$TC_FILE" 2>/dev/null | sort -u | tail -1 | sed "s/TC-${MODULE}-//")
NEXT_TC=$(printf "%03d" $((10#${LAST_TC:-0} + 1)))
TC_CODE="TC-${MODULE}-${NEXT_TC}"

cat <<EOF

✅ Task $TASK เริ่มแล้ว (marked [~] ใน 07)

📝 ขั้นต่อไป — สร้าง TC ใน $TC_FILE:

   TC Code: $TC_CODE
   Linked Task: $TASK
   วันที่: $DATE

   copy block 'TC ใหม่' จาก section "Templates" ใน $TC_FILE
   แล้วกรอก:
     - Pre-conditions
     - Steps
     - Expected
     - Test Data

🧪 เมื่อพร้อมทดสอบ:
   bash scripts/new-report.sh $TASK $MODULE

EOF

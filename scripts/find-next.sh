#!/usr/bin/env bash
# find-next.sh — แสดง task ถัดไปที่พร้อมทำใน 07-implement-plan.md
# - task ที่สถานะ [ ] + deps ทุกตัวเป็น [x]
# - แสดง Wave, Model, Agent, Count ที่ต้องใช้

set -e
PLAN="docs/07-implement-plan.md"

if [ ! -f "CLAUDE.md" ] && [ -d "variants" ]; then
  echo "⚠️  ยังไม่ได้รัน setup.sh — ยังไม่มี CLAUDE.md ของโปรเจกต์ · บอก user ให้รัน 'bash setup.sh' ก่อน"
  exit 0
fi

if [ ! -f "$PLAN" ]; then
  echo "⚠️  ไม่พบ $PLAN — รัน setup.sh ก่อน"
  exit 0
fi

if grep -q 'สถานะ: TEMPLATE' docs/01-requirement.md 2>/dev/null; then
  echo ""
  echo "⚠️  โปรเจกต์ยังไม่ผ่าน Kickoff (docs/01-requirement.md ยังเป็น TEMPLATE)"
  echo "    → ทำหัวข้อ 'Kickoff' ใน CLAUDE.md ก่อน: เก็บเอกสารลูกค้า → ถามคำถามชุดเดียว → เขียน 10/01/03-05 → archify → 07 → ขอ approve"
  echo "    → ห้ามเริ่ม task / เขียนโค้ดจนกว่าจะ approve"
  exit 0
fi

# Get all done task codes
DONE=$(grep -oE '\*\*[A-Z]+-[0-9]+\*\*' "$PLAN" | grep -B1 '\[x\]' 2>/dev/null | tr -d '*' || true)

echo ""
echo "╭───────────────────────────────────────────╮"
echo "│  Next available tasks ([ ] + deps พร้อม)  │"
echo "╰───────────────────────────────────────────╯"
echo ""

# Print all rows where status = [ ]
# Format: | W1 | **AUTH-001** | งาน | Model | Agent | Count | Deps | [ ] |
grep -E '\|\s*W[0-9]+\s*\|\s*\*\*[A-Z]+-[0-9]+\*\*' "$PLAN" | grep '\[ \]' | head -10 | \
  awk -F '|' '{
    wave=$2; task=$3; work=$4; model=$5; agent=$6; count=$7; deps=$8;
    gsub(/^ +| +$/, "", wave); gsub(/^ +| +$/, "", task);
    gsub(/^ +| +$/, "", model); gsub(/^ +| +$/, "", agent);
    gsub(/^ +| +$/, "", count); gsub(/^ +| +$/, "", deps);
    gsub(/\*\*/, "", task);
    printf "  • %-12s [%s] %-12s · %s × %s · deps: %s\n", task, wave, model, agent, count, deps;
  }'

echo ""
echo "ใช้: bash scripts/new-task.sh <TASK_CODE>  เพื่อเริ่ม"
echo ""

#!/bin/bash
# iBizTech Project Setup Script
# ใช้หลัง clone template repo

set -e
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo ""
echo "=== iBizTech Project Setup ==="
echo ""

# 1. ชื่อโปรเจกต์
read -p "ชื่อโปรเจกต์ (เช่น My Web App): " PROJECT_NAME
if [ -z "$PROJECT_NAME" ]; then
  echo "Error: ต้องระบุชื่อโปรเจกต์"
  exit 1
fi

# 2. ประเภท
echo ""
echo "ประเภทโปรเจกต์:"
echo "  1) Fullstack  — Next.js only (API routes ใน Next.js)"
echo "  2) Separated  — Next.js + NestJS/Express (API แยก repo/service)"
read -p "เลือก (1/2): " TYPE

if [ "$TYPE" != "1" ] && [ "$TYPE" != "2" ]; then
  echo "Error: เลือกได้แค่ 1 หรือ 2"
  exit 1
fi

# 3. copy CLAUDE.md + 05 ตาม variant
echo ""
if [ "$TYPE" = "1" ]; then
  cp variants/CLAUDE-fullstack.md CLAUDE.md
  cp variants/05-datadictionary.md docs/05-datadictionary.md
  rm -f docs/05-api-spec.md
  echo -e "${GREEN}✅ ใช้ CLAUDE-fullstack.md + 05-datadictionary.md${NC}"
else
  cp variants/CLAUDE-separated.md CLAUDE.md
  echo -e "${GREEN}✅ ใช้ CLAUDE-separated.md + 05-api-spec.md${NC}"
fi

# 4. แทน [Project Name] ทุกไฟล์
DATE=$(TZ='Asia/Bangkok' date '+%Y-%m-%d')
find . -name "*.md" ! -path "./variants/*" ! -path "./.git/*" | while read f; do
  sed -i.bak "s/\[Project Name\]/$PROJECT_NAME/g" "$f"
  sed -i.bak "s/YYYY-MM-DD/$DATE/g" "$f"
  rm -f "$f.bak"
done

# 5. ลบ variants folder (ไม่ต้องเหลือใน project)
rm -rf variants/

# 6. init git (ถ้ายังไม่มี)
if [ ! -d ".git" ]; then
  git init
  git add .
  git commit -m "init: project setup from ibiztech-claude-template"
  echo -e "${GREEN}✅ git init + initial commit${NC}"
fi

echo ""
echo -e "${GREEN}=== Setup เสร็จแล้ว ===${NC}"
echo ""
echo -e "${YELLOW}Automation ที่ติดมา (พร้อมใช้ทันที):${NC}"
echo "  .claude/settings.json   ← permission allowlist + hooks"
echo "  scripts/find-next.sh    ← หา task ถัดไปที่พร้อมทำ"
echo "  scripts/new-task.sh     ← เริ่ม task (mark [~] + TC stub)"
echo "  scripts/new-report.sh   ← สร้าง Test Report จาก template"
echo "  scripts/log-test.sh     ← append log ใน 13"
echo "  scripts/log-issue.sh    ← สร้าง ISS-XXX ใน 12"
echo "  scripts/check-dod.sh    ← verify 6 DoD ก่อน mark [x]"
echo "  scripts/progress.sh     ← recalc Summary Progress"
echo ""
echo -e "${YELLOW}ขั้นตอนถัดไป (ทำก่อนเขียนโค้ดบรรทัดแรก):${NC}"
echo "  0. (ถ้า requirement ยังไม่ชัด) เปิด docs/10-value-research.md"
echo "     → ทำ research ทุก option ที่ลังเล → user APPROVED ก่อน"
echo "  1. เปิด docs/01-requirement.md → เขียน FR ทั้งหมด"
echo "  2. เปิด docs/07-implement-plan.md → แตก FR เป็น task code"
if [ "$TYPE" = "2" ]; then
  echo "  3. เปิด docs/05-api-spec.md → วาง API contract ก่อน implement"
fi
echo ""
echo "  จากนั้นบอก Claude:"
echo "  'อ่าน CLAUDE.md แล้วเริ่ม SETUP-001'"
echo ""

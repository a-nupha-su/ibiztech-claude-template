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

# 5.1 ถาม Quality Pipeline (Sonar + JMeter + Claude)
echo ""
echo -e "${YELLOW}Quality Pipeline (CI/CD):${NC}"
echo "  - SonarQube: static code analysis (recommended)"
echo "  - JMeter:    load/performance test"
echo "  - Claude:    auto-fix on quality gate failure"
echo ""
read -p "ตั้ง SonarQube + Claude auto-fix ไหม? (Y/n): " SETUP_SONAR
SETUP_SONAR="${SETUP_SONAR:-Y}"
if [[ "$SETUP_SONAR" =~ ^[Yy]$ ]]; then
  PROJECT_KEY=$(echo "$PROJECT_NAME" | tr '[:upper:]' '[:lower:]' | tr ' ' '-' | tr -cd 'a-z0-9-')
  bash scripts/setup-sonar.sh "$PROJECT_KEY" "$PROJECT_NAME"
else
  echo -e "${YELLOW}⏭  ข้าม Sonar — รัน 'bash scripts/setup-sonar.sh' ทีหลังได้${NC}"
fi

echo ""
read -p "ตั้ง JMeter load test ไหม? (y/N): " SETUP_JMETER
SETUP_JMETER="${SETUP_JMETER:-N}"
if [[ "$SETUP_JMETER" =~ ^[Yy]$ ]]; then
  bash scripts/setup-jmeter.sh
else
  echo -e "${YELLOW}⏭  ข้าม JMeter — รัน 'bash scripts/setup-jmeter.sh' ทีหลังได้${NC}"
fi

# 5.2 Auto-Pipeline deploy config
echo ""
echo -e "${YELLOW}Auto-Pipeline (research → approve → build → deploy):${NC}"
echo "  - Skill .claude/skills/auto-pipeline/ จัดการ orchestration"
echo "  - scripts/deploy.sh dispatch ไป vercel/docker/gh-actions/ssh"
echo "  - .env.deploy เก็บ target + secrets (gitignored)"
echo ""
read -p "Copy .env.deploy.example → .env.deploy ไหม? (Y/n): " SETUP_DEPLOY
SETUP_DEPLOY="${SETUP_DEPLOY:-Y}"
if [[ "$SETUP_DEPLOY" =~ ^[Yy]$ ]]; then
  if [[ ! -f .env.deploy ]]; then
    cp .env.deploy.example .env.deploy
    echo -e "${GREEN}✅ .env.deploy created — แก้ DEPLOY_TARGET + DEPLOY_URL + secrets ก่อนใช้${NC}"
  else
    echo -e "${YELLOW}⏭  .env.deploy มีอยู่แล้ว — ข้าม${NC}"
  fi
else
  echo -e "${YELLOW}⏭  ข้าม — รัน 'cp .env.deploy.example .env.deploy' ทีหลังได้${NC}"
fi

# 6. init git (ถ้ายังไม่มี)
if [ ! -d ".git" ]; then
  git init -q

  # ตรวจ git identity (global หรือ local)
  GIT_NAME=$(git config --get user.name || echo "")
  GIT_EMAIL=$(git config --get user.email || echo "")

  if [ -z "$GIT_NAME" ] || [ -z "$GIT_EMAIL" ]; then
    echo -e "${YELLOW}⚠️  git identity ยังไม่ตั้ง — ข้าม initial commit${NC}"
    echo "   ตั้งก่อน commit:"
    echo "     git config --global user.name \"Your Name\""
    echo "     git config --global user.email \"you@example.com\""
    echo "   แล้ว:"
    echo "     git add . && git commit -m 'init: project setup'"
  else
    git add .
    if git commit -q -m "init: project setup from ibiztech-claude-template"; then
      echo -e "${GREEN}✅ git init + initial commit ($GIT_NAME <$GIT_EMAIL>)${NC}"
    else
      echo -e "${YELLOW}⚠️  git init เสร็จ แต่ commit ไม่ผ่าน — รัน manual${NC}"
    fi
  fi
fi

echo ""
echo -e "${GREEN}=== Setup เสร็จแล้ว ===${NC}"
echo ""
echo -e "${YELLOW}Automation ที่ติดมา (พร้อมใช้ทันที):${NC}"
echo "  .claude/settings.json                  ← permission allowlist + hooks"
echo "  .github/workflows/quality-pipeline.yml ← Sonar + JMeter + Claude (เลือกใน dispatch)"
echo "  scripts/find-next.sh                   ← หา task ถัดไปที่พร้อมทำ"
echo "  scripts/new-task.sh                    ← เริ่ม task (mark [~] + TC stub)"
echo "  scripts/new-report.sh                  ← สร้าง Test Report จาก template"
echo "  scripts/log-test.sh                    ← append log ใน 13"
echo "  scripts/log-issue.sh                   ← สร้าง ISS-XXX ใน 12"
echo "  scripts/check-dod.sh                   ← verify 6 DoD ก่อน mark [x]"
echo "  scripts/progress.sh                    ← recalc Summary Progress"
echo "  scripts/setup-sonar.sh                 ← (re)configure Sonar key/host"
echo "  scripts/setup-jmeter.sh                ← (re)configure JMeter target/thresholds"
echo "  scripts/run-jmeter.sh                  ← run JMeter local (ก่อน push CI)"
echo "  scripts/deploy.sh                      ← auto-deploy (vercel/docker/gh-actions/ssh)"
echo "  scripts/pipeline-gate.sh               ← silent PostToolUse advisory checks"
echo "  .claude/skills/auto-pipeline/          ← end-to-end orchestrator skill"
echo "  .env.deploy.example                    ← copy → .env.deploy (deploy target + secrets)"
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
echo -e "${YELLOW}หรือใช้ Auto-Pipeline (end-to-end):${NC}"
echo "  'ทำ auto pipeline เรื่อง <topic> ตั้งแต่ research จนถึง deploy'"
echo "  → researcher → user approve (ครั้งเดียว) → architect → coder → tester → reviewer → deployer"
echo ""

#!/usr/bin/env bash
# setup-sonar.sh — เซ็ต SonarQube + Claude CI/CD ในโปรเจกต์
# Usage:
#   bash scripts/setup-sonar.sh                # interactive prompts
#   bash scripts/setup-sonar.sh KEY NAME HOST  # non-interactive
#
# หลังรันเสร็จ ต้องเข้า GitHub repo → Settings → Secrets → Actions
# เพื่อใส่ secrets: SONAR_TOKEN, SONAR_HOST_URL, ANTHROPIC_API_KEY

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PROPS="$ROOT/sonar-project.properties"
WORKFLOW="$ROOT/.github/workflows/quality-pipeline.yml"

echo ""
echo -e "${BLUE}=== SonarQube + Claude Setup ===${NC}"
echo ""

# Validate template files
if [ ! -f "$PROPS" ]; then
  echo -e "${RED}❌ ไม่พบ $PROPS — ติดตั้ง template ใหม่${NC}"
  exit 1
fi

if [ ! -f "$WORKFLOW" ]; then
  echo -e "${RED}❌ ไม่พบ $WORKFLOW — ติดตั้ง template ใหม่${NC}"
  exit 1
fi

# Inputs (CLI or prompt)
PROJECT_KEY="${1:-}"
PROJECT_NAME="${2:-}"
SONAR_HOST="${3:-}"

if [ -z "$PROJECT_KEY" ]; then
  DEFAULT_KEY=$(basename "$ROOT" | tr '[:upper:]' '[:lower:]' | tr ' ' '-')
  read -p "Sonar Project Key (default: $DEFAULT_KEY): " PROJECT_KEY
  PROJECT_KEY="${PROJECT_KEY:-$DEFAULT_KEY}"
fi

if [ -z "$PROJECT_NAME" ]; then
  DEFAULT_NAME=$(basename "$ROOT")
  read -p "Sonar Project Name (default: $DEFAULT_NAME): " PROJECT_NAME
  PROJECT_NAME="${PROJECT_NAME:-$DEFAULT_NAME}"
fi

if [ -z "$SONAR_HOST" ]; then
  echo ""
  echo "Sonar Host URL:"
  echo "  1) SonarCloud   — https://sonarcloud.io"
  echo "  2) Self-hosted  — http://localhost:9000 หรือ URL ของคุณ"
  read -p "เลือก (1/2) หรือใส่ URL ตรง: " HOST_CHOICE
  case "$HOST_CHOICE" in
    1) SONAR_HOST="https://sonarcloud.io" ;;
    2) read -p "URL: " SONAR_HOST ;;
    http*) SONAR_HOST="$HOST_CHOICE" ;;
    *) SONAR_HOST="https://sonarcloud.io" ;;
  esac
fi

# Replace placeholders
echo ""
echo -e "${YELLOW}→ Updating sonar-project.properties${NC}"
sed -i.bak \
  -e "s|__PROJECT_KEY__|$PROJECT_KEY|g" \
  -e "s|__PROJECT_NAME__|$PROJECT_NAME|g" \
  "$PROPS"
rm -f "$PROPS.bak"

# SonarCloud needs organization
if echo "$SONAR_HOST" | grep -q "sonarcloud.io"; then
  read -p "SonarCloud Organization key: " SONAR_ORG
  if [ -n "$SONAR_ORG" ]; then
    sed -i.bak "s|# sonar.organization=your-org-key.*|sonar.organization=$SONAR_ORG|" "$PROPS"
    rm -f "$PROPS.bak"
  fi
fi

echo -e "${GREEN}✅ Updated sonar-project.properties${NC}"
echo "   projectKey:  $PROJECT_KEY"
echo "   projectName: $PROJECT_NAME"

# Write .env.sonar.example (reminder)
ENV_EXAMPLE="$ROOT/.env.sonar.example"
cat > "$ENV_EXAMPLE" <<EOF
# SonarQube + Claude Integration
# Copy เป็น .env.sonar (gitignored) สำหรับ run local scan
# สำหรับ CI ใส่ค่าเหล่านี้ที่ GitHub → Settings → Secrets → Actions

SONAR_TOKEN=
SONAR_HOST_URL=$SONAR_HOST
ANTHROPIC_API_KEY=
EOF
echo -e "${GREEN}✅ สร้าง .env.sonar.example${NC}"

# Append to .gitignore
if ! grep -q "^\.env\.sonar$" "$ROOT/.gitignore" 2>/dev/null; then
  printf "\n# Sonar local secrets\n.env.sonar\n.sonar-fix/\n" >> "$ROOT/.gitignore"
  echo -e "${GREEN}✅ Updated .gitignore${NC}"
fi

# Summary
echo ""
echo -e "${BLUE}=== ขั้นตอนถัดไป ===${NC}"
echo ""
echo -e "${YELLOW}1) ตั้ง GitHub Secrets${NC} (Settings → Secrets and variables → Actions → New repository secret):"
echo ""
echo "   SONAR_TOKEN        จาก $SONAR_HOST → My Account → Security → Generate Token"
echo "   SONAR_HOST_URL     $SONAR_HOST"
echo "   ANTHROPIC_API_KEY  จาก https://console.anthropic.com"
echo ""
echo -e "${YELLOW}2) สร้าง project ใน SonarQube${NC} ด้วย key: ${GREEN}$PROJECT_KEY${NC}"
echo ""
echo -e "${YELLOW}3) (Optional) ทดสอบ scan local${NC}:"
echo ""
echo "   cp .env.sonar.example .env.sonar  # ใส่ค่าจริงในนี้"
echo "   set -a && source .env.sonar && set +a"
echo "   npx -y sonar-scanner"
echo ""
echo -e "${YELLOW}4) Push code${NC} → workflow .github/workflows/sonar-claude.yml จะ trigger เอง"
echo ""
echo -e "${GREEN}ดูเอกสารเต็ม:${NC} docs/17-sonar-setup.md"
echo ""

#!/usr/bin/env bash
# setup-jmeter.sh — ตั้งค่า JMeter target + thresholds + บอก secret ที่ต้องใส่
# Usage:
#   bash scripts/setup-jmeter.sh                          # interactive
#   bash scripts/setup-jmeter.sh https://app.example.com  # non-interactive

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
THRESHOLDS="$ROOT/tests/jmeter/thresholds.env"
JMX="$ROOT/tests/jmeter/baseline.jmx"

echo ""
echo -e "${BLUE}=== JMeter + Claude Setup ===${NC}"
echo ""

if [ ! -f "$JMX" ]; then
  echo -e "${RED}❌ ไม่พบ $JMX — ติดตั้ง template ใหม่${NC}"
  exit 1
fi

TARGET_URL="${1:-}"
if [ -z "$TARGET_URL" ]; then
  read -p "Default target URL (เช่น https://staging.example.com/api/health, ว่างได้): " TARGET_URL
fi

if [ -n "$TARGET_URL" ]; then
  echo -e "${GREEN}✅ Target: $TARGET_URL${NC}"
else
  echo -e "${YELLOW}⚠  ไม่ได้ใส่ target — workflow จะอ่านจาก secret JMETER_TARGET_URL หรือ workflow input${NC}"
fi

# Thresholds tuning
echo ""
echo -e "${YELLOW}=== Performance Budget (Enter = เก็บ default) ===${NC}"
echo ""

CUR_P95=$(grep "^P95_MAX_MS=" "$THRESHOLDS" | cut -d= -f2)
read -p "P95 max (ms) [default: $CUR_P95]: " NEW_P95
NEW_P95="${NEW_P95:-$CUR_P95}"

CUR_ERR=$(grep "^ERROR_RATE_MAX=" "$THRESHOLDS" | cut -d= -f2)
read -p "Error rate max (%) [default: $CUR_ERR]: " NEW_ERR
NEW_ERR="${NEW_ERR:-$CUR_ERR}"

# Update thresholds.env
sed -i.bak \
  -e "s|^P95_MAX_MS=.*|P95_MAX_MS=$NEW_P95|" \
  -e "s|^ERROR_RATE_MAX=.*|ERROR_RATE_MAX=$NEW_ERR|" \
  "$THRESHOLDS"
rm -f "$THRESHOLDS.bak"

echo ""
echo -e "${GREEN}✅ Updated tests/jmeter/thresholds.env${NC}"
echo "   P95_MAX_MS=$NEW_P95"
echo "   ERROR_RATE_MAX=$NEW_ERR"

# Append target to .env.sonar.example (combined env file)
if [ -n "$TARGET_URL" ] && [ -f "$ROOT/.env.sonar.example" ]; then
  if ! grep -q "^JMETER_TARGET_URL=" "$ROOT/.env.sonar.example"; then
    printf "\n# JMeter target (optional — workflow input ก็ override ได้)\nJMETER_TARGET_URL=%s\n" "$TARGET_URL" >> "$ROOT/.env.sonar.example"
  else
    sed -i.bak "s|^JMETER_TARGET_URL=.*|JMETER_TARGET_URL=$TARGET_URL|" "$ROOT/.env.sonar.example"
    rm -f "$ROOT/.env.sonar.example.bak"
  fi
  echo -e "${GREEN}✅ Updated .env.sonar.example${NC}"
fi

# Append to .gitignore
if ! grep -q "^tests/jmeter/results/" "$ROOT/.gitignore" 2>/dev/null; then
  printf "\n# JMeter results\ntests/jmeter/results/\n" >> "$ROOT/.gitignore"
  echo -e "${GREEN}✅ Updated .gitignore${NC}"
fi

# Summary
echo ""
echo -e "${BLUE}=== ขั้นตอนถัดไป ===${NC}"
echo ""
echo -e "${YELLOW}1) ตั้ง GitHub Secret (optional — ถ้าจะใช้ default target):${NC}"
echo ""
echo "   JMETER_TARGET_URL  = $TARGET_URL"
echo ""
echo "   (Settings → Secrets and variables → Actions → New repository secret)"
echo ""
echo -e "${YELLOW}2) (Optional) ทดสอบ local:${NC}"
echo ""
echo "   # ติดตั้ง jmeter ก่อน: brew install jmeter (macOS) หรือ apt install jmeter"
echo "   bash scripts/run-jmeter.sh ${TARGET_URL:-https://your-url.com}"
echo ""
echo -e "${YELLOW}3) Trigger workflow:${NC}"
echo ""
echo "   GitHub → Actions → Quality Pipeline → Run workflow"
echo "   ติ๊ก 'Run JMeter load test' = ON → Run"
echo ""
echo -e "${GREEN}ดูเอกสารเต็ม:${NC} docs/18-jmeter-setup.md"
echo ""

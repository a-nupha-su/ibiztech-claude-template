#!/usr/bin/env bash
# create-project.sh — สร้าง project ใหม่จาก ibiztech-claude-template
# Usage: bash create-project.sh <DEST_PATH>
# ตัวอย่าง:
#   bash create-project.sh ~/my-new-project
#   bash create-project.sh /tmp/test-project

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

DEST="${1:-}"

if [ -z "$DEST" ]; then
  echo "Usage: $0 <DEST_PATH>"
  echo "ตัวอย่าง: $0 ~/my-new-project"
  exit 1
fi

# Expand ~
DEST="${DEST/#\~/$HOME}"

# Find template path (where this script lives)
TEMPLATE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Validate template
if [ ! -f "$TEMPLATE_DIR/setup.sh" ]; then
  echo -e "${RED}❌ ไม่พบ setup.sh ใน $TEMPLATE_DIR${NC}"
  exit 1
fi

# Validate destination
if [ -e "$DEST" ]; then
  if [ "$(ls -A "$DEST" 2>/dev/null)" ]; then
    echo -e "${RED}❌ $DEST มีอยู่แล้วและไม่ว่าง — เลือก path ใหม่หรือลบก่อน${NC}"
    exit 1
  fi
fi

echo ""
echo -e "${GREEN}=== Create iBizTech Project ===${NC}"
echo ""
echo "  Template:    $TEMPLATE_DIR"
echo "  Destination: $DEST"
echo ""

# Copy template (exclude internal state)
mkdir -p "$DEST"
echo -e "${YELLOW}→ Copy template files...${NC}"
rsync -a \
  --exclude='.git/' \
  --exclude='.claude-flow/' \
  --exclude='.DS_Store' \
  --exclude='create-project.sh' \
  "$TEMPLATE_DIR/" "$DEST/"

echo -e "${GREEN}✅ Copy เสร็จ${NC}"
echo ""

# cd + run setup.sh
cd "$DEST"
echo -e "${YELLOW}→ รัน setup.sh ใน $DEST${NC}"
echo ""
bash setup.sh

# Next steps
echo ""
echo -e "${GREEN}=== Project พร้อมใช้งานแล้ว ===${NC}"
echo ""
echo -e "${YELLOW}ต่อไป:${NC}"
echo ""
echo "  cd $DEST"
echo ""
echo "  # (ถ้ามีเอกสารลูกค้า)"
echo "  bash scripts/new-artifact.sh \"Requirements\" \"คุณ X\" ~/Downloads/req.pdf"
echo ""
echo "  # เปิด Claude Code"
echo "  claude"
echo ""
echo "  # ใน Claude session:"
echo "  → 'อ่าน CLAUDE.md + วิเคราะห์ docs/16-client-artifacts.md → สร้าง plan'"
echo ""

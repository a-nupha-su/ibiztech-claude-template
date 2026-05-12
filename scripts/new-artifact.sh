#!/usr/bin/env bash
# new-artifact.sh — บันทึก client artifact ใหม่ + append index row ใน 16
# Usage: bash scripts/new-artifact.sh "<TYPE>" "<FROM>" "<SOURCE_FILE>" ["<SLUG>"]
# ตัวอย่าง:
#   bash scripts/new-artifact.sh "Requirements" "คุณ Somchai" "~/Downloads/req.pdf"
#   bash scripts/new-artifact.sh "Mockup" "Designer A" "~/Downloads/flow.png" "login-flow"

set -e
TYPE="${1:?Usage: $0 \"<TYPE>\" \"<FROM>\" \"<SOURCE_FILE>\" [SLUG]}"
FROM="${2:?From required}"
SOURCE="${3:?Source file required}"
SLUG="${4:-$(basename "$SOURCE" | sed 's/\.[^.]*$//' | tr '[:upper:] ' '[:lower:]-')}"
DATE_FULL=$(TZ='Asia/Bangkok' date '+%Y-%m-%d')
DATE_COMPACT=$(TZ='Asia/Bangkok' date '+%Y%m%d')
INDEX="docs/16-client-artifacts.md"
ARTIFACTS_DIR="docs/client-artifacts"

# Expand ~ in source path
SOURCE_EXPANDED="${SOURCE/#\~/$HOME}"
if [ ! -f "$SOURCE_EXPANDED" ]; then
  echo "❌ ไม่พบไฟล์: $SOURCE_EXPANDED"
  exit 1
fi

# Find next NNN (ทั้งโปรเจกต์ ไม่แยกตาม date)
LAST=$(grep -oE 'CA-[0-9]{3}-[0-9]{8}' "$INDEX" 2>/dev/null | grep -oE 'CA-[0-9]{3}' | sort -u | tail -1 | sed 's/CA-//')
NNN=$(printf "%03d" $((10#${LAST:-0} + 1)))
CA="CA-${NNN}-${DATE_COMPACT}"

# Create destination folder
DEST_DIR="$ARTIFACTS_DIR/$DATE_FULL"
mkdir -p "$DEST_DIR"

# Copy file with new name
EXT="${SOURCE##*.}"
DEST_FILE="$DEST_DIR/CA-${NNN}-${SLUG}.${EXT}"
cp "$SOURCE_EXPANDED" "$DEST_FILE"

# Append Index row
INDEX_ROW="| $CA | $DATE_FULL | $FROM | $TYPE | \`$DEST_FILE\` | RECEIVED | — |"
awk -v row="$INDEX_ROW" '
  /^### Type categories/ { print row; print ""; print; next }
  { print }
' "$INDEX" > "${INDEX}.tmp" && mv "${INDEX}.tmp" "$INDEX"

cat <<EOF

✅ บันทึก Client Artifact แล้ว:
   CA Code:    $CA
   Type:       $TYPE
   From:       $FROM
   File:       $DEST_FILE
   Size:       $(ls -lh "$DEST_FILE" | awk '{print $5}')
   Status:     RECEIVED

📝 ขั้นต่อไป (ภายใน 24-48 ชม.):
   1. เปิด $INDEX
   2. copy 'ANALYSIS ENTRY TEMPLATE' block ไปวางใต้ Index table
   3. เปลี่ยน header เป็น: ## $CA — [Artifact Title]
   4. Status: RECEIVED → ANALYZING
   5. กรอก Section 1-10:
      - Summary
      - Explicit Requirements
      - Implicit / Hidden Requirements
      - Open Questions (ถามกลับลูกค้า)
      - Conflicts
      - Action Items (RR / FR / Task ที่จะสร้าง)
   6. Sign-off → ANALYZED → สร้าง outcome → ACTIONED

⚠️  ถ้าไฟล์มี PII / confidential → mask + พิจารณาใส่ .gitignore
EOF

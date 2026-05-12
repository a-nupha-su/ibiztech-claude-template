#!/usr/bin/env bash
# check-artifacts.sh — scan docs/client-artifacts/ + cross-ref กับ 16-client-artifacts.md
# พิมพ์สรุป: ใหม่ยังไม่ register / รอวิเคราะห์ / รอ action

INDEX="docs/16-client-artifacts.md"
ARTIFACTS_DIR="docs/client-artifacts"

# Exit เงียบถ้ายังไม่มี structure (โปรเจกต์ใหม่)
[ ! -d "$ARTIFACTS_DIR" ] && exit 0
[ ! -f "$INDEX" ] && exit 0

# Count raw files (ไม่นับ .gitkeep)
FILE_COUNT=$(find "$ARTIFACTS_DIR" -type f ! -name ".gitkeep" 2>/dev/null | wc -l | tr -d ' ')

# Exit เงียบถ้าไม่มี artifact เลย
[ "$FILE_COUNT" -eq 0 ] && exit 0

# Find untracked raw files (ไฟล์ที่ไม่มี CA entry ใน 16)
UNTRACKED_LIST=""
UNTRACKED_COUNT=0
while IFS= read -r f; do
  [ -z "$f" ] && continue
  CA_CODE=$(basename "$f" | grep -oE '^CA-[0-9]{3}' | head -1)
  if [ -z "$CA_CODE" ]; then
    UNTRACKED_LIST="${UNTRACKED_LIST}  • $f (ไม่มี CA prefix)\n"
    UNTRACKED_COUNT=$((UNTRACKED_COUNT + 1))
  elif ! grep -q "$CA_CODE" "$INDEX" 2>/dev/null; then
    UNTRACKED_LIST="${UNTRACKED_LIST}  • $f ($CA_CODE — ไม่มี entry ใน 16)\n"
    UNTRACKED_COUNT=$((UNTRACKED_COUNT + 1))
  fi
done < <(find "$ARTIFACTS_DIR" -type f ! -name ".gitkeep" 2>/dev/null)

# Count by Status — exclude example rows (มี "ตัวอย่าง" คำ)
count_status() {
  grep -E "\| $1 \|" "$INDEX" 2>/dev/null | grep -v 'ตัวอย่าง' | wc -l | tr -d ' '
}

RECEIVED=$(count_status RECEIVED)
ANALYZING=$(count_status ANALYZING)
ANALYZED=$(count_status ANALYZED)
ACTIONED=$(count_status ACTIONED)
OBSOLETE=$(count_status OBSOLETE)

PENDING=$((RECEIVED + ANALYZING))
TOTAL=$((RECEIVED + ANALYZING + ANALYZED + ACTIONED + OBSOLETE))

# Header
echo ""
echo "╭───────────────────────────────────────────────────╮"
echo "│  Client Artifacts Check                           │"
echo "╰───────────────────────────────────────────────────╯"
echo ""
echo "  📁 Raw files in client-artifacts/: $FILE_COUNT"
echo "  📋 CA entries (registered): $TOTAL"
echo ""
echo "  Status breakdown:"
echo "    🟡 RECEIVED   (รอวิเคราะห์):    $RECEIVED"
echo "    🟠 ANALYZING  (กำลังวิเคราะห์): $ANALYZING"
echo "    🟢 ANALYZED   (รอ action):     $ANALYZED"
echo "    ✅ ACTIONED   (สร้าง plan แล้ว): $ACTIONED"
echo "    ⚪ OBSOLETE                  : $OBSOLETE"
echo ""

WARN=0

# 1. Untracked files
if [ "$UNTRACKED_COUNT" -gt 0 ]; then
  echo "  ⚠️  ไฟล์ที่ยังไม่ register ($UNTRACKED_COUNT ไฟล์):"
  printf "$UNTRACKED_LIST"
  echo "     → รัน: bash scripts/new-artifact.sh \"<TYPE>\" \"<FROM>\" \"<FILE>\""
  echo ""
  WARN=1
fi

# 2. Pending analysis
if [ "$PENDING" -gt 0 ]; then
  echo "  ⚠️  $PENDING artifact(s) รอวิเคราะห์ — ก่อนสร้าง RR/FR/Task ใหม่ ควรวิเคราะห์ก่อน"
  grep -E '\| (RECEIVED|ANALYZING) \|' "$INDEX" 2>/dev/null | grep -v 'ตัวอย่าง' | \
    awk -F '|' '{ gsub(/^ +| +$/, "", $2); gsub(/^ +| +$/, "", $5); gsub(/^ +| +$/, "", $7); printf "     • %s — %s (%s)\n", $2, $5, $7 }' | head -5
  echo ""
  WARN=1
fi

# 3. ANALYZED but not yet ACTIONED
if [ "$ANALYZED" -gt 0 ]; then
  echo "  ℹ️  $ANALYZED artifact(s) วิเคราะห์เสร็จแต่ยังไม่ ACTIONED (สร้าง RR/FR/Task)"
  echo ""
  WARN=1
fi

# 4. ALL GOOD
if [ "$WARN" -eq 0 ]; then
  echo "  ✅ ทุก artifact register + วิเคราะห์ + actioned ครบ"
  echo ""
fi

# Recommendation
if [ "$WARN" -eq 1 ] && { [ "$PENDING" -gt 0 ] || [ "$UNTRACKED_COUNT" -gt 0 ]; }; then
  echo "  💡 ก่อนสร้าง task/research ใหม่ → เคลียร์ artifact ค้างก่อน"
  echo "     (อาจมี requirement ใน artifact ที่ overlap หรือเปลี่ยน scope)"
  echo ""
fi

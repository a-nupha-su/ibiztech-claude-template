#!/usr/bin/env bash
# check-requirements.sh — ตรวจว่าเครื่องนี้มี tool / skill ที่ template ต้องใช้ครบไหม
#                         ตัวไหนขาด → ถามก่อน ติดตั้งเมื่อผู้ใช้ตอบ y เท่านั้น
#
# Usage:
#   bash scripts/check-requirements.sh                 ตรวจทุกกลุ่ม + ถามติดตั้งทีละตัว (interactive)
#   bash scripts/check-requirements.sh srs manhours    ตรวจเฉพาะกลุ่มที่ระบุ
#   bash scripts/check-requirements.sh --check [กลุ่ม]  ตรวจอย่างเดียว ไม่ถาม ไม่ติดตั้ง (ให้ Claude ใช้)
#   bash scripts/check-requirements.sh --check --quiet  พิมพ์เฉพาะตัวที่ขาด (ใช้ใน SessionStart hook)
#
# กลุ่ม: core · srs · manhours · test · quality
# exit: 0 = ตัวบังคับครบ · 1 = ยังขาดตัวบังคับ
#
# กติกา: script นี้ "ไม่ติดตั้งอะไรเอง" ถ้าไม่ได้รับคำตอบ y — ใน --check ไม่ถามและไม่ติดตั้งเลย

set -u

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TPL="$ROOT/templates"
VENV="$TPL/.venv"
OFFICECLI="${OFFICECLI:-$HOME/.local/bin/officecli}"

GREEN='\033[0;32m'; YELLOW='\033[1;33m'; RED='\033[0;31m'; NC='\033[0m'

CHECK_ONLY=0; QUIET=0; SEL=()
set +u   # bash 3.2 (macOS) มองอาเรย์ว่างเป็น unbound
for a in "$@"; do
  case "$a" in
    --check) CHECK_ONLY=1 ;;
    --quiet) QUIET=1 ;;
    -h|--help) sed -n '2,15p' "$0"; exit 0 ;;
    core|srs|manhours|test|quality) SEL+=("$a") ;;
    *) echo "ไม่รู้จัก: $a (ดู --help)"; exit 2 ;;
  esac
done
[ ${#SEL[@]} -eq 0 ] && SEL=(core srs manhours test quality)

MISSING_REQUIRED=0
MISSING_LIST=()

say() { [ "$QUIET" -eq 1 ] || echo -e "$@"; }

mark_missing() { [ "$1" = "required" ] && MISSING_REQUIRED=1; MISSING_LIST+=("$2"); }

have() { command -v "$1" >/dev/null 2>&1; }

pkg_install_cmd() {   # $1 = brew formula, $2 = apt package, $3 = "cask" ถ้าเป็น brew cask
  if have brew; then
    [ "${3:-}" = "cask" ] && echo "brew install --cask $1" || echo "brew install $1"
  elif have apt-get; then
    echo "sudo apt-get install -y $2"
  else
    echo ""
  fi
}

# need <ระดับ required|optional> <ชื่อ> <ใช้ทำอะไร> <คำสั่งตรวจ> <คำสั่งติดตั้ง หรือ "" = ติดตั้งเองตามคำแนะนำ> [คำแนะนำ]
need() {
  local level="$1" name="$2" why="$3" test_cmd="$4" install_cmd="$5" hint="${6:-}"
  if eval "$test_cmd" >/dev/null 2>&1; then
    say "  ${GREEN}✓${NC} $name"
    return 0
  fi
  local tag="ขาด"; [ "$level" = "optional" ] && tag="ขาด (ไม่บังคับ)"
  if [ "$QUIET" -eq 1 ]; then
    echo "⚠️  [$tag] $name — $why · ติดตั้ง: ${install_cmd:-$hint}"
  else
    echo -e "  ${RED}✗${NC} $name ${YELLOW}[$tag]${NC} — $why"
    [ -n "$install_cmd" ] && echo "      คำสั่งติดตั้ง: $install_cmd"
    [ -n "$hint" ] && echo "      หมายเหตุ: $hint"
  fi
  [ "$CHECK_ONLY" -eq 1 ] && { mark_missing "$level" "$name"; return 1; }
  if [ -z "$install_cmd" ]; then
    echo "      → ติดตั้งอัตโนมัติไม่ได้ ทำตามหมายเหตุข้างบนแล้วรัน script นี้ซ้ำ"
    mark_missing "$level" "$name"; return 1
  fi
  local ans=""
  if [ -t 0 ]; then
    read -r -p "      ติดตั้ง $name ตอนนี้ไหม? (y/N): " ans || ans=""
  else
    read -r -p "      ติดตั้ง $name ตอนนี้ไหม? (y/N): " ans </dev/tty 2>/dev/null || ans=""
  fi
  if [[ "$ans" =~ ^[Yy]$ ]]; then
    if bash -c "$install_cmd"; then
      if eval "$test_cmd" >/dev/null 2>&1; then
        echo -e "      ${GREEN}✓ ติดตั้งแล้ว${NC}"
        return 0
      fi
      echo -e "      ${YELLOW}ติดตั้งจบแต่ยังตรวจไม่เจอ — เปิด terminal ใหม่แล้วรันซ้ำ${NC}"
    else
      echo -e "      ${RED}ติดตั้งไม่สำเร็จ — ดู error ข้างบน${NC}"
    fi
  else
    echo "      → ข้าม (งานที่ต้องใช้ $name จะทำไม่ได้จนกว่าจะติดตั้ง)"
  fi
  mark_missing "$level" "$name"; return 1
}

venv_has() {  # $1 = python module
  [ -x "$VENV/bin/python" ] && "$VENV/bin/python" -c "import $1"
}

VENV_INSTALL="python3 -m venv '$VENV' && '$VENV/bin/pip' install -q -r '$TPL/requirements.txt'"

for g in "${SEL[@]}"; do
  case "$g" in
  core)
    say "\n${YELLOW}[core]${NC} ใช้ทั้ง template"
    need required "git" "version control" "have git" "$(pkg_install_cmd git git)"
    need required "Node.js 18+" "skill archify + scripts" \
      "node -e 'process.exit(+process.versions.node.split(\".\")[0]>=18?0:1)'" "$(pkg_install_cmd node nodejs)"
    need required "pnpm" "package manager ของโปรเจกต์" "have pnpm" "npm install -g pnpm"
    need required "python3" "เทมเพลต SRS / Manhours" "have python3" "$(pkg_install_cmd python python3)"
    for s in archify auto-pipeline sonar-quality-gate; do
      need required "skill $s" "อยู่ใน .claude/skills/$s (มากับ template)" "[ -f '$ROOT/.claude/skills/$s/SKILL.md' ]" "" \
        "skill หาย — copy โฟลเดอร์ .claude/skills/$s จาก ibiztech-claude-template กลับมา"
    done
    ;;
  srs)
    say "\n${YELLOW}[srs]${NC} เอกสาร SRS / BR (templates/business-requirement)"
    need required "OfficeCLI" "สร้างและ validate ไฟล์ .docx" "[ -x '$OFFICECLI' ]" \
      "curl -fsSL https://raw.githubusercontent.com/iOfficeAI/OfficeCLI/main/install.sh | bash"
    need required "python venv (python-docx, pythainlp)" "จัดตาราง + ตัดคำไทยใน .docx" \
      "venv_has docx && venv_has pythainlp" "$VENV_INSTALL"
    need required "ฟอนต์ TH Sarabun New" "ฟอนต์ของเอกสาร — ไม่มีแล้วภาพเรนเดอร์ใช้ฟอนต์สำรอง" \
      "{ fc-list 2>/dev/null; ls ~/Library/Fonts /Library/Fonts ~/.local/share/fonts /usr/share/fonts 2>/dev/null; } | grep -qiE 'sarabun ?new'" "" \
      "ดาวน์โหลดชุดฟอนต์ TH Sarabun New (ฟอนต์แห่งชาติ SIPA) แล้วดับเบิลคลิกไฟล์ .ttf เพื่อติดตั้ง"
    if [ "$(uname)" = "Darwin" ]; then
      need optional "Microsoft Word" "ตรวจฉบับส่งจริง (word_pdf.sh: ตารางล้น/ตัดคำ)" \
        "[ -d '/Applications/Microsoft Word.app' ]" "" "ติดตั้ง Microsoft Word จาก Microsoft 365"
    fi
    ;;
  manhours)
    say "\n${YELLOW}[manhours]${NC} ใบประเมิน Manhours (templates/manhours)"
    need required "python venv (openpyxl)" "สร้างไฟล์ .xlsx" "venv_has openpyxl" "$VENV_INSTALL"
    need required "LibreOffice" "คำนวณสูตรใหม่ + ตรวจ error (recalc_check.py)" \
      "have soffice || have libreoffice || [ -x /Applications/LibreOffice.app/Contents/MacOS/soffice ]" \
      "$(pkg_install_cmd libreoffice libreoffice-calc cask)"
    ;;
  test)
    say "\n${YELLOW}[test]${NC} E2E (บังคับก่อน mark [x])"
    need required "Claude Code CLI" "ใช้เพิ่ม MCP Playwright" "have claude" "npm install -g @anthropic-ai/claude-code"
    need required "MCP Playwright" "E2E test ผ่าน browser" \
      "claude mcp list 2>/dev/null | grep -qi playwright" "claude mcp add playwright -- npx @playwright/mcp@latest"
    ;;
  quality)
    say "\n${YELLOW}[quality]${NC} Quality Pipeline (local)"
    need optional "sonar-scanner" "สแกนโค้ดในเครื่อง (CI ใช้ของ GitHub Actions)" "have sonar-scanner" "$(pkg_install_cmd sonar-scanner sonar-scanner)"
    need optional "JMeter" "load test ในเครื่อง (run-jmeter.sh)" "have jmeter" "$(pkg_install_cmd jmeter jmeter)"
    ;;
  esac
done

if [ "$QUIET" -eq 0 ]; then
  echo ""
  if [ ${#MISSING_LIST[@]} -eq 0 ]; then
    echo -e "${GREEN}ครบทุกตัว${NC}"
  else
    echo -e "${YELLOW}ยังขาด: ${MISSING_LIST[*]}${NC}"
    [ "$CHECK_ONLY" -eq 1 ] && echo "ติดตั้งแบบถามทีละตัว: bash scripts/check-requirements.sh ${SEL[*]}"
  fi
fi
exit $MISSING_REQUIRED

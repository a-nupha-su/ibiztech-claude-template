#!/usr/bin/env bash
# run-jmeter.sh — รัน JMeter local ทดสอบก่อน push CI
# Usage:
#   bash scripts/run-jmeter.sh <TARGET_URL> [users] [duration_sec]
# ตัวอย่าง:
#   bash scripts/run-jmeter.sh https://app.example.com/api/health
#   bash scripts/run-jmeter.sh https://app.example.com/api/users 20 60

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

URL="${1:-}"
USERS="${2:-10}"
DURATION="${3:-30}"
RAMP="${4:-10}"

if [ -z "$URL" ]; then
  echo "Usage: $0 <TARGET_URL> [users] [duration_sec] [ramp_sec]"
  echo "ตัวอย่าง: $0 https://app.example.com/api/health 10 30"
  exit 1
fi

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
JMX="$ROOT/tests/jmeter/baseline.jmx"
RESULTS_DIR="$ROOT/tests/jmeter/results"
THRESHOLDS="$ROOT/tests/jmeter/thresholds.env"

if [ ! -f "$JMX" ]; then
  echo -e "${RED}❌ ไม่พบ $JMX${NC}"
  exit 1
fi

# Check jmeter installed
if ! command -v jmeter &> /dev/null; then
  echo -e "${RED}❌ ไม่พบคำสั่ง jmeter${NC}"
  echo ""
  echo "ติดตั้งก่อน:"
  echo "  macOS:  brew install jmeter"
  echo "  Linux:  https://jmeter.apache.org/download_jmeter.cgi"
  echo "  Docker: docker run -v \$PWD:/tests justb4/jmeter -n -t /tests/tests/jmeter/baseline.jmx ..."
  exit 1
fi

# Parse URL
PROTOCOL="http"
[[ "$URL" =~ ^https ]] && PROTOCOL="https"
STRIPPED="${URL#http://}"; STRIPPED="${STRIPPED#https://}"
HOST="${STRIPPED%%/*}"
PATH_PART="/${STRIPPED#*/}"
[ "$PATH_PART" = "/$HOST" ] && PATH_PART="/"
PORT="80"; [ "$PROTOCOL" = "https" ] && PORT="443"
if [[ "$HOST" == *":"* ]]; then
  PORT="${HOST##*:}"; HOST="${HOST%%:*}"
fi

echo ""
echo -e "${YELLOW}→ Running JMeter${NC}"
echo "  Target:   $PROTOCOL://$HOST:$PORT$PATH_PART"
echo "  Users:    $USERS"
echo "  Ramp:     ${RAMP}s"
echo "  Duration: ${DURATION}s"
echo ""

rm -rf "$RESULTS_DIR"
mkdir -p "$RESULTS_DIR"

cd "$RESULTS_DIR"
jmeter -n \
  -t "$JMX" \
  -l result.jtl \
  -e -o report \
  -Jtarget.protocol="$PROTOCOL" \
  -Jtarget.host="$HOST" \
  -Jtarget.port="$PORT" \
  -Jtarget.path="$PATH_PART" \
  -Jusers="$USERS" \
  -Jramp="$RAMP" \
  -Jduration="$DURATION"

cd "$ROOT"

# Check thresholds
echo ""
bash "$ROOT/scripts/jmeter-check.sh" "$RESULTS_DIR/result.jtl" "$THRESHOLDS"

echo ""
echo -e "${GREEN}✅ Report:${NC} file://$RESULTS_DIR/report/index.html"

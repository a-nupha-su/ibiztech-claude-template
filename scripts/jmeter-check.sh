#!/usr/bin/env bash
# jmeter-check.sh — verify JMeter .jtl against thresholds.env
# Usage: bash scripts/jmeter-check.sh <result.jtl> <thresholds.env>
# Output: sets $GITHUB_OUTPUT 'result=PASSED|FAILED' + prints summary

set -e

JTL="${1:-tests/jmeter/results/result.jtl}"
ENV_FILE="${2:-tests/jmeter/thresholds.env}"

if [ ! -f "$JTL" ]; then
  echo "::error::JTL file not found: $JTL"
  exit 1
fi

if [ ! -f "$ENV_FILE" ]; then
  echo "::error::Thresholds file not found: $ENV_FILE"
  exit 1
fi

# Load thresholds
set -a; source "$ENV_FILE"; set +a

# Parse JTL CSV (skip header)
# Columns: timeStamp,elapsed,label,responseCode,...,success,...
TOTAL=$(tail -n +2 "$JTL" | wc -l | tr -d ' ')
if [ "$TOTAL" -eq 0 ]; then
  echo "::error::No samples in JTL"
  exit 1
fi

ERRORS=$(tail -n +2 "$JTL" | awk -F, '$8=="false"' | wc -l | tr -d ' ')
ERROR_RATE=$(awk -v e="$ERRORS" -v t="$TOTAL" 'BEGIN{printf "%.2f", (e/t)*100}')

# Latency stats from column 2 (elapsed in ms)
LATENCIES=$(tail -n +2 "$JTL" | awk -F, '{print $2}' | sort -n)
COUNT=$(echo "$LATENCIES" | wc -l | tr -d ' ')

P95_IDX=$(awk -v c="$COUNT" 'BEGIN{printf "%d", c*0.95}')
P99_IDX=$(awk -v c="$COUNT" 'BEGIN{printf "%d", c*0.99}')
P95=$(echo "$LATENCIES" | awk "NR==$P95_IDX")
P99=$(echo "$LATENCIES" | awk "NR==$P99_IDX")
AVG=$(echo "$LATENCIES" | awk '{s+=$1} END{printf "%.0f", s/NR}')

# Throughput (rough — total/duration)
FIRST_TS=$(tail -n +2 "$JTL" | head -1 | awk -F, '{print $1}')
LAST_TS=$(tail -n +2 "$JTL" | tail -1 | awk -F, '{print $1}')
DURATION_SEC=$(awk -v f="$FIRST_TS" -v l="$LAST_TS" 'BEGIN{printf "%.1f", (l-f)/1000}')
TPS=$(awk -v t="$TOTAL" -v d="$DURATION_SEC" 'BEGIN{ if (d>0) printf "%.2f", t/d; else printf "0" }')

echo ""
echo "=== JMeter Result Summary ==="
echo "  Samples:    $TOTAL"
echo "  Errors:     $ERRORS ($ERROR_RATE%)"
echo "  Avg:        ${AVG} ms  (max: ${AVG_MAX_MS:-N/A} ms)"
echo "  P95:        ${P95} ms  (max: ${P95_MAX_MS:-N/A} ms)"
echo "  P99:        ${P99} ms  (max: ${P99_MAX_MS:-N/A} ms)"
echo "  Throughput: ${TPS} req/s (min: ${THROUGHPUT_MIN_RPS:-0} rps)"
echo ""

# Check thresholds
FAIL=0
[ -n "${AVG_MAX_MS:-}" ] && [ "$AVG_MAX_MS" -gt 0 ] && \
  awk -v v="$AVG" -v m="$AVG_MAX_MS" 'BEGIN{exit !(v>m)}' && \
  { echo "❌ AVG $AVG > $AVG_MAX_MS"; FAIL=1; }

[ -n "${P95_MAX_MS:-}" ] && [ "$P95_MAX_MS" -gt 0 ] && \
  awk -v v="$P95" -v m="$P95_MAX_MS" 'BEGIN{exit !(v>m)}' && \
  { echo "❌ P95 $P95 > $P95_MAX_MS"; FAIL=1; }

[ -n "${P99_MAX_MS:-}" ] && [ "$P99_MAX_MS" -gt 0 ] && \
  awk -v v="$P99" -v m="$P99_MAX_MS" 'BEGIN{exit !(v>m)}' && \
  { echo "❌ P99 $P99 > $P99_MAX_MS"; FAIL=1; }

[ -n "${ERROR_RATE_MAX:-}" ] && \
  awk -v v="$ERROR_RATE" -v m="$ERROR_RATE_MAX" 'BEGIN{exit !(v>m)}' && \
  { echo "❌ Error rate $ERROR_RATE% > $ERROR_RATE_MAX%"; FAIL=1; }

[ -n "${THROUGHPUT_MIN_RPS:-}" ] && [ "$THROUGHPUT_MIN_RPS" != "0" ] && \
  awk -v v="$TPS" -v m="$THROUGHPUT_MIN_RPS" 'BEGIN{exit !(v<m)}' && \
  { echo "❌ Throughput $TPS rps < $THROUGHPUT_MIN_RPS rps"; FAIL=1; }

if [ "$FAIL" -eq 1 ]; then
  echo ""
  echo "❌ JMeter quality gate: FAILED"
  [ -n "${GITHUB_OUTPUT:-}" ] && echo "result=FAILED" >> "$GITHUB_OUTPUT"
  exit 1
fi

echo "✅ JMeter quality gate: PASSED"
[ -n "${GITHUB_OUTPUT:-}" ] && echo "result=PASSED" >> "$GITHUB_OUTPUT"
exit 0

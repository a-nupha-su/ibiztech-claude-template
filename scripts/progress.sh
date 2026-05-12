#!/usr/bin/env bash
# progress.sh — recalc Summary Progress ใน 07-implement-plan.md
# Usage: bash scripts/progress.sh [--silent]

PLAN="docs/07-implement-plan.md"
SILENT=false
[ "$1" = "--silent" ] && SILENT=true

[ ! -f "$PLAN" ] && exit 0

count_phase() {
  local pattern="$1"
  local total=$(grep -cE "\\*\\*${pattern}-[0-9]+\\*\\*" "$PLAN" 2>/dev/null || echo 0)
  local done_count=$(grep -E "\\*\\*${pattern}-[0-9]+\\*\\*.*\\[x\\]" "$PLAN" 2>/dev/null | wc -l | tr -d ' ')
  local pct=0
  [ "$total" -gt 0 ] && pct=$((done_count * 100 / total))
  echo "$total $done_count $pct"
}

read SETUP_T SETUP_D SETUP_P <<< "$(count_phase SETUP)"
read AUTH_T AUTH_D AUTH_P <<< "$(count_phase AUTH)"
read LAYOUT_T LAYOUT_D LAYOUT_P <<< "$(count_phase LAYOUT)"
read A_T A_D A_P <<< "$(count_phase A)"
read QA_T QA_D QA_P <<< "$(count_phase QA)"
read DEPLOY_T DEPLOY_D DEPLOY_P <<< "$(count_phase DEPLOY)"

TOTAL=$((SETUP_T + AUTH_T + LAYOUT_T + A_T + QA_T + DEPLOY_T))
DONE=$((SETUP_D + AUTH_D + LAYOUT_D + A_D + QA_D + DEPLOY_D))
TOTAL_PCT=0
[ "$TOTAL" -gt 0 ] && TOTAL_PCT=$((DONE * 100 / TOTAL))

if [ "$SILENT" = "false" ]; then
  echo ""
  echo "📊 Progress Summary"
  echo "─────────────────────────────────"
  printf "  %-12s %3d/%-3d  %3d%%\n" "Setup"    "$SETUP_D"  "$SETUP_T"  "$SETUP_P"
  printf "  %-12s %3d/%-3d  %3d%%\n" "Auth"     "$AUTH_D"   "$AUTH_T"   "$AUTH_P"
  printf "  %-12s %3d/%-3d  %3d%%\n" "Layout"   "$LAYOUT_D" "$LAYOUT_T" "$LAYOUT_P"
  printf "  %-12s %3d/%-3d  %3d%%\n" "Module A" "$A_D"      "$A_T"      "$A_P"
  printf "  %-12s %3d/%-3d  %3d%%\n" "QA"       "$QA_D"     "$QA_T"     "$QA_P"
  printf "  %-12s %3d/%-3d  %3d%%\n" "Deploy"   "$DEPLOY_D" "$DEPLOY_T" "$DEPLOY_P"
  echo "─────────────────────────────────"
  printf "  %-12s %3d/%-3d  %3d%%\n" "รวม" "$DONE" "$TOTAL" "$TOTAL_PCT"
  echo ""
fi

#!/usr/bin/env bash
# pipeline-gate.sh — silent advisory checks for auto-pipeline state.
#
# Runs on PostToolUse(Edit|Write). Does NOT block, NOT execute deploy —
# the deployer agent owns deploy. This script only surfaces signals:
#   - missing .env.deploy when DEPLOY references appear
#   - quality gate cache present but stale
#   - 10-value-research.md has unapproved RR-XXX before code edits in src/
#
# Designed to fail silently (exit 0) so it never breaks Edit/Write.

set -u

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR" 2>/dev/null || exit 0

WARN_FILE=".deploy-logs/.gate-warn"
mkdir -p .deploy-logs 2>/dev/null || exit 0
: > "$WARN_FILE"

# 1. Pipeline skill referenced but .env.deploy missing
if grep -rqsE "auto-pipeline|DEPLOY_TARGET" docs/ 2>/dev/null; then
  if [[ ! -f .env.deploy ]] && [[ -f .env.deploy.example ]]; then
    echo "ⓘ auto-pipeline detected — .env.deploy not configured (cp .env.deploy.example .env.deploy)" >> "$WARN_FILE"
  fi
fi

# 2. Code edited in src/ without an APPROVED research entry (when 10-value has RR rows)
if [[ -d src ]] && [[ -f docs/10-value-research.md ]]; then
  HAS_RR="$(grep -cE '^\| RR-[0-9]+' docs/10-value-research.md 2>/dev/null || echo 0)"
  HAS_APPROVED="$(grep -cE 'APPROVED' docs/10-value-research.md 2>/dev/null || echo 0)"
  if [[ "$HAS_RR" -gt 0 ]] && [[ "$HAS_APPROVED" -eq 0 ]]; then
    echo "ⓘ research entries exist but none APPROVED — phase 2 gate not passed" >> "$WARN_FILE"
  fi
fi

# 3. Deploy log older than 24h while quality passed — suggest re-deploy
LATEST_LOG="$(ls -t .deploy-logs/deploy-*.log 2>/dev/null | head -1)"
if [[ -n "$LATEST_LOG" ]]; then
  if [[ $(find "$LATEST_LOG" -mmin +1440 2>/dev/null) ]]; then
    echo "ⓘ last deploy >24h old ($LATEST_LOG) — consider re-running scripts/deploy.sh" >> "$WARN_FILE"
  fi
fi

# Silent unless debug
if [[ "${PIPELINE_GATE_VERBOSE:-0}" == "1" ]] && [[ -s "$WARN_FILE" ]]; then
  cat "$WARN_FILE" >&2
fi

exit 0

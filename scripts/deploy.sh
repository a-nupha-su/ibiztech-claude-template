#!/usr/bin/env bash
# deploy.sh — auto-deploy dispatcher (called by auto-pipeline / deployer agent)
#
# Reads .env.deploy:
#   DEPLOY_TARGET = vercel | docker | gh-actions | ssh
#   DEPLOY_URL    = (for health check)
#   ...target-specific vars
#
# Exit codes:
#   0 = deploy + health check ok
#   1 = config missing
#   2 = build failed
#   3 = deploy failed
#   4 = health check failed (deploy completed but URL not 200)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$ROOT_DIR"

# ---------- load config ----------
if [[ ! -f .env.deploy ]]; then
  echo "✗ .env.deploy not found. Copy .env.deploy.example → .env.deploy and fill in." >&2
  exit 1
fi

# shellcheck disable=SC1091
set -a; source .env.deploy; set +a

DEPLOY_TARGET="${DEPLOY_TARGET:-}"
DEPLOY_URL="${DEPLOY_URL:-}"

if [[ -z "$DEPLOY_TARGET" ]]; then
  echo "✗ DEPLOY_TARGET not set in .env.deploy" >&2
  exit 1
fi

TS="$(date +%Y%m%d-%H%M%S)"
LOG_DIR=".deploy-logs"
mkdir -p "$LOG_DIR"
LOG_FILE="$LOG_DIR/deploy-$TS.log"

log() { echo "[$(date +%H:%M:%S)] $*" | tee -a "$LOG_FILE"; }

log "=== Deploy started: target=$DEPLOY_TARGET ==="

# ---------- pre-deploy: build ----------
log "→ pre-deploy build"
if ! pnpm build >> "$LOG_FILE" 2>&1; then
  log "✗ build failed — see $LOG_FILE"
  exit 2
fi
log "✓ build ok"

# ---------- dispatch ----------
deploy_vercel() {
  log "→ vercel deploy --prod"
  if ! npx vercel deploy --prod --yes --token "${VERCEL_TOKEN:?VERCEL_TOKEN required}" \
       >> "$LOG_FILE" 2>&1; then
    return 1
  fi
}

deploy_docker() {
  : "${DOCKER_IMAGE:?DOCKER_IMAGE required (e.g. registry/app:tag)}"
  log "→ docker build $DOCKER_IMAGE"
  docker build -t "$DOCKER_IMAGE" . >> "$LOG_FILE" 2>&1 || return 1
  log "→ docker push $DOCKER_IMAGE"
  docker push "$DOCKER_IMAGE" >> "$LOG_FILE" 2>&1 || return 1
  if [[ -n "${K8S_DEPLOYMENT:-}" ]]; then
    log "→ kubectl rollout restart $K8S_DEPLOYMENT"
    kubectl rollout restart "deployment/$K8S_DEPLOYMENT" \
      ${K8S_NAMESPACE:+-n "$K8S_NAMESPACE"} >> "$LOG_FILE" 2>&1 || return 1
    kubectl rollout status "deployment/$K8S_DEPLOYMENT" \
      ${K8S_NAMESPACE:+-n "$K8S_NAMESPACE"} --timeout=180s >> "$LOG_FILE" 2>&1 || return 1
  fi
}

deploy_gh_actions() {
  : "${GH_WORKFLOW:?GH_WORKFLOW required (e.g. deploy.yml)}"
  log "→ gh workflow run $GH_WORKFLOW"
  gh workflow run "$GH_WORKFLOW" --ref "${GH_REF:-main}" >> "$LOG_FILE" 2>&1 || return 1
  # poll latest run
  sleep 5
  RUN_ID="$(gh run list --workflow="$GH_WORKFLOW" --limit 1 --json databaseId -q '.[0].databaseId')"
  log "→ watch run $RUN_ID"
  gh run watch "$RUN_ID" --exit-status >> "$LOG_FILE" 2>&1 || return 1
}

deploy_ssh() {
  : "${SSH_HOST:?SSH_HOST required}"
  : "${SSH_PATH:?SSH_PATH required}"
  : "${SSH_RESTART_CMD:?SSH_RESTART_CMD required (e.g. 'systemctl restart app')}"
  log "→ rsync to $SSH_HOST:$SSH_PATH"
  rsync -az --delete \
    --exclude node_modules --exclude .git --exclude .env \
    ./ "$SSH_HOST:$SSH_PATH/" >> "$LOG_FILE" 2>&1 || return 1
  log "→ ssh restart"
  ssh "$SSH_HOST" "$SSH_RESTART_CMD" >> "$LOG_FILE" 2>&1 || return 1
}

case "$DEPLOY_TARGET" in
  vercel)     deploy_vercel     || { log "✗ vercel deploy failed";     exit 3; } ;;
  docker)     deploy_docker     || { log "✗ docker deploy failed";     exit 3; } ;;
  gh-actions) deploy_gh_actions || { log "✗ gh workflow failed";       exit 3; } ;;
  ssh)        deploy_ssh        || { log "✗ ssh deploy failed";        exit 3; } ;;
  *) echo "✗ unknown DEPLOY_TARGET: $DEPLOY_TARGET" >&2; exit 1 ;;
esac
log "✓ deploy ok"

# ---------- health check ----------
if [[ -n "$DEPLOY_URL" ]]; then
  log "→ health check $DEPLOY_URL"
  for i in 1 2 3 4 5; do
    CODE="$(curl -s -o /dev/null -w '%{http_code}' --max-time 10 "$DEPLOY_URL" || echo 000)"
    if [[ "$CODE" == "200" ]]; then
      log "✓ health $CODE (attempt $i)"
      break
    fi
    log "  health $CODE (attempt $i) — retry in 6s"
    sleep 6
    if [[ $i -eq 5 ]]; then
      log "✗ health check failed after 5 attempts (last=$CODE)"
      exit 4
    fi
  done
else
  log "⊘ DEPLOY_URL not set — skip health check"
fi

# ---------- post-deploy: report ----------
REPORT="docs/test-reports/TR-deploy-$TS.md"
mkdir -p docs/test-reports
cat > "$REPORT" <<EOF
# TR-deploy-$TS

| Field | Value |
|-------|-------|
| Target | $DEPLOY_TARGET |
| URL | ${DEPLOY_URL:-N/A} |
| Timestamp | $(date -u +%Y-%m-%dT%H:%M:%SZ) |
| Build | ok |
| Deploy | ok |
| Health | ${DEPLOY_URL:+200}${DEPLOY_URL:-skipped} |
| Log | $LOG_FILE |

## Commit
\`\`\`
$(git log -1 --oneline 2>/dev/null || echo 'no git')
\`\`\`
EOF

log "✓ report → $REPORT"
log "=== Deploy complete ==="
echo "$DEPLOY_URL"  # stdout: deploy URL for downstream agents

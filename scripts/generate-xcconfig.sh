#!/usr/bin/env bash
# Generate one environment xcconfig file from Default.
#
# Usage: scripts/generate-xcconfig.sh <environment> <file>
#   environment: development | production
#
# Environment variables:
#   HONEYBADGER_API_KEY  Baked into the file. Empty for sandbox/snapshot runs;
#                        the real secret for release builds.
#   API_SECRET           Production API secret (from GHA secrets).
#                        Falls back to Default.xcconfig for local/sandbox use.
#   API_CLIENT_ID        Production API client ID (from GHA secrets).
#                        Falls back to Default.xcconfig for local/sandbox use.
#
# DEVELOPMENT_TEAM is the Bike Index team, hardcoded: it is not a secret (it
# appears in provisioning profiles and docs) and is the same for every
# environment and every CI path.
#
# API_HOST / API_PORT come from #include "Default"; only the keys that must
# differ from the sandbox defaults are written.
set -euo pipefail

ENVIRONMENT="${1:?usage: generate-xcconfig.sh <environment> <file>}"
FILE="${2:?usage: generate-xcconfig.sh <environment> <file>}"

case "$ENVIRONMENT" in
  development|production) ;;
  *) echo "unknown environment: $ENVIRONMENT (use development, production)" >&2; exit 1 ;;
esac
DEVELOPMENT_TEAM="8ZM5ZL6ABT"
HONEYBADGER_API_KEY="${HONEYBADGER_API_KEY:-}"
API_SECRET="${API_SECRET:-}"
API_CLIENT_ID="${API_CLIENT_ID:-}"

{
  echo '#include "Default"'
  echo "DEVELOPMENT_TEAM = ${DEVELOPMENT_TEAM}"
  echo "HONEYBADGER_API_KEY = ${HONEYBADGER_API_KEY}"
  if [[ -n "$API_SECRET" ]]; then
    echo "API_SECRET = ${API_SECRET}"
  else
    grep '^API_SECRET' Default.xcconfig
  fi
  if [[ -n "$API_CLIENT_ID" ]]; then
    echo "API_CLIENT_ID = ${API_CLIENT_ID}"
  else
    grep '^API_CLIENT_ID' Default.xcconfig
  fi
} > "$FILE"

echo "generated $FILE ($ENVIRONMENT)"

if [[ "$ENVIRONMENT" == "production" ]]; then
  if [[ -z "$HONEYBADGER_API_KEY" ]]; then
    cat <<'EOF'
Reminder: HONEYBADGER_API_KEY is not set. `validate-xcconfig.sh production`
will fail until you export HONEYBADGER_API_KEY. To use your own OAuth app,
create one at https://bikeindex.org/oauth/applications (redirect URI:
bikeindex://) and set API_CLIENT_ID / API_SECRET via environment variables.
EOF
  fi
fi

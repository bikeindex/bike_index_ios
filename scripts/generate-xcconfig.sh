#!/usr/bin/env bash
# Generate one environment xcconfig file from Default.
#
# Usage: scripts/generate-xcconfig.sh <environment> <file>
#   environment: development | production
#
# Environment variables:
#   HONEYBADGER_API_KEY  Baked into the file. Empty for sandbox/snapshot runs;
#                        the real secret for release builds.
#   DEVELOPMENT_TEAM     Defaults to 8ZM5ZL6ABT; overridden on the release path
#                        where it comes from a secret.
#
# API_HOST / API_PORT come from #include "Default"; only the keys that must
# differ from the sandbox defaults are written.
set -euo pipefail

ENVIRONMENT="${1:?usage: generate-xcconfig.sh <environment> <file>}"
FILE="${2:?usage: generate-xcconfig.sh <environment> <file>}"

case "$ENVIRONMENT" in
  development) TEAM_DEFAULT="8ZM5ZL6ABT" ;;
  production)  TEAM_DEFAULT="8ZM5ZL6ABT" ;;
  *) echo "unknown environment: $ENVIRONMENT (use development, production)" >&2; exit 1 ;;
esac
DEVELOPMENT_TEAM="${DEVELOPMENT_TEAM:-$TEAM_DEFAULT}"
HONEYBADGER_API_KEY="${HONEYBADGER_API_KEY:-}"

{
  echo '#include "Default"'
  echo "DEVELOPMENT_TEAM = ${DEVELOPMENT_TEAM}"
  echo "HONEYBADGER_API_KEY = ${HONEYBADGER_API_KEY}"
  grep '^API_SECRET' Default.xcconfig
  grep '^API_CLIENT_ID' Default.xcconfig
} > "$FILE"

echo "generated $FILE ($ENVIRONMENT)"

if [[ "$ENVIRONMENT" == "production" ]]; then
  # The file is written with the shared sandbox OAuth credentials from
  # Default.xcconfig. validate-xcconfig.sh production will fail until a real
  # Honeybadger key is set and (for non-Bike-Index accounts) real OAuth
  # credentials are in place.
  cat <<'EOF'
Reminder: this file uses the shared sandbox OAuth credentials from Default.xcconfig
and an empty HONEYBADGER_API_KEY. `validate-xcconfig.sh production` will fail until
you set HONEYBADGER_API_KEY. To use your own OAuth app, create one at
https://bikeindex.org/oauth/applications (redirect URI: bikeindex://) and set
API_CLIENT_ID / API_SECRET in this file.
EOF
fi

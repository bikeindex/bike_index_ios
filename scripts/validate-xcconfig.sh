#!/usr/bin/env bash
# Validate that an XCConfig file contains all required keys with non-empty values.
#
# Usage: ./scripts/validate-xcconfig.sh <environment>
#   environment: "test", "development", or "production"
#
# Validates the following files and keys:
#   test          -> Test-credentials.xcconfig (TEST_USERNAME, TEST_PASSWORD)
#   development   -> BikeIndex-development.xcconfig (API_SECRET, API_CLIENT_ID, DEVELOPMENT_TEAM)
#   production    -> BikeIndex-production.xcconfig (API_SECRET, API_CLIENT_ID, DEVELOPMENT_TEAM)
#
# Note: UITests also need API_HOST and API_PORT for universal link resolution.
# In CI/CD scenarios that need is met by include-Default.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

if [[ $# -ne 1 ]]; then
  echo "Usage: $0 <test|development|production>"
  exit 1
fi

ENV="$1"

case "$ENV" in
  test)
    FILE="Test-credentials.xcconfig"
    KEYS=(TEST_USERNAME TEST_PASSWORD)
    ;;
  development)
    FILE="BikeIndex-development.xcconfig"
    KEYS=(API_SECRET API_CLIENT_ID DEVELOPMENT_TEAM)
    ;;
  production)
    FILE="BikeIndex-production.xcconfig"
    KEYS=(API_SECRET API_CLIENT_ID DEVELOPMENT_TEAM)
    ;;
  *)
    echo "ERROR: Invalid environment '$ENV'. Must be one of: test, development, production"
    exit 1
    ;;
esac

FILE_PATH="$PROJECT_ROOT/$FILE"

# Last value of a key (xcconfig semantics: a later definition wins).
# `|| true` so a key with no match doesn't trip `set -o pipefail`/`-e`.
key_value() {
  local key="$1"
  ( (grep "^${key}[[:space:]]*=" "$FILE_PATH" || true) | tail -n1 \
    | sed 's/^[^=]*=[[:space:]]*//' | sed 's/[[:space:]]*$//' | tr -d '\r' )
}

if [[ ! -f "$FILE_PATH" ]]; then
  echo "ERROR: File not found: $FILE_PATH"
  exit 1
fi

MISSING=()

for key in "${KEYS[@]}"; do
  if ! grep -qE "^${key}[[:space:]]*=[[:space:]]+[^/]" "$FILE_PATH"; then
    MISSING+=("$key")
  fi
done

if [[ ${#MISSING[@]} -gt 0 ]]; then
  echo "ERROR: Missing or empty values for keys in $FILE:"
  for key in "${MISSING[@]}"; do
    echo "  - $key"
  done
  exit 1
fi

# Validate that api_client_id and api_secret are exactly 43 characters long (development/production only)
if [[ "$ENV" == "development" || "$ENV" == "production" ]]; then
  for key in API_CLIENT_ID API_SECRET; do
    value=$(key_value "$key")
    len=${#value}
    if [[ $len -ne 43 ]]; then
      echo "ERROR: $key in $FILE must be exactly 43 characters (got $len)"
      exit 1
    fi
  done
fi

# Production releases must ship with a real Honeybadger key (error reporting
# is non-fatal in the app, but a release should not ship with it silently off).
if [[ "$ENV" == "production" ]]; then
  hb=$(key_value "HONEYBADGER_API_KEY")
  if [[ -z "$hb" ]]; then
    echo "ERROR: HONEYBADGER_API_KEY in $FILE is empty or missing (required for production)"
    exit 1
  fi
fi

echo "OK: All required keys present in $FILE ($ENV)"

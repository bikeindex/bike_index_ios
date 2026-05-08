#!/usr/bin/env bash
# Validate that an XCConfig file contains all required keys with non-empty values.
# Required keys are documented in:
# - BikeIndex-template.xcconfig
# - Test-credentials-template.xcconfig
#
# Usage: ./scripts/validate-xcconfig.sh <xcconfig-file> <key1> [key2] ...
#
# Example:
#   ./scripts/validate-xcconfig.sh Test-credentials.xcconfig \
#     TEST_USERNAME TEST_PASSWORD

set -euo pipefail

if [[ $# -lt 2 ]]; then
  echo "Usage: $0 <xcconfig-file> <key1> [key2] ..."
  exit 1
fi

FILE="$1"
shift

if [[ ! -f "$FILE" ]]; then
  echo "ERROR: File not found: $FILE"
  exit 1
fi

MISSING=()

for key in "$@"; do
  # Match lines like "KEY = value" where value is non-empty and does not start with "//".
  # The regex requires at least one character after "=" (plus optional whitespace),
  # and that first character is NOT "/" (to exclude commented-out keys).
  if ! grep -qE "^${key}[[:space:]]*=[[:space:]]+[^/]" "$FILE"; then
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

echo "OK: All required keys present in $FILE"

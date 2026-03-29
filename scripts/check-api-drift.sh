#!/usr/bin/env bash
# check-api-drift.sh
# Claude Code PostToolUse hook — runs after any Edit tool call on .cs files
# Warns when an endpoint/handler file changes that might affect frontend types.
#
# Called with: bash check-api-drift.sh "$CLAUDE_TOOL_INPUT_FILE_PATH"

set -e

CHANGED_FILE="${1:-}"

# --- Only care about endpoint/handler .cs files ---
if [[ -z "${CHANGED_FILE}" ]]; then exit 0; fi
if [[ "${CHANGED_FILE}" != *.cs ]]; then exit 0; fi

# Check if it's an endpoint or handler file
if [[ "${CHANGED_FILE}" != *Endpoint* ]] && \
   [[ "${CHANGED_FILE}" != *Handler* ]] && \
   [[ "${CHANGED_FILE}" != *Controller* ]] && \
   [[ "${CHANGED_FILE}" != *Dto* ]]; then
  exit 0
fi

# --- Colors ---
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo ""
echo -e "${YELLOW}⚠️  API Contract Change Detected${NC}"
echo "   Modified: $(basename "${CHANGED_FILE}")"
echo ""

# --- Try to find associated frontend project ---
# Pattern: backend at workspace/project/backend/, frontend at workspace/project/frontend/
BACKEND_DIR=$(dirname "${CHANGED_FILE}")
PROJECT_ROOT=""

# Walk up to find a frontend sibling
SEARCH_DIR="${BACKEND_DIR}"
for i in {1..6}; do
  SEARCH_DIR=$(dirname "${SEARCH_DIR}")
  if [ -d "${SEARCH_DIR}/frontend" ]; then
    PROJECT_ROOT="${SEARCH_DIR}"
    break
  fi
  # Check wesoco works pattern
  if ls "${SEARCH_DIR}"/../*/package.json &>/dev/null 2>&1; then
    break
  fi
done

# --- Check if backend is running ---
BACKEND_URL="http://localhost:5000"
SPEC_REACHABLE=false

if curl -sf "${BACKEND_URL}/openapi/v1.json" -o /dev/null 2>&1; then
  SPEC_REACHABLE=true
fi

# --- Check for api.generated.ts in nearby frontend ---
GENERATED_FILE=""
if [ -n "${PROJECT_ROOT}" ] && [ -f "${PROJECT_ROOT}/frontend/src/types/api.generated.ts" ]; then
  GENERATED_FILE="${PROJECT_ROOT}/frontend/src/types/api.generated.ts"
fi

# --- Output warning ---
echo -e "${BLUE}Action required:${NC}"

if [ "${SPEC_REACHABLE}" = true ] && [ -n "${GENERATED_FILE}" ]; then
  # Actually check for drift
  CURRENT_HASH=$(md5 -q "${GENERATED_FILE}" 2>/dev/null || md5sum "${GENERATED_FILE}" 2>/dev/null | cut -d' ' -f1)
  FRESH_SPEC=$(curl -sf "${BACKEND_URL}/openapi/v1.json")
  FRESH_HASH=$(echo "${FRESH_SPEC}" | md5 -q 2>/dev/null || echo "${FRESH_SPEC}" | md5sum 2>/dev/null | cut -d' ' -f1)

  if [ "${CURRENT_HASH}" != "${FRESH_HASH}" ]; then
    echo "   Backend is running and spec has changed."
    echo "   Run: cd ${PROJECT_ROOT}/frontend && npm run gen:api"
  else
    echo "   Backend is running — spec unchanged (no frontend update needed)."
    exit 0
  fi
else
  echo "   1. Start the backend: dotnet run --project src/{Project}.Provider"
  echo "   2. Run in frontend:   npm run gen:api"
  echo "   3. Fix any TypeScript errors"
  echo "   4. Commit both files together"
  echo ""
  echo "   Rule: api-contract-rules.md"
fi

echo ""

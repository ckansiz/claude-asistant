#!/usr/bin/env bash
# gen-api-types.sh
# Usage: ./scripts/gen-api-types.sh <backend-url> <frontend-path>
# Example: ./scripts/gen-api-types.sh http://localhost:5000 ~/workspace/wesoco/works/my-project
#
# Fetches OpenAPI spec from .NET backend and regenerates TypeScript types in frontend.

set -e

BACKEND_URL="${1:-http://localhost:5000}"
FRONTEND_PATH="${2:-}"
SPEC_ENDPOINT="${BACKEND_URL}/openapi/v1.json"
OUTPUT_FILE="src/types/api.generated.ts"

# --- Colors ---
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}🔄 API Type Codegen${NC}"
echo "   Backend: ${BACKEND_URL}"
echo "   Frontend: ${FRONTEND_PATH:-$(pwd)}"

# --- Validate backend is reachable ---
if ! curl -sf "${SPEC_ENDPOINT}" -o /dev/null 2>&1; then
  echo -e "${RED}❌ Cannot reach ${SPEC_ENDPOINT}${NC}"
  echo "   Make sure the backend is running: dotnet run --project src/{Project}.Provider"
  exit 1
fi

echo -e "${GREEN}✓ Backend reachable${NC}"

# --- Navigate to frontend ---
if [ -n "${FRONTEND_PATH}" ]; then
  cd "${FRONTEND_PATH}"
fi

# --- Check openapi-typescript is installed ---
if ! npx openapi-typescript --version &>/dev/null 2>&1; then
  echo -e "${YELLOW}⚠ openapi-typescript not found, installing...${NC}"
  npm install --save-dev openapi-typescript
fi

# --- Create types directory if needed ---
mkdir -p "$(dirname ${OUTPUT_FILE})"

# --- Generate ---
echo "   Generating ${OUTPUT_FILE}..."
npx openapi-typescript "${SPEC_ENDPOINT}" \
  --output "${OUTPUT_FILE}" \
  --default-non-nullable \
  --alphabetize

# --- Add header comment ---
TEMP_FILE=$(mktemp)
cat > "${TEMP_FILE}" << 'HEADER'
// =============================================================================
// AUTO-GENERATED FILE — DO NOT EDIT MANUALLY
// Generated from OpenAPI spec. Run 'npm run gen:api' to update.
// =============================================================================

HEADER
cat "${OUTPUT_FILE}" >> "${TEMP_FILE}"
mv "${TEMP_FILE}" "${OUTPUT_FILE}"

echo -e "${GREEN}✅ Types generated: ${OUTPUT_FILE}${NC}"

# --- TypeScript check ---
if command -v npx &>/dev/null && [ -f "tsconfig.json" ]; then
  echo "   Running type check..."
  if npx tsc --noEmit 2>&1; then
    echo -e "${GREEN}✅ No type errors${NC}"
  else
    echo -e "${YELLOW}⚠ Type errors found — frontend code needs updating to match new API contract${NC}"
  fi
fi

echo ""
echo -e "${BLUE}Next steps:${NC}"
echo "   1. Review changes: git diff ${OUTPUT_FILE}"
echo "   2. Fix any TypeScript errors in your components"
echo "   3. Commit both backend changes + updated types together"

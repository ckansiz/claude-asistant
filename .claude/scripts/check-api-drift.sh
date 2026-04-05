#!/usr/bin/env bash
# check-api-drift.sh
# PostToolUse hook: runs after every Edit to catch API contract drift.
# Triggered by settings.local.json when a file is edited.
#
# What it does:
#   1. If the edited file is a .NET endpoint/DTO → reminds to regenerate api.generated.ts
#   2. If the edited file is api.generated.ts directly → warns it must never be manually edited
#   3. Otherwise → silent exit (no noise for unrelated edits)

FILE="${1:-}"

if [[ -z "$FILE" ]]; then
  exit 0
fi

# --- Guard: api.generated.ts must never be manually edited ---
if [[ "$FILE" == *"api.generated.ts" ]]; then
  echo ""
  echo "⚠️  API CONTRACT WARNING"
  echo "   src/types/api.generated.ts was edited manually."
  echo "   This file is auto-generated. Manual edits will be overwritten."
  echo "   Run: cd frontend && npm run gen:api"
  echo ""
  exit 0
fi

# --- Detect backend changes that affect the OpenAPI spec ---
is_dotnet_endpoint=false

# Endpoint files (Provider layer)
if [[ "$FILE" == *"Endpoints"* && "$FILE" == *.cs ]]; then
  is_dotnet_endpoint=true
fi

# DTO / record files (Application layer)
if [[ "$FILE" == *"Dto"* && "$FILE" == *.cs ]]; then
  is_dotnet_endpoint=true
fi
if [[ "$FILE" == *"Command"* && "$FILE" == *.cs ]]; then
  is_dotnet_endpoint=true
fi
if [[ "$FILE" == *"Query"* && "$FILE" == *.cs ]]; then
  is_dotnet_endpoint=true
fi
if [[ "$FILE" == *"Response"* && "$FILE" == *.cs ]]; then
  is_dotnet_endpoint=true
fi
if [[ "$FILE" == *"Request"* && "$FILE" == *.cs ]]; then
  is_dotnet_endpoint=true
fi

if [[ "$is_dotnet_endpoint" == true ]]; then
  echo ""
  echo "📡 API CONTRACT REMINDER"
  echo "   Backend file changed: $(basename "$FILE")"
  echo "   If you added/removed/renamed endpoints or DTOs, regenerate types:"
  echo ""
  echo "   1. dotnet run --project src/*.Provider"
  echo "   2. cd frontend && npm run gen:api"
  echo "   3. npx tsc --noEmit"
  echo "   4. Commit both .cs changes + api.generated.ts together"
  echo ""
fi

exit 0

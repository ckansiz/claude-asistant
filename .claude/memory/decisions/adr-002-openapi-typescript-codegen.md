# ADR-002: OpenAPI → TypeScript Codegen for API Contract Sync

**Date**: 2025-Q4
**Status**: Accepted
**Projects**: qoommerce (and all projects with .NET backend + TS frontend)

## Decision

Use `openapi-typescript` to generate `src/types/api.generated.ts` from the .NET backend's `/openapi/v1.json` endpoint. Commit the generated file to git.

## Rationale

- Eliminates manual type duplication between .NET DTOs and frontend types
- TypeScript compiler catches breaking contract changes at compile time
- Generated file diff in git makes API changes visible in PRs
- `check-api-drift.sh` hook reminds developers to regenerate after backend edits

## Workflow

1. .NET endpoint annotated with `Produces<T>()` + XML doc comments
2. Backend runs → exposes `/openapi/v1.json`
3. `npm run gen:api` regenerates `api.generated.ts`
4. `npx tsc --noEmit` catches breaks
5. Both `.cs` changes and `api.generated.ts` committed together

## Constraints

- `api.generated.ts` must **never** be edited manually
- Every endpoint must use explicit DTOs (never anonymous objects)
- All endpoints need `.Produces<T>()` annotations

## Applied in `api-contract.md` context file.

---
name: security
description: This skill should be used when the user asks to "add authentication", "configure auth", "validate input", "set up CORS", "add rate limiting", "handle secrets", or works on auth/security-sensitive code.
version: 1.0.0
---

# Security Standards

Apply when implementing authentication, authorization, input validation, or any security-sensitive code.

## Authentication

- **New projects**: better-auth (TypeScript-native, supports OAuth, magic link, passkeys)
- **qoommerce**: OpenIddict (OpenID Connect server on .NET)
- Never roll custom auth — use established libraries

## Authorization

- .NET: policy-based authorization via `[Authorize(Policy = "...")]` or `.RequireAuthorization()`
- Every endpoint must have an explicit auth requirement — no "open by default"
- Role checks at endpoint level, not inside handlers
- Next.js: middleware.ts for route protection, server-side session checks in layouts

## Input Validation

- **.NET**: FluentValidation for command/query validation, run before handler execution
- **TypeScript**: Zod schemas for all user input — `safeParse()`, never trust raw input
- Validate at system boundaries (API endpoints, form submissions), not deep inside business logic
- Reject early, fail fast

## Secrets Management

- Never hardcode API keys, connection strings, or tokens
- `.env` files for local dev — never committed (`.env.example` committed as template)
- Production: environment variables via K8s Secrets or cloud provider secret store
- Rotate keys if accidentally exposed (even in a reverted commit — git history persists)

## CORS

- Explicit allowed origins — never `*` in production
- Astro/Next.js: configure in middleware or `next.config.js`
- .NET: `AddCors()` with named policies, applied per endpoint group

## Rate Limiting

- .NET: `AddRateLimiter()` with fixed/sliding window policies
- Apply to auth endpoints (login, register, password reset) at minimum
- Return `429 Too Many Requests` with `Retry-After` header

## SQL Injection Prevention

- Always use parameterized queries — EF Core and Prisma/Drizzle handle this by default
- Never use string interpolation in raw SQL: `FromSqlRaw($"SELECT * WHERE id = {id}")` is vulnerable
- Use `FromSqlInterpolated()` or parameterized `FromSqlRaw()` if raw SQL is needed

## XSS Prevention

- React/Astro escape by default — never use `dangerouslySetInnerHTML` or `set:html` with user content
- Sanitize user-generated HTML with DOMPurify if rich text is required
- Content-Security-Policy headers in production

## HTTPS & Headers

- Enforce HTTPS in production (`UseHttpsRedirection()`, `Strict-Transport-Security` header)
- Security headers: `X-Content-Type-Options: nosniff`, `X-Frame-Options: DENY`, `Referrer-Policy: strict-origin-when-cross-origin`

## Error Handling

- Never expose stack traces, internal paths, or SQL errors to clients
- .NET: `UseExceptionHandler()` with generic error response in production
- Log full details server-side, return safe messages client-side
- Use `Result<T>` pattern — business errors are expected, not exceptions

## Dependency Security

- Run `dotnet list package --vulnerable` periodically
- Run `npm audit` periodically
- Pin dependency versions in production (no `^` or `~` ranges for critical packages)

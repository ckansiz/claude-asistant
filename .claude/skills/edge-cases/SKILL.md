---
name: edge-cases
description: This skill should be used whenever a feature, bug fix, or endpoint is being designed, planned, reviewed, or tested. Provides a systematic checklist to surface non-happy-path scenarios — input, state, auth, concurrency, limits, i18n, accessibility, mobile, offline, failure modes — plus stack-specific additions. Auto-loads alongside `intake`, `spec-writing`, `plan-mode`, `code-review`, `testing`.
version: 1.0.0
---

# Edge Case Checklist

Apply when turning an idea into a spec, plan, implementation, or test. The happy path writes itself. Edge cases don't — and unhandled edge cases become production bugs.

**Rule:** do not mark a spec, plan, or PR "done" until this checklist has been walked at least once. Pick at least one finding per applicable category, or explicitly note "N/A — reason".

## How to Use

1. Read the task.
2. Walk the categories below, one by one.
3. Write down concrete, task-specific edge cases (generic "what if the server is down" doesn't count — be specific: "what if the payment provider returns 402 mid-checkout").
4. Attach them to the intake brief, spec, plan, or test plan.
5. Each edge case must resolve into one of: *handle in code*, *test for it*, *document as known limit*, *out of scope*.

## Core Categories

### Input
- Missing / null / undefined fields
- Empty string vs whitespace vs zero
- Extreme length (1 char, 10k chars, multi-MB)
- Unicode, emoji, RTL text, zero-width chars
- Type coercion (string "123" vs number 123, "true" vs true)
- Trimming, normalization (NFC vs NFD)
- Injection: SQL, XSS, HTML in names, path traversal in filenames
- File upload: wrong MIME, wrong extension, zip bombs, 0-byte, oversized
- Numbers: negative, zero, float precision, overflow, `NaN`, `Infinity`
- Dates: past / future, DST boundary, leap year, timezone mismatch

### State
- First-time user, no data ("empty state")
- Partial data (half-filled profile, half-completed checkout)
- Stale data (cached list vs fresh server state)
- Inconsistent state across tabs / devices
- Optimistic UI rolled back after server rejection

### Auth & Authorization
- Unauthenticated request
- Authenticated but unauthorized (wrong role)
- Expired token mid-request
- Token refresh race
- Session hijack protection (CSRF, SameSite)
- Role escalation via tampered payload (trusting client-sent role)
- Impersonation / admin-as-user scenarios

### Concurrency
- Two users editing the same record (last-write-wins vs conflict detection)
- Double-click / double-submit on payment buttons
- Long-running job + user retry → duplicate work
- Webhook retries (is the handler idempotent?)
- Background job + HTTP request racing on the same row

### Limits & Quotas
- Rate limits (per IP, per user, per API key) — what happens at the threshold?
- Pagination edge: page 0, page beyond last, page size 0, huge page size
- Database row limits, query timeout
- File size / count limits
- Client-side list render at 10k rows (virtualize?)
- Free tier vs paid tier limits

### Failure Modes
- Network timeout mid-request
- External API down / slow / rate-limited
- DB connection lost / pool exhausted
- Payment provider returns "pending" indefinitely
- Email/SMS delivery fails silently
- Disk full, memory pressure
- Partial success (half the batch saved, half failed)

### Time & Timezone
- User in different timezone than server
- DST transitions (lost hour, duplicate hour)
- Scheduled job during DST change
- Date range with only one side specified
- "Today" for a user depending on their clock
- Clock skew between services

### i18n / l10n
- Turkish dotted/dotless I (`i`, `ı`, `İ`, `I`) — `.toLowerCase()` pitfalls
- Turkish currency (₺), thousands separator (.), decimal (,)
- RTL languages if the client ever expands
- Translated string overflow (German is +30%)
- Plural forms (0, 1, many, few — not all languages have 2 forms)
- Untranslated key fallback

### Accessibility
- Keyboard-only navigation (no mouse)
- Screen reader announces the right thing
- Focus trap in modals + focus restoration on close
- Color-only signals (also use text/icon)
- Touch target ≥ 44×44 px on mobile
- `prefers-reduced-motion` respected
- Form errors: announced, associated with fields, not just red border

### Mobile & Responsive
- Small viewport (320 px width still works)
- Large viewport (ultrawide)
- Touch vs hover — no hover-only interactions
- iOS safe area (notch), Android back button
- Slow 3G / offline
- App backgrounded mid-flow, resumed later
- Rotation mid-form

### Privacy, Security, Compliance
- PII in logs (never log tokens, full emails, card numbers)
- KVKK / GDPR — data export, data deletion
- Right-to-be-forgotten cascading to backups?
- Cookie consent before tracking
- HTTPS everywhere, no mixed content
- Secure cookie flags (HttpOnly, Secure, SameSite)

### SEO & Sharing (if public-facing)
- Canonical URL
- OG image + meta tags
- Sitemap + robots.txt
- Indexability of private/auth pages ("noindex")
- Redirect chains

### Analytics & Observability
- Is the event fired for both success and failure?
- Logs correlation ID across services
- Error tracked in Sentry / equivalent with user + request context
- Alert fires on the scenarios that should page someone

## Stack-Specific Additions

### .NET (ASP.NET Core / EF Core)
- `CancellationToken` propagated through the request pipeline
- `async void` absent outside event handlers
- N+1 queries — check `Include` + `AsSplitQuery` if needed
- Transactions around multi-step writes
- EF change tracking leaks across requests (singleton DbContext anti-pattern)
- Global exception handler returns ProblemDetails, not stack traces
- Null ref after `FirstOrDefault` without null check

### Astro
- SSR vs client island — is the component hydrated when it should be?
- `client:only` flicker
- `Astro.request` headers availability in SSG
- API routes: method guard (405 for wrong method), CORS if cross-origin
- Image optimization for remote URLs needs `image.domains` config
- Middleware runs per request — heavy work is a tax on every page

### Next.js 15 (App Router)
- Server Component accidentally pulling client-only lib (bundle bloat)
- `use client` boundary placed correctly — not at the top of the tree
- `cookies()`/`headers()` usage inside cached functions → error
- Revalidation tags consistent across reads and writes
- Streaming + error boundary — partial render on failure
- Middleware matcher includes static assets by mistake

### React Native / Expo
- Deep link lands mid-auth flow
- Push notification opened from cold start vs warm start
- Background fetch / app kill
- iOS vs Android permission prompt timing
- Keyboard covers input, no `KeyboardAvoidingView`
- Safe area + status bar per platform
- Offline-first — what the app shows with no network

### Flutter
- `BuildContext` used after `await` without `mounted` check
- `Dio` cancel token on screen dispose
- Riverpod provider disposed while listener still active
- Platform channel exceptions unhandled
- iOS / Android permission manifest gaps

### Database / Migrations
- Adding NOT NULL to existing table without default → fails on deploy
- Rename column without deprecation path breaks old clients
- Index added without `CONCURRENTLY` locks prod
- Foreign key cascade deletes more than intended
- Backfill scripts not idempotent
- Migration order vs deploy order (code expects column that isn't there yet)

### Forms & Validation
- Client-side only validation → server accepts bad data
- Spam: Turnstile / hCaptcha bypass
- Duplicate submission protection
- Autofill quirks (password managers, iOS strong-password)
- Uploaded file retained after form reset

### Payments
- Webhook arrives before the client-side confirmation page
- Webhook arrives twice (idempotency)
- User closes tab mid-payment
- 3DS challenge failure
- Refund partial vs full
- Currency mismatch, decimal scale mismatch

### SEO/Marketing Pages
- Canonical URL mismatches with rendered URL
- Prerendered HTML has a different locale than the client detects
- Redirect loop on trailing slash
- Missing hreflang for multi-language sites

## Output Format

When attaching to a brief, spec, plan, or test plan:

```markdown
## Edge Cases Considered

| # | Category | Scenario | Resolution |
|---|----------|----------|------------|
| 1 | Auth | Token expires mid-upload | retry w/ refresh, surface toast on second failure |
| 2 | Concurrency | Double-click "Pay" | disable button on submit, idempotency key server-side |
| 3 | i18n | Turkish `İ` in search | use `ToLowerInvariant` with explicit culture |
| … | | | |

N/A categories: {list with one-line reason each}
```

## Anti-Patterns

- "We'll handle edge cases later" — later = never
- Listing edge cases without resolutions — half the work
- Copy-pasting the generic list verbatim — the client sees that and loses trust
- Testing only the happy path because edge cases "are unlikely" — production finds them anyway

## Companion Skills

- `intake` — where edge-case sweep first runs
- `spec-writing` — edge cases become requirements
- `plan-mode` — plan references edge cases
- `testing` — every non-N/A edge case needs a test or a deliberate decision not to test
- `code-review` — reviewer checks the edge-case table exists and is honest

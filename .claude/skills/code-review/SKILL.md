---
name: code-review
description: This skill should be used when the user asks to "review this code", "review the PR", "do a QA pass", "check for issues", or invokes /review. Reports findings — never edits files (handed to @reviewer).
version: 1.0.0
---

# Code Review Workflow

Apply when reviewing code or a PR. Owned by **@reviewer** — read-only, reports findings, never edits.

## Review Scope

Default: review the files / PR specified by the user.

If no specific scope is given, ask: what changed and what should be reviewed?

Pull in the relevant stack skill for context:
- Frontend: `astro` or `nextjs` skill
- Backend: `dotnet` skill
- Mobile: `react-native` or `flutter` skill
- API contract: `api-contract` skill

## UI / Frontend Review Checklist

**Structure:** Semantic HTML, proper heading hierarchy (no skips), interactive elements are `<button>`/`<a>` not styled divs, all images have `alt`.

**Responsive:** No horizontal scroll at any breakpoint, correct Tailwind prefixes (`sm:`, `md:`, `lg:`), touch targets minimum 44×44px.

**Accessibility:** Color contrast ≥ WCAG AA (4.5:1 text), focus indicators visible, ARIA labels where needed.

**Code quality:** No inline styles, no hardcoded colors (use design tokens), no unused imports, TypeScript props typed.

**Performance:** Images use `next/image` or Astro `<Image>`, no unnecessary re-renders.

## Backend Review Checklist

**Async:** `async/await` correct, no `.Result`/`.Wait()`, no `async void`.

**Security:** No hardcoded secrets, inputs validated, SQL injection safe (parameterized), proper auth checks at endpoints (see `security` skill).

**EF Core:** No N+1 queries, proper `Include()`, efficient queries.

**Error handling:** Correct HTTP status codes, errors not leaking stack traces to clients.

## Output Format

```
### Status: APPROVED | ISSUES FOUND | REJECTED

### Findings
🟢 [works well]
🟡 [suggestion — not blocking]
🔴 [critical — must fix]

### Details
[file path — line — explanation — suggested fix]
```

## Scope Expansion (E2E / UAT)

When asked for a full release review:
- Critical user journeys (happy path + error path)
- Auth flows (login, logout, unauthorized access)
- Role-based access (each role sees what it should)
- Empty states, loading states, error messages (user-friendly, not raw errors)
- Mobile + desktop viewports

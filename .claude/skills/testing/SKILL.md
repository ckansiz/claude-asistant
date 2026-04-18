---
name: testing
description: This skill should be used when the user asks to "write a test", "set up xUnit/Vitest/Jest", "add an integration test", "mock an API", or modifies test files (`*.test.ts`, `*Tests.cs`).
version: 1.0.0
---

# Testing Standards

Apply when writing or modifying tests in any project.

## .NET (xUnit + FluentAssertions)

### Structure
- Test project per source project: `{Project}.Tests/`
- Naming: `{ClassName}Tests.cs` → `{MethodName}_Should_{ExpectedBehavior}`
- Arrange-Act-Assert pattern, one assertion concept per test

### What to test
- Command/query handlers (business logic)
- Domain entity methods and validation
- Endpoint integration tests (`WebApplicationFactory`)
- EF Core queries against real PostgreSQL (Testcontainers)

### What NOT to test
- Framework code (EF Core, ASP.NET plumbing)
- Private methods directly
- Trivial mappings (DTO → entity if using AutoMapper/Mapster)

### Packages
- `xUnit` — test framework
- `FluentAssertions` — readable assertions
- `NSubstitute` — mocking
- `Testcontainers.PostgreSql` — real DB for integration tests
- `Microsoft.AspNetCore.Mvc.Testing` — `WebApplicationFactory`

### Example
```csharp
public class CreateOrderHandlerTests
{
    [Fact]
    public async Task Handle_Should_ReturnSuccess_WhenOrderIsValid()
    {
        // Arrange
        var handler = new CreateOrderHandler(dbContext);
        var command = new CreateOrderCommand { /* ... */ };

        // Act
        var result = await handler.Handle(command, CancellationToken.None);

        // Assert
        result.IsSuccess.Should().BeTrue();
    }
}
```

## Astro / Next.js (Vitest)

### Structure
- Test files next to source: `component.test.ts` or `__tests__/` directory
- Naming: `describe('{Component}')` → `it('should {behavior}')`

### What to test
- Utility functions and helpers
- API route handlers (request/response)
- React component behavior (Testing Library)
- Form validation logic (Zod schemas)

### Packages
- `vitest` — test runner (compatible with Vite/Astro)
- `@testing-library/react` — component testing
- `@testing-library/user-event` — user interaction simulation
- `msw` — API mocking (Mock Service Worker)

### Config
```typescript
// vitest.config.ts
import { defineConfig } from 'vitest/config'

export default defineConfig({
  test: {
    environment: 'jsdom',
    globals: true,
    setupFiles: ['./src/test/setup.ts'],
  },
})
```

## React Native (Jest + RNTL)

### Structure
- Test files: `__tests__/{Component}.test.tsx`
- Naming: same as web (describe/it pattern)

### Packages
- `jest` — test runner (Expo default)
- `@testing-library/react-native` — component testing
- `msw` — API mocking

### What to test
- Screen rendering and navigation
- User interactions (press, type, scroll)
- Zustand store logic
- API hooks (TanStack Query with msw)

## End-to-End & Smoke Tests (Playwright)

Apply when the task touches a critical user journey, a public landing page, or anything the client will demo.

### Setup (shared across Astro / Next.js / any web app)
- Package: `@playwright/test`
- Config: `playwright.config.ts` at project root
- Folder: `e2e/` for journeys, `e2e/smoke/` for smoke tests
- Browsers: chromium + webkit (mobile-relevant); add firefox only if client uses it

### Config skeleton
```typescript
// playwright.config.ts
import { defineConfig, devices } from '@playwright/test'

export default defineConfig({
  testDir: './e2e',
  fullyParallel: true,
  retries: process.env.CI ? 2 : 0,
  reporter: [['html'], ['list']],
  use: {
    baseURL: process.env.BASE_URL ?? 'http://localhost:4321',
    trace: 'on-first-retry',
    screenshot: 'only-on-failure',
    video: 'retain-on-failure',
  },
  projects: [
    { name: 'desktop', use: { ...devices['Desktop Chrome'] } },
    { name: 'mobile',  use: { ...devices['iPhone 13'] } },
  ],
  webServer: {
    command: 'npm run build && npm run preview',
    url: 'http://localhost:4321',
    reuseExistingServer: !process.env.CI,
    timeout: 120_000,
  },
})
```

### Critical User Journey Pattern

One file per journey; name by business outcome, not by page.

```typescript
// e2e/checkout.spec.ts
import { test, expect } from '@playwright/test'

test.describe('Checkout — TR customer buys a product', () => {
  test('guest checkout → order confirmation', async ({ page }) => {
    await page.goto('/')
    await page.getByRole('link', { name: 'Ürünler' }).click()
    await page.getByRole('button', { name: /sepete ekle/i }).first().click()
    await page.goto('/sepet')
    await page.getByRole('button', { name: /ödeme/i }).click()

    await page.getByLabel('E-posta').fill('test@example.com')
    await page.getByLabel('Ad Soyad').fill('Ali Yılmaz')
    // ... rest of form

    await page.getByRole('button', { name: /siparişi tamamla/i }).click()
    await expect(page.getByText(/sipariş numarası/i)).toBeVisible()
  })
})
```

Rules:
- Prefer role/label selectors — `getByRole`, `getByLabel`. Test IDs (`data-testid`) only when semantic selectors are ambiguous.
- One happy path + one realistic failure per journey (e.g., invalid card, out-of-stock).
- Keep under 60 s per test; parallelize.
- Never share mutable state across tests (each test gets fresh DB seed or isolated user).

### Smoke Test Checklist

Smoke tests run before every deploy (and after every hotfix). They prove the site is not on fire — deep correctness is for unit/integration.

```typescript
// e2e/smoke/smoke.spec.ts
import { test, expect } from '@playwright/test'

const paths = ['/', '/hakkimizda', '/iletisim', '/giris'] // per project

for (const path of paths) {
  test(`${path} renders 200 OK`, async ({ page }) => {
    const response = await page.goto(path)
    expect(response?.status()).toBe(200)
    await expect(page.locator('body')).not.toContainText(/error|exception|stack trace/i)
  })
}

test('login → dashboard (if auth exists)', async ({ page }) => {
  // only if project has auth
})

test('checkout critical path loads (if e-commerce)', async ({ page }) => {
  // only if project has checkout
})
```

Per-project smoke checklist (adapt, don't skip):
- [ ] Home page renders, no console error
- [ ] Main navigation links all return 200
- [ ] Login page loads, form interactable
- [ ] Critical CTAs are present (contact form, buy button, etc.)
- [ ] Footer shows correct year / brand / legal links
- [ ] Sitemap + robots + favicon reachable
- [ ] SSL green (production smoke only)
- [ ] Analytics fires (production smoke only — use a Playwright request listener)

### When Smoke is Enough vs. Full E2E

| Situation | Smoke only | Full E2E |
|-----------|------------|----------|
| Hotfix | ✅ | — |
| Content-only change | ✅ | — |
| New feature on auth / payment / checkout | — | ✅ |
| Schema migration | — | ✅ |
| Pre-launch / go-live | ✅ (prod) | ✅ (staging) |

### Pre-Launch / Go-Live Testing

Run before the client sees it live. A client-facing feature is not "done" until this passes.

- [ ] Full E2E suite — green
- [ ] Smoke against staging — green
- [ ] Smoke against production (post-deploy) — green
- [ ] Visual regression (see `visual-regression` skill) — no unexpected diffs
- [ ] Lighthouse / Core Web Vitals (see `performance` skill) — meets target
- [ ] Manual check on real iOS + Android device (at least one each) for public sites
- [ ] Accessibility quick check: tab through, screen reader on home + primary CTA

Log results in the Test Report (see `orchestration` skill) before declaring ready for delivery.

## General Rules

- Tests run in CI — broken tests block merge
- No `test.skip` or `test.todo` in committed code without a linked issue
- Prefer integration tests over unit tests for API endpoints
- Mock external services (APIs, email), never mock the database in integration tests
- Test error paths, not just happy paths
- Every non-N/A entry in the `edge-cases` checklist either has a test **or** a deliberate "documented, not tested" note — never silently skipped
- Smoke suite is mandatory for hotfix paths and pre-launch; full E2E is mandatory for auth/payment/checkout-touching features

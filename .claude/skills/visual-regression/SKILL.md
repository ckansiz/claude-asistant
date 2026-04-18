---
name: visual-regression
description: This skill should be used when the user asks to "run visual tests", "check for UI regressions", "compare screenshots", "update Playwright baselines", "add visual test", or invokes /visual-regression. Drives Playwright-based screenshot comparison, severity classification, and baseline update decisions.
version: 1.0.0
---

# Visual Regression Testing (Playwright)

Apply when guarding UI against accidental visual change. Uses Playwright for page-level, component-level, and responsive-breakpoint screenshot comparison.

## Stack

| Concern | Tool |
|---------|------|
| Screenshot engine | Playwright |
| Config | `playwright.config.ts` |
| Spec files | `playwright/visual/*.spec.ts` |
| Baseline images | `playwright/visual-snapshots/` (committed to git) |
| Helpers | `playwright/helpers/viewports.ts` |

## Viewports (Standard)

| Project | Size |
|---------|------|
| desktop | 1280 × 720 |
| tablet | 768 × 1024 |
| mobile | 390 × 844 |

Define in `playwright.config.ts`:

```ts
projects: [
  { name: 'desktop', use: { viewport: { width: 1280, height: 720 } } },
  { name: 'tablet',  use: { viewport: { width: 768,  height: 1024 } } },
  { name: 'mobile',  use: { viewport: { width: 390,  height: 844 } } },
]
```

## Spec Structure

Three kinds of specs under `playwright/visual/`:

```
playwright/
├── helpers/
│   └── viewports.ts      # Shared: page URLs, component selectors, waitForPageReady()
├── visual/
│   ├── pages.spec.ts         # Full-page screenshots (every marketing page)
│   ├── components.spec.ts    # Element-level shots (header, hero, footer, cards)
│   └── responsive.spec.ts    # Breakpoint behaviour checks
└── visual-snapshots/          # Baselines, committed
```

## Writing a Visual Test

```ts
import { test, expect } from '@playwright/test'
import { waitForPageReady } from '../helpers/viewports'

test.describe('Pricing page — visual regression', () => {
  test('full page renders correctly', async ({ page }) => {
    await page.goto('/fiyatlandirma')
    await waitForPageReady(page)

    await expect(page).toHaveScreenshot('pricing-page.png', { fullPage: true })
  })

  test('pricing cards render correctly', async ({ page }) => {
    await page.goto('/fiyatlandirma')
    await waitForPageReady(page)

    const cards = page.locator('[data-testid="pricing-card"]')
    await expect(cards.first()).toHaveScreenshot('pricing-card.png')
  })
})
```

### Key Rules

- **Always** call `waitForPageReady(page)` before screenshot — waits for network idle, fonts loaded, animations settled.
- **Always** use descriptive names: `{feature}-{viewport?}-{state?}.png`.
- Use `page.locator()` for element shots, `.first()` when multiple matches possible.
- Use `test.skip(condition, reason)` for viewport-specific tests.
- Use `testInfo.project.name` when behaviour differs across viewports.
- **Never** hardcode viewport sizes — use project config.
- Shared page URLs + component selectors live in `playwright/helpers/viewports.ts`.

### Selector Priority

1. `data-testid` attributes — most stable
2. Semantic tags — `header`, `footer`, `main`, `nav`, `section`
3. ARIA roles — `[role="dialog"]`
4. `:nth-of-type()`, `:first-of-type` for disambiguation
5. **Avoid** CSS class selectors — fragile under styling changes

## Helper: `waitForPageReady`

```ts
// playwright/helpers/viewports.ts
import type { Page } from '@playwright/test'

export async function waitForPageReady(page: Page): Promise<void> {
  await page.waitForLoadState('networkidle')
  await page.evaluate(() => document.fonts.ready)
  // Disable animations for deterministic screenshots
  await page.addStyleTag({
    content: `*, *::before, *::after {
      animation-duration: 0s !important;
      transition-duration: 0s !important;
    }`,
  })
  await page.waitForTimeout(150)  // let layout settle
}
```

## Running Tests

```bash
# All visual tests
npx playwright test --config=playwright.config.ts

# Specific spec
npx playwright test playwright/visual/pages.spec.ts

# Specific viewport
npx playwright test --project=mobile

# Update baselines (see rules below)
npx playwright test --update-snapshots

# HTML report with diffs
npx playwright show-report
```

Alias via `package.json` scripts (convention from wcard):

```json
{
  "scripts": {
    "test:visual": "playwright test",
    "test:visual:update": "playwright test --update-snapshots",
    "test:visual:report": "playwright show-report"
  }
}
```

## Severity Classification

When a visual test fails, classify before acting:

| Severity | Description | Example |
|----------|-------------|---------|
| **Critical** | Layout broken, content invisible / overlapping | Grid collapsed, text outside viewport |
| **High** | Major visual mismatch, usability affected | Wrong colors, missing sections, responsive broken |
| **Medium** | Noticeable cosmetic issue | Spacing drift, font weight off, border missing |
| **Low** | Minor pixel-level diff | Anti-aliasing, sub-pixel rendering |

Critical / High → treat as a bug, escalate to `bug-fix` workflow.
Medium → ticket and fix in the next PR.
Low → usually the baseline needs updating (see below).

## Baseline Update Rules

Never blindly run `--update-snapshots`. First:

1. Open the HTML report (`test:visual:report`) — look at the diff images.
2. Decide: is this an **intentional** UI change (the code change requires it) or an **unintentional regression**?
3. **Intentional** → run `test:visual:update`, review the new baselines by eye, commit with `test(ui): update baselines after {change}`.
4. **Unintentional** → do NOT update. Fix the code instead.

Baseline commits should be **separate** from implementation commits — reviewers can see the visual diff independently.

## Adding New Coverage

1. Add new page URL to `MARKETING_PAGES` in `playwright/helpers/viewports.ts`.
2. Add new component target to `COMPONENT_TARGETS` if element-level.
3. Write the test in the appropriate `playwright/visual/*.spec.ts`.
4. Run `test:visual:update` to generate initial baseline.
5. Visually verify the baseline looks correct before committing.

## CI Integration

- Visual tests run on every PR (GitHub Actions).
- Failing visual tests block merge.
- PR author reviews the HTML report artifact.
- If the failure is intentional, author re-generates baseline locally and pushes the update commit.

## Reporting (for orchestration)

When the tester role reports visual results (see `orchestration` skill's Test Report format), include:

```
Visual (playwright): PASS/FAIL
  - {N} tests failed
  - Severities: {critical: 0, high: 1, medium: 2, low: 0}
  - Decision: bug (escalate) | intentional (update baseline)
```

## Constraints

- Do not fix CSS / layout code as part of the visual regression task — report it to `@builder` via the orchestration loop.
- Do not update baselines without explicitly confirming the change is intentional.
- Do not write production code from this role — only test code under `playwright/`.

## Companion Skills

- `orchestration` — tester report format
- `testing` — non-visual test strategy
- `bug-fix` — when a visual regression is a real bug

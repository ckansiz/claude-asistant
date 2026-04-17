---
name: i18n
description: This skill should be used when the user asks to "add Turkish translation", "localize the site", "set up i18n", "add multi-language support", "configure next-intl", "configure astro-i18n", or works on multi-language content for TR clients.
version: 1.0.0
---

# Internationalization (Turkish + English)

Apply when a project needs multi-language support. Default assumption: **Turkish is primary**, English is secondary (most Wesoco clients). Flip if the client is EN-first.

## URL Strategy

Prefer path-based routing — better for SEO than subdomains for small sites:

```
/              → TR (default, no prefix)
/en/           → English
/en/products   → English product page
```

Rationale: TR clients' organic traffic is TR; keeping TR at root avoids breaking existing rankings.

## Next.js — next-intl

```bash
npm install next-intl
```

```
messages/
  tr.json
  en.json
src/
  i18n.ts         # config
  middleware.ts   # locale detection
  app/
    [locale]/
      layout.tsx
      page.tsx
```

```ts
// src/i18n.ts
import { getRequestConfig } from 'next-intl/server'

export default getRequestConfig(async ({ locale }) => ({
  messages: (await import(`../messages/${locale}.json`)).default,
}))
```

```ts
// middleware.ts
import createMiddleware from 'next-intl/middleware'

export default createMiddleware({
  locales: ['tr', 'en'],
  defaultLocale: 'tr',
  localePrefix: 'as-needed',  // TR at root, /en prefix for English
})

export const config = { matcher: ['/((?!api|_next|.*\\..*).*)'] }
```

```tsx
// Server component usage
import { useTranslations } from 'next-intl'

export default function Page() {
  const t = useTranslations('home')
  return <h1>{t('title')}</h1>
}
```

## Astro — astro-i18n / @astrojs/i18n (v5)

Astro 5 ships i18n natively:

```js
// astro.config.mjs
export default defineConfig({
  i18n: {
    defaultLocale: 'tr',
    locales: ['tr', 'en'],
    routing: {
      prefixDefaultLocale: false,  // TR at root
    },
  },
})
```

```
src/
  pages/
    index.astro          # TR homepage
    products.astro       # TR products
    en/
      index.astro        # EN homepage
      products.astro
  i18n/
    tr.json
    en.json
  lib/i18n.ts            # helper to load messages
```

## Message File Structure

Flat keys scoped by feature — never deeply nested:

```json
{
  "nav.home": "Anasayfa",
  "nav.products": "Ürünler",
  "home.hero.title": "Yapmadığımız iş yok",
  "home.hero.cta": "İletişime geç",
  "form.error.required": "{field} zorunlu"
}
```

Why flat: easy grep, easy diff in PRs, Google Translate friendly for first-pass content.

## Variables & Plurals

```json
{
  "cart.items": "{count, plural, =0 {Sepet boş} one {# ürün} other {# ürün}}",
  "welcome": "Hoşgeldin, {name}"
}
```

TR has no "one" vs "other" distinction like English — use `other` and let the count render naturally.

## What NOT to Translate

- Brand names, product names (unless the client explicitly localized them)
- Tech terms where TR convention is to keep EN (e.g. "Blog", "SEO", "E-ticaret" vs "E-commerce" — match client preference)
- Legal entity names, addresses, VKN

## Date, Number, Currency

```ts
// Dates
new Intl.DateTimeFormat('tr-TR', { dateStyle: 'long' }).format(date)
// → "17 Nisan 2026"

// Currency — TRY for TR, EUR/USD optional
new Intl.NumberFormat('tr-TR', { style: 'currency', currency: 'TRY' }).format(price)
// → "₺1.234,56"
```

## SEO Hooks

- `<html lang="tr">` or `"en"` — set per page
- `<link rel="alternate" hreflang="tr" href="..." />` + `hreflang="en"` + `hreflang="x-default"`
- Localized `<title>` and `<meta name="description">`
- Separate `sitemap.xml` entries per locale

Use `seo` skill for the full SEO checklist.

## Content Workflow with Clients

- Client delivers copy in Google Docs / Notion — one doc per locale
- Strings go into `messages/*.json` — never hardcode inside components
- For long-form content (blog posts, legal pages), prefer CMS (see `cms` skill) over JSON files

## Companion Skills

- `nextjs` / `astro` — routing and layout integration
- `seo` — hreflang, sitemap per locale
- `cms` — CMS-driven multi-language content

---
name: seo
description: This skill should be used when the user asks to "add meta tags", "set up OG image", "generate sitemap", "add structured data / JSON-LD", "configure robots.txt", "improve SEO", "add canonical URL", or prepares a marketing site for launch.
version: 1.0.0
---

# SEO Standards (Marketing Sites)

Apply when launching or auditing client marketing sites. Technical SEO only — content/keyword strategy is the client's job.

## The Must-Haves (Every Page)

Every page — not just the homepage — needs:

1. Unique `<title>` (50–60 chars)
2. Unique `<meta name="description">` (140–160 chars)
3. `<link rel="canonical">` pointing at the preferred URL
4. OG + Twitter meta (title, description, image)
5. `<html lang="tr">` (or correct locale)

Put this in the layout/head helper — never duplicate per page manually.

## Next.js — Metadata API

```ts
// app/layout.tsx — defaults
import type { Metadata } from 'next'

export const metadata: Metadata = {
  metadataBase: new URL('https://client-domain.com'),
  title: { default: 'Client Name', template: '%s | Client Name' },
  description: 'Default description',
  openGraph: {
    type: 'website',
    locale: 'tr_TR',
    siteName: 'Client Name',
    images: ['/og-default.png'],
  },
  twitter: { card: 'summary_large_image' },
  robots: { index: true, follow: true },
}

// app/products/[slug]/page.tsx — per-page
export async function generateMetadata({ params }): Promise<Metadata> {
  const product = await getProduct(params.slug)
  return {
    title: product.name,
    description: product.excerpt,
    alternates: { canonical: `/products/${product.slug}` },
    openGraph: { images: [product.image] },
  }
}
```

## Astro — per-page in frontmatter

```astro
---
// src/layouts/Base.astro
interface Props {
  title: string
  description: string
  image?: string
  canonical?: string
}
const { title, description, image = '/og-default.png', canonical = Astro.url.href } = Astro.props
---
<head>
  <title>{title}</title>
  <meta name="description" content={description} />
  <link rel="canonical" href={canonical} />

  <meta property="og:type" content="website" />
  <meta property="og:title" content={title} />
  <meta property="og:description" content={description} />
  <meta property="og:image" content={new URL(image, Astro.site).href} />
  <meta property="og:locale" content="tr_TR" />

  <meta name="twitter:card" content="summary_large_image" />
  <meta name="twitter:title" content={title} />
  <meta name="twitter:description" content={description} />
  <meta name="twitter:image" content={new URL(image, Astro.site).href} />
</head>
```

## OG Image — Dynamic Generation

Static `og-default.png` (1200×630, under 300KB) works for most pages. For per-article OG images:

```ts
// app/og/route.tsx — Next.js
import { ImageResponse } from 'next/og'

export async function GET(req: Request) {
  const { searchParams } = new URL(req.url)
  const title = searchParams.get('title') ?? 'Client Name'
  return new ImageResponse(
    <div style={{ display: 'flex', background: '#0c1727', color: 'white', width: '100%', height: '100%', padding: 80, fontSize: 64 }}>
      {title}
    </div>,
    { width: 1200, height: 630 }
  )
}
```

Reference: `openGraph: { images: [\`/og?title=${encodeURIComponent(title)}\`] }`.

## Sitemap

### Next.js

```ts
// app/sitemap.ts
import type { MetadataRoute } from 'next'

export default async function sitemap(): Promise<MetadataRoute.Sitemap> {
  const products = await getProducts()
  return [
    { url: 'https://client-domain.com', changeFrequency: 'weekly', priority: 1 },
    { url: 'https://client-domain.com/about', changeFrequency: 'monthly' },
    ...products.map(p => ({
      url: `https://client-domain.com/products/${p.slug}`,
      lastModified: p.updatedAt,
    })),
  ]
}
```

### Astro

```bash
npm install @astrojs/sitemap
```

```js
// astro.config.mjs
import sitemap from '@astrojs/sitemap'
export default defineConfig({
  site: 'https://client-domain.com',
  integrations: [sitemap()],
})
```

## robots.txt

### Next.js

```ts
// app/robots.ts
import type { MetadataRoute } from 'next'

export default function robots(): MetadataRoute.Robots {
  return {
    rules: [
      { userAgent: '*', allow: '/', disallow: ['/admin', '/api'] },
    ],
    sitemap: 'https://client-domain.com/sitemap.xml',
  }
}
```

### Astro

Put `public/robots.txt`:

```
User-agent: *
Allow: /
Disallow: /admin

Sitemap: https://client-domain.com/sitemap-index.xml
```

## Structured Data (JSON-LD)

Add to pages that match known schemas — richer Google results.

```tsx
// Organization (homepage)
<script type="application/ld+json" dangerouslySetInnerHTML={{ __html: JSON.stringify({
  '@context': 'https://schema.org',
  '@type': 'Organization',
  name: 'Client Name',
  url: 'https://client-domain.com',
  logo: 'https://client-domain.com/logo.png',
  sameAs: ['https://instagram.com/client', 'https://linkedin.com/company/client'],
})}} />

// Article / BlogPosting
{ '@context': 'https://schema.org', '@type': 'Article', headline, author, datePublished, image }

// Product
{ '@context': 'https://schema.org', '@type': 'Product', name, image, offers: { '@type': 'Offer', price, priceCurrency: 'TRY', availability: 'https://schema.org/InStock' } }

// LocalBusiness (TR clients with physical address)
{ '@context': 'https://schema.org', '@type': 'LocalBusiness', name, address, telephone, openingHours }
```

Validate with Google's Rich Results Test before going live.

## Multi-Language SEO

For `i18n` sites, add hreflang alternates:

```html
<link rel="alternate" hreflang="tr" href="https://client.com/about" />
<link rel="alternate" hreflang="en" href="https://client.com/en/about" />
<link rel="alternate" hreflang="x-default" href="https://client.com/about" />
```

Separate sitemap entries per locale. Full setup in `i18n` skill.

## Analytics

- **Plausible** or **Umami** — privacy-first, KVKK-friendly, lightweight (default for TR clients)
- **Google Analytics 4** — when client insists or already has it; add cookie consent banner
- **Cloudflare Web Analytics** — free, zero-JS, basic metrics

Never load analytics before consent for EU/KVKK-sensitive clients.

## Performance Impact

SEO and performance are joined — slow sites rank lower. See `performance` skill for Lighthouse, Core Web Vitals, image/font optimization.

## Pre-Launch SEO Checklist

- [ ] Every page has unique title + description
- [ ] Canonical URLs set
- [ ] OG images render (test with opengraph.xyz or Facebook Debugger)
- [ ] sitemap.xml accessible at `/sitemap.xml`
- [ ] robots.txt allows indexing (not leftover `Disallow: /` from staging!)
- [ ] No staging URLs in HTML (grep for `staging.`, `preview.`)
- [ ] Structured data validates (Rich Results Test)
- [ ] Submit sitemap in Google Search Console
- [ ] `<meta name="robots" content="noindex">` removed from production
- [ ] 404 page exists and returns status 404 (not 200)
- [ ] Redirects configured (trailing slash, www vs apex, http→https)

## Common Mistakes

- Shipping with `noindex` still on (catastrophic — blocks all traffic for weeks)
- Same title/description across all pages (duplicate content penalty)
- OG image not absolute URL (previews fail on Slack/Twitter)
- Forgetting to set `metadataBase` in Next.js (breaks OG in production)
- Blocking CSS/JS in robots.txt (breaks Google's rendering)

## Companion Skills

- `performance` — Core Web Vitals, image optimization
- `i18n` — hreflang for multi-language
- `cms` — CMS-managed meta fields

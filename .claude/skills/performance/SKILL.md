---
name: performance
description: This skill should be used when the user asks to "improve Lighthouse score", "optimize Core Web Vitals", "reduce LCP/CLS/INP", "analyze bundle size", "optimize images", "preload fonts", "speed up the site", or audits an existing site before launch.
version: 1.0.0
---

# Performance Standards (Marketing + App)

Apply to improve or audit page speed. Target: Lighthouse 90+ on mobile for marketing sites; prioritize Core Web Vitals over score theater.

## Core Web Vitals Targets

| Metric | Good | Needs Improvement |
|--------|------|-------------------|
| LCP (Largest Contentful Paint) | ≤ 2.5s | 2.5–4.0s |
| INP (Interaction to Next Paint) | ≤ 200ms | 200–500ms |
| CLS (Cumulative Layout Shift) | ≤ 0.1 | 0.1–0.25 |

Measure real-user data with Vercel Analytics, Cloudflare RUM, or Plausible's Web Vitals add-on — lab data (Lighthouse) is a proxy, not the truth.

## LCP — The Hero Image Story

LCP is almost always the hero image or H1. Fix priorities:

1. **Preload the LCP image** — in `<head>`, before other resources:
   ```html
   <link rel="preload" as="image" href="/hero.webp" fetchpriority="high" />
   ```
2. **Use modern formats** — AVIF or WebP, JPEG only as fallback. Next.js `<Image>` and Astro `<Image>` handle this automatically.
3. **Serve the right size** — do not load a 2000px hero for a 375px phone. Set `sizes` prop.
4. **Don't lazy-load above-the-fold** — only lazy-load images below the viewport.
5. **Preconnect to image CDN** — if hosted externally:
   ```html
   <link rel="preconnect" href="https://cdn.client.com" crossorigin />
   ```

## Images — The Heaviest Mistake

### Next.js

```tsx
import Image from 'next/image'

// Above the fold — hero
<Image
  src="/hero.jpg"
  alt="Hero"
  width={1920}
  height={1080}
  priority            // preload + no lazy
  sizes="100vw"
/>

// Below the fold
<Image
  src={product.image}
  alt={product.name}
  width={400}
  height={300}
  sizes="(max-width: 768px) 100vw, 33vw"
  loading="lazy"      // default, but explicit is fine
/>
```

### Astro

```astro
---
import { Image } from 'astro:assets'
import hero from '@/assets/hero.jpg'
---
<Image src={hero} alt="Hero" widths={[400, 800, 1600]} sizes="100vw" loading="eager" />
```

### Raw `<img>` (fallback only)

```html
<img
  src="/hero.jpg"
  srcset="/hero-400.webp 400w, /hero-800.webp 800w, /hero-1600.webp 1600w"
  sizes="100vw"
  width="1600"
  height="900"
  alt="..."
  loading="lazy"
  decoding="async"
/>
```

Always set `width` + `height` attributes — prevents CLS.

## Fonts — The Silent CLS Killer

Default stack: DM Sans. Load once, no FOIT, no FOUT jumping.

### Self-host (preferred)

Download DM Sans from Google Fonts → ship `.woff2` from your domain.

```css
/* globals.css */
@font-face {
  font-family: 'DM Sans';
  src: url('/fonts/dm-sans-variable.woff2') format('woff2-variations');
  font-weight: 100 1000;
  font-style: normal;
  font-display: swap;
}
```

```html
<link rel="preload" href="/fonts/dm-sans-variable.woff2" as="font" type="font/woff2" crossorigin />
```

### Next.js `next/font`

```ts
// app/layout.tsx
import { DM_Sans } from 'next/font/google'

const dmSans = DM_Sans({ subsets: ['latin', 'latin-ext'], display: 'swap', variable: '--font-dm-sans' })

export default function Layout({ children }) {
  return <html lang="tr" className={dmSans.variable}><body>{children}</body></html>
}
```

### Latin-ext Subset for TR

Turkish characters (ğ, ş, ı, İ) live in `latin-ext`. Always include it or text renders in fallback font.

## CLS — Reserve Space

- Always set image `width` + `height` (or aspect-ratio CSS)
- Never inject content above existing content (cookie banners: overlay or bottom-fixed, not top push-down)
- Embedded videos / iframes: set dimensions, or `aspect-ratio: 16/9`
- Ad slots: pre-reserve with min-height placeholder

## INP — JS Responsiveness

- Avoid long tasks (>50ms) on main thread
- Debounce expensive handlers (search, scroll)
- Move heavy work to `requestIdleCallback` or a Web Worker
- In React: `useTransition` for non-urgent state updates
- Astro: default zero-JS — use islands sparingly, prefer `client:visible` over `client:load`

## Bundle Analysis

### Next.js

```bash
ANALYZE=true npm run build
```

With `@next/bundle-analyzer` in `next.config.js`:

```js
import bundleAnalyzer from '@next/bundle-analyzer'
const withBundleAnalyzer = bundleAnalyzer({ enabled: process.env.ANALYZE === 'true' })
export default withBundleAnalyzer({ /* config */ })
```

### Astro

```bash
npx astro build
npx vite-bundle-visualizer
```

### Red flags in the report

- Whole icon libraries (`lucide-react` is fine — tree-shakable; `react-icons` is not)
- Moment.js (use date-fns or Intl)
- Multiple copies of React (check lockfile)
- A `locales/` bundle with all 50 languages (configure to include only needed ones)

## Caching

- Static assets: `Cache-Control: public, max-age=31536000, immutable` (Next.js / Astro default for hashed filenames)
- HTML: short cache or `no-cache` with ETag revalidation
- API responses: `stale-while-revalidate` for lists that update infrequently
- CDN at Cloudflare: cache everything except `/api/*` by default

## JavaScript Budget

For a marketing site, first-load JS budget:

- < 100 KB gzipped — good
- 100-200 KB — acceptable
- > 200 KB — audit ruthlessly

For an app (dashboard, shop), more is acceptable — but split by route.

## Audit Workflow

```bash
# Lighthouse CLI on mobile preset
npx lighthouse https://preview-url.vercel.app --preset=desktop --view
npx lighthouse https://preview-url.vercel.app --preset=mobile --view

# WebPageTest — real-device profiling
# https://www.webpagetest.org — pick Istanbul/Ankara location for TR clients
```

### Chrome DevTools checklist

- Network tab → sort by size → anything > 500KB needs justification
- Performance tab → record page load → find long tasks (>50ms yellow bars)
- Coverage tab → find unused CSS/JS (> 50% unused = split or remove)

## Pre-Launch Performance Checklist

- [ ] Lighthouse Mobile score ≥ 90 (performance)
- [ ] LCP < 2.5s on 4G
- [ ] CLS < 0.1 with no banners / ads triggering shifts
- [ ] INP < 200ms on interactions
- [ ] All images use `next/image` or Astro `<Image>` (grep for raw `<img>`)
- [ ] Fonts self-hosted or `next/font`, with `display: swap`
- [ ] Bundle analyzed — no surprise dependencies
- [ ] Analytics loaded after interaction / consent, not render-blocking
- [ ] Third-party scripts (maps, chat widgets) lazy-loaded or on-interaction
- [ ] Cloudflare CDN enabled with Brotli compression
- [ ] `<link rel="preconnect">` for external image/font CDNs

## Common Wins (Fast to Apply)

1. Add `priority` to hero image → −1s LCP
2. Preload LCP image → −500ms LCP
3. Self-host fonts → −300ms + fewer connections
4. Swap `react-icons` for `lucide-react` → often −50KB
5. Lazy-load map / video / chat widget → −200KB initial
6. Cloudflare caching on HTML → second-visit near-instant

## Companion Skills

- `seo` — performance and ranking are linked
- `astro` / `nextjs` — framework-specific optimizations

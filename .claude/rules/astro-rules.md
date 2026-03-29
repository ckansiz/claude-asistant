# Astro Project Standards

Applies to: All Astro 4/5 projects in ~/workspace/wesoco/works/ and ~/workspace/qoommerce/frontend/

## Directory Structure

```
src/
  pages/                  # File-based routing
    api/                  # API endpoints (*.ts files)
    admin/                # Admin routes
    [slug].astro          # Dynamic routes
    index.astro
  components/
    ui/                   # Reusable UI primitives
    features/             # Feature-specific components
    admin/                # Admin-only components
    layout/               # Header, Footer, Nav
  layouts/
    Base.astro            # Root HTML layout
    Page.astro            # Standard page layout
    Admin.astro           # Admin panel layout
  lib/
    db/                   # Database connection and queries
      index.ts            # DB client export
    api/                  # API helper functions
    utils/                # Utility functions
    hooks/                # React hooks (for island components)
    types/                # TypeScript types
  content/                # Content Collections (blog, products, etc.)
    config.ts             # Collection schemas
  styles/
    globals.css
  middleware.ts           # Astro middleware (auth, redirects)
  env.d.ts                # Environment type declarations
public/                   # Static assets
astro.config.mjs
tailwind.config.mjs
tsconfig.json
```

## Component Types

**`.astro` files:** Layouts, templates, static/SSR content. Default choice.
**`.tsx` files:** Interactive island components that need React state/events.

```astro
---
// ProductCard.astro — server-rendered, no JS bundle
import type { Product } from '@/lib/types'
interface Props { product: Product }
const { product } = Astro.props
---

<div class="card">
  <h2>{product.name}</h2>
  <!-- Static, no client JS -->
</div>
```

```tsx
// AddToCartButton.tsx — interactive island
'use client' is NOT used in Astro. Just export normally.
import { useState } from 'react'

export function AddToCartButton({ productId }: { productId: string }) {
  const [loading, setLoading] = useState(false)
  return <button onClick={() => handleAdd(productId)}>Add to Cart</button>
}
```

## Island Directives

| Directive | When to Use |
|-----------|------------|
| `client:load` | Immediately needed on page load (cart button, auth forms) |
| `client:visible` | Lazy load when enters viewport (below-fold content) |
| `client:idle` | Load when browser is idle (non-critical widgets) |
| `client:only="react"` | Never SSR (dashboard charts, maps) |

```astro
<!-- ✅ Only interactive parts get JS -->
<ProductGallery images={images} />           <!-- .astro — no JS -->
<AddToCartButton client:load productId={id} /> <!-- .tsx — minimal JS -->
<ReviewList client:visible productId={id} />   <!-- .tsx — lazy loaded -->
```

## Tailwind CSS

All Astro projects use **Tailwind v3** with `@astrojs/tailwind` integration.

```mjs
// astro.config.mjs
import tailwind from '@astrojs/tailwind'
export default defineConfig({
  integrations: [tailwind()],
})
```

```mjs
// tailwind.config.mjs
export default {
  content: ['./src/**/*.{astro,html,js,jsx,md,mdx,svelte,ts,tsx,vue}'],
  theme: {
    extend: {
      colors: { primary: 'var(--color-primary)' }
    }
  }
}
```

Do NOT mix Tailwind v3 and v4 syntax in same project.

## Database

**New projects:** Drizzle ORM — lightweight, type-safe, edge-compatible.
**Existing:** TypeORM and Prisma are supported — do not migrate unless requested.

```ts
// src/lib/db/index.ts — Drizzle example
import { drizzle } from 'drizzle-orm/postgres-js'
import postgres from 'postgres'
import * as schema from './schema'

const client = postgres(import.meta.env.DATABASE_URL)
export const db = drizzle(client, { schema })
```

## API Routes

```ts
// src/pages/api/products.ts
import type { APIRoute } from 'astro'
import { db } from '@/lib/db'

export const GET: APIRoute = async ({ request }) => {
  const products = await db.query.products.findMany()
  return new Response(JSON.stringify(products), {
    headers: { 'Content-Type': 'application/json' }
  })
}

export const POST: APIRoute = async ({ request }) => {
  const body = await request.json()
  // validate + insert
  return new Response(JSON.stringify({ id: newProduct.id }), { status: 201 })
}
```

## Image Optimization

**Always use Astro's `<Image>` component.** Native `<img>` tags are forbidden for local assets.

```astro
---
import { Image } from 'astro:assets'
import heroImage from '@/assets/hero.jpg'
---

<!-- ✅ Optimized -->
<Image src={heroImage} alt="Hero" width={1200} height={600} />

<!-- ❌ Never for local assets -->
<img src="/hero.jpg" alt="Hero" />
```

## TypeScript Configuration

```json
// tsconfig.json
{
  "extends": "astro/tsconfigs/strict",
  "compilerOptions": {
    "baseUrl": ".",
    "paths": { "@/*": ["./src/*"] }
  }
}
```

## SSR vs Static

- **SSR (server output):** For sites with auth, personalization, dynamic data
  ```mjs
  output: 'server', adapter: node({ mode: 'standalone' })
  ```
- **Hybrid:** Mix of static and server routes
  ```mjs
  output: 'hybrid'
  // Add export const prerender = false to SSR pages
  ```
- **Static:** Pure content sites with no server-side logic

## Middleware

```ts
// src/middleware.ts
import { defineMiddleware } from 'astro:middleware'

export const onRequest = defineMiddleware(async (context, next) => {
  const { pathname } = context.url
  if (pathname.startsWith('/admin')) {
    // auth check
    const session = await getSession(context.request)
    if (!session) return context.redirect('/login')
  }
  return next()
})
```

## Content Collections

For blog posts, products, or any structured content:

```ts
// src/content/config.ts
import { defineCollection, z } from 'astro:content'

export const collections = {
  blog: defineCollection({
    type: 'content',
    schema: z.object({
      title: z.string(),
      pubDate: z.date(),
      description: z.string(),
    })
  })
}
```

## Environment Variables

```ts
// src/env.d.ts
/// <reference types="astro/client" />
interface ImportMetaEnv {
  readonly DATABASE_URL: string
  readonly SECRET_KEY: string
}
interface ImportMeta {
  readonly env: ImportMetaEnv
}
```

Access: `import.meta.env.DATABASE_URL` (not `process.env`).

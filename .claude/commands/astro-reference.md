# Astro Project Code Examples

Use this when building Astro components, pages, API routes, or configuring database/middleware.

## Directory Structure

```
src/
  pages/
    api/                  # API endpoints (*.ts files)
    admin/                # Admin routes
    [slug].astro          # Dynamic routes
    index.astro
  components/
    ui/                   # shadcn/ui primitives
    features/             # Feature components
    admin/                # Admin-only components
    layout/               # Header, Footer, Nav
  layouts/
    Base.astro            # Root HTML layout
    Page.astro            # Standard page layout
    Admin.astro           # Admin panel layout
  lib/
    db/                   # Database setup and queries
    api/                  # API helpers
    utils/                # Utility functions
    hooks/                # React hooks (island components)
    types/                # TypeScript types
  content/                # Content Collections
    config.ts
  styles/
    globals.css
  middleware.ts
  env.d.ts
```

## Components: .astro vs .tsx

**.astro files** — Server-rendered, static, no JavaScript bundle:

```astro
---
// ProductCard.astro
import type { Product } from '@/lib/types'
interface Props { product: Product }
const { product } = Astro.props
---

<div class="card">
  <h2>{product.name}</h2>
  <!-- Static content, zero client JS -->
</div>
```

**.tsx files** — Interactive islands that need React state/event handlers:

```tsx
// AddToCartButton.tsx
// No 'use client' directive in Astro (that's Next.js)
import { useState } from 'react'

export function AddToCartButton({ productId }: { productId: string }) {
  const [loading, setLoading] = useState(false)
  return <button onClick={() => handleAdd(productId)}>Add to Cart</button>
}
```

## Island Directives

Use island directives to control when/if JavaScript loads:

| Directive | When to Use |
|-----------|------------|
| `client:load` | Needed on page load (cart button, auth form) |
| `client:visible` | Load when enters viewport (below-fold widgets) |
| `client:idle` | Load when browser idle (non-critical components) |
| `client:only="react"` | Never SSR (interactive dashboard, map) |

```astro
<!-- Only the interactive parts get JS -->
<ProductGallery images={images} />           <!-- .astro — no JS -->
<AddToCartButton client:load productId={id} /> <!-- .tsx — minimal JS -->
<ReviewList client:visible productId={id} />   <!-- .tsx — lazy loaded -->
```

## Tailwind CSS v3 Setup

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

## Drizzle ORM Database

```ts
// src/lib/db/index.ts
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

Always use Astro's `<Image>` component for local assets. Never raw `<img>`:

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

```mjs
// Server-rendered — for auth, personalization, dynamic data
output: 'server'
adapter: node({ mode: 'standalone' })

// Hybrid — mix of static and server routes
output: 'hybrid'
// Add to SSR pages: export const prerender = false

// Static — pure content sites, no server logic
output: 'static'
```

## Middleware

```ts
// src/middleware.ts
import { defineMiddleware } from 'astro:middleware'

export const onRequest = defineMiddleware(async (context, next) => {
  const { pathname } = context.url
  if (pathname.startsWith('/admin')) {
    const session = await getSession(context.request)
    if (!session) return context.redirect('/login')
  }
  return next()
})
```

## Content Collections

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

Access with `import.meta.env.DATABASE_URL` (not `process.env`).

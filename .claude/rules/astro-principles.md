# Astro Project Principles

**Applies to:** All Astro 5 projects in wesoco and qoommerce contexts.

## Component Types: .astro vs .tsx

**.astro files** — server-rendered, static, zero client JavaScript:
```astro
---
// Server-side logic only
import type { Product } from '@/lib/types'
---

<div class="card">
  <h2>{product.name}</h2>
</div>
```

**.tsx files** — interactive islands for state/event handling:
```tsx
// No 'use client' directive in Astro (that's Next.js)
import { useState } from 'react'

export function AddToCart({ productId }: { productId: string }) {
  const [loading, setLoading] = useState(false)
  return <button onClick={() => { ... }}>Add to Cart</button>
}
```

## Island Directives (Lazy Loading)

Control **when** and **if** JavaScript loads for interactive components:

| Directive | When to Use |
|-----------|------------|
| `client:load` | Needed on page load (cart button, auth form) |
| `client:visible` | Load when enters viewport (below-fold widgets) |
| `client:idle` | Load when browser idle (non-critical) |
| `client:only="react"` | Never SSR (dashboard, map) |

```astro
<ProductGallery images={images} />              <!-- .astro → no JS -->
<AddToCartButton client:load productId={id} />  <!-- .tsx → minimal JS -->
<ReviewList client:visible productId={id} />    <!-- .tsx → lazy loaded -->
```

## Tailwind CSS

Use **v3** with `@astrojs/tailwind` integration:
```mjs
// astro.config.mjs
import tailwind from '@astrojs/tailwind'
export default defineConfig({ integrations: [tailwind()] })
```

```mjs
// tailwind.config.mjs
export default {
  content: ['./src/**/*.{astro,html,js,jsx,ts,tsx}'],
  theme: { extend: { colors: { primary: 'var(--color-primary)' } } }
}
```

Do NOT mix Tailwind v3 and v4 in same project.

## Database

**New projects:** Drizzle ORM — lightweight, type-safe, edge-compatible.
**Existing:** TypeORM and Prisma supported. Do not migrate unless requested.

```ts
// src/lib/db/index.ts
import { drizzle } from 'drizzle-orm/postgres-js'
import postgres from 'postgres'
import * as schema from './schema'

const client = postgres(import.meta.env.DATABASE_URL)
export const db = drizzle(client, { schema })
```

## API Routes

Astro API endpoints live in `src/pages/api/`:
```ts
// src/pages/api/products.ts
import type { APIRoute } from 'astro'

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

**Always use Astro's `<Image>` component** for local assets. Never raw `<img>`:
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
// Server-rendered (auth, personalization, dynamic data)
output: 'server'
adapter: node({ mode: 'standalone' })

// Hybrid (mix of static and server routes)
output: 'hybrid'
// Add to SSR pages: export const prerender = false

// Static (pure content, no server logic)
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

For structured content (blog, products):
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

---

## Full Code Examples

For directory structure, component templates, Drizzle setup, API route examples, image optimization, middleware setup, and content collection schemas, see `/astro-reference`

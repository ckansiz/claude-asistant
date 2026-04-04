# Astro Standards

## Directory Structure

```
src/
  pages/              # File-based routing
    api/              # API endpoints (*.ts)
  components/
    ui/               # Reusable UI primitives
    features/         # Feature-specific
    layout/           # Header, Footer, Nav
  layouts/
    Base.astro
  lib/
    db/               # DB client + queries
    utils/
    hooks/            # React hooks (for island components)
    types/
  styles/
    globals.css
  middleware.ts
  env.d.ts
public/
astro.config.mjs
tailwind.config.mjs
```

## Component Types

**.astro files** — server-rendered, zero client JS. Default choice.

**.tsx files** — interactive islands that need state/events. No `'use client'` (that's Next.js).

```tsx
// AddToCartButton.tsx — interactive island
import { useState } from 'react'
export function AddToCartButton({ productId }: { productId: string }) {
  const [loading, setLoading] = useState(false)
  return <button onClick={...}>Add to Cart</button>
}
```

## Island Directives

| Directive | When |
|-----------|------|
| `client:load` | Needed immediately (cart button, auth form) |
| `client:visible` | Lazy load (below-fold widgets) |
| `client:idle` | Non-critical widgets |
| `client:only="react"` | Never SSR (dashboard, map) |

```astro
<ProductGallery images={images} />                <!-- .astro — no JS -->
<AddToCartButton client:load productId={id} />    <!-- .tsx — minimal JS -->
<ReviewList client:visible productId={id} />      <!-- .tsx — lazy -->
```

## API Routes

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
  return new Response(JSON.stringify({ id }), { status: 201 })
}
```

## Database — New Projects Use Drizzle

```ts
// src/lib/db/index.ts
import { drizzle } from 'drizzle-orm/postgres-js'
import postgres from 'postgres'
import * as schema from './schema'

const client = postgres(import.meta.env.DATABASE_URL)
export const db = drizzle(client, { schema })
```

Existing projects: TypeORM and Prisma supported — don't migrate unless asked.

## Tailwind

Use Tailwind **v3** with `@astrojs/tailwind` integration. Do NOT mix v3 and v4 in same project.

```mjs
// astro.config.mjs
import tailwind from '@astrojs/tailwind'
export default defineConfig({ integrations: [tailwind()] })
```

## Images

**Always use Astro's `<Image>` component.** Never raw `<img>` for local assets.

```astro
---
import { Image } from 'astro:assets'
import heroImage from '@/assets/hero.jpg'
---
<Image src={heroImage} alt="Hero" width={1200} height={600} />
```

## SSR vs Static

```mjs
// Server-rendered
output: 'server', adapter: node({ mode: 'standalone' })

// Hybrid (mix)
output: 'hybrid'  // + export const prerender = false on SSR pages

// Static
output: 'static'
```

## Middleware

```ts
// src/middleware.ts
import { defineMiddleware } from 'astro:middleware'
export const onRequest = defineMiddleware(async (context, next) => {
  if (context.url.pathname.startsWith('/admin')) {
    const session = await getSession(context.request)
    if (!session) return context.redirect('/login')
  }
  return next()
})
```

## Environment Variables

Access with `import.meta.env.DATABASE_URL` (not `process.env`).

```ts
// src/env.d.ts
/// <reference types="astro/client" />
interface ImportMetaEnv {
  readonly DATABASE_URL: string
}
```

## TypeScript

```json
{
  "extends": "astro/tsconfigs/strict",
  "compilerOptions": { "baseUrl": ".", "paths": { "@/*": ["./src/*"] } }
}
```

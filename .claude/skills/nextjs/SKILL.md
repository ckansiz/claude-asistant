---
name: nextjs
description: This skill should be used when the user asks to "build a Next.js page", "add a Server Component", "create an API route handler", "set up Prisma", "use shadcn/ui", or works on Next.js 15 / App Router projects (kanser-tedavi, oltan, serkan-tayar).
version: 1.0.0
---

# Next.js 15 Standards

Apply when implementing Next.js 15 + App Router + TypeScript + shadcn/ui + Prisma (PostgreSQL).

## Directory Structure

```
src/
  app/                    # App Router — all routes
    (auth)/               # Route groups
    api/                  # Route Handlers
    globals.css
    layout.tsx
    page.tsx
  components/
    ui/                   # shadcn/ui (auto-generated, never edit manually)
    features/             # Feature-specific components
    layout/               # Header, Footer, Sidebar, Nav
    shared/               # Reusable primitives not from shadcn
  lib/
    db.ts                 # Prisma singleton
    auth.ts               # Auth config
    utils.ts              # cn() and utilities
    validations/          # Zod schemas
  types/
    index.ts
    api.generated.ts      # OpenAPI-generated — DO NOT EDIT
  hooks/                  # use-*.ts
  middleware.ts
```

## Server vs Client Components

Default to Server Component (no directive needed).

Add `'use client'` only when the component needs: event handlers, `useState`/`useReducer`, browser APIs, `useEffect`.

```tsx
// ✅ Server Component
export default async function ProductPage({ params }: { params: { id: string } }) {
  const product = await db.product.findUnique({ where: { id: params.id } })
  return <ProductDetail product={product} />
}

// ✅ Client Component
'use client'
export function AddToCartButton({ productId }: { productId: string }) {
  const [loading, setLoading] = useState(false)
}
```

## Data Fetching

- Server components: direct DB via Prisma, or `fetch()` with Next.js caching
- Client components: TanStack Query — never raw `useEffect` + `fetch`

## Prisma Singleton

```ts
// src/lib/db.ts
import { PrismaClient } from '@prisma/client'
const globalForPrisma = globalThis as unknown as { prisma: PrismaClient }
export const db = globalForPrisma.prisma ?? new PrismaClient()
if (process.env.NODE_ENV !== 'production') globalForPrisma.prisma = db
```

Always `prisma migrate dev`, never `prisma db push` in production. See `database` skill.

## API Route Handlers

```ts
// src/app/api/products/route.ts
import { NextRequest, NextResponse } from 'next/server'

export async function GET(request: NextRequest) {
  const products = await db.product.findMany()
  return NextResponse.json(products)
}

export async function POST(request: NextRequest) {
  const body = await request.json()
  const result = schema.safeParse(body)
  if (!result.success) {
    return NextResponse.json({ error: result.error }, { status: 400 })
  }
  const product = await db.product.create({ data: result.data })
  return NextResponse.json(product, { status: 201 })
}
```

## Error Handling Files

Each route segment: `error.tsx` (`'use client'`), `not-found.tsx`, `loading.tsx`.

## shadcn/ui

```bash
npx shadcn@latest init
npx shadcn@latest add button card input label
```

Components land in `src/components/ui/` — never edit generated files. Customize via `globals.css` CSS variables.

## Tailwind

New projects: Tailwind v4 (CSS-based config, no `tailwind.config.js`).

```css
/* globals.css */
@import "tailwindcss";
@theme {
  --color-primary: oklch(45% 0.2 264);
}
```

Existing v3 projects: never migrate unless doing a major refactor.

## Authentication

- New projects: `better-auth`
- Existing: keep NextAuth unless full auth rewrite

## Imports

Always `@/` imports. Relative imports (`../../`) only within the same feature folder.

## File Naming

| Type | Convention |
|------|-----------|
| Pages | kebab-case (`product-detail/page.tsx`) |
| Components | PascalCase (`ProductCard.tsx`) |
| Hooks | camelCase + `use` prefix (`useProductFilter.ts`) |
| Utils | kebab-case (`format-currency.ts`) |
| API routes | kebab-case dir (`api/product-orders/route.ts`) |

## Companion Skills

- `typescript` — strict mode, naming, component structure
- `database` — Prisma migration workflow, PostgreSQL conventions
- `security` — input validation, CORS, auth patterns
- `testing` — Vitest standards
- `commits` — commit conventions
- `api-contract` — load when project also has a .NET backend

# Next.js Project Standards

Applies to: All Next.js 15/16 projects in ~/workspace/wesoco/works/ and ~/workspace/qoommerce/

## Directory Structure

```
src/
  app/                    # App Router — all routes here
    (auth)/               # Route groups for layout separation
    (dashboard)/
    api/                  # Route Handlers
    globals.css
    layout.tsx
    page.tsx
  components/
    ui/                   # shadcn/ui components (auto-generated, do not edit manually)
    features/             # Feature-specific components (product/, cart/, user/)
    layout/               # Header, Footer, Sidebar, Nav
    shared/               # Reusable primitives not from shadcn
  lib/
    db.ts                 # Prisma client singleton
    auth.ts               # Auth configuration (better-auth / NextAuth)
    utils.ts              # cn() and other utilities
    validations/          # Zod schemas
  types/
    index.ts              # Global type exports
    api.generated.ts      # OpenAPI-generated types — DO NOT EDIT MANUALLY
  hooks/                  # Custom React hooks (use-*.ts)
  middleware.ts           # Next.js middleware (auth, i18n, redirects)
prisma/
  schema.prisma
```

## Tailwind CSS

**New projects: Tailwind v4 (CSS-based config)**
```css
/* globals.css */
@import "tailwindcss";

@theme {
  --color-primary: oklch(45% 0.2 264);
  /* custom tokens here */
}
```
No `tailwind.config.js` — configuration lives in CSS.

**Existing v3 projects:** Migrate to v4 when doing a major refactor. Do NOT mix v3 and v4 in same project.

## shadcn/ui

**Mandatory for all new projects.**

```bash
npx shadcn@latest init
npx shadcn@latest add button card input label # etc.
```

- Components land in `src/components/ui/` — never edit generated files
- Use `cn()` from `src/lib/utils.ts` for class merging
- Customize via `globals.css` CSS variables, never by editing component source

## Server vs Client Components

Default: **Server Component** (no directive needed).

Add `'use client'` only when the component needs:
- Event handlers (`onClick`, `onChange`, `onSubmit`)
- React state (`useState`, `useReducer`)
- Browser APIs (`window`, `localStorage`, `navigator`)
- Lifecycle effects (`useEffect`)

```tsx
// ✅ Server Component (default)
export default async function ProductPage({ params }: { params: { id: string } }) {
  const product = await db.product.findUnique({ where: { id: params.id } })
  return <ProductDetail product={product} />
}

// ✅ Client Component (needs interactivity)
'use client'
export function AddToCartButton({ productId }: { productId: string }) {
  const [loading, setLoading] = useState(false)
  // ...
}
```

## Data Fetching

**Server components:** `fetch()` with Next.js caching or direct DB calls via Prisma.
**Client components:** TanStack Query (React Query) — no raw `useEffect` + `fetch`.

```tsx
// ✅ Server: direct DB
const products = await db.product.findMany({ where: { active: true } })

// ✅ Client: React Query
const { data, isLoading } = useQuery({
  queryKey: ['products'],
  queryFn: () => fetch('/api/products').then(r => r.json())
})
```

## Prisma

```ts
// src/lib/db.ts — singleton pattern (required)
import { PrismaClient } from '@prisma/client'

const globalForPrisma = globalThis as unknown as { prisma: PrismaClient }

export const db = globalForPrisma.prisma ?? new PrismaClient()

if (process.env.NODE_ENV !== 'production') globalForPrisma.prisma = db
```

- Schema: `prisma/schema.prisma`
- Always run `prisma migrate dev` — never `prisma db push` in production
- Use `prisma generate` after schema changes

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
  // validate with Zod
  const result = schema.safeParse(body)
  if (!result.success) {
    return NextResponse.json({ error: result.error }, { status: 400 })
  }
  const product = await db.product.create({ data: result.data })
  return NextResponse.json(product, { status: 201 })
}
```

## Error Handling Files

Each route segment should have:
- `error.tsx` — caught errors (must be `'use client'`)
- `not-found.tsx` — 404 states
- `loading.tsx` — Suspense fallback

## Authentication

- **New projects:** `better-auth` (modern, type-safe, no vendor lock-in)
- **Existing:** Keep NextAuth v4 unless doing full auth rewrite
- Config in `src/lib/auth.ts`
- Session access: `auth()` in Server Components, `useSession()` in Client Components

## i18n

Use `next-intl` for all multi-language projects.
```
src/
  i18n/
    routing.ts
    request.ts
  messages/
    tr.json
    en.json
```

## Absolute Imports

```json
// tsconfig.json
{
  "compilerOptions": {
    "paths": { "@/*": ["./src/*"] }
  }
}
```

Always use `@/` imports. Relative imports (`../../`) forbidden except within the same feature folder.

## File Naming

| Type | Convention | Example |
|------|-----------|---------|
| Pages | kebab-case | `product-detail/page.tsx` |
| Components | PascalCase | `ProductCard.tsx` |
| Hooks | camelCase with `use` prefix | `useProductFilter.ts` |
| Utils | kebab-case | `format-currency.ts` |
| Types | PascalCase | `Product.ts` |
| API routes | kebab-case directory | `api/product-orders/route.ts` |

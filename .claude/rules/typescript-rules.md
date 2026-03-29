# TypeScript & React Standards

Applies to: All Next.js and Astro projects in the workspace.

## TypeScript Configuration

All projects must use strict mode:

```json
{
  "compilerOptions": {
    "strict": true,
    "noUncheckedIndexedAccess": true,
    "exactOptionalPropertyTypes": true
  }
}
```

**Forbidden:**
- `any` type — use `unknown` and narrow with type guards
- `// @ts-ignore` — fix the type error instead
- `// @ts-nocheck` — never
- Type assertions (`as X`) without prior validation

## Naming Conventions

| What | Convention | Example |
|------|-----------|---------|
| Types / Interfaces | PascalCase | `ProductDto`, `UserProfile` |
| React Components | PascalCase | `ProductCard`, `UserAvatar` |
| Functions | camelCase | `formatCurrency`, `getUserById` |
| Variables | camelCase | `productList`, `isLoading` |
| Constants | UPPER_CASE | `MAX_RETRIES`, `API_BASE_URL` |
| Enums | PascalCase + values UPPER_CASE | `enum Status { ACTIVE, INACTIVE }` |
| Files — utilities | kebab-case | `format-currency.ts` |
| Files — components | PascalCase | `ProductCard.tsx` |
| Files — hooks | camelCase with `use` | `useProductFilter.ts` |
| Files — pages/routes | kebab-case | `product-detail/page.tsx` |

## Interfaces vs Types

- `interface` for object shapes that may be extended
- `type` for unions, intersections, mapped types, aliases

```ts
// ✅ Interface for component props and data shapes
interface Product {
  id: string
  name: string
  price: number
}

interface ProductCardProps {
  product: Product
  onAddToCart: (id: string) => void
}

// ✅ Type for unions and complex compositions
type Status = 'active' | 'inactive' | 'pending'
type ProductWithCategory = Product & { category: Category }
```

## Import Organization

Order (enforced by ESLint):
1. Node built-in modules (`path`, `fs`)
2. External packages (`react`, `next/link`, `prisma`)
3. Internal absolute imports (`@/components`, `@/lib`)
4. Relative imports (`./ProductCard`, `../utils`)

```ts
// ✅ Correct order
import { useState } from 'react'
import Link from 'next/link'
import { db } from '@/lib/db'
import { ProductCard } from './ProductCard'
```

## Exports

```ts
// ✅ Named exports for utilities and non-default exports
export function formatCurrency(amount: number): string { }
export const MAX_PAGE_SIZE = 100

// ✅ Default export for React components
export default function ProductPage() { }

// ❌ Avoid default exports for utilities (harder to track usage)
export default { formatCurrency, MAX_PAGE_SIZE }
```

## React Component Structure

Follow this order inside component files:

```tsx
// 1. Imports
import { useState } from 'react'
import { Button } from '@/components/ui/button'
import type { Product } from '@/types'

// 2. Types/Interfaces
interface ProductCardProps {
  product: Product
  className?: string
}

// 3. Component function
export function ProductCard({ product, className }: ProductCardProps) {
  // 4. Hooks (all hooks at top)
  const [isExpanded, setIsExpanded] = useState(false)

  // 5. Derived values
  const formattedPrice = formatCurrency(product.price)

  // 6. Handlers
  const handleToggle = () => setIsExpanded(prev => !prev)

  // 7. Return
  return (
    <div className={cn('card', className)}>
      <h3>{product.name}</h3>
      <p>{formattedPrice}</p>
      <Button onClick={handleToggle}>
        {isExpanded ? 'Show less' : 'Show more'}
      </Button>
    </div>
  )
}
```

## Async / Await

```ts
// ✅ Always async/await
async function fetchProduct(id: string): Promise<Product> {
  const product = await db.product.findUnique({ where: { id } })
  if (!product) throw new Error('Product not found')
  return product
}

// ❌ Promise chains
function fetchProduct(id: string): Promise<Product> {
  return db.product.findUnique({ where: { id } })
    .then(product => {
      if (!product) throw new Error('Not found')
      return product
    })
}
```

## Error Handling

```ts
// ✅ Type-safe error handling
async function getProduct(id: string): Promise<{ data: Product | null; error: string | null }> {
  try {
    const product = await db.product.findUnique({ where: { id } })
    return { data: product, error: null }
  } catch (err) {
    const message = err instanceof Error ? err.message : 'Unknown error'
    return { data: null, error: message }
  }
}

// ✅ Zod for input validation
import { z } from 'zod'

const createProductSchema = z.object({
  name: z.string().min(1).max(200),
  price: z.number().positive(),
})

type CreateProductInput = z.infer<typeof createProductSchema>
```

## Explicit Return Types

Required for all exported functions:

```ts
// ✅ Explicit
export function formatDate(date: Date): string { }
export async function getUser(id: string): Promise<User | null> { }

// ❌ Implicit (fine for internals, not exported functions)
export function formatDate(date: Date) { }
```

## Null Handling

```ts
// ✅ Optional chaining + nullish coalescing
const name = user?.profile?.displayName ?? 'Anonymous'

// ✅ Early return on null
function processOrder(order: Order | null) {
  if (!order) return
  // now order is Order (not null)
}

// ❌ Non-null assertion without check
const name = user!.profile!.displayName
```

## Zod Schemas for Validation

Use Zod at all system boundaries (user input, API responses, environment variables):

```ts
// Environment validation
import { z } from 'zod'

const envSchema = z.object({
  DATABASE_URL: z.string().url(),
  SECRET_KEY: z.string().min(32),
  NODE_ENV: z.enum(['development', 'production', 'test']),
})

export const env = envSchema.parse(process.env)
```

# TypeScript Principles

**Applies to:** All Next.js and Astro projects.

## Strict Mode (Mandatory)

All projects must use:
```json
{
  "compilerOptions": {
    "strict": true,
    "noUncheckedIndexedAccess": true,
    "exactOptionalPropertyTypes": true
  }
}
```

## Forbidden Patterns

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
| Files — pages | kebab-case | `product-detail/page.tsx` |

## Interface vs Type

```ts
// ✅ Interface for object shapes that may be extended
interface Product {
  id: string
  name: string
  price: number
}

// ✅ Type for unions, intersections, mapped types
type Status = 'active' | 'inactive' | 'pending'
type ProductWithCategory = Product & { category: Category }
```

## Import Organization

Order (enforced by ESLint):
1. Node built-in modules (`fs`, `path`)
2. External packages (`react`, `next/link`, `@prisma/client`)
3. Internal absolute imports (`@/components`, `@/lib`)
4. Relative imports (`./ProductCard`, `../utils`)

```ts
import { useState } from 'react'
import { db } from '@prisma/client'
import { Button } from '@/components/ui/button'
import { ProductCard } from './ProductCard'
```

## Exports

```ts
// ✅ Named exports for utilities
export function formatCurrency(amount: number): string { }
export const MAX_PAGE_SIZE = 100

// ✅ Default export for React components
export default function ProductPage() { }

// ❌ Don't use default exports for utilities
export default { formatCurrency, MAX_PAGE_SIZE }
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
    .then(product => { ... })
}
```

## Error Handling

Type-safe error handling with Zod:
```ts
import { z } from 'zod'

const createProductSchema = z.object({
  name: z.string().min(1).max(200),
  price: z.number().positive(),
})

type CreateProductInput = z.infer<typeof createProductSchema>

async function handleCreateProduct(input: unknown) {
  const result = createProductSchema.safeParse(input)
  if (!result.success) {
    return { error: result.error.flatten() }
  }
  // result.data is now typed as CreateProductInput
  const product = await db.product.create({ data: result.data })
  return { success: true, product }
}
```

## Explicit Return Types

Required for all exported functions:

```ts
// ✅ Explicit
export function formatDate(date: Date): string { }
export async function getUser(id: string): Promise<User | null> { }

// ❌ Implicit (ok for internals, not exports)
export function formatDate(date: Date) { }
```

## Null / Undefined Handling

```ts
// ✅ Optional chaining + nullish coalescing
const name = user?.profile?.displayName ?? 'Anonymous'

// ✅ Early return on null
function processOrder(order: Order | null) {
  if (!order) return
  // order is now Order (not null)
}

// ❌ Non-null assertion without check
const name = user!.profile!.displayName
```

## React Component Structure

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
  // 4. Hooks (all at top)
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

---

## Full Code Examples

For tsconfig examples, interface/type patterns, import organization, error handling with Zod, component structure, async patterns, and null handling, see `/typescript-reference`

# TypeScript Standards

## Strict Config (Mandatory)

```json
{
  "compilerOptions": {
    "strict": true,
    "noUncheckedIndexedAccess": true,
    "exactOptionalPropertyTypes": true,
    "baseUrl": ".",
    "paths": { "@/*": ["./src/*"] }
  }
}
```

## Forbidden

- `any` → use `unknown` and narrow with type guards
- `// @ts-ignore` → fix the type error
- `// @ts-nocheck` → never
- Type assertions (`as X`) without prior validation

## Naming

| What | Convention | Example |
|------|-----------|---------|
| Types / Interfaces | PascalCase | `ProductDto`, `UserProfile` |
| React Components | PascalCase | `ProductCard` |
| Functions | camelCase | `formatCurrency` |
| Variables | camelCase | `isLoading` |
| Constants | UPPER_CASE | `MAX_RETRIES` |
| Files — utilities | kebab-case | `format-currency.ts` |
| Files — components | PascalCase | `ProductCard.tsx` |
| Files — hooks | `use` prefix | `useProductFilter.ts` |

## Interface vs Type

```ts
// Interface — for object shapes that may be extended
interface Product { id: string; name: string; price: number }

// Type — for unions, intersections, mapped types
type Status = 'active' | 'inactive' | 'pending'
type ProductWithCategory = Product & { category: Category }
```

## Component Structure

```tsx
// 1. Imports
import { useState } from 'react'
import { Button } from '@/components/ui/button'
import type { Product } from '@/types'

// 2. Types
interface ProductCardProps { product: Product; className?: string }

// 3. Component
export function ProductCard({ product, className }: ProductCardProps) {
  // 4. Hooks — all at top
  const [isExpanded, setIsExpanded] = useState(false)
  // 5. Derived values
  const price = formatCurrency(product.price)
  // 6. Handlers
  const handleToggle = () => setIsExpanded(prev => !prev)
  // 7. Return
  return <div className={cn('card', className)}>...</div>
}
```

## Async / Await

```ts
// ✅
async function fetchProduct(id: string): Promise<Product> {
  const product = await db.product.findUnique({ where: { id } })
  if (!product) throw new Error('Not found')
  return product
}
// ❌ Promise chains
```

## Null Handling

```ts
// ✅
const name = user?.profile?.displayName ?? 'Anonymous'

// ✅ Early return
function process(order: Order | null) {
  if (!order) return
  // order is Order here
}

// ❌ Non-null assertion without check
const name = user!.profile!.displayName
```

## Validation with Zod

```ts
import { z } from 'zod'

const createProductSchema = z.object({
  name: z.string().min(1).max(200),
  price: z.number().positive(),
})

type CreateProductInput = z.infer<typeof createProductSchema>

async function handler(input: unknown) {
  const result = createProductSchema.safeParse(input)
  if (!result.success) return { error: result.error.flatten() }
  // result.data is typed as CreateProductInput
}
```

## Explicit Return Types (Exported Functions)

```ts
// ✅
export function formatDate(date: Date): string { ... }
export async function getUser(id: string): Promise<User | null> { ... }
```

## Import Order

1. Node built-ins (`path`, `fs`)
2. External packages (`react`, `next/link`)
3. Internal absolute imports (`@/components`, `@/lib`)
4. Relative imports (`./ProductCard`)

## Exports

```ts
// ✅ Named for utilities
export function formatCurrency(amount: number): string { }

// ✅ Default for React components
export default function ProductPage() { }
```

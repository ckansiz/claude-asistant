# API Contract (OpenAPI ↔ TypeScript) Reference

Use this when implementing or regenerating API contracts between .NET backend and TypeScript frontend.

## Backend Implementation

### XML Doc Comments on Endpoints

```csharp
/// <summary>Get a product by its ID</summary>
/// <param name="id">The product GUID</param>
group.MapGet("/{id:guid}", async (Guid id, ...) => { ... })
    .WithSummary("Get product by ID")
    .Produces<ProductDto>(200)
    .ProducesProblem(404);
```

### Response DTOs — Must Be Explicit

```csharp
// ✅ Explicit DTO — OpenAPI schema includes this
public record ProductDto
{
    public Guid Id { get; init; }
    public string Name { get; init; } = string.Empty;
    public decimal Price { get; init; }
    public string CategoryName { get; init; } = string.Empty;
}

// ❌ Anonymous object — type info is lost
return Results.Ok(new { id = product.Id, name = product.Name });
```

### Route Naming Convention

Kebab-case, resource-oriented:

```
GET    /api/products              → list
GET    /api/products/{id}         → single
POST   /api/products              → create
PUT    /api/products/{id}         → update
DELETE /api/products/{id}         → delete
GET    /api/product-categories    → kebab-case for compound names
```

## Frontend Codegen Workflow

### Setup

Add to `package.json`:

```json
{
  "scripts": {
    "gen:api": "openapi-typescript http://localhost:5000/openapi/v1.json -o src/types/api.generated.ts"
  },
  "devDependencies": {
    "openapi-typescript": "^7.0.0"
  }
}
```

Or use environment variable for backend URL:

```json
"gen:api": "openapi-typescript $BACKEND_URL/openapi/v1.json -o src/types/api.generated.ts"
```

### Rules for Generated File

- `src/types/api.generated.ts` — **never edit manually**
- **DO commit to git** (not in .gitignore) — diff shows what changed in the contract
- File header comment: `// Auto-generated from OpenAPI spec. Run 'npm run gen:api' to update.`

### Workflow: Backend Changes

```bash
# 1. Backend adds/modifies an endpoint
# 2. Start backend locally
dotnet run --project src/{Project}.Provider

# 3. Regenerate frontend types
cd ../frontend
npm run gen:api

# 4. Check for TypeScript errors
npx tsc --noEmit

# 5. Commit both together
git add src/types/api.generated.ts
git commit -m "feat(api): add create product endpoint

- Added POST /api/products endpoint
- Regenerated TypeScript types from OpenAPI spec"
```

### Using Generated Types in Frontend

```ts
// src/types/api.generated.ts usage
import type { components, paths } from '@/types/api.generated'

type Product = components['schemas']['ProductDto']
type CreateProductRequest = components['schemas']['CreateProductCommand']

// Type-safe fetch helper
async function getProduct(id: string): Promise<Product> {
  const res = await fetch(`/api/products/${id}`)
  if (!res.ok) throw new Error('Failed to fetch product')
  return res.json() as Promise<Product>
}
```

## Advanced: Orval (With React Query)

If you need auto-generated React Query hooks in addition to types:

```bash
npm install --save-dev orval
```

Configuration file `orval.config.ts`:

```ts
export default {
  api: {
    input: 'http://localhost:5000/openapi/v1.json',
    output: {
      mode: 'tags-split',
      target: 'src/lib/api/',
      client: 'react-query',
      schemas: 'src/types/api/',
    }
  }
}
```

This generates both types AND TanStack Query hooks:

```ts
// Auto-generated usage
import { useGetProductById, useCreateProduct } from '@/lib/api/products'

export function ProductPage({ id }: { id: string }) {
  const { data: product } = useGetProductById(id)
  const { mutate: createProduct } = useCreateProduct()
  // ...
}
```

## Contract Changes & Type Safety

When a backend DTO field is renamed or removed, the TypeScript compiler catches it after `npm run gen:api`:

```
src/components/ProductCard.tsx:45 - error TS2322: Type '{ id: string; title: string; }'
is not assignable to type 'Product'. Object literal may only specify known properties,
and 'title' does not exist in type 'Product'. Did you mean 'name'?
```

This is a **feature**, not a bug — the type system prevents silent data corruption.

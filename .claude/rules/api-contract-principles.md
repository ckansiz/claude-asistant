# API Contract Principles — OpenAPI ↔ TypeScript Sync

Backend ve frontend arasındaki tip güvenliğini sağlar.

## The Problem

When backend endpoint changes (new field, rename, property removed) → frontend doesn't know about it.
Result: runtime crash, undefined property errors, silent data corruption.

## The Solution: OpenAPI-First

```
.NET Backend          OpenAPI Spec         TypeScript Frontend
(Minimal APIs)   →    /openapi/v1.json  →   src/types/api.generated.ts
(with XML docs)       (auto-generated)      (auto-generated, committed)
```

---

## Backend Requirements

### 1. OpenAPI Endpoint

Each .NET project MUST expose the spec:
```csharp
builder.Services.AddOpenApi();
app.MapOpenApi();           // → /openapi/v1.json
app.MapScalarApiReference(); // → /scalar/v1 (docs UI)
```

### 2. XML Doc Comments (Mandatory)

Every endpoint must have `<summary>` and response type annotation:
```csharp
/// <summary>Get a product by its ID</summary>
group.MapGet("/{id:guid}", async (...) => { ... })
    .Produces<ProductDto>(200)
    .ProducesProblem(404);
```

### 3. Response DTOs (Explicit, Not Anonymous)

```csharp
// ✅ Explicit DTO — OpenAPI schema includes this
public record ProductDto { public Guid Id { get; init; } ... }

// ❌ Anonymous object — type info is lost
return Results.Ok(new { id = product.Id, name = product.Name });
```

### 4. Route Naming (Kebab-case, Resource-Oriented)

```
GET    /api/products              → list all
GET    /api/products/{id}         → get single
POST   /api/products              → create
PUT    /api/products/{id}         → update
DELETE /api/products/{id}         → delete
GET    /api/product-categories    → compound names in kebab-case
```

---

## Frontend Requirements

### 1. Codegen Script

Each frontend project needs `package.json`:
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

### 2. Generated File Rules

- `src/types/api.generated.ts` — **never edit manually**
- **DO commit to git** — diffs show what changed in the contract
- File header: `// Auto-generated from OpenAPI spec. Run 'npm run gen:api' to update.`

### 3. Using Generated Types

```ts
import type { components, paths } from '@/types/api.generated'

type Product = components['schemas']['ProductDto']

async function getProduct(id: string): Promise<Product> {
  const res = await fetch(`/api/products/${id}`)
  return res.json() as Promise<Product>
}
```

---

## Workflow When Backend Changes

```bash
# 1. Make endpoint change in .NET
# 2. Start backend
dotnet run --project src/{Project}.Provider

# 3. Regenerate frontend types
cd ../frontend
npm run gen:api

# 4. TypeScript compiler catches contract breaks
npx tsc --noEmit

# 5. Commit both together
git add src/types/api.generated.ts
git commit -m "feat(api): add create product endpoint

- Added POST /api/products endpoint
- Regenerated TypeScript types from OpenAPI spec"
```

---

## Type Safety in Action

When a DTO field is renamed or removed, TypeScript compiler catches it **immediately after** `npm run gen:api`:

```
error TS2322: Property 'title' does not exist in type 'Product'.
Did you mean 'name'?
```

This is **intentional** — the type system prevents silent data corruption.

---

## Advanced: Orval (Auto-Generated React Query Hooks)

`openapi-typescript` generates types only. For React Query hooks too:

```bash
npm install --save-dev orval
```

Config: `orval.config.ts`
```ts
export default {
  api: {
    input: 'http://localhost:5000/openapi/v1.json',
    output: {
      mode: 'tags-split',
      target: 'src/lib/api/',
      client: 'react-query',
    }
  }
}
```

Result: Auto-generated hooks like `useGetProductById()`, `useCreateProduct()`.

---

## Full Code Examples & Scenarios

For XML doc examples, response DTO patterns, Orval config, and codegen workflow bash scripts, see `/api-contract-reference`

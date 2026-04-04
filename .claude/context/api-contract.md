# API Contract Standards (OpenAPI ↔ TypeScript)

Ensures backend changes are immediately caught by the TypeScript compiler on the frontend.

## How It Works

```
.NET Backend       →    /openapi/v1.json    →    src/types/api.generated.ts
(XML doc comments)      (auto-generated)         (auto-generated, committed to git)
```

## Backend Requirements

### 1. Expose the spec

```csharp
builder.Services.AddOpenApi();
app.MapOpenApi();            // → /openapi/v1.json
app.MapScalarApiReference(); // → /scalar/v1
```

### 2. Every endpoint needs XML summary + Produces annotations

```csharp
/// <summary>Get a product by its ID</summary>
group.MapGet("/{id:guid}", async (...) => { ... })
    .WithSummary("Get product by ID")
    .Produces<ProductDto>(200)
    .ProducesProblem(404);
```

### 3. Explicit DTO — never anonymous objects

```csharp
// ✅ Schema appears in OpenAPI
public record ProductDto { public Guid Id { get; init; } ... }

// ❌ Type info lost
return Results.Ok(new { id = product.Id });
```

### 4. Route naming

```
GET    /api/products           → list
GET    /api/products/{id}      → single
POST   /api/products           → create
PUT    /api/products/{id}      → update
DELETE /api/products/{id}      → delete
GET    /api/product-categories → kebab-case compound names
```

## Frontend Requirements

### Codegen script in `package.json`

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

### Generated file rules

- `src/types/api.generated.ts` — **never edit manually**
- **Commit to git** — diffs show contract changes

### Using generated types

```ts
import type { components } from '@/types/api.generated'

type Product = components['schemas']['ProductDto']

async function getProduct(id: string): Promise<Product> {
  const res = await fetch(`/api/products/${id}`)
  return res.json() as Promise<Product>
}
```

## Workflow When Backend Changes

```bash
# 1. Change endpoint in .NET
# 2. Start backend: dotnet run --project src/{Project}.Provider
# 3. Regenerate types: cd frontend && npm run gen:api
# 4. TypeScript compiler catches breaks: npx tsc --noEmit
# 5. Fix + commit both together
```

TypeScript errors after `gen:api` are **intentional** — the type system caught a contract break.

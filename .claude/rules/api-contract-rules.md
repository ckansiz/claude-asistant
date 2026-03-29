# API Contract Rules — OpenAPI ↔ TypeScript Sync

Backend ve frontend arasındaki tip güvenliğini sağlamak için her projede uygulanır.

## Sorun

Backend endpoint değişince (yeni alan, rename, kaldırılan property) frontend bundan haberdar olmuyor.
Sonuç: runtime crash, undefined property errors, silent data corruption.

## Çözüm: OpenAPI-First

```
.NET Backend          OpenAPI Spec         TypeScript Frontend
──────────────   →   /openapi/v1.json  →   src/types/api.generated.ts
(endpoints)           (auto-generated)      (auto-generated, committed)
```

---

## Backend (.NET) Gereksinimleri

### 1. OpenAPI Spec Endpoint

Her .NET projesinde zorunlu (`Program.cs`):

```csharp
builder.Services.AddOpenApi();
// ...
app.MapOpenApi(); // → /openapi/v1.json
app.MapScalarApiReference(); // → /scalar/v1 (docs UI)
```

### 2. XML Doc Comments — Zorunlu

Her endpoint `<summary>` ve response type annotation içermeli:

```csharp
/// <summary>Get a product by its ID</summary>
/// <param name="id">The product GUID</param>
group.MapGet("/{id:guid}", async (Guid id, ...) => { ... })
    .WithSummary("Get product by ID")
    .Produces<ProductDto>(200)
    .ProducesProblem(404);
```

### 3. Response DTO Zorunluluğu

**Anonim obje döndürme.** Her response explicit bir DTO sınıfı olmalı:

```csharp
// ✅ Explicit DTO — OpenAPI schema'ya girer
public record ProductDto
{
    public Guid Id { get; init; }
    public string Name { get; init; } = string.Empty;
    public decimal Price { get; init; }
    public string CategoryName { get; init; } = string.Empty;
}

// ❌ Anonim — tip bilgisi kaybolur
return Results.Ok(new { id = product.Id, name = product.Name });
```

### 4. Route Naming

Kebab-case, resource-oriented:

```
GET    /api/products              → list
GET    /api/products/{id}         → single
POST   /api/products              → create
PUT    /api/products/{id}         → update
DELETE /api/products/{id}         → delete
GET    /api/product-categories    → kebab-case for compound names
```

---

## Frontend (Next.js / Astro) Gereksinimleri

### 1. Codegen Script

Her frontend projesinde `package.json`'a ekle:

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

Veya backend URL env'den:
```json
"gen:api": "openapi-typescript $BACKEND_URL/openapi/v1.json -o src/types/api.generated.ts"
```

### 2. Generated File Kuralları

- `src/types/api.generated.ts` — **elle düzenlenmez**
- `.gitignore`'a eklenmez — **commit'lenir** (CI'da regenerate edilmez, diff'den anlaşılsın)
- Dosya başına yorum: `// Auto-generated from OpenAPI spec. Run 'npm run gen:api' to update.`

### 3. API Çağrıları Generated Tiplerle

```ts
// src/types/api.generated.ts kullanımı
import type { components, paths } from '@/types/api.generated'

type Product = components['schemas']['ProductDto']
type CreateProductRequest = components['schemas']['CreateProductCommand']

// Fetch helper with types
async function getProduct(id: string): Promise<Product> {
  const res = await fetch(`/api/products/${id}`)
  if (!res.ok) throw new Error('Failed to fetch product')
  return res.json() as Promise<Product>
}
```

---

## Codegen Akışı

### Senaryo 1: Backend'de endpoint eklendi / değişti

```bash
# 1. Backend değişikliğini yap
# 2. Backend'i çalıştır
dotnet run --project src/{Project}.Provider

# 3. Frontend'de tipleri regenerate et
cd ../frontend
npm run gen:api

# 4. TypeScript hatalarını düzelt (varsa)
npx tsc --noEmit

# 5. Her ikisini birlikte commit'le
git add src/types/api.generated.ts
git commit -m "feat(api): add create product endpoint

- Added POST /api/products endpoint
- Regenerated TypeScript types from OpenAPI spec"
```

### Senaryo 2: DTO alanı değişti (rename / removed)

TypeScript compiler `api.generated.ts` güncellendikten sonra kullanan kodları flagler.
Bu bir **feature, not a bug** — tip sistemi kontrat kırılmasını yakalar.

---

## check-api-drift.sh — Claude Code Hook

`smurfs/scripts/check-api-drift.sh` betiği bir `.cs` endpoint/handler dosyası değiştirildiğinde çalışır:

1. Değiştirilen dosyanın `Endpoints/` veya `Handlers/` içinde olup olmadığını kontrol eder
2. Backend ayaktaysa spec'i çeker
3. Frontend `api.generated.ts` checksum'ını karşılaştırır
4. Farklıysa kullanıcıyı uyarır: `⚠️ API contract changed — run npm run gen:api in frontend`

---

## Orval (Gelişmiş Alternatif)

`openapi-typescript` yalnızca tipler üretir. Eğer React Query hooks de istiyorsan:

```bash
npm install --save-dev orval
```

```ts
// orval.config.ts
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

Bu konfigürasyonla `npm run gen:api` hem tipler hem TanStack Query hooks üretir:

```ts
// Auto-generated usage
import { useGetProductById, useCreateProduct } from '@/lib/api/products'

export function ProductPage({ id }: { id: string }) {
  const { data: product } = useGetProductById(id)
  const { mutate: createProduct } = useCreateProduct()
  // ...
}
```

---

## Handy + Painter Smurf İçin Özet

**Handy Smurf (backend değişikliği sonrası):**
> "Bu endpoint değişikliği frontend'de type drift yaratır. Painter Smurf'a `npm run gen:api` çalıştırmasını söyle."

**Painter Smurf (frontend'de API entegrasyonu):**
> 1. `npm run gen:api` çalıştır
> 2. `src/types/api.generated.ts`'den tipleri import et
> 3. Elle tip yazma — generated tiplerden türet

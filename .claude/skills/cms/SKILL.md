---
name: cms
description: This skill should be used when the user asks to "set up Strapi", "integrate Sanity", "use PayloadCMS", "add a headless CMS", "model content types", "connect frontend to CMS", or works on content-driven site features (blog, pages, products managed by non-devs).
version: 1.0.0
---

# Headless CMS Standards (Strapi / Sanity / Payload)

Apply when a client needs to edit content without developer help. The site stays on Astro / Next.js; the CMS lives in a separate app or service.

## When to Pick What

| CMS | Best for | Why |
|-----|----------|-----|
| **Strapi v5** | Client owns content, Node.js hosting available | Self-hostable, TR clients OK with it, used in wcard-website |
| **Sanity** | Editorial workflow, real-time collaboration | Best UX for content teams, generous free tier |
| **PayloadCMS** | TypeScript-first, integrated with Next.js | CMS + admin as part of the Next.js app, same DB |
| Directus | Existing PostgreSQL content | Auto-generates admin from your schema |

Skip WordPress for new projects unless the client explicitly demands it.

## Strapi v5 (default for Wesoco-style clients)

Separate app. Deploys independently. REST + GraphQL out of the box.

### Setup

```bash
npx create-strapi-app@latest cms --quickstart  # SQLite for dev
# Production: switch to PostgreSQL via config/database.ts
```

### Content Type Structure

Content types modeled in Strapi admin, persisted as JSON schemas under `src/api/{type}/content-types/{type}/schema.json`. Commit these — they're source of truth.

```json
// src/api/article/content-types/article/schema.json
{
  "kind": "collectionType",
  "collectionName": "articles",
  "info": { "singularName": "article", "pluralName": "articles", "displayName": "Article" },
  "options": { "draftAndPublish": true },
  "attributes": {
    "title": { "type": "string", "required": true },
    "slug": { "type": "uid", "targetField": "title", "required": true },
    "content": { "type": "blocks" },
    "cover": { "type": "media", "allowedTypes": ["images"] },
    "locale": { "type": "enumeration", "enum": ["tr", "en"] }
  }
}
```

### Fetching from Next.js / Astro

```ts
// lib/strapi.ts
const STRAPI_URL = process.env.NEXT_PUBLIC_STRAPI_URL!
const STRAPI_TOKEN = process.env.STRAPI_API_TOKEN!  // read-only token

export async function fetchStrapi<T>(path: string, params?: Record<string, string>): Promise<T> {
  const qs = params ? '?' + new URLSearchParams(params) : ''
  const res = await fetch(`${STRAPI_URL}/api${path}${qs}`, {
    headers: { Authorization: `Bearer ${STRAPI_TOKEN}` },
    next: { revalidate: 60 },  // ISR — 60s cache
  })
  if (!res.ok) throw new Error(`Strapi ${path} → ${res.status}`)
  return res.json() as Promise<T>
}

// Usage
const { data } = await fetchStrapi<{ data: Article[] }>('/articles', {
  'populate': 'cover',
  'filters[locale][$eq]': 'tr',
  'sort': 'publishedAt:desc',
})
```

### Preview Mode

Strapi draft content → frontend preview. Use Next.js Draft Mode:

```ts
// app/api/preview/route.ts
import { draftMode } from 'next/headers'
import { redirect } from 'next/navigation'

export async function GET(req: Request) {
  const { searchParams } = new URL(req.url)
  if (searchParams.get('secret') !== process.env.PREVIEW_SECRET) return new Response('Invalid', { status: 401 })
  ;(await draftMode()).enable()
  redirect(searchParams.get('slug') ?? '/')
}
```

## Sanity

Content lives in Sanity's cloud. Frontend fetches via GROQ queries. Best editorial UX in the market.

```bash
npm create sanity@latest
```

```ts
// sanity.config.ts — schemas defined in code
import { defineConfig } from 'sanity'
import { structureTool } from 'sanity/structure'

export default defineConfig({
  projectId: 'xxx',
  dataset: 'production',
  plugins: [structureTool()],
  schema: {
    types: [
      {
        name: 'article',
        type: 'document',
        fields: [
          { name: 'title', type: 'string', validation: (r) => r.required() },
          { name: 'slug', type: 'slug', options: { source: 'title' } },
          { name: 'content', type: 'blockContent' },
        ],
      },
    ],
  },
})
```

```ts
// Frontend fetch
import { createClient } from '@sanity/client'

const client = createClient({
  projectId: process.env.NEXT_PUBLIC_SANITY_PROJECT_ID,
  dataset: 'production',
  apiVersion: '2024-12-01',
  useCdn: true,
})

const articles = await client.fetch(`*[_type == "article" && locale == $locale] | order(_createdAt desc)`, { locale: 'tr' })
```

## PayloadCMS

TypeScript-native, runs inside the Next.js app, uses the same Postgres. No separate service to deploy.

```bash
npx create-payload-app@latest
```

```ts
// payload.config.ts
import { buildConfig } from 'payload'
import { postgresAdapter } from '@payloadcms/db-postgres'

export default buildConfig({
  db: postgresAdapter({ pool: { connectionString: process.env.DATABASE_URL } }),
  collections: [
    {
      slug: 'articles',
      admin: { useAsTitle: 'title' },
      fields: [
        { name: 'title', type: 'text', required: true },
        { name: 'slug', type: 'text', required: true, unique: true },
        { name: 'content', type: 'richText' },
        { name: 'locale', type: 'select', options: ['tr', 'en'] },
      ],
    },
  ],
})
```

```ts
// Direct DB access inside the same app (no HTTP)
import { getPayload } from 'payload'
import config from '@payload-config'

const payload = await getPayload({ config })
const { docs: articles } = await payload.find({ collection: 'articles', where: { locale: { equals: 'tr' } } })
```

## Content Modeling Principles

- **One collection = one entity** (articles, products, team members). Never overload types.
- **Slugs are required + unique** — the URL contract.
- **Locale field on multi-language content** (not separate collections per locale).
- **Separate `publishedAt` from `createdAt`** — editors schedule posts.
- **Images via CMS media library** — never store file paths as strings.
- **Rich text:** prefer block-based (Strapi Blocks, Sanity PortableText, Payload Lexical) over Markdown for non-dev editors.

## Deployment

- **Strapi:** separate Fly.io / Railway / Coolify app, PostgreSQL + S3-compatible storage for media
- **Sanity:** hosted by Sanity (no deploy needed)
- **Payload:** deploys with the Next.js app, needs Postgres + media storage (S3 / R2)

See `deployment` skill for host choices.

## Security

- Never expose write tokens to the frontend — only read-only tokens
- Strapi: create a Read-Only API token in admin, set as `STRAPI_API_TOKEN`
- Rate limit public CMS endpoints (CDN layer)
- Admin panel behind auth — never `0.0.0.0` without IP allowlist

## Companion Skills

- `nextjs` / `astro` — frontend data fetching patterns
- `deployment` — hosting CMS + media
- `i18n` — multi-locale content
- `security` — API tokens, admin access

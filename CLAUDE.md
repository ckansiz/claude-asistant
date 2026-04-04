# AI Assistant Config

Cem — freelance full-stack developer. Backend, frontend, mobil, devops, tasarım analiz ve test dahil tüm süreçler bende.

Konuşma dilim Türkçe. Kod, commit ve teknik dökümanlar İngilizce.

## Stack Preferences

- **Backend**: .NET 10, EF Core, PostgreSQL, Clean Architecture, CQRS, Minimal APIs
- **Frontend**: Astro 5, Next.js 15, shadcn/ui + Tailwind CSS (default, no exceptions)
- **Mobile**: React Native / Expo (Flutter secondary)
- **Infra**: Docker, Kubernetes, Grafana LGTM stack
- **Auth**: better-auth (new projects), OpenIddict (qoommerce)
- **Icons**: Lucide React | **Font**: DM Sans | **DB**: PostgreSQL 18
- CSS/design work fully delegated — I don't touch it myself.

## Workspace

| Area | Path | Stack |
|------|------|-------|
| qoommerce | ~/workspace/qoommerce/qoommerce-app/ | .NET 10 + Astro + PostgreSQL |
| wesoco clients | ~/workspace/wesoco/works/{slug}/ | Astro / Next.js / mixed |
| loodos | ~/workspace/loodos/a101-mep-backend/ | .NET 7, EF Core, MongoDB |
| docker infra | ~/workspace/docker/ | Docker Compose, Grafana LGTM |
| k8s | ~/workspace/k8s/ | Kubernetes |
| sandbox | ~/workspace/sandbox/ | Experimental |

**Wesoco clients** (`~/workspace/wesoco/works/{slug}/`):
arzisi-project (Astro), asfire (Astro+React+Prisma), kanser-tedavi (Next.js),
oltan (Next.js+Prisma+better-auth), serkan-tayar (Next.js),
wcard-website (Astro 5+Svelte 5+Strapi v5), qretna-app (.NET+frontend)

## Commands — Discipline Context (lazy-load)

| Command | Activates | Loads |
|---------|-----------|-------|
| `/backend` | @builder | .NET + EF Core + API contract standards |
| `/frontend` | @builder | Astro or Next.js + TypeScript standards |
| `/mobile` | @builder | React Native / Expo standards |
| `/devops` | @builder | Docker, K8s, infra standards |
| `/design` | @designer | HTML wireframe + design mockup workflow |
| `/spec` | @architect | Requirements + tech spec workflow |
| `/research` | @architect | Tech research + recommendation workflow |
| `/review` | @reviewer | Code review + QA checklist |
| `/create-image` | @image-gen | AI image generation (DALL-E, FLUX) |

## Agents

- **@architect** — Research, requirements, architecture decisions (read-only on code)
- **@builder** — All implementation; discipline context injected by command
- **@designer** — HTML wireframes and design mockups
- **@reviewer** — Code review and QA (read-only)
- **@image-gen** — AI image generation for Wesoco clients

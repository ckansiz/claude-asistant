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

## Architecture: Agents + Skills + Commands

**Agents** role-only (who acts). **Skills** technical + procedural knowledge (what + how); auto-load by description match. **Commands** thin slash-entry points that activate the right agent + trigger skills.

### Agents (`.claude/agents/`)

- **@architect** — Research, requirements, architecture, orchestration (read-only on code)
- **@builder** — Full-stack implementation; stack standards arrive via skills
- **@designer** — HTML wireframes and design mockups
- **@reviewer** — Code review and QA (read-only)
- **@image-gen** — AI image generation for Wesoco clients

### Skills (`.claude/skills/`)

Stack:
- `dotnet`, `astro`, `nextjs`, `react-native`, `flutter`, `devops`

Cross-cutting:
- `typescript`, `database`, `security`, `testing`, `commits`, `git-workflow`, `api-contract`

Design / spec / review:
- `design-workflow`, `image-generation`, `spec-writing`, `tech-research`, `code-review`

Ship & run:
- `deployment`, `seo`, `performance`

Client-facing features:
- `forms`, `payments`, `cms`, `i18n`

Process & orchestration:
- `orchestration`, `plan-mode`, `new-feature`, `bug-fix`, `hotfix`, `visual-regression`

Freelance practice:
- `client-handoff`

### Commands (`.claude/commands/`)

| Command | Activates | Skills it triggers |
|---------|-----------|--------------------|
| `/dotnet` | @builder | `dotnet`, `database`, `api-contract`, `security`, `testing`, `commits` |
| `/astro` | @builder | `astro`, `typescript`, `database`, `security`, `testing`, `commits` |
| `/nextjs` | @builder | `nextjs`, `typescript`, `database`, `security`, `testing`, `commits` |
| `/mobile` | @builder | `react-native` (or `flutter`), `typescript`, `commits` |
| `/devops` | @builder | `devops`, `security`, `commits` |
| `/design` | @designer | `design-workflow` |
| `/spec` | @architect | `spec-writing` |
| `/research` | @architect | `tech-research` |
| `/review` | @reviewer | `code-review` + stack skill |
| `/create-image` | @image-gen | `image-generation` |
| `/plan` | — | `plan-mode` |
| `/new-feature` | orchestrator loop | `new-feature`, `orchestration`, `plan-mode` |
| `/bug-fix` | orchestrator loop | `bug-fix`, `orchestration`, `plan-mode` |
| `/hotfix` | orchestrator loop | `hotfix`, `orchestration` |
| `/ui-test` | @reviewer | `visual-regression` |

> `/frontend` is deprecated — use `/astro` or `/nextjs` instead.

## Rules

### Plan Mode (Mandatory for non-trivial work)
Before writing code: list affected files, summarize changes, get user approval. No edits, no new files, no destructive commands without approval. See `plan-mode` skill.

### Definition of Done
After any code change, run **in order**:
1. Type check / static analysis
2. Unit tests
3. Integration / API tests (if backend or API changed)
4. Build
5. Atomic Conventional Commits (see `commits` skill)
6. Branch pushed

Any failure → stop, no further changes, report honestly. Task is not "done" until every gate passes. See `orchestration` skill for stack-specific commands and the Production Readiness Checklist.

### Destructive Command Guard
`.claude/hooks/safety-check.mjs` auto-blocks destructive SQL (DROP/DELETE/TRUNCATE), `rm -rf`, `git push --force`, `git reset --hard`, migration rollback/reset, seed scripts, `docker volume rm`, `docker system prune`, `docker-compose down -v`, `kubectl delete ns/pv/--all`, `fly apps destroy`, `vercel remove -y`, etc. These require explicit user approval even when intended.

### Git
- Never commit directly to `main` — work on `feat/`, `fix/`, `hotfix/`, `refactor/` branches
- Atomic commits: one logical change per commit
- Conventional Commits format (see `commits` skill): `type(scope): description`
- Code review required before PR merge (hotfix exempt — review happens post-merge)
- PR body includes Production Readiness checklist + Turkish `## Changelog` section for TR clients
- Post-merge: smoke test critical paths

### Reports & Handoffs
When roles hand work between each other (orchestrator → @builder → @reviewer), use the report formats in `orchestration` skill: Builder Handoff Report, Code Review Report, Test Report. Never report "done" without passing quality gates.

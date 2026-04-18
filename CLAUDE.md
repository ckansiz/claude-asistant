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

## Architecture: Agents + Skills

**Agents** role-only (who acts, who can edit). **Skills** technical + procedural knowledge (what + how); auto-load by description match and are invocable directly by name (`/skill-name` or natural language like "write a spec"). No separate commands layer — every slash command *is* a skill.

### Agents (`.claude/agents/`)

- **@architect** — Discovery (intake), research, specs, architecture, orchestrator during loops. Read-only on production code; may write under `docs/`.
- **@builder** — Full-stack implementation. Only agent allowed to edit production source. Must resolve every edge-case row.
- **@reviewer** — Code review + test execution (unit/integration/smoke/E2E/visual). Audits the edge-case table. Read-only.
- **@designer** — HTML wireframes + mockups. Must cover empty/loading/error/long-content states on both viewports.
- **@image-gen** — AI image generation for Wesoco clients.

Client-facing reports (`client-report`) and handoffs (`client-handoff`) have **no dedicated agent** — the main session produces them directly by invoking the skill. These are freelancer-to-client communication, not an internal loop role.

### Skills (`.claude/skills/`)

Stack:
- `dotnet`, `astro`, `nextjs`, `react-native`, `flutter`, `devops`

Cross-cutting:
- `typescript`, `database`, `security`, `testing`, `commits`, `git-workflow`, `api-contract`

Discovery & planning:
- `intake`, `edge-cases`, `spec-writing`, `tech-research`, `plan-mode`

Design / review:
- `design-workflow`, `image-generation`, `code-review`

Ship & run:
- `deployment`, `seo`, `performance`

Client-facing features:
- `forms`, `payments`, `cms`, `i18n`

Process & orchestration:
- `orchestration`, `new-feature`, `bug-fix`, `hotfix`, `visual-regression`

Freelance practice:
- `client-handoff`, `client-report`

### Invocation

Skills are invoked three ways — pick whichever is faster:
- **Slash**: `/skill-name` (e.g. `/intake`, `/astro`, `/new-feature`)
- **Natural language**: "write a spec for X", "review this PR", "checkout formunu düzelt" — the harness auto-matches by skill description
- **Agent delegation**: an active agent (orchestrator / @architect / @builder / @reviewer) invokes skills on behalf of the user

Stack entry points (`astro`, `nextjs`, `dotnet`, `react-native`, `flutter`, `devops`) activate @builder and auto-load the relevant cross-cutting skills (`typescript`, `database`, `security`, `testing`, `commits`, `api-contract` as applicable).

Workflow entry points (`new-feature`, `bug-fix`, `hotfix`) start the orchestration loop described in the `orchestration` skill.

Discovery / planning (`intake`, `spec-writing`, `plan-mode`, `tech-research`, `edge-cases`) run read-only; no production code edited.

Review / test (`code-review`, `testing`, `visual-regression`) run via @reviewer, read-only.

Client communication (`client-report`, `client-handoff`) run in the main session, no agent.

## End-to-End Freelance Flow

Every non-trivial job flows through these phases. Each phase is a skill (invoke via slash or keyword).

1. **Intake / Discovery** — `intake` + `edge-cases` → `docs/intake/{date}-{slug}.md`
2. **Spec** (XL only) — `spec-writing` + `edge-cases` → `docs/requirements.md` + `docs/tech-spec.md`
3. **Plan** — `plan-mode` + `edge-cases`
4. **Build** — stack skill (`astro` / `nextjs` / `dotnet` / `react-native` / `flutter` / `devops`) + `commits`
5. **Review** — `code-review` + relevant stack skill
6. **Test** — `testing` (unit + integration + smoke/E2E) + `visual-regression` for UI
7. **Ship** — `commits` + `git-workflow` + `deployment`
8. **Report** — `client-report {daily|delivery|weekly|incident|handoff}`

`new-feature`, `bug-fix`, `hotfix` wrap phases 1–8 as orchestrated loops. See `orchestration` skill for the Intake Gate rules (when intake is mandatory vs skippable).

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

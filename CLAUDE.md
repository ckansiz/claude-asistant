# AI Assistant Config

Freelance AI-assisted engineering workspace. Agent + Skill architecture tuned for full-stack delivery (discovery → build → ship → report).

This file is **template-managed** — it is overwritten by `scripts/sync-eng-team.sh`. Project-specific context (identity, stack preferences, workspace map, client list, ADRs) lives under `.claude/memory/` and is never touched by sync.

> **First-time setup**: populate `.claude/memory/profile.md`, `.claude/memory/workspace.md`, and `.claude/memory/clients/` for this project. See `.claude/memory/README.md`.

## Stack Defaults

Treat these as **suggested defaults**, not hard rules — override in `.claude/memory/profile.md` for this project.

- **Backend**: .NET 10, EF Core, PostgreSQL, Clean Architecture, CQRS, Minimal APIs
- **Frontend**: Astro 5, Next.js 15, shadcn/ui + Tailwind CSS
- **Mobile**: React Native / Expo (Flutter secondary)
- **Infra**: Docker, Kubernetes, Grafana LGTM stack
- **Auth**: better-auth (new projects), OpenIddict (legacy)
- **Icons**: Lucide React | **Font**: DM Sans | **DB**: PostgreSQL 18

## Project Context

Project identity, workspace paths, client roster, and team conventions are **not** stored in this file — read them at runtime from:

- `.claude/memory/profile.md` — developer identity, language preferences, delegation rules
- `.claude/memory/workspace.md` — project roots, path keywords, stack-per-project
- `.claude/memory/clients/` — one file per client (stack, branding, deploy target, constraints)
- `.claude/memory/decisions/` — ADRs for this project

If any of these files is missing, prompt the user to fill them before proceeding with non-trivial work.

## Architecture: Agents + Skills

**Agents** role-only (who acts, who can edit). **Skills** technical + procedural knowledge (what + how); auto-load by description match and are invocable directly by name (`/skill-name` or natural language like "write a spec"). No separate commands layer — every slash command *is* a skill.

### Agents (`.claude/agents/`)

- **@architect** — Discovery (intake), research, specs, architecture, orchestrator during loops. Read-only on production code; may write under `docs/`.
- **@builder** — Full-stack implementation. Only agent allowed to edit production source. Must resolve every edge-case row.
- **@reviewer** — Code review + test execution (unit/integration/smoke/E2E/visual). Audits the edge-case table. Read-only.
- **@designer** — HTML wireframes + mockups. Must cover empty/loading/error/long-content states on both viewports.
- **@image-gen** — AI image generation (optional, stack-agnostic; used by `image-generation` skill).

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

Sprint & orchestration:
- `sprint`, `retro`, `orchestration`, `new-feature`, `bug-fix`, `hotfix`, `visual-regression`

Freelance practice:
- `client-handoff`, `client-report`

### Invocation

Skills are invoked three ways — pick whichever is faster:
- **Slash**: `/skill-name` (e.g. `/intake`, `/astro`, `/new-feature`)
- **Natural language**: "write a spec for X", "review this PR" — the harness auto-matches by skill description
- **Agent delegation**: an active agent (orchestrator / @architect / @builder / @reviewer) invokes skills on behalf of the user

Stack entry points (`astro`, `nextjs`, `dotnet`, `react-native`, `flutter`, `devops`) activate @builder and auto-load the relevant cross-cutting skills (`typescript`, `database`, `security`, `testing`, `commits`, `api-contract` as applicable).

Workflow entry points (`new-feature`, `bug-fix`, `hotfix`) start the orchestration loop described in the `orchestration` skill.

Discovery / planning (`intake`, `spec-writing`, `plan-mode`, `tech-research`, `edge-cases`) run read-only; no production code edited.

Review / test (`code-review`, `testing`, `visual-regression`) run via @reviewer, read-only.

Client communication (`client-report`, `client-handoff`) run in the main session, no agent.

## End-to-End Freelance Flow

Every non-trivial job flows through these phases inside a **sprint folder** (`docs/sprints/{YYYY-MM-DD}-{client}-{slug}/`). Each phase is a skill (invoke via slash or keyword).

0. **Sprint Init** — `sprint` → folder created from `docs/sprints/_template/`, `00-sprint.md` filled, `04-decisions.md` seeded
1. **Intake / Discovery** — `intake` + `edge-cases` → `01-intake.md`
2. **Spec** (XL only) — `spec-writing` + `edge-cases` → `02-spec.md`
3. **Plan** — `plan-mode` + `edge-cases` → `03-plan.md`
4. **Build** — stack skill (`astro` / `nextjs` / `dotnet` / `react-native` / `flutter` / `devops`) + `commits` → `05-handoffs/builder-report.md`
5. **Review** — `code-review` + relevant stack skill → `05-handoffs/review-report.md`
6. **Test** — `testing` (unit + integration + smoke/E2E) + `visual-regression` for UI → `05-handoffs/test-report.md`
7. **Ship** — `commits` + `git-workflow` + `deployment` → `06-delivery.md`
8. **Report** — `client-report {daily|delivery|weekly|incident|handoff}`
9. **Retro** — `retro` → `07-retro.md` (full, İyi/Kötü/Aksiyon) or `02-mini-retro.md` (hotfix, root cause/why missed/prevention) → aksiyonlar applied → `08-system-updates/SUMMARY.md` links

`new-feature`, `bug-fix`, `hotfix` wrap phases 0–9 as orchestrated loops. See `orchestration` skill for the Intake Gate rules (when intake is mandatory vs skippable).

## Sprint & Retro

Every delivered job is a **sprint**. Delivery-based (not time-based): a 2-day fix and a 2-week feature are each one sprint. See `docs/sprints/README.md` and `sprint` / `retro` skills.

**Size thresholds:**

| Size | Scope | Sprint folder | Retro |
|------|-------|---------------|-------|
| S | <4h, trivial, single file, typo/copy/config | skip | skip |
| M | 1–3 days, one feature/fix | required | full |
| L | 3–10 days, multi-component | required | full |
| XL | >10 days, spec-driven | required | full + mid-sprint check |
| Hotfix | any duration, prod-critical | required (mini) | **mini (mandatory)** |

**Retro contract**: every M+ retro produces ≤3 concrete aksiyonlar. Each aksiyon has a type (`skill` / `CLAUDE.md` / `memory`) and a target file. Aksiyonlar are applied on `chore/retro-{sprint-slug}-{n}` branches and linked in `08-system-updates/SUMMARY.md`. **Sprint is not closed until every aksiyon is applied or explicitly backlogged.**

**Hotfix mini-retro is non-negotiable**: the entire reason hotfix defers full review is that mini-retro compensates. Skipping it = pure tech debt.

**Decisions log (`04-decisions.md`)**: every key trade-off gets a timestamped line — `[YYYY-MM-DD HH:MM] <agent>: <decision> — <why>`. Undocumented decisions surface as retro findings.

## Team Roles (in sprint context)

| Agent | Sprint role |
|-------|-------------|
| @architect | Sprint lifecycle owner. Opens folder (Phase 0), runs close checklist, facilitates retro (Phase 9). Orchestrator — only voice to user. |
| @builder | Appends implementation trade-offs to `04-decisions.md`. Writes `05-handoffs/builder-report.md`. |
| @reviewer | Writes `05-handoffs/review-report.md` + `test-report.md`. Maintains cross-sprint "patterns observed" in memory → retro input. |
| @designer | Appends UX/layout decisions to `04-decisions.md`. Mock links referenced from `03-plan.md`. |
| Main session | Writes `06-delivery.md` and client-facing parts. Signs off retro aksiyonları. |

## Rules

### Plan Mode (Always on)
**This workspace runs in plan mode at all times.** Every task — trivial or not — starts with a plan. No edits, no new files, no destructive commands until the user explicitly approves the plan. Flow: understand request → present plan (affected files, summary of changes, risks) → wait for approval → execute. If the user's message is a question or clarification, answer it directly without a plan; plans are only required before taking action. See `plan-mode` skill.

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
- PR body includes Production Readiness checklist + localized `## Changelog` section when the project requires it
- Post-merge: smoke test critical paths

### Reports & Handoffs
When roles hand work between each other (orchestrator → @builder → @reviewer), use the report formats in `orchestration` skill: Builder Handoff Report, Code Review Report, Test Report. Never report "done" without passing quality gates.

## Template Maintenance

This repo (`eng-team`) is the **upstream template**. Projects bootstrap from it and periodically sync managed files.

- **Bootstrap** (new project): `scripts/bootstrap.sh` clones managed paths into a target project and writes a starter `.claude/memory/` skeleton.
- **Sync** (existing project): `scripts/sync-eng-team.sh` updates managed paths to the latest upstream version, leaving `.claude/memory/`, project sprint folders, and `.claude/settings.local.json` untouched.
- **Managed paths**: listed in `.eng-team.manifest`. Anything outside the manifest is considered project-local and never touched by sync.

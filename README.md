# eng-team

A Claude Code workspace template for freelance full-stack delivery. It ships a curated set of **agents**, **skills**, **hooks**, and **sprint templates** that guide a job from intake → spec → build → review → ship → retro — with guardrails (plan mode, destructive-command guard, definition-of-done gates) baked in.

This repo is both the **upstream template** (pulled by downstream projects) and a **reference implementation** you can read to understand how the pieces fit together.

> **Deep dive**: [`CLAUDE.md`](CLAUDE.md) has the full agent + skill + sprint + rules reference. This README covers setup and day-to-day workflow.

---

## Table of contents

1. [What you get](#what-you-get)
2. [Prerequisites](#prerequisites)
3. [Install into a new project](#install-into-a-new-project)
4. [Update an existing project (sync)](#update-an-existing-project-sync)
5. [First-run checklist](#first-run-checklist)
6. [Daily workflow](#daily-workflow)
7. [Managed vs. project-local paths](#managed-vs-project-local-paths)
8. [Architecture: agents and skills](#architecture-agents-and-skills)
9. [Sprint lifecycle](#sprint-lifecycle)
10. [Rules you must follow](#rules-you-must-follow)
11. [Extending the template](#extending-the-template)
12. [Troubleshooting](#troubleshooting)

---

## What you get

- **5 role-based agents** — `@architect`, `@builder`, `@reviewer`, `@designer`, `@image-gen` — each with a scoped edit policy.
- **~40 skills** covering stack work (.NET, Astro, Next.js, React Native, Flutter, DevOps), cross-cutting concerns (TS, DB, security, testing, commits), discovery & planning (intake, spec, plan-mode), review & test (code-review, visual-regression), deployment, client-facing features (forms, payments, CMS, i18n), and sprint orchestration.
- **A sprint lifecycle** — sized delivery folders under `docs/sprints/`, decisions log, handoff reports, mandatory retro with concrete actions.
- **Safety hooks** — `safety-check.mjs` blocks destructive commands (DROP, `rm -rf`, force-push, `docker volume rm`, migration resets, etc.) unless explicitly approved.
- **A template sync mechanism** — `.eng-team.manifest` declares which paths the template owns; `sync-eng-team.sh` updates only those, never touching project-local content.

## Prerequisites

- **Claude Code CLI** installed and authenticated (`claude --version`)
- **git** and **gh** (GitHub CLI) — `gh` is required for bootstrap
- **bash** (macOS / Linux shell) — scripts assume POSIX
- **rsync** — used by `sync-eng-team.sh` (pre-installed on macOS and most Linux)

Optional (stack-dependent):
- **.NET 10 SDK**, **Node 20+**, **pnpm** / **npm**, **Python 3.11+** — only if the downstream project uses them
- **Docker** — for devops/infra skills

## Install into a new project

```bash
# 1. Create (or cd into) the target project directory
cd ~/workspace/my-new-project

# 2. Clone the template to a scratch location
gh repo clone ckansiz/eng-team /tmp/eng-team-src

# 3. Run bootstrap against your project root
/tmp/eng-team-src/scripts/bootstrap.sh .
```

`bootstrap.sh` does the following:

- Copies every path listed in `.eng-team.manifest` (agents, skills, hooks, `CLAUDE.md`, sprint templates, the sync script) into your project.
- Creates an empty `.claude/memory/` skeleton with a `README.md` explaining what to fill in.
- Writes `.eng-team.lock` pinning the upstream SHA so future syncs know what they updated from.
- Leaves your existing `README.md`, `.gitignore`, `package.json` / `*.csproj` / etc. **untouched**.

After bootstrap:

```bash
cd ~/workspace/my-new-project
git add .
git commit -m "chore: bootstrap eng-team template"
```

## Update an existing project (sync)

From inside any project that was bootstrapped from this template:

```bash
# Preview what sync would change (no writes)
./scripts/sync-eng-team.sh --dry-run

# Check whether a newer upstream version exists
./scripts/sync-eng-team.sh --check

# Apply updates
./scripts/sync-eng-team.sh

# Update the sync script itself (bootstraps onto newer protocol)
./scripts/sync-eng-team.sh --self
```

Sync **overwrites** every path in `.eng-team.manifest` (agents, skills, hooks, `CLAUDE.md`, sprint templates). It **never** touches:

- `.claude/memory/` (project identity, clients, ADRs)
- `.claude/settings.local.json` (machine-local overrides)
- `docs/sprints/{YYYY-MM-DD}-*` (active sprint folders)
- `README.md`, `.gitignore`, application code
- Anything outside the manifest

**When to sync**: after every upstream release, before starting a new sprint. Treat the sync diff like a PR — review, commit, tag.

```bash
./scripts/sync-eng-team.sh
git diff                               # review what changed
git add .claude CLAUDE.md docs/sprints/_template* .eng-team.*
git commit -m "chore: sync eng-team template to <sha>"
```

## First-run checklist

Bootstrap only copies the template scaffolding — project identity lives under `.claude/memory/`. Fill these in **before** doing any real work, or the agents will ask for them on every non-trivial task.

- [ ] **`.claude/memory/profile.md`** — who the developer is, language preference (TR/EN), delegation style, quality bar
- [ ] **`.claude/memory/workspace.md`** — project roots on disk, path keywords → which project they map to, stack per project
- [ ] **`.claude/memory/clients/{client}.md`** — one file per client: stack, branding, deploy target, SLA, known constraints
- [ ] **`.claude/memory/decisions/`** — ADRs for architectural calls (create as you go)
- [ ] **`.claude/settings.local.json`** — local overrides (model, hooks on/off, MCP servers). Gitignored.
- [ ] **`.env`** files for any tools you'll use (e.g. `tools/image-generator/.env` if you generate images)

Reference: `.claude/memory/README.md` — shipped with the template, tells you the schema for each file.

## Daily workflow

This workspace runs **plan mode at all times**. Every non-trivial task follows this shape:

1. **User request** → agent reads, restates, asks clarifying questions if scope is unclear.
2. **Plan presented** → affected files, change summary, risks, edge cases. No edits yet.
3. **User approves** → agent executes. Any surprise pauses for re-approval.
4. **Definition of Done** runs in order: type check → unit → integration → build → atomic conventional commit → branch pushed.
5. **Report** honestly. Failures stop the loop; they don't get hidden.

### Invoking skills (three equivalent ways)

| Method | Example |
|--------|---------|
| Slash command | `/intake`, `/new-feature`, `/code-review`, `/astro` |
| Natural language | "write a spec for the auth rewrite", "review this PR" |
| Agent delegation | An orchestrator agent invokes skills on your behalf during a workflow loop |

### Stack entry points

Typing `/astro`, `/nextjs`, `/dotnet`, `/react-native`, `/flutter`, or `/devops` activates `@builder` and auto-loads the relevant cross-cutting skills (`typescript`, `database`, `security`, `testing`, `commits`, `api-contract` where applicable).

### Workflow entry points

- **`/new-feature`** — full orchestration loop: intake → plan → build → review → test → PR
- **`/bug-fix`** — same loop with root-cause emphasis + regression test
- **`/hotfix`** — compressed loop: analyze → fix → smoke → PR, with mandatory mini-retro after merge

## Managed vs. project-local paths

| Path | Template-managed (overwritten on sync) | Project-local (never touched) |
|------|:--:|:--:|
| `CLAUDE.md` | ✓ | |
| `.claude/agents/` | ✓ | |
| `.claude/skills/` | ✓ | |
| `.claude/hooks/` | ✓ | |
| `.claude/scripts/` | ✓ | |
| `.claude/settings.json` | ✓ | |
| `docs/sprints/_template/` & `_template-hotfix/` | ✓ | |
| `docs/sprints/README.md` | ✓ | |
| `scripts/sync-eng-team.sh` | ✓ | |
| `.eng-team.manifest` | ✓ | |
| `.claude/memory/` | | ✓ |
| `.claude/settings.local.json` | | ✓ |
| `docs/sprints/{YYYY-MM-DD}-*` | | ✓ |
| `.eng-team.lock` | | ✓ (stores upstream SHA) |
| `README.md`, `.gitignore`, `tools/`, application code | | ✓ |

Canonical definition: [`.eng-team.manifest`](.eng-team.manifest).

## Architecture: agents and skills

**Agents** define *who acts and what they can edit*. **Skills** define *what to do and how*. Skills auto-load by description match — you don't import them by hand.

### Agents

| Agent | Role | Edit rights |
|-------|------|-------------|
| **@architect** | Discovery, specs, research, orchestrator | `docs/` only (read-only on source) |
| **@builder** | Full-stack implementation | Production code ✓ |
| **@reviewer** | Code review + test execution | Read-only |
| **@designer** | Wireframes + HTML mockups | Design artifacts only |
| **@image-gen** | AI image generation (optional) | — |

Client-facing reports (`client-report`, `client-handoff`) are produced **from the main session** — no dedicated agent, because they're freelancer→client communication, not an internal loop role.

### Skill catalog

- **Stack**: `dotnet`, `astro`, `nextjs`, `react-native`, `flutter`, `devops`
- **Cross-cutting**: `typescript`, `database`, `security`, `testing`, `commits`, `git-workflow`, `api-contract`
- **Discovery & planning**: `intake`, `edge-cases`, `spec-writing`, `tech-research`, `plan-mode`
- **Design / review**: `design-workflow`, `image-generation`, `code-review`, `visual-regression`
- **Ship & run**: `deployment`, `seo`, `performance`
- **Client-facing features**: `forms`, `payments`, `cms`, `i18n`
- **Sprint & orchestration**: `sprint`, `retro`, `orchestration`, `new-feature`, `bug-fix`, `hotfix`
- **Freelance practice**: `client-handoff`, `client-report`

Each skill lives in `.claude/skills/{name}/SKILL.md` — open any one to read its trigger phrases, preconditions, checklists, and output format.

## Sprint lifecycle

Every delivered job is a **sprint** (delivery-based, not time-based — a 2-day fix and a 2-week feature are each one sprint).

### Phases

| # | Phase | Skill(s) | Artifact |
|---|-------|----------|----------|
| 0 | Sprint init | `sprint` | folder from `_template/` |
| 1 | Intake | `intake` + `edge-cases` | `01-intake.md` |
| 2 | Spec (XL only) | `spec-writing` | `02-spec.md` |
| 3 | Plan | `plan-mode` + `edge-cases` | `03-plan.md` |
| 4 | Build | stack skill + `commits` | `05-handoffs/builder-report.md` |
| 5 | Review | `code-review` + stack skill | `05-handoffs/review-report.md` |
| 6 | Test | `testing` + `visual-regression` | `05-handoffs/test-report.md` |
| 7 | Ship | `git-workflow` + `deployment` | `06-delivery.md` |
| 8 | Report | `client-report` | client email / message |
| 9 | Retro | `retro` | `07-retro.md` + `08-system-updates/` |

### Size thresholds

| Size | Scope | Sprint folder | Retro |
|------|-------|---------------|-------|
| S | <4h, trivial | skip | skip |
| M | 1–3 days | required | full |
| L | 3–10 days | required | full |
| XL | >10 days, spec-driven | required | full + mid-sprint check |
| Hotfix | any, prod-critical | required (mini) | **mini (mandatory)** |

### Retro contract

- Every M+ retro produces **≤3 concrete aksiyonlar** (actions).
- Each action names a type (`skill` / `CLAUDE.md` / `memory`) and a target file.
- Actions are applied on `chore/retro-{sprint-slug}-{n}` branches and linked from `08-system-updates/SUMMARY.md`.
- **Sprint is not closed until every action is applied or explicitly backlogged.**
- **Hotfix mini-retro is non-negotiable** — hotfix defers full review precisely because mini-retro compensates.

## Rules you must follow

### 1. Plan mode — always on
Every task starts with a plan. No edits, no new files, no destructive commands until the user explicitly approves. If the user's message is a question, answer it directly — plans are only required before *taking action*.

### 2. Definition of Done (run in order)
1. Type check / static analysis
2. Unit tests
3. Integration / API tests (if backend or contract changed)
4. Build
5. Atomic Conventional Commits (`type(scope): description` — see `commits` skill)
6. Branch pushed

Any failure → stop, report honestly, do not proceed.

### 3. Destructive command guard
`.claude/hooks/safety-check.mjs` blocks (without explicit approval):
- SQL: `DROP`, `DELETE`, `TRUNCATE`
- Shell: `rm -rf`, `git push --force`, `git reset --hard`
- Migrations: rollback, reset, seed scripts
- Docker: `volume rm`, `system prune`, `compose down -v`
- K8s: `delete ns/pv/--all`
- Hosting: `fly apps destroy`, `vercel remove -y`

### 4. Git hygiene
- Never commit directly to `main` — branches: `feat/`, `fix/`, `hotfix/`, `refactor/`, `chore/`
- One logical change per commit (atomic)
- PR body includes Production Readiness checklist + localized `## Changelog` where required
- Post-merge: smoke test critical paths

### 5. Reports & handoffs
Orchestrator → `@builder` → `@reviewer` handoffs use the formats defined in the `orchestration` skill (Builder Handoff, Code Review, Test Report). Never report "done" without passing every quality gate.

## Extending the template

### Add an agent

1. Create `.claude/agents/{name}.md` with frontmatter: `name`, `description`, `model`, optionally `tools`.
2. Read-only agents should drop `Edit` and `Write` — e.g. `tools: All tools except Edit, Write`.
3. Update the agent table in `CLAUDE.md` and this README.

### Add a skill

1. Create `.claude/skills/{name}/SKILL.md` with frontmatter:
   - `name` — lowercase, hyphenated
   - `description` — must contain trigger phrases the harness matches against ("use when...")
   - `version`
2. Structure the body: triggers, preconditions, procedure, checklist, output format.
3. Add the skill to the catalog in `CLAUDE.md` and this README.
4. Cross-link from related skills where it fits in the workflow.

### Add a managed path

1. Create the file/dir.
2. Add it to `.eng-team.manifest` (trailing `/` for directories, no slash for single files).
3. Test: `./scripts/sync-eng-team.sh --dry-run` from a downstream project should show the new path.

### Publish template changes

Work on `main` of this repo. Downstream projects pick up changes via `./scripts/sync-eng-team.sh`. Tag breaking changes with a commit message prefix like `BREAKING:` so downstream syncs can flag them.

## Troubleshooting

**Sync overwrote something I wanted to keep.**
It shouldn't — but if a file needs to become project-local, remove it from `.eng-team.manifest` upstream and re-sync. Use `git reflog` / `git checkout HEAD~1 -- path` to recover.

**`gh repo clone` fails in bootstrap.**
Check `gh auth status`. Bootstrap uses `gh` so org-private templates work without extra token plumbing.

**Safety hook keeps blocking a legitimate command.**
The hook prints exactly what matched. If the command is truly needed, run it yourself once in a separate terminal (outside Claude's approval flow) — or extend `.claude/hooks/safety-check.mjs` upstream with a narrower rule.

**Plan mode feels like friction on a one-liner.**
It's intentional — the workspace is tuned for non-trivial delivery work. For one-liners, state the change in one sentence and say "approve"; the agent will execute immediately.

**Skill didn't auto-load when I expected.**
Auto-load is description-match driven. Open the SKILL.md and check the trigger phrases — either rephrase your request or invoke the skill by slash name.

**I want to use this template without the freelance flow.**
Everything is opt-in. Delete the sprint templates, skip `/intake`, skip `/retro`. The `@builder` + stack skills + safety hook still work as a lean engineering scaffold.

---

## Directory reference

```
eng-team/
├── CLAUDE.md                     # Full workspace rules (template-managed)
├── README.md                     # This file (project-local in downstream)
├── .eng-team.manifest            # Managed-path list (read by sync script)
├── .claude/
│   ├── agents/                   # Agent definitions
│   ├── skills/                   # Skill definitions
│   ├── hooks/safety-check.mjs    # Destructive-command guard
│   ├── scripts/                  # Helper scripts (e.g. API drift check)
│   ├── memory/                   # PROJECT-LOCAL — fill in first-run checklist
│   ├── settings.json             # Hook registration (tracked)
│   └── settings.local.json       # Local overrides (gitignored)
├── docs/sprints/
│   ├── _template/                # Full sprint template
│   ├── _template-hotfix/         # Hotfix sprint template
│   └── {YYYY-MM-DD}-*/           # Active sprints (project-local)
├── scripts/
│   ├── bootstrap.sh              # One-shot install into a new project
│   └── sync-eng-team.sh          # Update managed paths in an existing project
└── tools/                        # Opt-in helper tools (e.g. image-generator)
```

---

**License / authorship**: personal freelance workspace. Use, fork, adapt. No warranty.

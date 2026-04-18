# eng-team — Claude Code Agent Workspace Template

Agnostic template for freelance AI-assisted engineering workflows. Clone into a project, fill `.claude/memory/` with project-specific context, and deliver through a structured agent + skill system (discovery → build → ship → report).

Stack defaults, agent roles, and sprint flow → [`CLAUDE.md`](CLAUDE.md).

## Quick Start

### Bootstrap a new project

```bash
cd ~/workspace/my-new-project
gh repo clone ckansiz/eng-team /tmp/eng-team-src
/tmp/eng-team-src/scripts/bootstrap.sh .
```

This copies managed paths (`.claude/agents/`, `.claude/skills/`, `.claude/hooks/`, `CLAUDE.md`, sprint templates, and the sync script) into your project. An empty `.claude/memory/` skeleton is created so you can add project profile, workspace map, clients, and ADRs.

### Sync an existing project

```bash
cd ~/workspace/my-project
./scripts/sync-eng-team.sh --dry-run   # preview changes
./scripts/sync-eng-team.sh             # apply updates
./scripts/sync-eng-team.sh --check     # just check if new version is available
```

Sync overwrites managed paths (agents, skills, hooks, CLAUDE.md, sprint templates). It **never** touches `.claude/memory/`, `.claude/settings.local.json`, your active sprint folders, or anything outside the manifest.

## What's Managed vs Local

| Path | Template-managed (overwritten on sync) | Project-local (never touched) |
|------|:-:|:-:|
| `CLAUDE.md` | ✓ | |
| `.claude/agents/` | ✓ | |
| `.claude/skills/` | ✓ | |
| `.claude/hooks/` | ✓ | |
| `.claude/scripts/` | ✓ | |
| `docs/sprints/_template/` `_template-hotfix/` | ✓ | |
| `scripts/sync-eng-team.sh` `.eng-team.manifest` | ✓ | |
| `.claude/memory/` | | ✓ |
| `docs/sprints/{YYYY-MM-DD}-*` | | ✓ |
| `.claude/settings.local.json` | | ✓ |
| `.eng-team.lock` | | ✓ (stores upstream SHA) |

Canonical list lives in [`.eng-team.manifest`](.eng-team.manifest).

## Architecture: Agents + Skills

**Agents** are role definitions (who acts, who can edit). **Skills** are technical + procedural knowledge (what + how). Skills auto-load by description match and can be invoked via `/skill-name` or natural language. Every slash command *is* a skill — no separate commands layer.

### Agents (`.claude/agents/`)

| Agent | Role | Edit rights |
|-------|------|-------------|
| **@architect** | Discovery, spec, research, orchestrator | `docs/` only |
| **@builder** | Full-stack implementation | Production code ✓ |
| **@reviewer** | Code review + test execution | Read-only |
| **@designer** | Wireframe + HTML mockup | Design artifacts only |
| **@image-gen** | AI image generation (optional) | — |

Client-facing reports (`client-report`, `client-handoff`) run from the main session — no dedicated agent.

### Skills (`.claude/skills/`)

- **Stack**: `dotnet`, `astro`, `nextjs`, `react-native`, `flutter`, `devops`
- **Cross-cutting**: `typescript`, `database`, `security`, `testing`, `commits`, `git-workflow`, `api-contract`
- **Discovery & planning**: `intake`, `edge-cases`, `spec-writing`, `tech-research`, `plan-mode`
- **Design / review**: `design-workflow`, `image-generation`, `code-review`, `visual-regression`
- **Ship & run**: `deployment`, `seo`, `performance`
- **Client-facing features**: `forms`, `payments`, `cms`, `i18n`
- **Sprint & orchestration**: `sprint`, `retro`, `orchestration`, `new-feature`, `bug-fix`, `hotfix`
- **Freelance practice**: `client-handoff`, `client-report`

## End-to-End Flow

Every non-trivial job flows through these phases. `new-feature` / `bug-fix` / `hotfix` skills orchestrate them.

0. **Sprint Init** — `sprint` → folder from `docs/sprints/_template/`
1. **Intake** — `intake` + `edge-cases` → `01-intake.md`
2. **Spec** (XL only) — `spec-writing` → `02-spec.md`
3. **Plan** — `plan-mode` (plan → approval → execute)
4. **Build** — stack skill + `commits`
5. **Review** — `code-review` + stack skill
6. **Test** — `testing` + `visual-regression` (UI)
7. **Ship** — `git-workflow` + `deployment`
8. **Report** — `client-report {daily|delivery|weekly|incident|handoff}`
9. **Retro** — `retro` → actions applied → `08-system-updates/`

Between phases: **CHECKPOINT** — pause, present, wait for approval.

## Rules (summary)

- **Plan Mode mandatory**: non-trivial work requires a plan before any edit.
- **Definition of Done**: type check → unit → integration → build → conventional commit → branch push. On failure, stop and report honestly.
- **Destructive Command Guard**: `.claude/hooks/safety-check.mjs` blocks DROP / `rm -rf` / `git push --force` / migration resets / `docker volume rm` and similar.
- **Git**: no direct commits to `main`. Branches: `feat/` `fix/` `hotfix/` `refactor/`. Atomic Conventional Commits. PR body includes Production Readiness checklist.

Details → [`CLAUDE.md`](CLAUDE.md) + `orchestration` skill.

## Directory Structure

```
eng-team/
├── CLAUDE.md                     # Workspace instructions (template-managed)
├── README.md                     # This file
├── .eng-team.manifest            # Managed-path list (read by sync script)
├── .claude/
│   ├── agents/                   # Agent definitions (template-managed)
│   ├── skills/                   # Skill definitions (template-managed)
│   ├── hooks/
│   │   └── safety-check.mjs      # Destructive command guard
│   ├── scripts/                  # Helper scripts (e.g. API drift check)
│   ├── memory/                   # PROJECT-LOCAL (never touched by sync)
│   │   └── README.md             # Instructions for populating memory
│   ├── settings.json             # Hooks config (tracked)
│   └── settings.local.json       # Local overrides (gitignored)
├── docs/
│   └── sprints/
│       ├── _template/            # Full sprint template (template-managed)
│       ├── _template-hotfix/     # Hotfix sprint template (template-managed)
│       └── {YYYY-MM-DD}-*/       # Active sprint folders (project-local)
├── scripts/
│   ├── bootstrap.sh              # Install template into a new project
│   └── sync-eng-team.sh          # Update managed paths in existing project
└── tools/                        # Optional helper tools (e.g. image-generator)
```

## Extending

### Add an agent
1. Create `.claude/agents/{name}.md` — frontmatter: `name`, `description`, `model`, optionally `tools`
2. Read-only agents drop Edit/Write (e.g. `tools: All tools except Edit, Write`)
3. Update the agent table in `CLAUDE.md`

### Add a skill
1. Create `.claude/skills/{name}/SKILL.md` — frontmatter: `name`, `description` (use clear TRIGGER keywords; auto-load depends on this)
2. Add to the skill list in `CLAUDE.md` and this README
3. Cross-link relevant workflow/agent references

### Changes to this template
Push upstream improvements to `main` on this repo. Downstream projects pick them up via `./scripts/sync-eng-team.sh`.

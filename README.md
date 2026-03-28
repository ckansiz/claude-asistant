# Smurf Village - Federated Agent Architecture

A centralized agent orchestration system. The `smurfs/` directory serves as the "brain", each project works independently with its own smurf copies.

## Architecture

```
smurfs/ (Central Brain)                Project (.claude/)
┌──────────────────┐               ┌──────────────────────┐
│ Master Agents    │ ── push ──→   │ Local Agent Copies    │
│ Memory/Patterns  │ ── push ──→   │ Shared Patterns       │
│                  │               │                       │
│ Updated Brain    │ ←── pull ──   │ project-learnings.md  │
└──────────────────┘               └──────────────────────┘
```

- **Push:** Master smurf definitions + central patterns are copied to the project
- **Pull:** Learnings accumulated in the project are synced back to central
- **Project independence:** Sync NEVER touches the project's `rules/`, `CLAUDE.md` files

## Smurfs

| Smurf | File | Model | Role | Write Access |
|-------|------|-------|------|-------------|
| Papa Smurf | `papa-smurf.md` | **claude-opus-4-6** | Orchestrator, SDLC gatekeeper, checkpoint management | — |
| Poet Smurf | `poet-smurf.md` | claude-sonnet-4-6 | Requirements, PRD, user stories, tech spec | Yes |
| Vanity Smurf | `vanity-smurf.md` | claude-sonnet-4-6 | Wireframes first → 2-3 HTML design alternatives (works from Dreamy's design brief) | Yes |
| Painter Smurf | `painter-smurf.md` | claude-sonnet-4-6 | UI/CSS/Design, Tailwind, shadcn/ui | Yes |
| Brainy Smurf | `brainy-smurf.md` | Sonnet (default) / **Opus (E2E+UAT)** | Code review, QA, accessibility — Super Mode for pre-release | **No (read-only)** |
| Handy Smurf | `handy-smurf.md` | claude-sonnet-4-6 | .NET 10, EF Core, Docker, K8s, DB | Yes |
| Hefty Smurf | `hefty-smurf.md` | claude-haiku-4-5-20251001 | Scaffolding, project setup, sync-push | Yes |
| Dreamy Smurf | `dreamy-smurf.md` | **claude-opus-4-6** | Tech research + UI/UX design research (Dribbble, Behance, trends, design brief) | **No (read-only)** |
| Clumsy Smurf | `clumsy-smurf.md` | claude-sonnet-4-6 | Mobile apps (React Native/Expo/Flutter - stack TBD) | Yes |
| Smurfette | `smurfette.md` | claude-sonnet-4-6 | AI image generation — special day visuals, social media, branding (Wesoco) | Yes |

## SDLC Pipeline

```
Phase 1: Discovery
  Poet Smurf (spec) + Dreamy Smurf — Tech Research
  CHECKPOINT 1: User approves spec + stack

Phase 2: Design  ← 3 steps
  2a. Dreamy Smurf — UI/UX Design Research (Dribbble, Behance, trends, brief)
      CHECKPOINT 2a: User confirms visual direction
  2b. Vanity Smurf — Wireframes (gray-box layout structure only)
      CHECKPOINT 2b: User selects wireframe structure
  2c. Vanity Smurf — Full HTML designs (2 alternatives, from brief + approved wireframe)
      CHECKPOINT 2c: User selects design A or B

Phase 3: Development
  Hefty (scaffold) -> Painter + Handy (parallel) -> [Clumsy if mobile]
  -> Brainy (review)
  CHECKPOINT 3: Delivery report -> User business review -> Release
```

At every CHECKPOINT: stop, present clearly, wait for explicit approval before continuing.
Design Research → Wireframe → Full Design. Never collapse these steps.

## Tools

### Image Generator (`tools/image-generator/`)

Wesoco dijital ajans için özel gün görseli üretim pipeline'ı. Smurfette tarafından yönetilir.

- DALL-E 3 / FLUX 1.1 Pro / Stability AI desteği
- Otomatik metin overlay + logo compositing (Pillow + cairosvg)
- Logo rengi arkaplan parlaklığına göre otomatik seçilir (koyu bg → beyaz logo)
- `.env` dosyasında API key'ler tanımlanır
- Sistem bağımlılığı: `brew install cairo`

```bash
# Manuel çalıştırma (interactive CLI):
cd tools/image-generator
python papa_smurf.py
```

## Directory Structure

```
smurfs/
├── CLAUDE.md                        # Papa Smurf orchestrator instructions
├── .claude/
│   ├── agents/                      # 10 master smurf definitions
│   ├── rules/
│   │   ├── workspace-map.md         # Project -> directory -> stack mapping
│   │   ├── delegation-rules.md      # Delegation rules + SDLC pipeline
│   │   └── village-health.md        # Self-maintenance triggers + checklists
│   └── settings.local.json
├── memory/
│   ├── patterns/                    # Stack-based learnings
│   │   ├── nextjs-patterns.md
│   │   ├── astro-patterns.md
│   │   ├── dotnet-patterns.md
│   │   └── tailwind-patterns.md
│   ├── clients/                     # Client notes
│   └── decisions/                   # Architecture decisions (ADR)
├── templates/claude-md/             # Project CLAUDE.md templates
│   ├── nextjs-site.md
│   ├── astro-site.md
│   └── dotnet-backend.md
└── scripts/
    ├── sync-push.sh                 # Master -> Project
    └── sync-pull.sh                 # Project -> Master
```

## Usage

### 1. Deploy smurfs to a project

```bash
./scripts/sync-push.sh ~/workspace/wesoco/works/oltan
```

This command:
- Copies master agent files to `{project}/.claude/agents/`
- Writes central patterns to `{project}/.claude/rules/shared-patterns.md`
- Creates `{project}/.claude/project-learnings.md` (if missing)
- Does NOT touch the project's existing `rules/` or `CLAUDE.md` files

### 2. Work in the project directory

```bash
cd ~/workspace/wesoco/works/oltan
claude  # Open Claude Code
```

Smurfs can be used directly within the project:
- `@poet-smurf`    -- Requirements + tech spec
- `@vanity-smurf`  -- Design alternatives (HTML)
- `@painter-smurf` -- UI/CSS implementation
- `@brainy-smurf`  -- Code review
- `@handy-smurf`   -- Backend work
- `@hefty-smurf`   -- Setup/scaffold
- `@dreamy-smurf`  -- Research
- `@clumsy-smurf`  -- Mobile (after stack decision)

### 3. Pull learnings back to central

```bash
# Single project:
./scripts/sync-pull.sh ~/workspace/wesoco/works/oltan

# All projects:
./scripts/sync-pull.sh --all
```

### 4. Re-deploy updated brain to projects

```bash
./scripts/sync-push.sh ~/workspace/wesoco/works/oltan
```

## Workspace Map

| Project | Directory | Stack |
|---------|-----------|-------|
| qoommerce (backend) | `~/workspace/qoommerce/qoommerce-app/backend/` | .NET 10, EF Core, PostgreSQL |
| qoommerce (frontend) | `~/workspace/qoommerce/qoommerce-app/frontend/` | Astro 4, React 18, shadcn/ui |
| loodos | `~/workspace/loodos/a101-mep-backend/` | .NET, EF Core, MongoDB |
| docker infra | `~/workspace/docker/` | Docker Compose, PostgreSQL 18, Grafana LGTM |
| k8s | `~/workspace/k8s/` | Kubernetes YAML |
| wesoco clients | `~/workspace/wesoco/works/{slug}/` | Next.js / Astro (varies) |

### Wesoco Clients

arzisi-project, asfire, canan-ince-borekci, efor-klima, kanser-tedavi, kkm-hendislik, kofteci-ekrem, ms-ako, oltan, ppf-web, profarkgarage.com.tr, qretna-app, ram-makina, serkan-tayar, trabzonppfcom, wcard-website, wcards, wesoco-uc, wesoco-website

## Memory System

### Write rule
Smurfs write important discoveries to the project's `.claude/project-learnings.md`:

```markdown
## 2026-03-28 - Tailwind Dark Mode
**Smurf:** painter-smurf
**Pattern:** This project uses dark mode class strategy, not media
**Applicable to:** All wesoco Next.js projects
```

### Sync cycle
```
Work in project -> project-learnings.md updated
        |
sync-pull.sh -> central memory updated
        |
sync-push.sh -> updated knowledge distributed to all projects
```

## Adding a New Smurf

1. Create `.claude/agents/{name}.md` with `name`, `description`, `model` frontmatter
2. Use `disallowedTools` to restrict permissions (disable Write/Edit for review-only agents)
3. Add to **CLAUDE.md** Delegation Rules section
4. Add to **README.md** agent table ← this file
5. Add chain/parallel dispatch rule to `.claude/rules/delegation-rules.md`
6. Add pointer to global `MEMORY.md`
7. Deploy to projects with `sync-push.sh`

> **Rule:** A smurf is not "added" until all 7 steps are done. README accuracy is non-negotiable.

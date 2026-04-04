# Smurf Village - GitHub Copilot Agent Workspace

Cem'in kişisel GitHub Copilot agent ortamı. Freelance full-stack geliştirme süreçleri için yapılandırılmış ajan sistemi.

## Agents

| Agent | Model | Role | Write |
|-------|-------|------|-------|
| `architect` | claude-opus-4-5 | Research, requirements, architecture decisions | No |
| `builder` | claude-sonnet-4-6 | Full implementation — backend, frontend, mobile, infra | Yes |
| `designer` | claude-sonnet-4-6 | HTML wireframes + full design alternatives | Yes |
| `reviewer` | claude-sonnet-4-6 | Code review, QA, accessibility (read-only) | No |
| `image-gen` | — | AI image generation for Wesoco clients (DALL-E / FLUX) | Yes |

## Commands

| Command | Agent | Purpose |
|---------|-------|---------|
| `/backend` | builder | .NET + EF Core + API contract standards |
| `/frontend` | builder | Astro or Next.js + TypeScript standards |
| `/mobile` | builder | React Native / Expo standards |
| `/devops` | builder | Docker, K8s, infra |
| `/design` | designer | HTML wireframe + design mockup workflow |
| `/spec` | architect | Requirements + tech spec |
| `/research` | architect | Tech research + recommendation |
| `/review` | reviewer | Code review + QA checklist |
| `/create-image` | image-gen | Special day visuals, social media, branding |

## SDLC Pipeline

```
Phase 1: Discovery
  /spec (architect) + /research (architect)
  CHECKPOINT 1: Spec + stack onayı

Phase 2: Design  ← 3 adım
  2a. /research (architect) — UI/UX design research (Dribbble, Behance, trends, brief)
      CHECKPOINT 2a: Görsel yön onayı
  2b. /design (designer) — Wireframes (gray-box, layout only)
      CHECKPOINT 2b: Wireframe seçimi
  2c. /design (designer) — Full HTML designs (2 alternatif, brief + wireframe üzerinden)
      CHECKPOINT 2c: Design A veya B seçimi

Phase 3: Development
  /devops (scaffold) → /frontend + /backend (paralel) → [/mobile] → /review
  CHECKPOINT 3: Delivery raporu → Release
```

Her CHECKPOINT'te dur, net şekilde sun, onay bekle.

## Tools

### Image Generator (`tools/image-generator/`)

Wesoco dijital ajans için özel gün görseli üretim pipeline'ı. `/create-image` komutuyla tetiklenir.

- DALL-E 3 / FLUX 1.1 Pro desteği
- Otomatik metin overlay + logo compositing (Pillow + cairosvg)
- Logo rengi arkaplan parlaklığına göre otomatik seçilir (koyu bg → beyaz logo)
- `.env` dosyasında API key'ler tanımlanır
- Sistem bağımlılığı: `brew install cairo`

```bash
cd tools/image-generator
python papa_smurf.py
```

## Directory Structure

```
smurfs/
├── CLAUDE.md                  # Copilot workspace instructions (stack, agents, commands)
├── .claude/
│   ├── agents/                # 5 agent tanımı (architect, builder, designer, reviewer, image-gen)
│   ├── commands/              # /backend, /frontend, /mobile, /devops, /design, /spec, /research, /review, /create-image
│   ├── context/               # Inject edilebilir bağlam dosyaları (dotnet.md, astro.md, nextjs.md, ...)
│   ├── memory/                # Kalıcı hafıza
│   │   ├── profile.md         # Geliştirici profili + tercihler
│   │   ├── workspace.md       # Proje → dizin → stack haritası
│   │   └── decisions/         # Architecture decision records (ADR)
│   └── settings.local.json
├── projects/                  # Proje belgeleri (spec, design, roadmap)
│   ├── blocero/
│   └── wcard-website/
└── tools/
    └── image-generator/       # Wesoco görsel üretim pipeline'ı
```

## Workspace Map

| Area | Path | Stack |
|------|------|-------|
| qoommerce | `~/workspace/qoommerce/qoommerce-app/` | .NET 10 + Astro + PostgreSQL |
| wesoco clients | `~/workspace/wesoco/works/{slug}/` | Mixed |
| loodos | `~/workspace/loodos/a101-mep-backend/` | .NET 7, EF Core, MongoDB |
| docker infra | `~/workspace/docker/` | Docker Compose, Grafana LGTM |
| k8s | `~/workspace/k8s/` | Kubernetes |
| sandbox | `~/workspace/sandbox/` | Experimental |

### Wesoco Clients

arzisi-project (Astro), asfire (Astro+React+Prisma), kanser-tedavi (Next.js), oltan (Next.js+Prisma+better-auth), serkan-tayar (Next.js), wcard-website (Astro 5+Svelte 5+Strapi v5), qretna-app (.NET+frontend)

## Adding an Agent

1. `.claude/agents/{name}.md` oluştur — `name`, `description`, `model` frontmatter zorunlu
2. Read-only agentlar için `disallowedTools: [Edit, Write]` ekle
3. `CLAUDE.md` agent tablosunu güncelle
4. `README.md` agent tablosunu güncelle ← bu dosya

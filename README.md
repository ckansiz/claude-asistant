# Smurf Village - Claude Code Agent Workspace

Cem'in kişisel Claude Code agent ortamı. Freelance full-stack geliştirme süreçleri için yapılandırılmış ajan sistemi.

Agent, command ve stack tercihleri → `CLAUDE.md`

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
  /devops (scaffold) → /astro or /nextjs or /dotnet (paralel) → [/mobile] → /review
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
├── CLAUDE.md                  # Workspace instructions (stack, agents, commands)
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

## Adding an Agent

1. `.claude/agents/{name}.md` oluştur — `name`, `description`, `model` frontmatter zorunlu
2. Read-only agentlar için `disallowedTools: [Edit, Write]` ekle
3. `CLAUDE.md` agent ve command tablolarını güncelle

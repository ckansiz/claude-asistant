# Smurf Village — Claude Code Agent Workspace

Cem'in kişisel Claude Code ortamı. Freelance full-stack geliştirme (discovery → build → ship → report) için yapılandırılmış ajan + skill sistemi.

Stack tercihleri, workspace haritası ve kurallar → `CLAUDE.md`

## Architecture: Agents + Skills

**Agents** rol tanımıdır (kim yapar, kim edit edebilir). **Skills** teknik + prosedürel bilgidir (ne + nasıl). Açıklamaya göre otomatik yüklenir, `/skill-name` ile veya doğal dille çağrılır. Ayrı bir `commands/` katmanı yok — her slash komutu bir skill.

### Agents (`.claude/agents/`)

| Agent | Rol | Edit yetkisi |
|-------|-----|---------------|
| **@architect** | Discovery, spec, research, orchestrator | Sadece `docs/` |
| **@builder** | Full-stack implementation | Production code ✓ |
| **@reviewer** | Code review + test execution | Read-only |
| **@designer** | Wireframe + HTML mockup | Sadece design artifacts |
| **@image-gen** | Wesoco için AI görsel üretim | — |

Client-facing raporlar (`client-report`, `client-handoff`) ana session'dan çalışır, ayrı agent yok.

### Skills (`.claude/skills/`)

- **Stack**: `dotnet`, `astro`, `nextjs`, `react-native`, `flutter`, `devops`
- **Cross-cutting**: `typescript`, `database`, `security`, `testing`, `commits`, `git-workflow`, `api-contract`
- **Discovery & planning**: `intake`, `edge-cases`, `spec-writing`, `tech-research`, `plan-mode`
- **Design / review**: `design-workflow`, `image-generation`, `code-review`, `visual-regression`
- **Ship & run**: `deployment`, `seo`, `performance`
- **Client-facing features**: `forms`, `payments`, `cms`, `i18n`
- **Orchestration**: `orchestration`, `new-feature`, `bug-fix`, `hotfix`
- **Freelance practice**: `client-handoff`, `client-report`

## End-to-End Flow

Her non-trivial iş bu fazlardan geçer. `new-feature` / `bug-fix` / `hotfix` skill'leri bu fazları orkestre eder.

1. **Intake** — `intake` + `edge-cases` → `docs/intake/{date}-{slug}.md`
2. **Spec** (XL only) — `spec-writing` → `docs/requirements.md` + `docs/tech-spec.md`
3. **Plan** — `plan-mode` (plan → onay → execute)
4. **Build** — stack skill + `commits`
5. **Review** — `code-review` + stack skill
6. **Test** — `testing` + `visual-regression` (UI için)
7. **Ship** — `git-workflow` + `deployment`
8. **Report** — `client-report {daily|delivery|weekly|incident|handoff}`

Her faz arası **CHECKPOINT** — dur, sun, onay bekle.

## Rules (özet)

- **Plan Mode zorunlu**: non-trivial iş için önce plan, onay sonrası edit.
- **Definition of Done**: type check → unit → integration → build → conventional commit → branch push. Fail olursa dur, rapor et.
- **Destructive Command Guard**: `.claude/hooks/safety-check.mjs` DROP / `rm -rf` / `git push --force` / migration reset / `docker volume rm` gibi komutları engeller.
- **Git**: `main`'e direkt commit yok. `feat/` `fix/` `hotfix/` `refactor/` branch'leri. Atomic Conventional Commits. PR body'de Production Readiness checklist + TR clients için `## Changelog`.

Detaylar → `CLAUDE.md` + `orchestration` skill.

## Directory Structure

```
eng-team/
├── CLAUDE.md                     # Workspace instructions (zorunlu kurallar)
├── README.md                     # Bu dosya
├── .claude/
│   ├── agents/                   # 5 agent (architect, builder, reviewer, designer, image-gen)
│   ├── skills/                   # 36 skill (stack + cross-cutting + orchestration + client)
│   ├── hooks/
│   │   └── safety-check.mjs      # Destructive command guard (PreToolUse)
│   ├── scripts/
│   │   └── check-api-drift.sh    # OpenAPI ↔ TS codegen drift detection
│   ├── memory/
│   │   ├── profile.md            # Developer profile + preferences
│   │   ├── workspace.md          # Proje → dizin → stack haritası
│   │   ├── clients/              # Per-client bilgi (arzisi, asfire, kanser-tedavi, oltan, ...)
│   │   └── decisions/            # ADR (no-mediatr, openapi-codegen, agent-models, ui-stack)
│   ├── settings.json             # Hooks config (git'e gider)
│   └── settings.local.json       # Local overrides (git'e gitmez)
├── projects/                     # Proje belgeleri (spec, design, roadmap)
│   ├── blocero/
│   └── wcard-website/
└── tools/
    └── image-generator/          # Wesoco özel gün görseli pipeline'ı
```

## Tools

### Image Generator (`tools/image-generator/`)

Wesoco dijital ajans için özel gün görseli üretim pipeline'ı. `image-generation` skill üzerinden tetiklenir.

- DALL-E 3 (default) / FLUX 1.1 Pro / Stable Image Core
- Otomatik metin overlay + logo compositing (Pillow + cairosvg)
- Logo rengi arkaplan parlaklığına göre seçilir (koyu bg → beyaz logo)
- API key'ler `.env` içinde
- Sistem bağımlılığı: `brew install cairo`

```bash
cd tools/image-generator
python papa_smurf.py
```

## Extending

### Yeni agent eklemek
1. `.claude/agents/{name}.md` — frontmatter: `name`, `description`, `model`, gerekirse `tools`
2. Read-only agent için Edit/Write erişimini kaldır (örn. `tools: All tools except Edit, Write`)
3. `CLAUDE.md` agent tablosunu güncelle

### Yeni skill eklemek
1. `.claude/skills/{name}/SKILL.md` — frontmatter: `name`, `description` (TRIGGER kelimeleri açık yaz, auto-load buna göre çalışır)
2. `CLAUDE.md` skill listesini güncelle
3. İlgili workflow/agent referansları varsa cross-link et

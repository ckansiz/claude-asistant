# Şirin Köyü - Federated Agent Architecture

Merkezi bir ajan orkestrasyon sistemi. `smurfs/` dizini "beyin" görevi görür, her proje kendi şirin kopyalarıyla bağımsız çalışır.

## Mimari

```
smurfs/ (Merkez Beyin)              Proje (.claude/)
┌──────────────────┐               ┌──────────────────────┐
│ Master Agents    │ ── push ──→   │ Local Agent Copies    │
│ Memory/Patterns  │ ── push ──→   │ Shared Patterns       │
│                  │               │                       │
│ Updated Brain    │ ←── pull ──   │ project-learnings.md  │
└──────────────────┘               └──────────────────────┘
```

- **Push:** Master şirin tanımları + merkezi pattern'lar projeye kopyalanır
- **Pull:** Projede biriken öğrenimler merkeze aktarılır
- **Proje bağımsızlığı:** Projenin `rules/`, `CLAUDE.md` dosyalarına sync DOKUNMAZ

## Şirinler

| Şirin | Dosya | Model | Rol | Yazma İzni |
|-------|-------|-------|-----|------------|
| Ressam Şirin | `ressam-sirin.md` | opus | UI/CSS/Design, Tailwind, shadcn/ui | Var |
| Gözlüklü Şirin | `gozluklu-sirin.md` | opus | Code review, QA, accessibility | **Yok (read-only)** |
| Hırdavat Şirin | `hirdavat-sirin.md` | opus | .NET 10, EF Core, Docker, K8s, DB | Var |
| Çırak Şirin | `cirak-sirin.md` | sonnet | Scaffolding, proje kurulumu, sync-push | Var |
| Araştırmacı Şirin | `arastirmaci-sirin.md` | opus | Teknoloji araştırma, best practice | **Yok (read-only)** |

## Zorunlu Zincirler

```
UI/CSS işi        → Ressam Şirin → Gözlüklü Şirin (review zorunlu)
Yeni proje        → Çırak Şirin  → (ilgili şirin)
Bilinmeyen konu   → Araştırmacı  → (uygulayıcı şirin)
Backend+Frontend  → Hırdavat + Ressam (paralel) → Gözlüklü (review)
```

## Dizin Yapısı

```
smurfs/
├── CLAUDE.md                        # Şirin Baba orkestratör talimatları
├── .claude/
│   ├── agents/                      # 5 master şirin tanımı
│   ├── rules/
│   │   ├── workspace-map.md         # Proje → dizin → stack eşlemesi
│   │   └── delegation-rules.md      # Delegasyon kuralları
│   └── settings.local.json
├── memory/
│   ├── patterns/                    # Stack bazlı öğrenimler
│   │   ├── nextjs-patterns.md
│   │   ├── astro-patterns.md
│   │   ├── dotnet-patterns.md
│   │   └── tailwind-patterns.md
│   ├── clients/                     # Müşteri notları
│   └── decisions/                   # Mimari kararlar (ADR)
├── templates/claude-md/             # Proje CLAUDE.md şablonları
│   ├── nextjs-site.md
│   ├── astro-site.md
│   └── dotnet-backend.md
└── scripts/
    ├── sync-push.sh                 # Master → Proje
    └── sync-pull.sh                 # Proje → Master
```

## Kullanım

### 1. Projeye şirinleri dağıt

```bash
./scripts/sync-push.sh ~/workspace/wesoco/works/oltan
```

Bu komut:
- Master agent dosyalarını `{proje}/.claude/agents/` altına kopyalar
- Merkezi pattern'ları `{proje}/.claude/rules/shared-patterns.md`'ye yazar
- `{proje}/.claude/project-learnings.md` oluşturur (yoksa)
- Projenin mevcut `rules/` ve `CLAUDE.md` dosyalarına **dokunmaz**

### 2. Proje dizininde çalış

```bash
cd ~/workspace/wesoco/works/oltan
claude  # Claude Code'u aç
```

Proje içinde şirinler doğrudan kullanılabilir:
- `@ressam-sirin` — UI/CSS işi ver
- `@gozluklu-sirin` ��� Review yaptır
- `@hirdavat-sirin` — Backend işi ver
- `@cirak-sirin` — Kurulum/scaffold
- `@arastirmaci-sirin` — Araştırma

### 3. Öğrenimleri merkeze çek

```bash
# Tek proje:
./scripts/sync-pull.sh ~/workspace/wesoco/works/oltan

# Tüm projeler:
./scripts/sync-pull.sh --all
```

Bu komut:
- Projelerdeki `project-learnings.md` dosyalarını okur
- İçeriği `memory/patterns/cross-project-learnings.md`'ye aktarır
- Senkronlanan girdileri `[SYNCED]` olarak işaretler

### 4. Güncellenmiş beyni projelere geri dağıt

```bash
./scripts/sync-push.sh ~/workspace/wesoco/works/oltan
```

## Şirin Baba ile Orkestrasyon

`smurfs/` dizininde `@sirin-baba` olarak çalıştığında Şirin Baba:

1. Kullanıcının isteğini analiz eder
2. Hedef proje dizinini belirler (`workspace-map.md`'den)
3. İlgili memory dosyalarını okur
4. Doğru şirine dispatch eder
5. Sonucu doğrular (gerekirse Gözlüklü'yü çağırır)
6. Merkezi memory'yi günceller

## Workspace Haritası

| Proje | Dizin | Stack |
|-------|-------|-------|
| qoommerce (backend) | `~/workspace/qoommerce/qoommerce-app/backend/` | .NET 10, EF Core, PostgreSQL |
| qoommerce (frontend) | `~/workspace/qoommerce/qoommerce-app/frontend/` | Astro 4, React 18, shadcn/ui |
| loodos | `~/workspace/loodos/a101-mep-backend/` | .NET, EF Core, MongoDB |
| docker infra | `~/workspace/docker/` | Docker Compose, PostgreSQL 18, Grafana LGTM |
| k8s | `~/workspace/k8s/` | Kubernetes YAML |
| wesoco clients | `~/workspace/wesoco/works/{slug}/` | Next.js / Astro (değişken) |

### Wesoco Müşterileri

arzisi-project, asfire, canan-ince-borekci, efor-klima, kanser-tedavi, kkm-hendislik, kofteci-ekrem, ms-ako, oltan, ppf-web, profarkgarage.com.tr, qretna-app, ram-makina, serkan-tayar, trabzonppfcom, wcard-website, wcards, wesoco-uc, wesoco-website

## Memory Sistemi

### Yazma kuralı
Şirinler çalışırken önemli keşiflerini projenin `.claude/project-learnings.md` dosyasına yazar:

```markdown
## 2026-03-28 - Tailwind Dark Mode
**Sirin:** ressam-sirin
**Pattern:** Bu projede dark mode class strategy kullanılıyor, media değil
**Applicable to:** Tüm wesoco Next.js projeleri
```

### Sync döngüsü
```
Proje'de çalış → project-learnings.md güncellenir
        ↓
sync-pull.sh → merkez memory güncellenir
        ↓
sync-push.sh → güncel bilgi tüm projelere dağıtılır
```

## Yeni Şirin Ekleme

1. `smurfs/.claude/agents/` altına yeni `.md` dosyası oluştur
2. YAML frontmatter'da `name`, `description`, `model` belirt
3. `disallowedTools` ile izinleri kısıtla (review ajanlarında Write/Edit kapat)
4. `CLAUDE.md`'deki delegasyon kurallarına ekle
5. `delegation-rules.md`'ye zincir kuralını ekle
6. `sync-push.sh` ile projelere dağıt

# Wcard Website - Proje Ozeti

> Son guncelleme: 2026-03-29
> Inceleyen: Papa Smurf (Opus)

---

## Proje Amaci

Wcard, NFC ve QR kod destekli dijital kartvizit platformudur. Kullanicilar fiziksel bir NFC kart satin alir, karti hesabina baglar (claim), profil bilgilerini doldurur ve kart taratildiginda `/reader/{serial}` URL'si uzerinden dijital profilleri goruntulenebilir.

**Domain:** wcard.tr
**Sirket:** Wesoco Technology
**Repo:** `~/workspace/wesoco/works/wcard-website/`

---

## Teknoloji Yigini (Stack)

| Katman | Teknoloji | Versiyon |
|--------|-----------|----------|
| Frontend Framework | Astro (SSR mode, standalone Node) | 5.17.3 |
| Interactive Islands | Svelte 5 | 5.x |
| CSS | Tailwind CSS v3 | 3.4.17 |
| CMS / Backend | Strapi v5 (Headless) | 5.7.0+ |
| Database | PostgreSQL | 16 (Alpine) |
| Email | Resend | 6.9.4 |
| Dosya Yukleme | Cloudflare R2 (S3 uyumlu) | - |
| Bot Korumasi | Cloudflare Turnstile | - |
| QR Kod | qrcode (npm) | 1.5.4 |
| Validasyon | Zod | 4.3.6 |
| Icon | Lucide (Astro) | 0.563.0 |
| Test (Unit) | Vitest | 3.1.0 |
| Test (E2E) | Cypress | 13.17.0 |
| Package Manager | Yarn 1.22 (workspaces) | - |
| Container | Docker + Docker Compose | - |
| CI/CD | GitHub Actions (3 workflow) | - |

**Not:** Astro projesi Svelte island'lari kullaniyor. Standart Wesoco stack'inden (React + shadcn/ui) farkli bir tercih. Bu proje icin shadcn/ui gecerli degil cunku Svelte kullaniliyor.

---

## Mimari Yapi

### Monorepo (Yarn Workspaces)

```
wcard-website/
  apps/
    cms/              # Strapi v5 CMS (Headless)
      config/         # Strapi konfigurasyonu (CommonJS)
      scripts/        # seed.js (1000 kart), migrate-orders.js
      src/api/        # 13 Content Type
    web/              # Astro SSR Frontend
      src/
        pages/        # 15+ Astro sayfasi (Turkce URL slug'lar)
        components/
          interactive/  # 9 Svelte bilesen (client-side island)
          ui/           # 10 Astro bilesen (SSR)
        lib/            # auth, strapi, email, validators, rate-limit, icons
        layouts/        # Layout.astro
        styles/         # global.css
  cypress/              # E2E test (smoke)
  docker-compose.yml    # 3 servis: postgres, cms, web
  .github/workflows/    # ci.yml, build-and-push.yml, test.yml
```

### Content Types (Strapi CMS)

| Content Type | Amac |
|-------------|------|
| `card` | Fiziksel kart (serialCode, isClaimed, owner, profile) |
| `wcard-user` | Kullanici (email, name, cards) - Strapi users-permissions'tan bagimsiz |
| `wcard-session` | Oturum (token, user, expiresAt, revokedAt) |
| `profile` | Dijital profil (fullName, title, phone, email, website, bio, avatarUrl) |
| `auth-token` | Magic link token (purpose: register/login/claim) |
| `order` | Siparis (plan, cardLimit, status: pending/confirmed/cancelled) |
| `plan` | Fiyat plani (slug, title, cardLimit, price, features) |
| `home-page`, `about-page`, `pricing-page`, `features-page`, `contact-page` | CMS-driven sayfa icerikleri |
| `global-setting` | Site geneli ayarlar (nav, footer, SEO defaults) |

### API Endpoint'leri (Astro SSR)

| Endpoint | Method | Amac |
|----------|--------|------|
| `/api/auth/register` | POST | Email ile kayit magic link gonder |
| `/api/auth/login` | POST | Email ile giris magic link gonder |
| `/api/auth/verify` | GET | Magic link dogrula, session olustur |
| `/api/auth/logout` | POST | Session revoke, cookie sil |
| `/api/auth/session` | GET | Mevcut session bilgisi |
| `/api/card/claim` | POST | Kart baglama (session gerekli) |
| `/api/profile/update` | PUT | Profil guncelleme (session + sahiplik kontrolu) |

### Frontend Sayfalari

| URL | Sayfa |
|-----|-------|
| `/` | Ana sayfa (CMS-driven hero, features, how-it-works, CTA) |
| `/ozellikler` | Ozellikler sayfasi |
| `/fiyatlandirma` | Fiyatlandirma + FAQ |
| `/hakkimizda` | Hakkimizda |
| `/iletisim` | Iletisim formu + harita |
| `/giris` | Giris (magic link) |
| `/uye-ol` | Kayit (magic link) |
| `/panel` | Dashboard (kart listesi, baglama, siparisler) |
| `/panel/[serial]` | Profil duzenleme |
| `/reader/[serial]` | Public profil gorunumu |
| `/gizlilik-politikasi` | Gizlilik politikasi |
| `/kvkk` | KVKK metni |
| `/404`, `/500` | Hata sayfalari |

---

## Kullanici Akislari

### 1. Kayit (Passwordless)
`/uye-ol` -> email gir -> magic link emaili (Resend) -> `/api/auth/verify?token=...&purpose=register` -> hesap olusur + session cookie -> `/panel`

### 2. Giris
`/giris` -> email gir -> magic link emaili -> `/api/auth/verify?...&purpose=login` -> session cookie -> `/panel`

### 3. Kart Baglama
Panel'de seri numarasi gir -> `POST /api/card/claim` -> kart limit kontrolu (order-based) -> kart kullaniciya baglenir -> profil duzenleme

### 4. Profil Duzenleme
`/panel/[serial]` -> Zod validated form -> `PUT /api/profile/update` -> Strapi profile guncelle/olustur

### 5. Kart Okuma (Public)
NFC/QR tap -> `wcard.tr/reader/XXXXXXXX` -> claimed ise public profil goster + vCard indirme, unclaimed ise kayit yonlendirmesi

---

## Deployment

### Docker Compose
- **postgres**: PostgreSQL 16 Alpine, healthcheck, named volume
- **cms**: Strapi v5, depends_on postgres (healthy), non-root user, Cloudflare R2 upload
- **web**: Astro SSR (Node standalone), depends_on cms, non-root user

### CI/CD (GitHub Actions)
- `ci.yml`: PR/push -> lint + type check -> unit test -> build (env mock)
- `build-and-push.yml`: Docker image build ve registry push
- `test.yml`: Test pipeline

### Dosya Depolama
Cloudflare R2 -> `cdn.wcard.tr` public URL -> `@strapi/provider-upload-aws-s3`

---

## Tamamlanan Ozellikler

- [x] Passwordless auth (magic link via Resend)
- [x] Session yonetimi (30 gun, httpOnly cookie)
- [x] Kart baglama (claim) + limit sistemi (plan/order)
- [x] Profil CRUD (tek birlesik tip)
- [x] Public profil gorunumu + vCard indirme
- [x] QR kod uretimi
- [x] Rate limiting (IP bazli, in-memory sliding window)
- [x] Guvenlik header'lari (CSP, HSTS, X-Frame-Options, Referrer-Policy)
- [x] CORS sinirlandirmasi (env-based)
- [x] Turnstile captcha
- [x] CMS-driven icerik (6 sayfa + global ayarlar)
- [x] SEO (meta tags, OG, JSON-LD, robots.txt, sitemap)
- [x] 404/500 hata sayfalari
- [x] Skip-to-content erisebilirlik
- [x] Cookie consent banner (KVKK)
- [x] Docker (multi-stage build, non-root, healthcheck)
- [x] CI/CD (GitHub Actions)
- [x] Unit testler (Vitest) + Smoke testler (Cypress)
- [x] Seed script (1000 kart)

## Bekleyen Ozellikler

- [ ] OG gorseli (kullanici saglayacak)
- [ ] Redis-based rate limiting
- [ ] Auth token garbage collection
- [ ] Font yukleme optimizasyonu
- [ ] PostgreSQL backup stratejisi
- [ ] Structured logging
- [ ] Reverse proxy + SSL terminasyonu
- [ ] Renk kontrasti auditi (WCAG AA)

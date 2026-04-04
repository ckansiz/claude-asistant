# Wcard Website - Gelistirme Yol Haritasi

> Son guncelleme: 2026-03-29
> Inceleyen: Papa Smurf (Opus)

---

## Faz 0: ACIL - Guvenlik Yamalari (1-2 gun)

Bu gorevler production'a cikmadan once MUTLAKA tamamlanmalidir.

| # | Gorev | Efor | Aciklama |
|---|-------|------|----------|
| 1 | Credential rotation | 1-2 saat | Tum API key, secret, token'lari yenile (R2, Resend, Strapi, Turnstile) |
| 2 | Scoped Strapi API token | 30 dk | Full-access token yerine least-privilege token olustur |
| 3 | User enumeration fix | 30 dk | Register/login'de generic response don |
| 4 | Purpose validation (verify.ts) | 15 dk | `as any` cast yerine whitelist validation |
| 5 | Env variable validation | 15 dk | Startup'ta zorunlu env'leri kontrol et |

---

## Faz 1: Kisa Vade - Launch Oncesi (1-2 hafta)

### Guvenlik Iyilestirmeleri
| # | Gorev | Efor |
|---|-------|------|
| 1 | CSP header ekleme | 1 saat |
| 2 | Session cookie format degisikligi (userId cikar) | 1 saat |
| 3 | SSL/TLS + reverse proxy (Caddy/Nginx) | 2-3 saat |
| 4 | CSRF token veya SameSite strict | 2-3 saat |

### Performans
| # | Gorev | Efor |
|---|-------|------|
| 5 | Font yukleme optimizasyonu (preload + swap) | 30 dk |
| 6 | CMS response caching (global settings icin) | 1 saat |
| 7 | Strapi populate=* kaldir, field-specific yap | 1 saat |

### Kod Kalitesi
| # | Gorev | Efor |
|---|-------|------|
| 8 | strapi.ts parcala (types, user, card, cms-pages, auth) | 2-3 saat |
| 9 | `any` type'lari Strapi response tiplerine cevir | 1-2 saat |
| 10 | Path alias (`@/`) tanimla | 30 dk |
| 11 | tsconfig jsx/react konfigurasyonunu kaldir (Svelte projesi) | 15 dk |

### Test
| # | Gorev | Efor |
|---|-------|------|
| 12 | API endpoint unit testleri (register, login, verify, claim, profile/update) | 3-4 saat |
| 13 | Strapi client fonksiyon testleri (mock) | 2-3 saat |
| 14 | Cypress E2E: auth flow + card claim (PRODUCTION-TASKS'ta "tamamlandi" ama dosyalar yok) | 3-4 saat |

### SEO
| # | Gorev | Efor |
|---|-------|------|
| 15 | OG gorseli olustur ve ekle | 1 saat |
| 16 | Sitemap lastmod sabit tarih | 15 dk |

---

## Faz 2: Orta Vade - Launch Sonrasi (1-2 ay)

### Altyapi
| # | Gorev | Aciklama |
|---|-------|----------|
| 1 | Redis-based rate limiting | Multi-instance icin zorunlu |
| 2 | Auth token garbage collection | Cron job ile suresi dolmuslari temizle |
| 3 | PostgreSQL backup stratejisi | pg_dump cron veya managed backup |
| 4 | Docker resource limits | CPU/memory sinirlandirmasi |
| 5 | Structured logging (JSON) | Console.error -> winston/pino |
| 6 | Monitoring/alerting | Health endpoint + uptime monitoring |

### Ozellik Gelistirme
| # | Gorev | Aciklama |
|---|-------|----------|
| 7 | Avatar yukleme (R2) | Profil fotografi upload + crop |
| 8 | Coklu dil destegi | i18n (Turkce + Ingilizce) |
| 9 | Analytics dashboard | Kart taratilma istatistikleri |
| 10 | Sosyal medya linkleri profilde | LinkedIn, Instagram, Twitter, vb. |

### Erisebilirlik
| # | Gorev | Aciklama |
|---|-------|----------|
| 11 | WCAG AA renk kontrasti auditi | axe-core ile otomatik test |
| 12 | Keyboard navigation testi | Tum formlar ve interaktif elemanlar |
| 13 | Screen reader uyumluluk testi | ARIA etiketleri gozden gecir |

---

## Faz 3: Uzun Vade (3-6 ay)

| # | Gorev | Aciklama |
|---|-------|----------|
| 1 | Kubernetes migration | Docker Compose'dan K8s'e gecis |
| 2 | CDN entegrasyonu | Cloudflare CDN ile statik asset cache |
| 3 | Webhook entegrasyonu | Kart taratildiginda webhook tetikle |
| 4 | API public endpointler | 3rd party entegrasyonlar icin public API |
| 5 | Mobil uygulama | NFC okuma + profil yonetimi (React Native) |
| 6 | A/B testing altyapisi | CMS-driven deneysel ozellikler |
| 7 | Strapi -> custom backend migration | Olcek buyudugunde Strapi'den cikmak gerekebilir |

---

## Teknik Borc Ozeti

| Kategori | Adet | Oncelik |
|----------|------|---------|
| Guvenlik yamalari | 5 | ACIL |
| Guvenlik iyilestirmeleri | 4 | Kisa vade |
| Performans | 3 | Kisa vade |
| Kod kalitesi | 4 | Kisa vade |
| Test eksiklikleri | 3 | Kisa vade |
| SEO | 2 | Kisa vade |
| Altyapi | 6 | Orta vade |
| **TOPLAM** | **27** | |

---

## Stack Notlari

Bu proje Wesoco standart stack'inden (React + shadcn/ui) farkli olarak **Svelte** kullaniyor. Bu karar Astro island architecture ile uyumlu ve performans acisindan iyi bir tercih. Ancak:

1. shadcn/ui Svelte icin resmi olarak desteklenmiyor (sadece React)
2. Gelecekte React-based projelerde ortak bilesen paylasimi mumkun degil
3. Svelte 5 (runes) yeni - topluluk ve ekosistem React'a gore dar

**Oneri:** Mevcut durumda Svelte ile devam et. Yeni ozellikler icin Svelte ecosystem'ini kullan. Buyuk bir yeniden yazim gerekmedikce stack degisikligi onermiyorum.

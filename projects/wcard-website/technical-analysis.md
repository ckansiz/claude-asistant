# Wcard Website - Teknik Analiz

> Son guncelleme: 2026-03-29
> Inceleyen: Papa Smurf (Opus)

---

## 1. Klasor Yapisi ve Organizasyon

### Deger: Iyi

Monorepo yapisi (Yarn workspaces) ile `apps/cms` ve `apps/web` temiz bir sekilde ayrilmis. Her iki uygulamanin bagimliliklari izole. Root `docker-compose.yml` ile orchestration saglanmis.

**Guzellikleri:**
- `apps/web/src/lib/` altinda concern separation (auth, strapi, email, validators, rate-limit)
- `components/interactive/` (Svelte) vs `components/ui/` (Astro) ayrimi net
- Turkce URL slug'lar (giris, uye-ol, panel, ozellikler, hakkimizda, iletisim, fiyatlandirma)
- CMS content type'lari mantiksal gruplama ile organize

**Eksikler:**
- `apps/web/src/lib/strapi.ts` dosyasi 730+ satir - cok buyuk, parcalanmali
- Path alias (`@/`) tanimli degil - relative import'lar kullaniliyor (`../../../lib/...`)
- `dist/` klasorleri hem CMS hem Web icinde commit'lenmis gibi gorunuyor (web/dist build artifact)

---

## 2. TypeScript Kullanimi

### Deger: Orta-Iyi

**Olumlu:**
- `tsconfig.json` Astro strict mode extend ediyor (`astro/tsconfigs/strict`)
- Zod validasyon semalari type export'lari ile eslesmis (`z.infer<typeof schema>`)
- Strapi client'ta tip tanimlari kapsamli (40+ interface)
- `env.d.ts` ile ortam degiskenleri tip tanimi mevcut

**Sorunlar:**
- `strapi.ts` mapper fonksiyonlarinda yogun `any` kullanimi (`mapPlan(raw: any)`, `mapUser(raw: any)`, vb.) - 10+ fonksiyonda `any` parametre
- `auth.ts`'de `cookies: any` parametresi (3 fonksiyonda) - Astro'nun `AstroCookies` tipi kullanilmali
- `tsconfig.json`'da `jsx: "react-jsx"` ve `jsxImportSource: "react"` tanimli ama proje Svelte kullaniyor - tutarsiz konfigurason
- `noUncheckedIndexedAccess` aktif degil

---

## 3. Kod Kalitesi

### Deger: Orta

**Olumlu:**
- API endpoint'leri tutarli bir patern izliyor: rate limit -> body parse -> Zod validate -> business logic -> JSON response
- Session yonetimi clean separation ile yazilmis (auth.ts -> strapi.ts)
- Error handling her endpoint'te try/catch ile sarili
- Validators tek dosyada merkezi ve Zod-based

**Sorunlar:**

#### strapi.ts Karmasikligi
730+ satirlik tek dosya. Icerik:
- 40+ interface tanimi
- 15+ CRUD fonksiyonu
- 6 CMS sayfa fetch fonksiyonu
- 5 mapper fonksiyonu
Parcalanmali: `strapi/types.ts`, `strapi/user.ts`, `strapi/card.ts`, `strapi/cms-pages.ts`, `strapi/auth.ts`

#### Console.error Kullanimi
API endpoint'lerinde (6 adet) `console.error` ile hata loglanmis. Uretim ortaminda structured logging (JSON) olmasi gereken yerde raw console cikisi var. Ancak PRODUCTION-TASKS.md'de bu P2 olarak not edilmis.

#### Naming Convention Tutarsizliklari
- Dosya isimleri genellikle kebab-case ama bazi Svelte bilesenler PascalCase (`AuthForm.svelte`, `Dashboard.svelte`) - bu Svelte icin normal
- Turkce ve Ingilizce karisik: `giris.astro` ama `auth.ts`, `email.ts`
- Commit mesajlari conventional commits'e uyuyor ama bazi eskiler (`fix: changes`, `fix: env`) cok genel

---

## 4. Bagimlilik Analizi

### apps/web (Frontend)
| Paket | Versiyon | Durum |
|-------|----------|-------|
| astro | 5.17.3 | Guncel |
| svelte | 5 | Major version, guncel |
| tailwindcss | 3.4.17 | v3 - guncel (v4'e gecilmemis, Astro v3 ile uyumlu) |
| zod | 4.3.6 | Zod 4! (yeni, cogu proje hala v3 kullaniyor - dikkatli olunmali) |
| resend | 6.9.4 | Guncel |
| @lucide/astro | 0.563.0 | Guncel |
| vitest | 3.1.0 | Guncel |

### apps/cms (Strapi)
| Paket | Versiyon | Durum |
|-------|----------|-------|
| @strapi/strapi | 5.7.0+ | Guncel |
| pg | 8.11.3 | Guncel |
| typescript | 5.7.2 | Guncel |

**Potansiyel Sorunlar:**
- Zod 4 cok yeni. API degisiklikleri olabilir. Projede `z.union([z.string().url(), z.literal("")])` gibi v4 ile calisabilecek ama gelecekte breaking change riski olan patternler var.
- `postinstall` script'i sharp-libvips icin sembolik link olusturuyor (monorepo workaround) - kirilgan

---

## 5. Test Durumu

### Deger: Orta

**Mevcut Testler:**
- `validators.test.ts`: 16 test case - kapsamli schema validasyonu
- `auth.test.ts`: 6 test case - constant'lar ve token uretimi
- `cypress/e2e/smoke/pages.cy.ts`: Sayfa yuklenme smoke testleri

**Eksikler:**
- API endpoint'leri icin hic unit/integration test yok (register, login, verify, claim, profile/update)
- Strapi client fonksiyonlari icin test yok
- Email gonderimi icin test yok
- `auth.test.ts` sadece pure fonksiyonlari test ediyor, `getSession()` ve `createSession()` icin test yok (Strapi mock'lu)
- PRODUCTION-TASKS.md'de "Minimum %80 coverage" hedefi belirtilmis ama muhtemelen cok altinda
- Cypress'te sadece 1 smoke test dosyasi var, auth-flow ve card-claim E2E testleri yok (PRODUCTION-TASKS.md'de "tamamlandi" yazsa da dosyalar mevcut degil)

---

## 6. Performans

### Deger: Orta

**Olumlu:**
- Astro SSR ile server-side rendering - sadece interaktif kisimlar Svelte island olarak yukleniyor
- Docker multi-stage build ile production image boyutu optimize
- Rate limiting ile abuse korumasi

**Sorunlar:**
- **Font yukleme:** CSS `@import` ile Google Fonts yukleniyor (global.css satir 2) - render-blocking. `<link rel="preload">` veya `font-display: swap` kullanilmali
- **Layout.astro'da her istekte CMS fetch:** `getGlobalSettings()` ve `getSession()` her sayfa yuklemesinde cagiriliyor. Strapi response'u cache'lenmemis
- **strapi.ts populate=*:** `POPULATE_ALL = "populate=*"` kullanimi - gereksiz veri cekiyor, sadece gerekli alanlar populate edilmeli (bazi fonksiyonlarda zaten field-specific populate yapilmis, tutarsiz)

---

## 7. SEO

### Deger: Iyi

- Her sayfada meta title, description, OG tags, Twitter cards
- Canonical URL tanimli
- JSON-LD structured data (Organization + WebSite)
- robots.txt dogru sitemap URL'si ile
- Sitemap dinamik (sitemap.xml.ts)
- `lang="tr"` ve `hreflang="tr"` tanimli
- Skip-to-content link mevcut

**Eksikler:**
- OG gorseli henuz yok (`/og-image.jpg` dosyasi mevcut degil)
- Sitemap `lastmod` sabit tarih degil (her build'de degisiyor)

---

## 8. Deployment ve DevOps

### Deger: Iyi

- Docker Compose ile 3 servis orchestration
- Healthcheck'ler tanimli (postgres, cms, web)
- Non-root user ile container calistirma
- Multi-stage Docker build (builder + runner)
- GitHub Actions CI pipeline (lint -> test -> build)
- `.env` git'e dahil degil (.gitignore'da)
- `.env.example` kapsamli ve dokumante

**Eksikler:**
- Docker resource limit tanimli degil (memory, CPU)
- PostgreSQL backup stratejisi yok
- SSL/TLS terminasyonu yok (reverse proxy gerekli)
- Staging ortami tanimlanmamis

---

## 9. Kod Borclari Ozeti

| Borc | Oncelik | Etki |
|------|---------|------|
| `.env` dosyasinda gercek credential'lar (git'e commit'li degil ama dosya mevcut) | KRITIK | Guvenlik |
| `strapi.ts` 730+ satir tek dosya | Yuksek | Bakimlenebilirlik |
| `any` type kullanimi (10+ yer) | Yuksek | Tip guvenligi |
| API endpoint testleri yok | Yuksek | Guvenilirlik |
| Font yukleme render-blocking | Orta | Performans |
| Path alias yok | Orta | Gelistirici deneyimi |
| CMS response cache yok | Orta | Performans |
| tsconfig jsx/react konfigurasyonu tutarsiz | Dusuk | Temizlik |
| Console.error yerine structured logging | Dusuk | Observability |

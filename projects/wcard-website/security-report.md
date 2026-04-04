# Wcard Website - Guvenlik Raporu

> Son guncelleme: 2026-03-29
> Inceleyen: Papa Smurf (Opus)
> Oncelik: Kritik -> dusuk risk siralamasiyla

---

## KRITIK RISKLER

### SEC-01: .env Dosyasinda Gercek Credential'lar
**Severity:** KRITIK
**Dosya:** `.env` (proje root)

**Bulgu:** `.env` dosyasi gercek production credential'lari iceriyor:
- PostgreSQL baglanti bilgileri (gercek IP: `172.20.20.20`)
- Strapi JWT secret'lari ve API token salt'lari
- Cloudflare R2 access key ve secret key
- Resend API anahtari
- Cloudflare Turnstile secret key
- Strapi API token (tam uzunluk)

**Risk:** `.env` dosyasi `.gitignore`'da yer aliyor ve git'e commit'lenmemis. Ancak dosya working directory'de plaintext olarak mevcut. Herhangi bir yetkisiz erisim durumunda tum servis credential'lari aciga cikar.

**Onerilen Cozum:**
1. Tum mevcut credential'lari rotate et (ozellikle R2 key, Resend API key, Strapi secret'lar)
2. `.env` dosyasini `chmod 600` ile koruma altina al
3. Production icin secret management sistemi kullan (Docker secrets, Vault, veya platform env vars)
4. CI/CD'de GitHub Secrets kullan (zaten kismen yapilmis)

---

### SEC-02: Strapi API Token Tam Yetkili (Full Access)
**Severity:** KRITIK
**Dosya:** `.env` satir 24-26

**Bulgu:** `STRAPI_API_TOKEN` full-access token olarak kullaniliyor. Web uygulamasi bu token ile Strapi'nin tum CRUD islemlerini yapabiliyor. Token'in scope'u (read-only, custom) belirsiz.

**Risk:** Web uygulamasinda bir injection veya SSRF acigi bulunursa, saldirgan bu token ile tum CMS verisini okuyabilir/degistirebilir/silebilir.

**Onerilen Cozum:**
1. Strapi'de least-privilege API token olustur: sadece gerekli content type'lara read/write
2. CMS sayfa fetch'leri icin ayri read-only token
3. Kullanici islemleri (card, profile, session) icin ayri scoped token

---

## YUKSEK RISKLER

### SEC-03: Session Token Cookie'de userId Expose Ediliyor
**Severity:** Yuksek
**Dosya:** `apps/web/src/lib/auth.ts` satir 72

**Bulgu:** Session cookie formati `{userId}:{sessionToken}`. UserId (Strapi documentId) plaintext olarak cookie'de tasinmis. Bu bilgi ile Strapi API'ye dogrudan istekler yapilanabilir.

**Risk:** Cookie'ye erisen bir saldirgan userId'yi ogrenip Strapi API'ye dogrudan istek yapabilir (eger API token baska yoldan ele gecirilirse).

**Onerilen Cozum:**
- Cookie'de sadece session token tut
- UserId'yi server-side session lookup ile coz (zaten `findSession()` bunu yapiyor)
- Cookie formatini `sessionToken` tek basina yap, userId'yi session response'undan al

---

### SEC-04: User Enumeration - Register ve Login Endpoint'leri
**Severity:** Yuksek
**Dosyalar:** `apps/web/src/pages/api/auth/register.ts`, `login.ts`

**Bulgu:**
- Register: "Bu e-posta adresi zaten kayitli" (409) -> email'in kayitli oldugu belli oluyor
- Login: "Bu e-posta adresiyle kayitli bir hesap bulunamadi" (404) -> email'in kayitli olmadigini ortaya cikariyor

**Risk:** Saldirgan email listesi ile hangi email'lerin sistemde kayitli oldugunu tespit edebilir.

**Onerilen Cozum:**
Her iki endpoint'te de ayni generic mesaj don:
```
"E-posta adresinize bir baglanti gonderdik. Kayitli degilseniz lutfen uye olun."
```
Her iki durumda da 200 don. Sadece kayitli kullanicilara email gonder (veya register durumunda farkli email).

---

### SEC-05: Magic Link Verify Endpoint'inde Purpose Casting
**Severity:** Yuksek
**Dosya:** `apps/web/src/pages/api/auth/verify.ts` satir 29

**Bulgu:** `purpose` parametresi query string'den alinip `as any` ile cast ediliyor:
```typescript
const authToken = await verifyAuthToken(token, purpose as any);
```

**Risk:** Gelen `purpose` degeri dogrulanmiyor. Saldirgan gecersiz purpose degerleri gonderebilir. `verifyAuthToken` fonksiyonu Strapi'ye filter olarak gonderdiginden SQL injection riski dusuk ama business logic bypass riski var.

**Onerilen Cozum:**
```typescript
const validPurposes = ['register', 'login', 'claim'] as const;
if (!validPurposes.includes(purpose as any)) {
  return redirect('/?error=invalid-link');
}
```

---

### SEC-06: Rate Limiter In-Memory - Bypass Edilebilir
**Severity:** Yuksek
**Dosya:** `apps/web/src/lib/rate-limit.ts`

**Bulgu:** Rate limiter in-memory `Map` kullanıyor. Birden fazla instance (horizontal scaling) durumunda her instance kendi store'una sahip olacagindan rate limit bypass edilebilir. Ayrica server restart'ta tum state kaybolur.

**Risk:** DDoS ve brute-force saldirilarina karsi yetersiz koruma (tekil instance'da calisir ama olceklenmez).

**Onerilen Cozum:**
- Kisa vadede: Cloudflare/reverse proxy seviyesinde rate limiting ekle
- Uzun vadede: Redis-based rate limiter (PRODUCTION-TASKS.md P2-1'de not edilmis)

---

## ORTA RISKLER

### SEC-07: CSRF Korumasi Eksik
**Severity:** Orta
**Dosyalar:** Tum POST API endpoint'leri

**Bulgu:** POST endpoint'lerinde (register, login, claim, profile/update) CSRF token kontrolu yok. Cookie-based session kullanildiginda CSRF riski olusur.

**Hafifletici Faktorler:**
- `sameSite: "lax"` cookie ayari cross-site POST'lari engeller (tam degil ama onemli)
- Turnstile captcha bazi form'larda ek koruma sagliyor

**Onerilen Cozum:**
- State-changing POST isteklerinde CSRF token veya double-submit cookie pattern'i ekle
- Veya `sameSite: "strict"`'e gec (UX etkileri degerlendirilmeli)

---

### SEC-08: Content-Security-Policy Header Eksik
**Severity:** Orta
**Dosya:** `apps/web/src/middleware.ts`

**Bulgu:** Guvenlik header'lari arasinda `Content-Security-Policy` (CSP) yok. XSS saldirilarina karsi onemli bir savunma katmani eksik.

**Mevcut Header'lar (iyi):**
- X-Content-Type-Options: nosniff
- X-Frame-Options: DENY
- X-XSS-Protection: 1; mode=block
- Referrer-Policy: strict-origin-when-cross-origin
- Permissions-Policy: camera=(), microphone=(), geolocation=()
- Strict-Transport-Security (sadece PROD)

**Onerilen Cozum:**
```typescript
response.headers.set('Content-Security-Policy',
  "default-src 'self'; " +
  "script-src 'self' 'unsafe-inline' https://challenges.cloudflare.com; " +
  "style-src 'self' 'unsafe-inline' https://fonts.googleapis.com; " +
  "font-src 'self' https://fonts.gstatic.com; " +
  "img-src 'self' data: https://cdn.wcard.tr; " +
  "connect-src 'self' https://challenges.cloudflare.com;"
);
```

---

### SEC-09: Auth Token Garbage Collection Yok
**Severity:** Orta
**Dosya:** Strapi `auth-token` content type

**Bulgu:** Suresi dolmus veya kullanilmis auth token'lar veritabanindan silinmiyor. Zaman icinde birikir.

**Risk:** Performans degradasyonu ve gereksiz veri birikimine yol acar. Dogmasalik guvenlik riski dusuk (token'lar zaten usedAt/expiresAt ile filtreleniyor).

**Onerilen Cozum:**
- Cron job veya Strapi lifecycle hook ile suresi dolmus token'lari periyodik sil
- `WHERE expiresAt < NOW() - interval '24 hours' OR usedAt IS NOT NULL`

---

### SEC-10: Strapi URL ve Token Environment Fallback
**Severity:** Orta
**Dosya:** `apps/web/src/lib/strapi.ts` satir 1-2

**Bulgu:**
```typescript
const STRAPI_URL = process.env.STRAPI_URL ?? import.meta.env.STRAPI_URL ?? "http://localhost:1337";
const STRAPI_API_TOKEN = process.env.STRAPI_API_TOKEN ?? import.meta.env.STRAPI_API_TOKEN ?? "";
```
Fallback olarak bos string API token kabul ediliyor. Yanlislikla production'da bos token ile calismasi mumkun.

**Onerilen Cozum:**
Startup'ta env dogrulamasi yap:
```typescript
if (!STRAPI_API_TOKEN) throw new Error('STRAPI_API_TOKEN is required');
```

---

## DUSUK RISKLER

### SEC-11: X-Powered-By Header Strapi'de Aktif
**Severity:** Dusuk
**Dosya:** `apps/cms/config/middlewares.js`

**Bulgu:** `"strapi::poweredBy"` middleware aktif. Strapi versiyonunu aciga cikarir.

**Onerilen Cozum:** Middleware listesinden kaldir veya `X-Powered-By` header'ini override et.

---

### SEC-12: Error Response'larda Fazla Bilgi
**Severity:** Dusuk
**Dosya:** `apps/web/src/lib/strapi.ts` satir 326-328

**Bulgu:**
```typescript
throw new Error(`Strapi ${res.status}: ${text}`);
```
Strapi hata mesajlari catch bloklarinda `console.error` ile loglanip generic mesaj dondurulse de, internal error mesajinin stack trace ile loglanmasi bilgi sizintisina yol acabilir.

**Onerilen Cozum:** Production'da Strapi response body'sini loglama, sadece status code logla.

---

### SEC-13: .dockerignore Kontrolu
**Severity:** Dusuk
**Dosya:** `.dockerignore`

**Bulgu:** `.dockerignore` mevcut ve `.env` dosyasini exclude ediyor. Docker build'e credential sizmasini onluyor. Bu iyi bir uygulama.

**Durum:** SORUN YOK - dogru yapilandirma.

---

## OLUMLU GUVENLIK UYGULAMALARI

| Uygulama | Durum |
|----------|-------|
| Passwordless auth (magic link) | Parola yuzey alani yok |
| httpOnly + secure + sameSite cookie | XSS ile cookie calinamaz |
| Zod server-side validasyon | Tum input'lar dogrulaniyor |
| Rate limiting (IP bazli) | Brute-force yavaslatiyor |
| Turnstile captcha | Bot korumasi |
| CORS sinirlandirmasi | Cross-origin korumasi |
| Non-root Docker container | Container escape riski azaltilmis |
| Session expiry + revoke | Uzun sureli session kontrolu |
| Auth token tek kullanimlik + TTL | Token replay korumasi |
| Sahiplik kontrolu (profile/update) | IDOR korumasi |
| .gitignore .env | Credential git'e girmez |
| .dockerignore .env | Credential image'a girmez |

---

## Oncelik Siralamasiyla Aksiyon Plani

| # | Risk | Oncelik | Efor |
|---|------|---------|------|
| 1 | SEC-01: Credential rotation | KRITIK | 1-2 saat |
| 2 | SEC-02: Scoped API token | KRITIK | 30 dk |
| 3 | SEC-04: User enumeration fix | YUKSEK | 30 dk |
| 4 | SEC-05: Purpose validation | YUKSEK | 15 dk |
| 5 | SEC-03: Cookie format degisikligi | YUKSEK | 1 saat |
| 6 | SEC-08: CSP header ekleme | ORTA | 1 saat |
| 7 | SEC-07: CSRF token | ORTA | 2-3 saat |
| 8 | SEC-10: Env validation | ORTA | 15 dk |
| 9 | SEC-06: Redis rate limit | YUKSEK | 2-3 saat |
| 10 | SEC-09: Token GC | ORTA | 1 saat |

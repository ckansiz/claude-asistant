# Blocero — UI/UX Design Research Brief

> Araştırma tarihi: 2026-03-28
> Kaynak: Web araştırması — DoorLoop, Buildium, ikas, Linear, shadcn/ui ekosistemi, SaaS landing page benchmarklar

---

## 1. Trend Landscape (2025–2026)

### SaaS Landing Page Trendleri

**Gerçek ürün ekranı hero'da** (vs abstract 3D/illustration)
2025 itibarıyla veri net: ürün screenshot içeren hero section, stock görsel veya soyut ilustrasyona göre **%20 daha yüksek dönüşüm** sağlıyor. Ziyaretçi ürünü 3 saniye içinde "görmek" istiyor.

**"Vertikal sticky scroll" feature anlatımı**
Tek sayfa üzerinde, scroll ile reveal olan özellik bölümleri (Linear, Vercel stili) vs tabbed-feature-grid. Her ikisi de iyi çalışıyor ama türk pazar için tab/accordion daha tanıdık ve güven verici.

**Hero'da micro-interaction ve demo CTA**
"36 saniyede demo al" (DoorLoop), "Hemen başla — kredi kartı gerekmez" (Stripe, Ikas varyantları). İlk dönüşüm sürtüşmesini kaldırmak kritik.

**PropTech 2025 ana mesajı:** "Tek platform" (all-in-one). Tüm büyük oyuncular feature depth'i değil, platform bütünlüğünü vurguluyor.

### Admin Panel Trendleri

**shadcn/ui + Tailwind ekosistemi dominant**
2024-2025'te open-source admin template'lerin %60+'ı shadcn/ui üzerine kurulu. Zinc-based token sistemi, collapsible sidebar, command palette (⌘K) standart hale geldi.

**Collapsible left sidebar**
240px açık → 60px icon-only kapalı. Dar ekranlarda otomatik overlay drawer. Bu pattern artık default beklenti.

**Veri yoğunluğu vs breathing room dengesi**
Türkiye'deki site yöneticisi (35-60 yaş, teknik değil) için çok yoğun tablo arayüzleri çalışmıyor. Stat kartları → özet tablo → detay akışı daha güvenli.

### Kaçınılması Gereken Anti-Pattern'lar

| Anti-Pattern | Neden Kötü |
|--------------|-----------|
| Full-screen dark hero + floating glassmorphism cards | 2022-2023 trendi, artık "AI startup template" görünüyor |
| 6+ farklı section background rengi | Scatter effect — dikkat dağıtır |
| Hero'da animasyonlu gradient orb / blob | Jenerik AI aesthetik, güven vermiyor |
| "World-class", "revolutionary" micro-copy | Boş marka dili, TR pazar için özellikle etkisiz |
| Tüm dashboard'ı hero'ya koymak | Kullanıcı ne gördüğünü anlamıyor |
| Sonsuz feature listesi (30+ madde) | Feature overwhelm — conversion killer |
| Admin panel: 15+ sidebar item açık | Karmaşıklık algısı, yönetici olmak istemez |

---

## 2. Real-World Inspiration Table

| Referans | URL | Ne Alınabilir | Risk / Kaçınılacak |
|----------|-----|--------------|-------------------|
| **DoorLoop** | doorloop.com | Text-first hero, "X saniyede demo" CTA, star-rating sosyal kanıt bar'ı, mega menu yapısı | Renk paleti Blocero ile uyuşmuyor (mavi/pembe), çok yoğun içerik |
| **Linear** | linear.app | Minimal typography, dark background hero, feature reveal scroll, kelime ekonomisi | Çok teknik/developer odaklı; site yöneticisi hedef kitleye soğuk gelebilir |
| **Ikas** | ikas.com | Türk SaaS güven sinyalleri (müşteri sayısı, yatırımcı logo, kurucu görünürlüğü), "Ücretsiz başla / Demo al" dual CTA | Renk farklı (mavi), e-ticaret bağlamı |
| **Buildium** | buildium.com | Split hero (text + dashboard screenshot), vertical feature tabs, "property manager" persona specificity | Yeşil renk, çok US-market odaklı |
| **shadcn/ui Dashboard** | ui.shadcn.com/examples/dashboard | Sidebar yapısı, stat card layout, data table pattern, component token sistemi | Bu bir example — doğrudan kopyalanmamalı |
| **Supabase** | supabase.com | Dark hero → light içerik geçişi, terminal/code aesthetic, güçlü "open source" trust signal, bento grid | Çok developer-centric; non-technical kitleye uyarlanmalı |
| **Notion** | notion.so | Light, minimal, typography-led, "one tool for everything" mesajı | Çok generic artık; farklılaşmak için spesifik Blocero özelliklerini öne çıkar |
| **Vercel** | vercel.com | Dark + gradient banner, bold statement hero, feature showcase bento, enterprise badge | Çok premium/developer; Blocero'nun warmth'ından uzak |

---

## 3. Blocero Marketing Landing Page — Layout Direction Options

### Direction A: "Güven ve Basitlik" (Trust-First, Content-Led)

**Referans ruhu:** DoorLoop + Ikas hibrid. Navy üzerine değil, beyaz zemin üzerinde navy.

**Section Sırası:**
```
1. Sticky Nav — logo + nav links + "Ücretsiz Başla" CTA (navy fill)
2. Hero — Eyebrow badge ("Türkiye'nin ilk apartman ekosistemi"),
           H1 büyük başlık, 2 satır subtext, dual CTA + dashboard screenshot sağda
3. Trust Bar — "X site güveniyor · iyzico güvenceli · KVKK uyumlu" + logo strip
4. Problem/Solution — 3 card: "WhatsApp çağrıları · Aidat kaçakları · Kapıcı takibi yok"
                      → "Blocero ile bunlar geçmişte kaldı"
5. Feature Grid — 6 kart, icon + başlık + 2 satır açıklama (Tabs: Yönetici / Sakin / Kapıcı)
6. Differentiator Section — Hiperlokal Reklam: "Siz yönetirken platform kazanır"
                            → gelir modeli açıklaması + mock-up ads panel
7. Social Proof — Müşteri yorumları (3 kart, yer adı + daire sayısı)
8. Pricing — Freemium prominently: "Ücretsiz başla · Reklam gelirinizle büyüyün"
9. Final CTA — Full-width navy banner, tek CTA
10. Footer
```

**Hero Yaklaşımı:** Split layout — sol text, sağ dashboard screenshot (yönetici paneli özeti, anonymized data). Screenshot hafif tilted (perspective transform, -5deg).

**Renk Kullanımı:** Beyaz dominant, navy text + CTA, kırmızı sadece accent (badge, alt çizgi, icon accent). Section backgrounds: white / `#F8F9FC` alternating.

**Diferansiyatör Vurgusu:** Ayrı bir full-width section, subtle navy background, "Hiperlokal Reklam" başlığı, küçük harita ilustrasyon + "Site sakinleriniz bu reklamları görürken siz komisyon alırsınız" copy.

**Risk:** Conservative görünebilir. Rakiplerden yeterince farklı olmayabilir görsel olarak.

---

### Direction B: "Cesur Öne Çıkış" (Bold Differentiator)

**Referans ruhu:** Vercel dark hero → Supabase mid-page geçiş. Ama navy sıcaklığında.

**Section Sırası:**
```
1. Sticky Nav — logo + nav + "Demo İste" ghost + "Ücretsiz Başla" navy fill
2. Hero — Full dark navy (brand rengi) background
           Eyebrow: "Rakip yazılımlardan %3 commission alıyoruz, siz değil"
           H1: "Apartmanınızı Yönetin. Gelirinizi Büyütün."
           Subtext: hiperlokal reklam açıklaması
           CTA: "Ücretsiz dene" (kırmızı/accent fill)
           Merkez: animated dashboard mockup (hero içinde floating)
3. Stats Bar — beyaz zemin: "X bağımsız bölüm · Y aktif ödeme · Z reklam vereni"
4. "Rakiplerden Farkımız" Table — karşılaştırma tablosu (Blocero vs Genel Rakip)
   Sütunlar: Hiperlokal reklam / Kapıcı yönetimi / Freemium / Mobil uygulama
5. Feature Bento Grid — büyük/küçük card karışımı (6 cell)
   Ana cell: Kapıcı yönetimi (full width) — çünkü unique
   Orta cells: aidat, gider, duyuru, oylama
6. Gelir Modeli Section — "Blocero sadece size hizmet etmez, size para kazandırır"
   Adım adım gelir akışı: Sakin ödedi → iyzico → Blocero → Yönetici komisyon
7. Mobile App Showcase — Phone mockup grid (Sakin / Kapıcı / Yönetici ekranları)
8. Pricing Comparison — 3 col: Ücretsiz / Kurumsal / Reklam Geliri (ek col)
9. Final CTA — kırmızı background strip, tek mesaj
10. Footer
```

**Hero Yaklaşımı:** Dark navy full-width, merkez floating dashboard card (subtle glow, 0 0 40px rgba(navy,0.3) shadow), eyebrow badge kırmızı renkte.

**Renk Kullanımı:** Dark navy hero → light body geçişi. Kırmızı CTA + accent. Bento grid'de navy card background bazı hücrelerde.

**Diferansiyatör Vurgusu:** Hero'da, ikinci satırda, F7F7F7 yerine direkt "rakiplerinden fark" karşılaştırma tablosu (Feature comparison section). Kapıcı yönetimi ve hiperlokal reklam "✓ Sadece Blocero'da" badge'leriyle.

**Risk:** Çok satış odaklı görünebilir. "Rakipleri yok sayıyoruz" yaklaşımı bazı kullanıcıları itebilir. Dark hero Türk pazar için conservative kategoriye kıyasla daha riskli.

---

## 4. Blocero Admin Panel — Layout Direction Options

### Direction A: "Profesyonel Yönetici" (Data-Dense, Sidebar-Led)

**Referans ruhu:** shadcn/ui dashboard example + DoorLoop web panel

**Layout:**
```
┌─────────────────────────────────────────────┐
│ Topbar: Search  ·  Notifications  ·  Avatar │
├──────────┬──────────────────────────────────┤
│          │  4 Stat Card (aidat/gider/sakin) │
│ Sidebar  │  ─────────────────────────────  │
│ 240px    │  Aidat Durumu Tablosu            │
│          │  (Bu ay bekleyen ödemeler)       │
│ collapse │  ─────────────────────────────  │
│ → 60px   │  Son Giderler  |  Duyurular      │
│          │                                  │
└──────────┴──────────────────────────────────┘
```

**Sidebar Navigasyonu:**
- Dashboard
- Sakinler
- Aidat Takibi ← primary action
- Giderler
- Duyurular
- Oylamalar
- Karar Defteri
- Kapıcı Yönetimi
- Ayarlar

**Renk:** Sidebar `#1B2B5E` navy, beyaz ikon/text. Active item: `rgba(255,255,255,0.12)` background + sol border `#E32B2B`. Topbar: beyaz, subtle shadow.

**Veri yoğunluğu:** Orta-yüksek. Stat kart + tablo ağırlıklı. Teknik olmayan kullanıcı için ek açıklama mikro-copy'ler (empty state, hint text).

**Risk:** Çok item görünce "karmaşık" algısı. 8+ sidebar item açık olunca göz kayıyor.

---

### Direction B: "Kolay Yönetim" (Whitespace, Action-First)

**Referans ruhu:** Notion-like whitespace + Linear sidebar simplicity

**Layout:**
```
┌──────────────────────────────────────────────┐
│ Logo  ·  Blocero           Bildirim  Avatar  │
├──────┬───────────────────────────────────────┤
│      │  Günaydın, Ahmet!  Bugün 3 bekleyen  │
│ Nav  │  ─────────────────────────────────── │
│ 5    │  [Aidat Topla] [Gider Ekle] [Duyuru] │
│ item │  Quick Actions (3 büyük buton)        │
│ only │  ─────────────────────────────────── │
│      │  Bu Haftanın Özeti (mini stat cards)  │
│      │  ─────────────────────────────────── │
│      │  Bekleyen Görevler (activity feed)   │
└──────┴───────────────────────────────────────┘
```

**Sidebar Navigasyonu (sadeleştirilmiş):**
- Genel Bakış
- Aidat & Ödemeler
- Giderler
- Duyurular & Oylamalar
- Kapıcı

**Renk:** Sidebar daha açık — `#F1F4FA` light navy tint, navy text (değil beyaz). Active item: `#E8EDF8` + sol `#1B2B5E` border. Beyaz dominant gövde.

**Veri yoğunluğu:** Düşük. Hero aksiyonlar → özet → detay hiyerarşisi. Site yöneticisi için "ne yapmalıyım bugün?" sorusunu cevaplayan bir dashboard.

**Risk:** Feature depth hissi daha az. Power user için yetersiz gelebilir. Raporlama isteyen kurumsal müşteri "az şey" görüyor.

---

## 5. Visual Language Recommendations

### Renk Kullanım Kılavuzu

| Rol | Renk | Kullanım |
|-----|------|---------|
| Primary action | `#1B2B5E` Navy | Ana CTA buton, sidebar bg, heading |
| Accent / CTA variant | `#E32B2B` Red | Danger button, badge-error, "öne çıkan" CTA |
| Success | `#16A34A` Green | Ödeme yapıldı, onaylandı state |
| Warning | `#D97706` Amber | Gecikmiş aidat, uyarı badge |
| Background | `#F8F9FC` | Page body (değil saf beyaz) |
| Card | `#FFFFFF` border `#E2E8F0` | Tüm card'lar |
| Sidebar active accent | `#E32B2B` left border | Aktif nav item |

**Kural:** Kırmızı `#E32B2B` sadece accent ve danger için. CTA primary → navy. Kırmızı hero'da overwhelm yaratır, dikkatli kullan.

### Typography

DM Sans kullanılacak — doğru hiyerarşi kritik:

| Level | Boyut | Weight | Kullanım |
|-------|-------|--------|---------|
| Display | 48-64px | 700 | Landing page H1 |
| H2 | 32-40px | 700 | Section başlıkları |
| H3 | 20-24px | 600 | Card başlıkları |
| Body | 16px | 400 | Açıklamalar |
| Small | 14px | 400 | Meta, caption |
| Micro | 12px | 500 | Badge, label |

Line-height: 1.5 body, 1.2 heading. Letter-spacing: -0.02em display için (DM Sans bold sıkışır).

### İkon & İllüstrasyon

- **Lucide Icons** — stroke-width: 1.5 (ince ama okunabilir). Boyut: 20px regular, 24px feature card, 16px inline.
- **İllüstrasyon:** YOK — soyut illustrasyon yerine gerçek UI screenshot kullan (daha güvenilir, %20 yüksek conversion)
- **Dashboard screenshot treatment:** Beyaz kart içinde, `box-shadow: 0 25px 50px rgba(0,0,0,0.12)`, hafif border `1px solid #E2E8F0`
- **Harita:** Hiperlokal reklam bölümü için basit SVG Türkiye haritası (ilçe highlight), Google Maps embed değil

### Sosyal Kanıt Hiyerarşisi (Türk Pazar)

1. **Müşteri adeti + şehir** — "Trabzon'daki 47 site Blocero'ya geçti"
2. **iyzico logosu + "Güvenli Ödeme"** — ödeme güvencesi kritik
3. **KVKK uyumlu** — veri gizliliği endişesi yüksek
4. **Kurucu/ekip görünürlüğü** — ikas örneği, Türk pazarda güven için kurucu profili etkili
5. **Star rating** (G2/Capterra) — erken aşamada yoksa: "İlk 100 kullanıcıya ücretsiz onboarding"

---

## 6. Wireframe Direction Recommendation

### Landing Page için: **Direction A + Direction B mix** — ama ayrı wireframe'ler

**Önerim:** Her ikisi de güçlü, checkpoint'te kullanıcı karar versin. Ancak Blocero'nun Türk pazarına güven vermesi gerektiğinden **Direction A** daha az riskli. Direction B'nin karşılaştırma tablosu ise rakip konumlandırması için güçlü — bu element A'ya da eklenebilir.

### Admin Panel için: **Direction A** (sidebar-led)

Yönetici dashboard'u — aidat takip, gider, kapıcı — veri yoğun operasyon gerektiriyor. Direction A'nın sidebar navigation depth'i daha uygun. Direction B'nin "quick action" yaklaşımı onboarding / boş state için kullanılabilir ama ana dashboard için yetersiz.

---

## Kaynaklar

- [DoorLoop](https://www.doorloop.com) — property management SaaS referans
- [Buildium](https://www.buildium.com) — split hero + feature tabs
- [ikas](https://ikas.com) — Türk SaaS güven sinyalleri referansı
- [shadcn/ui Dashboard Example](https://ui.shadcn.com/examples/dashboard)
- [Lapa Ninja SaaS](https://www.lapa.ninja/category/saas/) — modern SaaS landing örnekleri
- [SaaS Landing Page Best Practices](https://procreator.design/blog/saas-landing-page-best-ui-design-practices/)
- [B2B SaaS Hero Section Conversion Data](https://screenhance.com/blog/saas-landing-page-screenshots)
- [PropTech Trends 2026](https://www.buildium.com/blog/proptech-trends-to-know/)

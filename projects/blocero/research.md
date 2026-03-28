# Blocero — Rekabet & Teknoloji Araştırması

> Araştırma tarihi: 2026-03-28
> Kaynak: Web araştırması — Türk apartman/site yönetim yazılımı piyasası

---

## 1. Rakip Analizi

| Rakip | Öne Çıkan Özellikler | Fiyatlandırma | Mobil Uygulama | Zayıf Nokta |
|-------|---------------------|---------------|---------------|-------------|
| **Konsiyon** | Banka entegrasyonu, plaka tanıma, komisyonsuz sanal POS, sınırsız bildirim | Yıllık sabit fiyat (tüm modüller dahil, %15 artış tavanı) | iOS + Android (yönetici + sakin — ayrı) | Fiyat kamuya açık değil |
| **Yönetimcell** | 12 taksit ödeme, tüm banka entegrasyonu, self-hosted seçeneği | Kamuya açık değil | iOS + Android (3 ayrı uygulama) | 15+ yıllık ürün, eski UI; hosting karmaşık |
| **NET YÖNETİM** | WhatsApp entegrasyonu, 6 ay ücretsiz, EHO banka okuma, 12 taksit | ~10 TL/bağımsız bölüm/ay (kampanya) | iOS + Android | Fiyat kampanyaya bağlı, uzun vade belirsiz |
| **Aidat.ai** | 15.000+ bağımsız bölüm, 125 site, rezervasyon, duyuru | Bilinmiyor | Var | Yeni (~2023), referans sayısı sınırlı |
| **ApartSoft** | Banka entegrasyonu, Excel/PDF raporlama, 30 gün ücretsiz deneme | Birim bazlı, teklif gerekiyor | **Yok** (mobil tarayıcı; uygulama "yolda") | Mobil uygulama eksikliği ciddi dezavantaj |
| **Bizimsiteyonetimi (BSY)** | Muhasebe + aidat takip, SMS paketi dahil | ~20 TL/bağımsız bölüm/ay; çok yıl indirimi | iOS + Android | Temel özellik seti, banka entegrasyonu belirsiz |
| **VAYONET** | Personel yönetimi, Huawei AppGallery, otomatik iş emri takibi | Kamuya açık değil | iOS + Android + Huawei | Şeffaf fiyat yok |
| **Vatansiteyonetimi** | SMS paketi dahil, birim bazlı fiyat | Kamuya açık (birim bazlı) | Belirtilmemiş | Marka bilinirliği düşük |

> **Not:** PRD'de adı geçen SiteBox, Daire360, YönetimNet arama sonuçlarında çıkmadı — ya pazar payı çok küçük, ya rebranding yaptılar, ya da pasif.

### Rekabet Boşlukları

- **Hiperlokal reklam geliri:** Hiçbir rakipte yok — Blocero'nun en güçlü diferansiyatörü
- **Fiyat şeffaflığı:** Rakiplerin çoğu fiyat gizliyor — Blocero açık freemium ile öne çıkabilir
- **Modern UX:** Çoğu rakip eski tasarım — DM Sans + temiz UI büyük avantaj
- **ApartSoft'un mobil eksikliği:** Hedeflenebilecek müşteri segmenti

---

## 2. iyzico Değerlendirmesi

### Komisyon Oranları (2025)

| İşlem Tipi | Oran |
|------------|------|
| Tek çekim (ticari) | %2,19 + 0,25 TL (KDV hariç) |
| Taksitli | %3,99 + 0,25 TL + banka vade farkı |
| Yurtdışı kart | %4,5 + işlem ücreti |
| Başlangıç ücreti | **Yok** |

### Güçlü Yönler
- BDDK + PCI-DSS Level 1 sertifikası
- Türk pazarında en yaygın tanınan payment gateway
- Hızlı entegrasyon (SDK + checkout form)
- Lisans sorunu yok — doğrudan kullanılabilir

### Zayıf Yönler
- Şikayetvar'da ödeme gecikme şikayetleri mevcut
- Müşteri hizmetleri yavaş yanıt reputation'ı
- Ticari hesap kurulumu: vergi levhası + imza sirküleri (1-2 hafta)

**Karar:** Faz 1 için iyzico. Craftgate alternatif; kendi sanal POS anlaşması Faz 2'de değerlendirilebilir.

---

## 3. Stack Önerileri — Faz 1 (50 Site Pilot)

### Backend: NestJS Modüler Monolit (PRD'yi destekliyor)

Araştırma bulgusu nettir: startup aşamasında microservices gereksiz yük getirir.

| Yaklaşım | Faz 1 için |
|----------|-----------|
| Microservices | ❌ — Operasyonel yük, DevOps maliyet, iterasyon yavaşlığı |
| Modüler Monolit | ✅ — Hızlı iterasyon, tek deployment, net module boundary |

**Geçiş noktası:** 500+ site veya ekip 5+ kişiye çıkınca microservice değerlendirmesi.

NestJS modüler yapı, PRD'deki "Clean Architecture + CQRS" yaklaşımıyla uyumlu. Modüller: `auth`, `sites`, `residents`, `payments`, `announcements`, `ads`.

### Mobile: Expo Managed Workflow

2025'te React Native core team bare workflow yerine Expo'yu öneriyor.

| Faktör | Expo Managed |
|--------|-------------|
| OTA Update | ✅ EAS ile store review beklemeden JS fix |
| Native Module | Config Plugins ile kamera, push notification |
| Bare'e geçiş | Her zaman mümkün |
| Aidat uygulaması fit | ✅ Custom native module ihtiyacı düşük |

### Ödeme Akışı

```
Faz 1: iyzico checkout form
Faz 2: kendi sanal POS anlaşması (işlem hacmi kanıtlanınca)
Faz 3: TCMB ödeme kuruluşu lisansı (opsiyonel, uzun vadeli)
```

---

## 4. TCMB/BDDK Lisans Gereksinimleri

> **Kritik:** 1 Ocak 2020'den itibaren ödeme kuruluşu lisansları **TCMB** veriyor (BDDK değil).
> Yasal dayanak: 6493 sayılı Kanun

| Gereksinim | Detay |
|------------|-------|
| Asgari sermaye | 2.000.000 TL |
| Başvuru ücreti | 500.000 TL |
| Süreç süresi | 12-18 ay |
| Gerekli belgeler | 3 yıllık iş planı, finansal projeksiyon, PCI-DSS uyumluluk, KVKK altyapısı, AML/CFT sistemi |

**Pratik karar:** Faz 1-2'de kendi lisansı için uğraşmayın. Pazar kanıtlandıktan (500+ site, aylık ~1M TL+ işlem) sonra lisans sürecine girilmesi önerilir.

---

## 5. Top 5 Risk

| # | Risk | Etki | Azaltma Stratejisi |
|---|------|------|-------------------|
| 1 | **Banka EHO entegrasyon gecikmesi** | Tüm rakiplerde otomatik banka okuma var; eksikse ürün zayıf görünür | Faz 1 başında banka API partnership görüşmesi başlatılmalı; geç kalınırsa manuel import fallback |
| 2 | **iyzico ödeme gecikmeleri** | Sakin ödedi, yönetici hesabına geç geçti → güven kaybı | İlk aylarda küçük yerleşimlerde test; SLA izleme dashboard'u |
| 3 | **Rakiplerin fiyat kırması** | NET YÖNETİM 10 TL/birim gibi agresif fiyatla pazar alabilir | Diferansiye değer: hiperlokal reklam, daha iyi UX, gerçek zamanlı raporlama |
| 4 | **KVKK compliance borcu** | Site sakini kişisel verisi işleniyor; denetim riski | Faz 1'de veri işleme envanteri + açık rıza akışı |
| 5 | **Mobil push notification kurulumu** | Aidat bildirimi temel değer önerisi; Apple izin akışı + Firebase setup zaman alır | Expo EAS Push erken entegre edin |

---

## 6. Açık Mimari Sorular

1. **Multi-tenant mimari:** Tek DB + `tenant_id` mi, schema-per-tenant mi?
   → 50 pilot için tek şema yeterli; 500+ için performance sorunu olabilir

2. **Banka entegrasyon yöntemi:** EHO için hangi aggregator?
   → Fineksus, Param, Papara API değerlendirmesi gerekiyor

3. **Aidat gecikme faizi hesabı:** Yasal kural mı, serbest mi?
   → Türk mevzuatı net kurallar koyuyor — early architecture'a girmeli

4. **Birincil müşteri:** Yönetim şirketleri (B2B SaaS) mi, bina yöneticileri (SMB) mi?
   → Bu karar fiyatlandırma ve feature önceliğini doğrudan etkiler

5. **Offline-first mobil:** Zayıf bağlantıda ödeme senaryosu?
   → Cache + sync stratejisi gerekiyor mu — erken karar gerekiyor

---

## Kaynaklar

- [Aidat.ai](https://aidat.ai/)
- [Konsiyon](https://konsiyon.com/apartman-yonetim-programi)
- [Yönetimcell](https://www.yonetimcell.com/)
- [NET YÖNETİM](https://netyonetim.com/)
- [ApartSoft](https://www.apartsoft.com/)
- [Bizimsiteyonetimi Fiyatlandırma](https://www.bizimsiteyonetimi.com/fiyatlandirma)
- [VAYONET](https://vayonet.com/)
- [iyzico Komisyon Oranları](https://www.ticimax.com/blog/iyzico-komisyon-oranlari)
- [TCMB Ödeme Kuruluşu Lisansı](https://www.finwiseconsulting.com/2022/odeme-ve-elektronik-para-kurulusu-kurma/)
- [NestJS Microservices vs Monolith 2025](https://kodekx-solutions.medium.com/microservices-vs-monolith-decision-framework-for-2025-b19570930cf7)
- [Expo vs Bare React Native 2025](https://www.godeltech.com/blog/expo-vs-bare-react-native-in-2025/)

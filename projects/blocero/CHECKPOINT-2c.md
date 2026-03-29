---
project: Blocero
phase: Design
checkpoint: 2c
status: PENDING_USER_DECISION
date: 2026-03-29
---

# CHECKPOINT 2c — Design Seçimi

## Durum

Her iki landing page tasarımı tamamlandı. Kullanıcıdan seçim bekleniyor.

## Tasarımlar

| Dosya | Konsept | Öne Çıkan Özellik |
|-------|---------|-------------------|
| `designs/design-landing-a.html` | "Akıllı Yönetim" | Temiz layout, feature grid, soft navy tones |
| `designs/design-landing-b.html` | "Cesur Öne Çıkış" | Dark hero, floating dashboard card, kırmızı aksanlar, competitor comparison table |

## Tasarım Sistemi (her ikisinde ortak)

- **Renkler:** `--navy: #1B2B5E`, `--red: #E32B2B`, `--white: #FFFFFF`
- **Font:** DM Sans (Google Fonts CDN)
- **İkonlar:** Lucide CDN
- **Breakpoints:** Mobile 320px / 768px / 1024px / 1440px

## Sonraki Adım

Kullanıcı A veya B seçimini onaylayınca → **Phase 3: Development** başlar:

1. Hefty Smurf → Next.js scaffold
2. Painter Smurf → seçilen tasarımı uygular
3. Handy Smurf → backend (API endpoints)
4. Brainy Smurf → review

## Notlar

- Blocero: apartman yönetimi + hiperlokal reklam SaaS platformu
- 3 kullanıcı rolü: Yönetici, Sakin, Kapıcı
- Freemium model + reklam geliri paylaşımı (%15 komisyon)
- Stack kararı: Next.js (frontend) + .NET 10 (backend) — henüz Dreamy Smurf onayı alınmadı

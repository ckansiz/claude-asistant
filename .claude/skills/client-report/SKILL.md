---
name: client-report
description: This skill should be used when the user asks to "write a status update", "send daily progress", "prepare a delivery report", "weekly summary", "client update in Turkish", or invokes /client-report. Produces client-facing Turkish reports — daily status, delivery handoff, weekly summary — separate from developer-facing Handoff/Review/Test reports.
version: 1.0.0
---

# Client Report Templates

Apply when writing reports **for the client** (not the developer loop). Cem's clients are mostly Turkish-speaking, non-technical, and care about *what it does*, *when they'll see it*, *what's left*. Reports must be short, concrete, and honest.

Developer-facing reports (`Builder Handoff`, `Code Review`, `Test Report`) live in `orchestration` skill — those are internal. Client reports are external.

## Tone & Style Rules

- Language: **Turkish** (unless the client asks otherwise)
- No jargon without a one-line plain-language gloss
- Lead with outcome, not process ("Login sayfası hazır" > "`AuthController.cs` dosyasında değişiklik yapıldı")
- Honest on blockers and delays — always with a proposed next step
- Never over-promise dates without a buffer
- Link artifacts (PR, preview URL, screenshot, video) — clients trust what they can see

## Report Types

### 1. Günlük / Sprint Status Update (short, frequent)

5 sentences max. Use when work is in progress and client wants regular visibility.

```markdown
**{Proje} — Durum Güncellemesi — {YYYY-MM-DD}**

**Bugün tamamlanan:**
- {iş 1}
- {iş 2}

**Devam eden:**
- {iş} — %{tahmini ilerleme}

**Engel / bekleyen cevap:**
- {varsa: soru, erişim, onay. Yoksa: "Yok."}

**Sonraki adım:**
- {somut bir şey, tarihli}
```

### 2. Teslim Raporu (end of feature / milestone)

Use at the end of a feature, bug fix, milestone, or sprint. Goes in the PR body (Turkish section) **and** as a message to the client.

```markdown
**{Proje} — Teslim Raporu — {YYYY-MM-DD}**

## Ne yapıldı
- {kısa, kullanıcı diliyle. Teknik terim gerekiyorsa parantez içinde açıkla}

## Nasıl test edildi
- {manuel test: hangi akış, hangi cihaz}
- {otomatik: kaç test, hepsi geçti mi}
- {preview URL: ... }

## Bilinen kısıtlar / ileride yapılacak
- {varsa — dürüst ol, "hiç yok" nadiren doğrudur}

## Kullanım notu (varsa)
- {admin paneline nasıl girilir, yeni alan nerede, vb.}

## Geri bildirim için
- {preview URL'de test et, {tarih}'e kadar yorum bekliyorum}
```

### 3. Haftalık Özet (retainer / ongoing work)

Use for ongoing clients — Friday summary, Monday plan.

```markdown
**{Proje} — Haftalık Özet — {hafta aralığı}**

## Bu hafta biten
- {iş} — canlıda / test ortamında / PR'da
- {iş} — ...

## Bu hafta başlayan ama devam eden
- {iş} — {durum}, {kalan tahmini}

## Önümüzdeki hafta
- {öncelik 1}
- {öncelik 2}
- {öncelik 3}

## Beklenen onay / cevap
- {sizden} — {ne için, ne zamana kadar}

## Not
- {varsa: tatil, release freeze, deploy uyarısı}
```

### 4. Kesinti / Hotfix Raporu (incident)

Use after a production incident. Short, factual, no blame. Send during **and** after.

```markdown
**{Proje} — Kesinti / Düzeltme Raporu — {YYYY-MM-DD HH:mm TRT}**

## Ne oldu
{bir cümle — kullanıcıya etki odaklı: "{HH:mm}–{HH:mm} arası checkout sayfası çalışmadı"}

## Etki
- Etkilenen kullanıcı: {tahmin, ya da "tüm kullanıcılar"}
- Süre: {dakika}
- Kayıp veri: {var / yok — emin değilsek: "doğrulanıyor"}

## Sebep
{1-2 cümle, teknik detay parantezde}

## Şu anda
- [x] Sorun giderildi
- [x] Canlıda doğrulandı
- [ ] Kalıcı çözüm (PR #X, önümüzdeki {gün})
- [ ] Postmortem yazılacak

## Bundan sonra tekrar olmaması için
- {somut aksiyon}
```

### 5. Proje Teslim / Handoff (end of project)

Use when a project is delivered to the client (or to another dev). Companion to `client-handoff` skill.

```markdown
**{Proje} — Proje Teslim Paketi — {YYYY-MM-DD}**

## Teslim edilen
- Canlı URL: ...
- Admin paneli URL + giriş: {ayrı kanaldan / şifre yöneticisinden}
- Kaynak kod: {repo link, branch}
- Dokümanlar: README, docs/ klasörü

## Kapsam özeti
- {madde madde — ne teslim edildi, ne edilmedi}

## Canlıya çıkmadan kontrol listesi
- [ ] DNS doğrulandı
- [ ] SSL aktif
- [ ] E-posta gönderimi çalışıyor
- [ ] Analytics kurulu
- [ ] Backup kurulu
- [ ] {proje-özel kontrol}

## Bakım ve destek
- {garantili destek kapsamı: {süre}, {saat}}
- İletişim: {kanal}
- Acil durum: {telefon/WhatsApp + saat aralığı}

## Fatura
- {tutar, tarih, IBAN veya ödeme linki}
```

## Invocation Shortcuts

When invoked via `/client-report` with an argument, map like so:

| Argument | Template |
|----------|----------|
| `daily` / `günlük` / `status` | Daily Status Update |
| `delivery` / `teslim` | Teslim Raporu |
| `weekly` / `haftalık` | Haftalık Özet |
| `incident` / `kesinti` / `hotfix` | Kesinti / Hotfix Raporu |
| `handoff` / `proje-teslim` | Proje Teslim Paketi |

If no argument, ask which one (or infer from context — post-merge → delivery, after incident → incident).

## Before Sending

Check:
- [ ] Dates / times are correct (TRT timezone explicit for incidents)
- [ ] All "{placeholder}" replaced
- [ ] No internal jargon (AST, DTO, JWT…) without gloss
- [ ] No developer-internal notes leaked (backlog items, refactors)
- [ ] Links work (preview URL reachable, PR accessible to client if they have repo access — otherwise screenshot)
- [ ] Turkish grammar + spelling — clients notice

## Where to Save

- Daily status → Slack/WhatsApp only, no file
- Delivery report → PR body `## Changelog` section (Turkish) + send as message
- Weekly summary → `docs/reports/weekly-{YYYY-WW}.md` + send as message
- Incident → `docs/reports/incidents/{YYYY-MM-DD}-{slug}.md` + send as message
- Project handoff → `docs/handoff/{YYYY-MM-DD}.md` + send as message

## Anti-Patterns

- "Bir kaç küçük düzeltme yaptım" — vague, builds no trust
- Dumping git log output — client doesn't read that
- Listing every file changed — client cares about user-visible outcomes
- Over-apologizing for bugs — explain + fix, don't grovel
- Sending Turkish AND English copy of the same report — pick one

## Companion Skills

- `client-handoff` — full project onboarding/delivery (this skill is the communication layer)
- `commits` — conventional commit messages (different audience — fellow developers)
- `orchestration` — internal developer-facing reports
- `intake` — the brief this report loop refers back to

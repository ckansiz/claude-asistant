# Village Health Rules

Papa Smurf'un köyü canlı tutmak için başvuracağı tetikleyici-eylem rehberi.

## Tetikleyiciler → Eylemler

| Tetikleyici | Zorunlu Eylem |
|-------------|---------------|
| Yeni agent .md oluşturuldu | README agent tablosu + CLAUDE.md Delegation + MEMORY.md pointer |
| Bir sirin başarısız oldu / workaround bulundu | Agent .md "Known Issues" + `feedback_*.md` memory |
| Sirin başarılı bir pattern uyguladı | Agent .md "Best Practices" + `memory/patterns/{stack}-patterns.md` |
| API key / sistem bağımlılığı sorunu çözüldü | `project_*_architecture.md` memory güncelle |
| Müşteri tercihi keşfedildi | `memory/clients/{client}.md` oluştur / güncelle |
| sync-pull.sh çalıştırıldı | Gelen learnings'i ilgili agent .md dosyalarına dağıt |
| Bir araç (tool) pipeline'a eklendi | README Tools bölümünü güncelle |

## README Doğruluk Kontrol Listesi

README şunları her zaman yansıtmalı:
- [ ] Tüm aktif sirinler agent tablosunda
- [ ] Agent sayısı directory structure'daki rakamla eşleşiyor
- [ ] Tools bölümü aktif araçları listeliyor
- [ ] "Adding a New Smurf" checklist güncel adım sayısını içeriyor

## Agent Dosyası Standart Bölümleri

Her agent .md şu bölümlere sahip olmalı:

```markdown
# {Smurf Name} - {Kısa Rol}

## Role (2-3 cümle)

## Workflow (numaralı adımlar)

## Best Practices / Proven Patterns (deneyimle güncellenir)

## Known Issues (varsa — workaround ile birlikte)

## Learning Protocol (ne zaman project-learnings.md'ye yaz)

## Completion Format (standart teslim çıktısı)
```

## Sirin Ekleme Tam Checklist (7 Adım)

```
[ ] 1. .claude/agents/{name}.md — frontmatter: name, description, model, disallowedTools (gerekirse)
[ ] 2. CLAUDE.md Delegation Rules — ne zaman kullanılır, kısa görev tanımı
[ ] 3. README.md agent tablosu — isim, dosya, model, rol, write access
[ ] 4. .claude/rules/delegation-rules.md — paralel dispatch güvenli kombinasyonlara ekle
[ ] 5. Global MEMORY.md — pointer satırı ekle
[ ] 6. CLAUDE.md Workspace Map veya araç açıklaması (gerekirse)
[ ] 7. sync-push.sh ile projelere dağıt (gerekirse)
```

## Hafıza Konumu

Tüm hafıza dosyaları `smurfs/memory/` altındadır (git-tracked, tek kaynak):

```
smurfs/memory/
  ├── MEMORY.md                — İndeks
  ├── user_profile.md          — Kullanıcı kim, nasıl çalışır
  ├── workspace_overview.md    — Proje haritası
  ├── feedback_*.md            — Yaklaşım kuralları (ne yapma, ne yap)
  ├── project_*.md             — Aktif proje/araç durumu
  ├── patterns/{stack}.md      — Teknik pattern birikimi
  ├── clients/{client}.md      — Müşteri tercihleri
  └── decisions/               — Mimari kararlar (ADR)
```

`~/.claude/projects/.../memory/MEMORY.md` → sadece yönlendirme (redirect), asıl dosyalar burada değil.

Kural: Oturum başında `smurfs/memory/MEMORY.md` okunur. Yeni hafıza yazılırken dosya `smurfs/memory/` altına oluşturulur.

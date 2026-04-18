# Sprints

Every delivered job is a **sprint**. Sprints are delivery-based, not time-based — a 2-day fix and a 2-week feature are each one sprint. The sprint folder captures everything: intake, plan, decisions, handoffs, delivery, retro, and the system updates the retro produced.

Sprints feed a continuous-improvement loop. Every M+ sprint ends with a retro that produces concrete changes to skills, agent cards, `CLAUDE.md`, or memory — linked from `08-system-updates/`. Without the system update, the retro is just writing.

## Folder naming

```
docs/sprints/{YYYY-MM-DD}-{client}-{slug}/
```

- `{YYYY-MM-DD}` — sprint **start** date (locked at init, never updated)
- `{client}` — client slug (`qoommerce`, `oltan`, `asfire`, `wcard`, `internal` for eng-team itself)
- `{slug}` — short kebab-case hint (`checkout-fix`, `auth-migration`, `seo-audit`)

Examples:
- `2026-04-18-qoommerce-checkout-refund-flow/`
- `2026-04-20-oltan-auth-500-hotfix/`
- `2026-04-22-internal-sprint-system/`

## Size thresholds

| Size | Scope | Sprint folder | Retro |
|------|-------|---------------|-------|
| **S** | <4h, trivial, single file, typo / copy / config | skip | skip |
| **M** | 1–3 days, one feature/fix | required | full |
| **L** | 3–10 days, multi-component | required | full |
| **XL** | >10 days, spec-driven | required | full + mid-sprint check |
| **Hotfix** | any duration, prod-critical | required (mini layout) | mini (mandatory) |

S-size work commits directly on a short-lived branch and skips sprint overhead. Everything else lives here.

## Full sprint layout (M / L / XL)

```
{sprint-folder}/
├── 00-sprint.md              Manifest: goal, size, client, deliverable, owner roles
├── 01-intake.md              intake skill output (Recommended Next Step, edge cases)
├── 02-spec.md                spec-writing output (XL only; otherwise omit or mark N/A)
├── 03-plan.md                plan-mode output — approved plan
├── 04-decisions.md           Live log. Every key decision, timestamped, with agent + why
├── 05-handoffs/
│   ├── builder-report.md     Builder Handoff Report (orchestration skill format)
│   ├── review-report.md      Code Review Report (APPROVED / CHANGES_REQUESTED)
│   └── test-report.md        Test Report (PASS / FAIL + coverage)
├── 06-delivery.md            PR links, commit SHAs, deploy notes, verification steps
├── 07-retro.md               İyi / Kötü / Aksiyon (max 3 aksiyon)
└── 08-system-updates/
    └── SUMMARY.md            Links to the commits/PRs that applied retro actions
```

## Hotfix layout (mini)

Hotfixes skip the full ladder but still capture root cause + prevention. Skipping mini-retro is not allowed.

```
{sprint-folder}/
├── 00-hotfix.md              What broke, when detected, impact, which path was fixed
├── 01-fix.md                 Diff summary, rollback-vs-forward-fix decision, smoke result
└── 02-mini-retro.md          Root cause / Why we missed it / Prevention action
```

## Who writes what

- **@architect** (orchestrator): creates the folder at sprint init, writes `00-sprint.md`, owns `04-decisions.md` summary pass at close, facilitates retro.
- **@builder**: writes `05-handoffs/builder-report.md`, appends to `04-decisions.md` for implementation trade-offs.
- **@reviewer**: writes `05-handoffs/review-report.md` and `test-report.md`, appends a "patterns observed" note to `07-retro.md` input.
- **@designer**: appends to `04-decisions.md` for UX/layout decisions; delivers mock links referenced from `03-plan.md`.
- **Main session** (freelancer voice): writes `06-delivery.md` and the client-facing parts; signs off retro aksiyonlar.

## Decisions log protocol (`04-decisions.md`)

One line per decision:

```
[YYYY-MM-DD HH:MM] <agent>: <decision> — <why> (<alternatives rejected, if any>)
```

Example:

```
[2026-04-18 14:22] architect: drop optimistic UI for refund flow — refund is server-authoritative, optimistic state risks ghost refunds (rejected: keep optimistic with rollback — too complex for M sprint)
[2026-04-18 15:40] builder: extract RefundCommand handler — existing OrderCommand was becoming 400 LoC (rejected: inline in OrderCommand — hurts readability)
```

If a decision has no visible entry here, the retro treats it as "undocumented decision — rework risk" and flags it.

## Retro → system update pipeline

Retro aksiyonları **en fazla 3 tane** olur. Fazlası "backlog" olarak `07-retro.md` sonunda listelenir, uygulanmaz.

Her aksiyon üç kategoriden birine düşer:

- **Skill update** — `.claude/skills/<name>/SKILL.md` dosyasına kural/checklist maddesi
- **CLAUDE.md update** — repo-level kural
- **Memory update** — `~/.claude/projects/.../memory/` altında `feedback_*` / `project_*` dosyası

Her aksiyon uygulandıktan sonra `08-system-updates/SUMMARY.md` dosyasına commit/PR linki yazılır. Sprint "closed" sayılmaz bu yapılmadan.

## Closing a sprint

Checklist (architect çalıştırır):

- [ ] `00-sprint.md` doldurulmuş (hedef, boyut, müşteri)
- [ ] `03-plan.md` onaylanmış ve dondurulmuş (post-approval değişiklikler `04-decisions.md`'de)
- [ ] `04-decisions.md` en az 3 satır (boyut ne olursa olsun)
- [ ] `05-handoffs/` içinde builder + review + test raporları var (hotfix hariç)
- [ ] `06-delivery.md` PR linki içeriyor
- [ ] `07-retro.md` yazılmış (M+ için full, hotfix için mini)
- [ ] `08-system-updates/SUMMARY.md` retro aksiyonlarının uygulandığını gösteriyor

Herhangi biri eksikse sprint açık kalır — eksik madde `04-decisions.md`'ye "sprint not closed: <reason>" olarak düşer.

## Templates

Two templates exist — pick the one that matches the work type:

- **Full sprint (M/L/XL)** → `docs/sprints/_template/`
- **Hotfix (mini)** → `docs/sprints/_template-hotfix/`

```bash
# Full sprint (M/L/XL)
cp -r docs/sprints/_template docs/sprints/2026-04-18-<client>-<slug>

# Hotfix
cp -r docs/sprints/_template-hotfix docs/sprints/2026-04-18-<client>-hotfix-<slug>
```

`sprint` skill drives the copy + `00-sprint.md` (or `00-hotfix.md`) fill step.

## Related skills

- `sprint` — sprint lifecycle (init, live log, close checklist)
- `retro` — full retro and mini-retro formats
- `orchestration` — Phase 0 (Sprint Init) + Phase 9 (Retro) sits on top of the loop
- `new-feature` / `bug-fix` / `hotfix` — all run inside a sprint folder

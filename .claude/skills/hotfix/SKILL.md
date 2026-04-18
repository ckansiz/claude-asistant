---
name: hotfix
description: This skill should be used when the user reports a critical production issue — "production is down", "urgent fix", "hotfix needed", "site is broken", or invokes /hotfix. Compressed workflow: analyze → fix → smoke → PR. Full code review + broad test coverage are deferred to post-merge.
version: 1.0.0
---

# Hotfix Workflow (Urgent Production Fix)

Apply only when production is broken and normal bug-fix turnaround is too slow. The tradeoff: shorter path to a deployed fix, at the cost of deferred review and coverage. Every hotfix leaves tech debt — log it immediately.

> Difference from `bug-fix`: code review and broad testing are deferred to a **follow-up task after merge**. The goal is to stop the bleeding first.

> Sprint folder: hotfix runs inside the **mini sprint layout** (`docs/sprints/{YYYY-MM-DD}-{client}-{slug}/` with `00-hotfix.md`, `01-fix.md`, `02-mini-retro.md`). See `sprint` skill. Mini-retro is **mandatory post-merge** — no exceptions.

## Steps

### 0. Sprint Init (mini layout)
Before triage, open a mini sprint folder from the **hotfix template**:
```bash
cp -r docs/sprints/_template-hotfix docs/sprints/{YYYY-MM-DD}-{client}-hotfix-{slug}
```
The sprint folder is required even for 10-minute hotfixes — without it there is no record of why we missed the bug.

### 1. Triage
- What's broken? (500 errors, blank page, auth broken, payments failing)
- Impact level — all users, a segment, one role?
- When did it start? Correlate with the latest deploy.

### 2. Decide: is hotfix the right tool?
Hotfix if: production users are actively affected and waiting longer will cause harm.
Otherwise use `bug-fix` — review and coverage matter when there's no fire.

### 3. Quickest safe action
Consider in order:
- **Rollback** — if the last deploy caused it, revert the deploy (Vercel → Promote previous; Fly → `fly releases` → redeploy previous image). Often faster and safer than a forward fix. See `deployment` skill.
- **Feature flag off** — if the broken feature is flagged, disable the flag.
- **Forward fix** — only when rollback isn't viable.

If rollback solves it, skip straight to step 7 and open a follow-up task for root-cause investigation.

### 4. Implement forward fix (→ @builder)
Branch: `hotfix/{short-description}` (not `fix/`).

Minimum quality check:
- Type check — PASS
- Build — PASS
- (Skip full unit/integration suite — it runs post-merge)

Builder returns **Builder Handoff Report**.

### 5. Smoke Test (→ @reviewer with `testing` skill)
Run smoke tests only — verify critical paths still load:
- Home / landing
- Login / auth
- The previously broken path (now fixed)
- Checkout / payment (if e-commerce)

Max 2 iterations. If smoke still fails, fall back to rollback.

### 6. Hotfix PR
Title: `hotfix(scope): description`. Body:
- **Issue** — what broke
- **Fix** — what changed (minimal, surgical)
- **Smoke test** — results
- A visible marker: `> ⚠️ HOTFIX — full review & tests happen post-merge`

Merge fast. Do not block on niceties.

### 7. Post-merge (required, not optional)
After merge, immediately:

1. Verify the fix on production.
2. Run full smoke suite against production.
3. Fill `00-hotfix.md` and `01-fix.md` in the sprint folder if you didn't during the rush:
   - `00-hotfix.md` — what broke, when detected, impact, which path was affected
   - `01-fix.md` — rollback-vs-forward decision, diff summary, smoke results
4. **Open a follow-up `bug-fix` task** in the issue tracker (or a new sprint) covering:
   - Proper regression test (if not added in this hotfix)
   - Full code review
   - Any refactor the rushed fix deferred

This follow-up is not negotiable — hotfixes without follow-up become tech debt that compounds.

### 8. Mini Retro (mandatory, within 24h of merge)
Invoke the `retro` skill with the **mini** variant. Write `02-mini-retro.md`:

- **Root cause** — 2–4 sentences. Not "X didn't work" — *why* X didn't work.
- **Why we missed it** — missing test, missing review, skipped gate, unclear requirement, environment drift. Be honest, not generous.
- **Prevention** — **at least 1 concrete action** (test / lint rule / checklist item / memory line / skill update). Max 2. "Be more careful" is not an action.

Apply every prevention aksiyonu and link it from the sprint's `08-system-updates/SUMMARY.md`. The hotfix sprint is not closed until:
- [ ] `02-mini-retro.md` written
- [ ] Prevention aksiyonları applied
- [ ] `08-system-updates/SUMMARY.md` has links

**Skipping mini-retro is not allowed.** The entire reason hotfix defers code review and broad testing is that mini-retro compensates — drop it and the hotfix becomes pure unaccounted tech debt.

### 9. Postmortem (optional — only for >1h user-facing impact)
For hotfixes affecting users for more than an hour, expand `02-mini-retro.md` with a postmortem section:
- Timeline (when broke / detected / mitigated / resolved)
- Communication to users / client (what was said, when)
- Action items beyond prevention aksiyonları (alerts, runbooks, process)

## What a Hotfix Is NOT

- A shortcut for normal bugs — use `bug-fix`
- A refactor opportunity — keep the diff minimal
- An excuse to skip commits conventions or Conventional Commits

## Companion Skills

- `sprint` — mini sprint layout (hotfix folder, decisions log)
- `retro` — mini-retro format (root cause / why missed / prevention)
- `orchestration` — handoff report formats
- `bug-fix` — the follow-up task format
- `deployment` — rollback mechanics per host
- `commits`

$ARGUMENTS

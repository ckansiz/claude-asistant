---
name: hotfix
description: This skill should be used when the user reports a critical production issue — "production is down", "urgent fix", "hotfix needed", "site is broken", or invokes /hotfix. Compressed workflow: analyze → fix → smoke → PR. Full code review + broad test coverage are deferred to post-merge.
version: 1.0.0
---

# Hotfix Workflow (Urgent Production Fix)

Apply only when production is broken and normal bug-fix turnaround is too slow. The tradeoff: shorter path to a deployed fix, at the cost of deferred review and coverage. Every hotfix leaves tech debt — log it immediately.

> Difference from `bug-fix`: code review and broad testing are deferred to a **follow-up task after merge**. The goal is to stop the bleeding first.

## Steps

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
3. **Open a follow-up `bug-fix` task** in the issue tracker covering:
   - Root cause analysis
   - Proper regression test
   - Full code review
   - Any refactor the rushed fix deferred

This follow-up is not negotiable — hotfixes without follow-up become tech debt that compounds.

### 8. Postmortem
For anything user-facing that lasted more than an hour, write a short postmortem (3-5 paragraphs):
- Timeline — when it broke, when detected, when fixed
- Root cause
- What prevented earlier detection
- Action items (tests, alerts, process)

Store in `docs/postmortems/{date}-{slug}.md`.

## What a Hotfix Is NOT

- A shortcut for normal bugs — use `bug-fix`
- A refactor opportunity — keep the diff minimal
- An excuse to skip commits conventions or Conventional Commits

## Companion Skills

- `orchestration` — handoff report formats
- `bug-fix` — the follow-up task format
- `deployment` — rollback mechanics per host
- `commits`

$ARGUMENTS

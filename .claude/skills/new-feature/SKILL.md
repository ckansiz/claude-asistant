---
name: new-feature
description: This skill should be used when the user asks to "add a new feature", "implement a new capability", "build a new page/endpoint/flow", or invokes /new-feature. Runs the end-to-end orchestration loop: analyze → plan → build → review → test → PR.
version: 1.0.0
---

# New Feature Workflow

Apply when the user requests a new feature. Follow the orchestration loop end-to-end. Details on roles, handoff reports, and the Production Readiness Checklist live in the `orchestration` skill — load it alongside this one.

> Sprint folder: every M+ new-feature runs inside a sprint folder (`docs/sprints/{YYYY-MM-DD}-{client}-{slug}/`). See `sprint` skill. Retro is mandatory at close (`07-retro.md` + `08-system-updates/`). S-size (<4h, trivial) skips the sprint folder.

## Steps

### 0. Sprint Init (→ `sprint` skill)
If the feature is M/L/XL (default assumption for new-feature), open a sprint folder first:
```bash
cp -r docs/sprints/_template docs/sprints/{YYYY-MM-DD}-{client}-{slug}
```
Fill `00-sprint.md` (goal, size, client, deliverable, roles). Seed `04-decisions.md` with the kickoff line.

### 1. Analyze
Read the request. Ask clarifying questions if scope is unclear:
- What problem does this solve?
- Who is the user?
- What's the success condition?
- Any constraints (timeline, stack, data)?

For bigger features (XL), hand off to `spec-writing` skill to fill `02-spec.md` inside the sprint folder.

Intake output → `01-intake.md` inside the sprint folder.

### 2. Feasibility (→ @architect)
Delegate to @architect for:
- Technical feasibility assessment
- Architecture impact
- Complexity estimate
- Dependencies needed

If the feature introduces a new library or pattern, run `tech-research` skill first.

### 3. Plan (→ user)
Produce a plan using the `plan-mode` skill format. Surface:
- Files to change / create
- Out-of-scope items
- Risks
- Verification steps

**Wait for user approval.** Do not start implementation without it.

### 4. Implement (→ @builder)
Delegate to @builder. Builder applies the relevant stack skill (`dotnet`, `astro`, `nextjs`, `react-native`, etc.) and returns the **Builder Handoff Report** (see `orchestration` skill).

Quality check gates (type check → tests → build) must all PASS before proceeding. If any FAIL, back to @builder — max 3 iterations.

### 5. Code Review (→ @reviewer or @architect)
Delegate review using the `code-review` skill. Reviewer returns the **Code Review Report** with verdict:
- `APPROVED` → continue
- `CHANGES_REQUESTED` → pass findings back to @builder, loop again (max 3 iter)

### 6. Test (→ @reviewer with `testing` skill)
Run:
- Unit tests
- Integration / API tests (if backend changed)
- Smoke / E2E tests (for critical paths)
- Visual regression (for UI changes — see `visual-regression` skill)

Tester returns **Test Report** with verdict:
- `PASS` → continue
- `FAIL` → back to @builder with failure detail, loop again (max 3 iter)

### 7. Production Readiness
Run the **Production Readiness Checklist** (see `orchestration` skill). Every item must be checked.

### 8. Pull Request
Use `gh pr create`. Title: `feat(scope): description`. Body includes:
- What / Why
- Test plan
- Production Readiness checklist
- **Changelog** section (Turkish for TR clients)

Share the PR URL with the user.

### 9. Post-merge
After the user confirms merge:
- Run smoke tests against the deployed preview/production URL
- Report any regression immediately
- Fill `06-delivery.md` in the sprint folder (PR URL, commit SHAs, deploy status)

### 10. Retro (→ `retro` skill, mandatory for M+)
Sprint is not closed until retro is written and aksiyonlar applied:
1. Run the sprint close checklist (`sprint` skill, Step 3) — every artifact present.
2. Invoke `retro` skill → produces `07-retro.md` (İyi / Kötü / Aksiyon, max 3 aksiyon).
3. Apply each aksiyon (skill edit / CLAUDE.md edit / memory entry) on `chore/retro-{sprint-slug}-{n}` branches.
4. Link every applied aksiyon in `08-system-updates/SUMMARY.md`.
5. Add `[timestamp] architect: sprint closed` line to `04-decisions.md`.

## Destructive Operations

If the feature requires schema change, seed data, mass updates, or any operation blocked by `.claude/hooks/safety-check.mjs` → **explicit user approval in step 3 (plan)**, before @builder starts.

## When to Skip Steps

- Typo / copy tweak: skip 2, 5, 6 → go straight to @builder + smoke test
- No UI change: skip visual regression
- No backend change: skip integration tests
- Internal refactor with full test coverage: may skip formal review but keep quality gates

## Companion Skills

- `sprint` — Phase 0 (folder init) + close checklist
- `retro` — Phase 9 (retro + system updates), mandatory at close
- `orchestration` — loop mechanics, report formats, Production Readiness
- `plan-mode` — plan format and discipline
- Stack skill (`dotnet` / `astro` / `nextjs` / `react-native` / `flutter` / `devops`) — discipline-specific standards
- `testing`, `visual-regression`, `code-review` — verification
- `commits`, `git-workflow` — commit + branch discipline

$ARGUMENTS

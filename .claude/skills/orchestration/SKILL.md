---
name: orchestration
description: This skill should be used when the user asks to "coordinate multi-agent work", "orchestrate a feature end-to-end", "run the full PO → architect → builder → reviewer loop", or when any workflow skill (new-feature, bug-fix, hotfix) is active. Defines the delegation loop, handoff report formats, quality gates, and Production Readiness Checklist.
version: 1.0.0
---

# Orchestration Playbook (Multi-Agent Workflow)

Apply when running multi-step work through multiple agents. Wraps how @architect (orchestrator mode), @builder, @reviewer collaborate and how their outputs are verified before declaring a task done.

## Roles in the Loop

| Role | Agent | What they produce |
|------|-------|-------------------|
| Orchestrator (PO) | Main session or @architect | Analysis, delegation, final PR |
| Technical lead | @architect | Feasibility, code review verdict |
| Implementer | @builder | Code + Handoff Report |
| Reviewer | @reviewer | Review findings + verdict |

The orchestrator is the **only** role that talks to the user. @builder / @reviewer / @architect report back to the orchestrator, never directly to the user.

## The Delegation Loop

```
User request
    ↓
Orchestrator: Intake Gate — is this trivial or does it need discovery?
    │
    ├─ Trivial (<2h, single file, obvious) → skip to Plan
    │
    └─ Non-trivial → @architect: Intake (intake + edge-cases skills)
                              ↓
                     Intake Brief → user approval
                              ↓
                     Recommended Next Step chosen:
                         ├─ XL → spec-writing → @architect writes requirements + tech-spec
                         ├─ M/L → plan-mode
                         └─ Hotfix → hotfix skill (intake compressed)
    ↓
@architect (if /spec): feasibility + tech plan  (tech-research / spec-writing skills)
    ↓
User: approves plan
    ↓
@builder: implement + Handoff Report
    ↓ (quality check FAIL → back to @builder, max 3 iter)
@reviewer (or @architect): code review
    ↓ (CHANGES_REQUESTED → back to @builder, max 3 iter)
@reviewer with testing skill: run tests (unit + integration + smoke/E2E as scope demands)
    ↓ (FAIL → back to @builder, max 3 iter)
Orchestrator: Production Readiness Checklist
    ↓
Orchestrator: open PR + Client Report (client-report skill) → deliver to user
```

If any loop hits 3 iterations without passing, stop and report honestly to the user — do not keep spinning.

## Intake Gate — When to Run Intake

Before delegating anything, the orchestrator decides whether an intake brief is required.

| Signal | Intake required? |
|--------|------------------|
| Task estimate <2h, single file, obvious change | No — direct to Plan |
| New feature, new endpoint, or new page | Yes |
| Bug with unclear root cause or cross-file impact | Yes |
| Auth / payment / data-deletion / schema touch | Yes (never skipped) |
| New integration or third-party service | Yes |
| New client or first task on a project | Yes |
| Hotfix | Intake compressed into step 1 of `hotfix` skill — not full brief |
| Copy tweak, typo, config bump | No |

When in doubt, run intake. Cheap compared to the cost of misunderstood scope.

## Quality Gates — Definition of Done

Before the orchestrator considers a task complete, **all** of the following must pass in order. Stop at the first failure, report it, never skip ahead.

### Generic (any stack)
1. Type check / static analysis
2. Unit tests
3. Integration / API tests (if backend/API changed)
4. Build / publish
5. Commits atomic + Conventional Commits format (see `commits` skill)
6. Branch pushed to remote

### .NET projects
```bash
dotnet build                                              # 0 errors
dotnet test                                               # 0 failures
dotnet ef migrations script --idempotent --no-build       # if migration changed
```

### Astro / Next.js
```bash
npm run typecheck   # or: npx astro check / tsc --noEmit
npm run test        # vitest / jest
npm run build       # production build
```

### React Native
```bash
npm run typecheck
npm test
npx expo export     # validates bundling (optional for small diffs)
```

If a gate fails and cannot be fixed within the iteration budget, the orchestrator escalates to the user with the exact failing command + output.

## Handoff Report Formats

### Builder Handoff Report

@builder must end every implementation task with:

```
## Builder Handoff
- Branch: {branch-name}
- Files changed: {list}
- Commits: {conventional commit list}
- New/changed endpoints: {list, or N/A}
- New/changed schema / migrations: {list, or N/A}
- New behavior requiring test: {description}

## Quality Check
- [ ] Type check — PASS/FAIL
- [ ] Unit tests — PASS/FAIL (X/Y passed)
- [ ] Integration tests — PASS/FAIL (X/Y passed) or N/A
- [ ] Build — PASS/FAIL
- [ ] Atomic commits — YES/NO
- [ ] Branch pushed — YES/NO
```

Do not report "done" until all checks PASS.

### Reviewer / Architect Code Review Report

```
## Code Review Report
- Reviewer: {architect | reviewer}
- Branch: {name}
- Files reviewed: {count}

## Findings
| # | Severity | File:line | Finding | Suggested fix |
|---|----------|-----------|---------|---------------|
| 1 | CRITICAL/HIGH/MEDIUM/LOW | path:N | description | fix |

## Verdict: APPROVED | CHANGES_REQUESTED
{if CHANGES_REQUESTED: explicit list of items to fix}
```

CRITICAL / HIGH → `CHANGES_REQUESTED` (merge blocker). MEDIUM / LOW only → `APPROVED` (merge OK, optional polish).

### Tester / Reviewer Test Report

```
## Test Report
- Scope: {feature / fix description}

## Results
| Test type | Status | Detail |
|-----------|--------|--------|
| Type check | PASS/FAIL | — |
| Unit | PASS/FAIL | X/Y passed |
| Integration / API | PASS/FAIL | X/Y passed |
| E2E | PASS/FAIL/SKIP | — |
| Visual regression | PASS/FAIL/SKIP | see `visual-regression` skill |

## Coverage
- New code tested: YES/NO
- Regression (existing tests broken): YES/NO
- Missing coverage: {list, or N/A}

## Verdict: PASS | FAIL
{if FAIL: which tests failed and what @builder needs to fix}
```

## Production Readiness Checklist

The orchestrator runs this checklist before opening a PR or declaring work done:

```
## Production Readiness
- [ ] Intake brief (if applicable) — approved and referenced
- [ ] Edge-case table (from `edge-cases` skill) — every row resolved (handled / tested / documented / out-of-scope)
- [ ] Builder quality check — all PASS
- [ ] Code review — APPROVED
- [ ] Tester verdict — PASS (unit + integration + smoke/E2E as scope demands)
- [ ] New behavior matches user intent
- [ ] No regressions (existing tests intact)
- [ ] No destructive changes, or user approved them
- [ ] Atomic Conventional Commits
- [ ] Branch pushed
- [ ] PR opened with changelog section
- [ ] Client report (if client-facing) drafted via `client-report` skill
```

Any unchecked item → surface it explicitly to the user, never hide gaps.

## Pull Request Conventions

- Title: Conventional Commit format (`feat(web): ...`, `fix(api): ...`)
- Body sections:
  1. **What** — 1-2 sentence summary
  2. **Why** — the motivation or linked issue
  3. **Test plan** — what was verified
  4. **Production Readiness** — the checklist above
  5. **Changelog** — plain-language, user-facing description (Turkish for TR clients)

Share the PR URL back to the user. Do not self-merge.

## When NOT to Orchestrate

Small, low-risk changes (typo, copy tweak, single-file refactor <20 lines) can skip the full loop:
- Orchestrator → @builder direct
- Skip separate code review, single test run is enough
- Still commit conventionally, still push, still open a PR

Orchestration overhead should match change scope — do not run a full loop for a comma fix.

## Companion Skills

- `intake` — runs at the Intake Gate; produces the brief that feeds spec/plan
- `edge-cases` — systematic non-happy-path sweep, referenced by intake/spec/plan/review/testing
- `plan-mode` — planning discipline before any delegation
- `new-feature` / `bug-fix` / `hotfix` — specific workflow variants
- `code-review` — reviewer checklist
- `testing` — test strategy per stack (unit, integration, smoke, E2E)
- `client-report` — Turkish client-facing reports at the end of the loop
- `commits` — commit message format
- `git-workflow` — branch strategy, PR template

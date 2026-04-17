---
name: bug-fix
description: This skill should be used when the user reports a bug or asks to "fix a bug", "investigate an issue", "debug production error", or invokes /bug-fix. Runs the orchestration loop with emphasis on root cause analysis and regression test coverage.
version: 1.0.0
---

# Bug Fix Workflow

Apply when a bug is reported. Same orchestration loop as `new-feature`, but with extra emphasis on root cause + regression test.

## Steps

### 1. Reproduce + Analyze
Pin down the bug:
- What page / endpoint / component is affected?
- Exact steps to reproduce
- Expected vs actual behavior
- Browser / OS / environment
- Does it happen in staging and production, or only one?

If cannot reproduce locally, ask the user for more detail before guessing.

### 2. Root Cause (→ @architect)
Delegate to @architect for root cause analysis. Do **not** jump straight to a fix — understand *why* the bug exists first. Otherwise the fix treats the symptom and the real issue resurfaces.

Output: a short root-cause summary (2-4 lines) + affected area.

### 3. Plan
Use the `plan-mode` skill. Specifically for bug fixes, include:
- Root cause in one sentence
- The minimal change that fixes it
- The regression test that will prove the bug doesn't come back

Get user approval before implementation.

### 4. Implement (→ @builder)
Delegate to @builder. Scope is tight — fix the bug, do not refactor surrounding code unless it's part of the root cause. Builder returns **Builder Handoff Report**.

Quality gates must pass (max 3 iter).

### 5. Code Review (→ @reviewer or @architect)
Same as `new-feature` step 5. Verdict `APPROVED` or `CHANGES_REQUESTED`.

### 6. Regression Test (→ @reviewer with `testing` skill)
**Critical**: the test must cover the specific scenario that triggered the bug. A bug without a regression test is a bug waiting to happen again.

Tester returns **Test Report**. If an existing test broke alongside the bug, inspect it — is the test wrong, or did the code change break something else?

### 7. Production Readiness
Same checklist as `new-feature`, with one extra item:
- [ ] Regression test exists and covers the bug scenario

### 8. Pull Request
Title: `fix(scope): description`. Body sections:
- **Bug description** — what the user reported
- **Root cause** — why it happened
- **Fix** — what changed
- **Test plan** — including the regression test
- **Production Readiness**
- **Changelog** (Turkish for TR clients)

### 9. Post-merge
Run smoke tests. If this was a production bug, verify the fix on production specifically.

## When the Fix Is Urgent

If the bug is breaking production *right now*, use `hotfix` skill instead — it compresses steps 5 & 6 to move faster.

## Companion Skills

- `orchestration` — loop mechanics, report formats
- `plan-mode` — plan discipline
- `testing` — regression test patterns per stack
- Stack skill — stack-specific debugging patterns
- `commits`, `git-workflow`

$ARGUMENTS

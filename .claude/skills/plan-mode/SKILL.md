---
name: plan-mode
description: This skill should be used before starting any non-trivial task — feature, bug fix, refactor, migration, schema change. Enforces the plan → approve → execute discipline and lists what must go into the plan before code is written.
version: 1.0.0
---

# Plan Mode Discipline

Apply before every non-trivial task. The goal: the user sees exactly what will change and approves, before any file is touched.

## When Plan Mode Is Mandatory

- Any new feature or endpoint
- Bug fix that touches more than one file
- Schema / migration change (DB, API contract)
- Dependency add / upgrade
- Refactor across multiple files
- Config change (Docker, K8s, CI, env)
- Anything that touches auth, payments, or data deletion

## When Plan Mode Is Optional (but still encouraged)

- Typo fix, copy tweak
- Single-line bug fix with obvious root cause
- Adding a console.log / inspection (then removing it)

## The Plan — Required Sections

```
## Plan: {one-line task summary}

### Goal
{what success looks like in one sentence}

### Files to change
- path/to/file-a.ts — {what}
- path/to/file-b.astro — {what}
- prisma/schema.prisma — {what}  (flag schema changes clearly)

### Files to create
- path/to/new-file.ts — {what}

### Out of scope
- {explicitly what will NOT be done — prevents scope creep}

### Risks / open questions
- {what could break, what decisions need user input}

### Verification
- {commands that will confirm it works: npm run build, npm test, smoke check}
```

Keep the plan under ~200 lines. If the plan is longer, the task is too big — split it.

## Approval Rules

- Do not write code, create files, or run build/migration commands until the user approves the plan.
- "Run this command to check something" is fine (read-only exploration).
- "Apply this edit" is not — that requires approval.

## After Approval — Execution Discipline

- If a discovery mid-execution forces a plan change, **stop and re-confirm** instead of silently widening scope.
- If the plan said 3 files and the change now needs 5, that is a scope change worth surfacing.
- If the plan did not mention a destructive operation (see `orchestration` skill's destructive list) and one is needed, get explicit approval before running it.

## Output After Execution

Use the Builder Handoff Report format (see `orchestration` skill) — shows what was actually done against what was planned. If reality diverged from the plan, call it out in the report.

## Companion Skills

- `orchestration` — the full multi-agent loop plan mode fits into
- `spec-writing` — for deeper up-front specs (docs/requirements.md, docs/tech-spec.md)

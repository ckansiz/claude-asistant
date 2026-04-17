---
name: commits
description: This skill should be used when the user asks to "commit", "create a commit", "write a commit message", or stages and commits changes in any project.
version: 1.0.0
---

# Commit Conventions

Apply for every git commit. All commits follow Conventional Commits.

## Format

```
type(scope): short description

[optional body — explain WHY, not what]
[optional footer — BREAKING CHANGE, Closes #123]
```

- Imperative mood: `add` not `added`, `fix` not `fixed`
- Max 72 chars for the first line

## Types

| Type | When |
|------|------|
| `feat` | New feature |
| `fix` | Bug fix |
| `refactor` | No fix, no feature |
| `style` | Formatting only |
| `test` | Tests only |
| `docs` | Documentation |
| `chore` | Dependencies, build config |
| `ci` | CI/CD changes |
| `perf` | Performance improvement |

## Scopes

| Scope | For |
|-------|-----|
| `frontend` | UI code |
| `backend` | API, handlers |
| `mobile` | React Native |
| `db` | Migrations, schema |
| `auth` | Authentication |
| `api` | API contracts, DTOs |
| `infra` | Docker, K8s |
| `config` | App config, env vars |

## Breaking Changes

```
feat(api)!: rename user token field

BREAKING CHANGE: token is now nested under data.token, not top-level
```

## Examples

```
feat(backend): add product search endpoint with pagination
fix(frontend): correct mobile nav z-index on iOS Safari
chore: update Tailwind to v4.1
feat(mobile)!: redesign onboarding flow

BREAKING CHANGE: email verification now required before proceeding
```

## Rules

- One concern per commit — never bundle unrelated changes
- Never commit secrets or API keys
- Use `Closes #123` in footer when closing an issue

# Commit Conventions

All commits across all projects must follow the **Conventional Commits** specification.

## Format

```
<type>(<scope>): <short description>

[optional body]

[optional footer]
```

- **type**: lowercase, from the list below
- **scope**: optional, lowercase, describes what was affected
- **short description**: imperative mood, no period, max 72 chars
- **body**: explain *why*, not *what* — only when the change needs context
- **footer**: breaking changes, closes issues

## Types

| Type | Use When |
|------|----------|
| `feat` | New feature or user-facing capability |
| `fix` | Bug fix |
| `refactor` | Code change that is neither a fix nor a feature |
| `style` | Formatting, whitespace — no logic change |
| `test` | Adding or updating tests |
| `docs` | Documentation only |
| `chore` | Dependency updates, build config, tooling |
| `ci` | CI/CD pipeline changes |
| `perf` | Performance improvement |
| `revert` | Revert a previous commit |

## Scopes (by project area)

| Scope | Use For |
|-------|---------|
| `frontend` | Astro/Next.js UI code |
| `backend` | .NET API, handlers, services |
| `mobile` | React Native / Expo / Flutter |
| `db` | Migrations, schema changes |
| `auth` | Authentication / authorization |
| `api` | API contracts, DTOs, endpoints |
| `infra` | Docker, K8s, CI/CD configs |
| `config` | App configuration, env vars |
| `ui` | Component styling, theming |
| `agents` | Smurf agent definitions |

Scope is optional but strongly recommended. When in doubt, use the most specific one.

## Breaking Changes

Add `!` after the type/scope, and add a `BREAKING CHANGE:` footer:

```
feat(api)!: change auth token response shape

BREAKING CHANGE: token is now nested under `data.token`, not top-level
```

## Examples

```
feat(backend): add product search endpoint with pagination

fix(frontend): correct mobile nav z-index overlap on iOS Safari

refactor(db): normalize product variants into separate table

test(backend): add unit tests for order total calculation

chore: update Tailwind to v4.1

docs: add API auth flow to tech-spec

ci: add GitHub Actions build check on pull request

feat(mobile)!: redesign onboarding flow

BREAKING CHANGE: onboarding now requires email verification before proceeding
```

## Rules

1. **Never** use past tense — use imperative: `add` not `added`, `fix` not `fixed`
2. **Never** commit secrets, API keys, or credentials
3. **One concern per commit** — do not bundle unrelated changes
4. If the commit closes an issue: `Closes #123` in the footer
5. Merge commits and WIP commits are allowed locally but should be squashed before push

## Multi-file changes

If a single logical change touches multiple areas, pick the primary scope. If truly cross-cutting, omit scope:

```
refactor: move shared auth logic to core library
```

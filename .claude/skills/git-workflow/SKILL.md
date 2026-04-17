---
name: git-workflow
description: This skill should be used when the user asks to "create a feature branch", "set up PR template", "pick a branching strategy", "do a release", "rebase", "resolve merge conflicts", or configures GitHub repo workflow (branches, PRs, releases). For commit message format, use the `commits` skill instead.
version: 1.0.0
---

# Git Workflow Standards

Apply for branching, PR flow, and releases. For commit message format (Conventional Commits), use the `commits` skill.

## Default Strategy: Trunk + Short-Lived Feature Branches

Solo / small-team freelance projects:

```
main ────●────●────●────●────●─────────  (always deployable)
          \    \         \
           feat/cart      feat/checkout
           (1-3 days)     (1-3 days)
```

- `main` is the only long-lived branch — always deployable, protected
- Feature branches live 1-3 days max — longer = merge conflicts
- Squash-merge to main (clean history)
- Delete the branch after merge

Skip GitFlow (`develop` + `release/*` + `hotfix/*`) for solo work — it's overhead without the team benefit.

## Branch Naming

```
feat/{scope}         # feat/contact-form
fix/{scope}          # fix/mobile-nav-overflow
chore/{scope}        # chore/upgrade-deps
docs/{scope}         # docs/readme-setup
refactor/{scope}     # refactor/split-auth-module
```

Match the Conventional Commit types from the `commits` skill — scope should align.

## Main Branch Protection (GitHub)

Settings → Branches → `main`:
- Require a pull request before merging
- Require status checks: build + tests
- Require linear history (enforces rebase or squash)
- Do not allow force push
- Do not allow deletion

## PR Template

Save as `.github/pull_request_template.md`:

```markdown
## What

<!-- 1-2 sentences: what changed and why -->

## Screenshots / Preview

<!-- Paste Vercel/Fly preview URL or screenshots for UI changes -->

## Testing

- [ ] Build passes locally
- [ ] Tests added / updated
- [ ] Smoke tested: {critical path}

## Checklist

- [ ] No secrets committed
- [ ] No `TODO` / `console.log` left behind
- [ ] DB migrations reviewed (if any)
- [ ] Breaking changes documented (if any)

Closes #<!-- issue number -->
```

## Rebase vs Merge

- **Rebase** feature branch onto `main` to stay up to date — keeps history linear
- **Never rebase** a branch other people have pulled (solo freelance: almost always safe)
- **Squash-merge** into `main` via GitHub UI — the feature lands as one commit with your PR description as the body

```bash
git checkout feat/cart
git fetch origin
git rebase origin/main
# resolve conflicts, test
git push --force-with-lease  # safer than --force
```

`--force-with-lease` fails if someone else pushed in the meantime — protects against overwriting unexpected changes.

## Merge Conflict Resolution

- Read both sides, understand the intent — don't just pick one blindly
- Test after resolving: `npm run build`, run the app, check the feature
- For generated files (`api.generated.ts`, lockfiles): regenerate from source (`npm run gen:api`, `npm install`) instead of manual merging

## Releases

### For continuous-deploy sites (most client work)

No explicit releases — every merge to `main` deploys. Use Vercel / Fly preview per PR for UAT.

### For apps with formal versions (mobile apps, SDKs, white-label products)

Semver tags on `main`:

```bash
# After merging a release-worthy set of features
git checkout main && git pull
git tag -a v1.2.0 -m "v1.2.0 — add checkout flow"
git push origin v1.2.0
```

Automate with `release-please` (GitHub Action) — reads Conventional Commits, opens a release PR with CHANGELOG.

## Hotfix Flow

Prod is broken, can't wait for the normal PR cycle:

```bash
git checkout main && git pull
git checkout -b fix/urgent-{slug}
# fix
git commit -m "fix(...)..."
git push -u origin fix/urgent-{slug}
# Open PR, skip the usual review delay, merge, deploy
```

Always open a PR even for hotfixes — the audit trail matters when the client asks "what changed?"

## `.gitignore` Essentials

```
# env
.env
.env.local
.env.*.local

# builds
node_modules/
.next/
dist/
build/
out/

# tool cache
.turbo/
.vercel/
.astro/

# OS
.DS_Store
Thumbs.db

# editor
.vscode/settings.json
.idea/

# logs
*.log

# .NET
bin/
obj/
*.user
```

## Secrets Hygiene

- `git-secrets` or `gitleaks` pre-commit hook to catch accidental secret commits
- If a secret leaks: rotate it immediately (the git history will never be truly erased on a public repo)
- Use `git filter-repo` (not `filter-branch`) for repo-wide cleanup — but rotate first, cleanup second

## Repo Access Handoff (end of project)

See `client-handoff` skill for the full delivery checklist. Git-specific items:
- Transfer repo to client's GitHub org (Settings → Transfer), or keep under yours per contract
- Remove my personal access tokens from Actions secrets
- Add client as admin, verify they can merge

## Companion Skills

- `commits` — message format
- `client-handoff` — repo transfer at project end
- `deployment` — preview deploys tied to PRs

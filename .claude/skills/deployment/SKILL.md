---
name: deployment
description: This skill should be used when the user asks to "deploy to Vercel", "deploy to Fly.io", "deploy to Railway", "deploy to Hetzner", "set up Coolify", "ship to production", "configure preview deployments", "set up custom domain", "rollback a deploy", or works on hosting/CI for a client project. For raw Docker/K8s/Grafana infra, use the `devops` skill instead.
version: 1.0.0
---

# Deployment Standards (Client Hosting)

Apply when deploying freelance projects to managed hosts. Pick the right target per stack and client budget. For self-hosted Docker/K8s infra, use the `devops` skill instead.

## Target Matrix

| Stack | First choice | Alternative | Self-host |
|-------|--------------|-------------|-----------|
| Next.js | Vercel | Railway | Coolify on Hetzner |
| Astro SSR | Vercel / Netlify | Fly.io | Coolify on Hetzner |
| Astro static | Cloudflare Pages | Netlify | — |
| .NET 10 | Fly.io | Railway | Coolify / K8s |
| React Native | EAS Build → App Store / Play | — | — |

## Vercel (Next.js / Astro)

- Connect GitHub repo → automatic preview deploys per PR, production deploy on main
- Env vars: set per environment (Production / Preview / Development) in dashboard, never commit `.env`
- Custom domain via Cloudflare — keep DNS at Cloudflare (proxy OFF for Vercel's apex), CNAME `www` to `cname.vercel-dns.com`
- Node version pinned in `package.json` `engines.node` or `.nvmrc`
- Use `vercel.json` only when framework detection is insufficient

## Fly.io (.NET / Astro SSR)

- `fly launch` — generates `fly.toml` + Dockerfile
- Secrets: `fly secrets set DATABASE_URL=...` — never in `fly.toml`
- Regions: default `ams` or `fra` for TR clients (low latency)
- Volumes for persistent data; external managed Postgres (Supabase / Neon) preferred over fly-postgres
- Health checks on `/health` endpoint — return 200 fast
- `fly deploy` for prod; `fly deploy --config fly.staging.toml` for staging

## Railway

- Simpler than Fly.io for small .NET + Postgres combos
- Env groups — share across services in the same project
- Built-in Postgres, Redis — easy for prototypes, migrate to managed DB at scale
- PR preview environments need manual setup

## Hetzner + Coolify (self-hosted, budget clients)

- Cheapest option for TR clients (€4–€8/mo CX22/CX32)
- Coolify = Vercel/Heroku-like UI on your VPS; handles Docker, SSL (Let's Encrypt), GitHub auto-deploy
- Install via `curl -fsSL https://cdn.coollabs.io/coolify/install.sh | bash`
- Daily automatic backups to S3-compatible storage (Hetzner Storage Box, Backblaze B2)
- Monitor with `devops` skill's Grafana LGTM stack if multiple services

## DNS (Cloudflare)

- Keep registrar separate from host; Cloudflare for DNS + CDN + SSL
- Apex record: A/AAAA to host IP, or CNAME flattening
- Set TTL low (300s) before a migration, raise back (3600s) after
- TR clients: add Cloudflare Analytics (free, KVKK-friendlier than GA)

## Environment Variables

- Local: `.env.local` (never committed), template committed as `.env.example`
- Preview / staging: separate values, never production secrets
- Production: host's secret store only — no plaintext in repo, no screenshots in Slack
- Rotate any secret that leaked, even in a deleted commit

## Preview Deployments

- Vercel / Netlify / Coolify: automatic per PR
- Use preview URLs in PR descriptions for client review
- Preview DB: shared staging DB or ephemeral Neon branch per PR (recommended for schema changes)

## Rollback

- Vercel: "Promote to Production" on any prior deploy
- Fly.io: `fly releases` → `fly deploy --image <previous-image>`
- Coolify: rollback button in UI
- Always verify health check + smoke-test critical path (login, checkout) after rollback

## Pre-Deploy Checklist

- [ ] `npm run build` / `dotnet publish` passes locally
- [ ] Tests green (see `testing` skill)
- [ ] DB migration reviewed (see `database` skill)
- [ ] Env vars set in target environment
- [ ] Rollback plan documented

## Companion Skills

- `devops` — Docker/K8s/Grafana for self-hosted setups
- `database` — migration workflow before a deploy
- `security` — secrets handling, HTTPS headers
- `git-workflow` — release branch / tag strategy

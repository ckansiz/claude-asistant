---
name: Workspace Overview
description: Structure of ~/workspace - projects, tech stacks, and infrastructure layout
type: project
---

~/workspace contains these key areas:

- **qoommerce/** - Multi-tenant e-commerce SaaS (.NET 10 + Astro + React + shadcn/ui, PostgreSQL, OpenIddict auth)
- **wesoco/** - Website platform + ~20 client sites (Astro, Next.js, mixed stacks)
- **loodos/** - A101 MEP backend (.NET, EF Core, GitLab CI)
- **docker/** - Centralized dev infra (PostgreSQL 18, Grafana LGTM stack)
- **k8s/** - Kubernetes deployment configs
- **sandbox/** - Experimental (APISIX gateway, infra testing)
- **sdks/** - Flutter SDK source
- **smurfs/** - NEW: Agent architecture workspace (currently empty)

**Why:** Understanding project layout helps route agent tasks to correct directories and tech stacks.
**How to apply:** When user references a project, map it to the correct directory and tech stack before acting.

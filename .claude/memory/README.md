# Project Memory Index

Lightweight index for `.claude/memory/`. Read the file you need; don't preload everything.

## Core

- [profile.md](profile.md) — Cem's identity, stack preferences, delegation preferences
- [workspace.md](workspace.md) — project roots, path keywords, Wesoco client stacks

## Clients (`clients/`)

One file per Wesoco client. Contains stack, branding, deploy target, known constraints.

- [_template.md](clients/_template.md) — copy when onboarding a new client
- [arzisi-project.md](clients/arzisi-project.md)
- [asfire.md](clients/asfire.md)
- [kanser-tedavi.md](clients/kanser-tedavi.md)
- [oltan.md](clients/oltan.md)
- [qretna-app.md](clients/qretna-app.md)
- [serkan-tayar.md](clients/serkan-tayar.md)
- [wcard-website.md](clients/wcard-website.md)

## Decisions (`decisions/`)

Architecture Decision Records — why we picked X over Y. Read before re-litigating a decision.

- [adr-001-no-mediatr.md](decisions/adr-001-no-mediatr.md)
- [adr-002-openapi-typescript-codegen.md](decisions/adr-002-openapi-typescript-codegen.md)
- [adr-003-agent-model-assignment.md](decisions/adr-003-agent-model-assignment.md)
- [adr-004-ui-stack-mandatory.md](decisions/adr-004-ui-stack-mandatory.md)

## When to Update

- New client → `clients/{slug}.md` (copy template) + add row to `workspace.md`
- New architecture decision → `decisions/adr-NNN-{slug}.md`
- Change in Cem's preferences / stack defaults → `profile.md`
- Never dump conversation logs or ephemeral task notes here — memory is for durable context

## Conventions

- Paths absolute from `.claude/memory/`
- Filenames lowercase, kebab-case
- ADRs immutable once accepted; supersede with a new ADR instead of rewriting

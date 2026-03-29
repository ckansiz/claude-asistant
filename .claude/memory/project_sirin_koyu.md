---
name: Sirin Koyu Architecture
description: Federated agent village - smurfs/ is central hub, agents are copied to projects via sync-push, learnings flow back via sync-pull
type: project
---

Sirin Koyu is a federated multi-agent system at ~/workspace/smurfs/.

**Architecture:** Hub + per-project copies with two-way sync.
- smurfs/ holds master agent definitions and central memory
- Projects get their own copies via `./scripts/sync-push.sh <path>`
- Project learnings flow back via `./scripts/sync-pull.sh <path>` (or --all)
- Project-specific context (rules/, CLAUDE.md) is never overwritten by sync

**Agents (5 smurfs):**
- ressam-sirin: UI/CSS/Design (opus)
- gozluklu-sirin: Code review/QA, READ-ONLY (opus)
- hirdavat-sirin: Backend/.NET/infra (opus)
- cirak-sirin: Scaffolding/setup (sonnet)
- arastirmaci-sirin: Research, READ-ONLY (opus)

**Why:** User wants project independence + centralized learning. No project should depend on smurfs/ to function.
**How to apply:** When starting work on a project, first sync-push agents there. Open Claude in the project directory directly.

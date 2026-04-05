# ADR-003: Agent Model Assignments

**Date**: 2026-Q1 (updated 2026-04-05)
**Status**: Accepted
**Scope**: All Claude Code agent invocations in this workspace

## Decision

Each agent has a fixed model tier assigned via frontmatter `model:` field. Use short names (`opus`, `sonnet`, `haiku`) — Claude Code resolves these to the latest version in each tier.

| Agent | Model | Rationale |
|-------|-------|-----------|
| architect | opus | Deep research, architecture decisions — needs strongest reasoning |
| builder | sonnet | Implementation across all stacks — fast, cost-effective |
| designer | sonnet | HTML wireframe/design generation — fast iteration |
| reviewer | sonnet | Code review, QA — standard analysis sufficient |
| image-gen | sonnet | Image generation pipeline — prompt crafting + tool use |

## Rationale

- **Opus** for research and architecture: highest quality reasoning for decisions that shape the project
- **Sonnet** for implementation and review: fast enough for code generation, cost-effective at scale
- Haiku tier currently unused — reserved for future mechanical/scaffolding tasks if needed

## Consequences

- Agent frontmatter uses short model names (`opus`, `sonnet`) — Claude Code maps to latest version
- When invoking agents via the Agent tool, the `model:` parameter in the tool call can override frontmatter if needed (e.g. promoting reviewer to opus for E2E/UAT reviews)

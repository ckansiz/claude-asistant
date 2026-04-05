# ADR-004: shadcn/ui + Tailwind CSS — Mandatory UI Stack

**Date**: 2025-Q3
**Status**: Accepted (non-negotiable)
**Scope**: All web surfaces (Astro, Next.js, any React project)

## Decision

All web UI must use shadcn/ui + Tailwind CSS. No Bootstrap, Material UI, Chakra UI, Ant Design, or plain CSS modules.

**Design token**:
- Primary: navy `#1B2B5E` (`--primary`)
- Border radius: `0.5rem` (`--radius`)
- Icon library: Lucide React
- Font: DM Sans

## Rationale

- Single design system across all ~20 Wesoco client sites + qoommerce
- Cem does not write CSS — UI is fully delegated (designer → builder → reviewer)
- shadcn/ui components are owned in the repo (copied, not imported) — easy to customize
- Tailwind's utility classes match NativeWind for mental model consistency with React Native

## Exceptions

- **React Native / Expo**: shadcn/ui is web-only → use NativeWind (same Tailwind classes)
- **HTML wireframes / mockups**: Tailwind CDN via `<script>` tag, simulate shadcn zinc scale
- **Email templates**: plain HTML + inline styles (no Tailwind)

## Consequences

- Bootstrap or other CSS frameworks must be removed if found in projects
- All new component requests go to @builder via `/frontend` (never written inline by other agents)
- UI PRs must pass @reviewer via `/review` before merge

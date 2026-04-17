---
name: spec-writing
description: This skill should be used when the user asks to "write a spec", "draft requirements", "produce a tech spec", "document the project", or invokes /spec. Transforms a user request into structured `docs/requirements.md` and `docs/tech-spec.md` (handed to @architect).
version: 1.0.0
---

# Specification Workflow

Apply when transforming a user request into structured documentation before any code is written. Owned by **@architect** (read-only on production code).

## Step 1: Ask Clarifying Questions

Before writing anything, ask to understand:
- What problem does this solve?
- Who are the users?
- Must-have vs nice-to-have features?
- Constraints (tech stack, timeline, integrations)?

Avoid asking too many questions in a single message — start with the most important and follow up.

## Step 2: Write Requirements

Output to `docs/requirements.md`:
- User stories: `As a [role], I want [action] so that [benefit]`
- Acceptance criteria per story
- Edge cases and error scenarios
- Out-of-scope items (explicit)

## Step 3: Write Tech Spec

Output to `docs/tech-spec.md`:
- Stack decisions with rationale (check existing stack first — see `tech-research` skill)
- Data model outline (entities + relationships)
- API endpoints (route, method, request/response shape)
- External integrations
- Open questions (anything blocking implementation)

## Completion

Present both documents for review. Implementation only starts after the user approves the spec.

## Stack Reminder

The default stack is .NET 10, Astro 5, Next.js 15, shadcn/ui + Tailwind, PostgreSQL 18. Solve with the existing stack before introducing new dependencies.

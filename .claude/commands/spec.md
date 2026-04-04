# /spec — Specification Mode

Activate **@architect** for this session.

## Goal

Transform a user request into structured documentation before any code is written.

## Step 1: Ask clarifying questions

Before writing anything, ask to understand:
- What problem does this solve?
- Who are the users?
- What are the must-have vs nice-to-have features?
- Any constraints (tech stack, timeline, integrations)?

## Step 2: Write requirements

Output to `docs/requirements.md`:
- User stories: `As a [role], I want [action] so that [benefit]`
- Acceptance criteria per story
- Edge cases and error scenarios
- Out of scope (explicit)

## Step 3: Write tech spec

Output to `docs/tech-spec.md`:
- Stack decisions with rationale
- Data model outline (entities + relationships)
- API endpoints (route, method, request/response shape)
- External integrations
- Open questions (anything blocking implementation)

## Completion

Present both documents for review. Implementation only starts after the user approves the spec.

$ARGUMENTS

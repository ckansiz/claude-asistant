---
name: spec-writing
description: This skill should be used when the user asks to "write a spec", "draft requirements", "produce a tech spec", "document the project", or invokes /spec-writing. Transforms an intake brief (or raw request) into structured `docs/requirements.md` and `docs/tech-spec.md` (handed to @architect).
version: 1.1.0
---

# Specification Workflow

Apply when transforming a request into structured documentation before any code is written. Owned by **@architect** (read-only on production code).

Prefer to run after `intake` has produced a brief — the spec then fills in detail. If intake was skipped, expand Step 1 below and ask broader clarifying questions before writing.

## Step 1: Clarifying Questions (Expanded)

Ask in batches of 3–5. Skip questions already answered in the intake brief.

### Business & Goals
- What problem does this solve? Who's the primary user?
- What does "done well" look like — a metric, a behavior, a stakeholder sign-off?
- Must-have vs nice-to-have? What's explicitly out of scope?
- SLA expectations — uptime, response time, support hours?

### Users & Access
- How many users, which roles, which permissions per role?
- Authentication source (email+password, OAuth, SSO)?
- Public-facing or authenticated-only?

### Data & Privacy
- What personal data is stored? Subject to KVKK / GDPR?
- Retention / deletion policy?
- Data residency (TR / EU / any) requirement?
- Audit log needed?

### Tech & Integrations
- Any non-negotiable stack choice, or pick from our defaults (.NET 10, Astro 5, Next.js 15, shadcn/ui, Tailwind, PostgreSQL 18)?
- External integrations (payment, email/SMS, analytics, CRM, ERP)?
- Existing auth system to integrate with?
- Branding assets available (logo, palette, font)?

### Delivery & Ops
- Deadline + milestones?
- Hosting target — Vercel / Fly / Hetzner / on-prem?
- Who deploys, who monitors, who gets paged?
- Budget shape — fixed / hourly / retainer?
- Post-launch support window?

Avoid dumping all questions in one message. Lead with the ones that block estimation.

## Step 2: Write Requirements

Output to `docs/requirements.md`:

```markdown
# Requirements — {Project / Feature Name}

**Version:** 0.1 Draft
**Owner:** {name}
**Related intake:** docs/intake/{date}-{slug}.md (if any)

## 1. Problem Statement
{1-2 paragraphs — what problem, who has it, why now}

## 2. Goals & Non-Goals
### Goals
- {measurable, short}

### Non-Goals (explicit)
- {what we are NOT solving}

## 3. Users & Roles
| Role | Description | Key actions |
|------|-------------|-------------|
| | | |

## 4. User Stories
- As a {role}, I want {action}, so that {benefit}.
- Acceptance criteria per story:
  - Given {context}
  - When {action}
  - Then {outcome}

## 5. Functional Requirements
- FR-01: {must behave like this}
- FR-02: ...

## 6. Non-Functional Requirements
- NFR-01: Performance — {target}
- NFR-02: Availability — {target}
- NFR-03: Security — {auth model, encryption}
- NFR-04: Accessibility — WCAG AA
- NFR-05: i18n — {languages, default}
- NFR-06: Privacy — {KVKK/GDPR items}

## 7. Edge Cases & Error Scenarios
(From the `edge-cases` skill — MANDATORY section, not optional.)

| # | Category | Scenario | Requirement |
|---|----------|----------|-------------|
| 1 | Auth | Expired token during upload | auto-refresh once, surface error on second failure |
| 2 | Input | Payload exceeds 5 MB | reject with 413 + user-friendly message |
| … | | | |

## 8. Out of Scope
- {explicit; prevents scope creep}

## 9. Open Questions
- {question → who answers → blocks what}
```

## Step 3: Write Tech Spec

Output to `docs/tech-spec.md`:

```markdown
# Tech Spec — {Project / Feature Name}

**Version:** 0.1 Draft
**Related requirements:** docs/requirements.md

## 1. Stack Decisions
| Area | Choice | Rationale |
|------|--------|-----------|
| Backend | .NET 10 + EF Core | existing stack |
| DB | PostgreSQL 18 | existing stack |
| Frontend | Astro 5 + shadcn/ui | existing stack |
| Auth | better-auth | new project |
| Payment | iyzico | TR client preference |

(Check existing stack first — `tech-research` skill only for genuine gaps.)

## 2. Architecture Overview
{diagram or 1-paragraph description — modules, data flow, external calls}

## 3. Data Model
### Entities
- **{Entity}** — {fields, relationships, invariants}

### Migrations
- New tables / columns
- Indexes
- Backfill steps (flagged if destructive — see `orchestration` destructive list)

## 4. API Contract
### Endpoints
| Method | Path | Purpose | Auth | Request | Response |
|--------|------|---------|------|---------|----------|
| POST | /api/... | create X | user | {DTO} | {DTO} |

### Error contract
- Error shape: `{ code, message, details }`
- Status codes per scenario

## 5. External Integrations
| Service | Purpose | Failure mode | Fallback |
|---------|---------|--------------|----------|
| | | | |

## 6. Security Model
- Auth flow
- Authorization rules per endpoint/page
- Secrets handling (env, vault, Doppler?)
- Input validation layers (client, server, DB constraints)
- Rate limits

## 7. Observability
- Logging — what, where, at what level
- Metrics — what, dashboard link
- Alerts — what pages someone, who

## 8. Edge Case Handling
Cross-reference requirements §7. For each entry, state **where** it's handled (domain, endpoint, client, infra).

## 9. Testing Strategy
- Unit: {what coverage target}
- Integration: {what covers the API}
- E2E / smoke: {critical journeys}
- Visual regression: {pages}

## 10. Rollout
- Feature flag? Gradual or all-at-once?
- Migration order vs code deploy order
- Rollback plan

## 11. Open Questions
- {blockers before implementation}
```

## Step 4: Review & Approval

Present both documents. **Implementation does not start** until the user marks the spec "Approved".

If the intake brief's Recommended Next Step was `plan-mode` (not `spec-writing`), that means the task is small enough to skip the full spec — a plan is sufficient. Do not write a 20-page spec for a 2-hour job.

## Stack Reminder

Default stack: .NET 10, Astro 5, Next.js 15, shadcn/ui + Tailwind, PostgreSQL 18, React Native/Expo (mobile), Docker + K8s + Grafana LGTM. Solve with existing stack before introducing new dependencies.

## Companion Skills

- `intake` — precedes spec; spec fills in the detail
- `edge-cases` — mandatory for Requirements §7
- `tech-research` — when a genuine stack gap is identified
- `plan-mode` — follows spec approval
- `orchestration` — the larger loop this spec sits inside

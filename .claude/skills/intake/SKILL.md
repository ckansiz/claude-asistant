---
name: intake
description: This skill should be used when a new work request arrives (feature, bug, integration, redesign) and before any plan or code is written. Also invoked via /intake. Produces a structured discovery brief — summary, stakeholder map, edge cases, open questions, risks, and scope estimate — so the freelancer can understand the job fully before committing.
version: 1.0.0
---

# Work Intake & Discovery

Apply the moment a new job, ticket, or request comes in. The goal: turn a fuzzy ask into a concrete, contract-ready brief **before** planning or estimating. Owned by **@architect** (read-only on production code).

Freelance reality: if intake is weak, scope creeps, edge cases bite mid-sprint, and the delivery is late. Intake is the cheapest insurance you have.

## When Intake Is Mandatory

- New client or new project
- Any request larger than ~2 hours of work
- Anything touching auth, payments, data model, integrations, migrations
- Redesigns, rewrites, or rewrites disguised as "small tweaks"
- Anything with a deadline, SLA, or external dependency

## When Intake Can Be Skipped

- Typo / copy tweak
- Single-file bug with obvious root cause
- Follow-up on a previously-intaked task (update the existing brief instead)

If skipped, still note *why* in the plan ("too small for intake — scope <2h, single file").

## Step 1 — Read the Raw Request

Before asking anything, read the request twice. Then explicitly note:
- What is being asked (literal)
- What seems to be assumed (implicit)
- What is vague or missing

Do not paraphrase the request as "understood" until after Step 2.

## Step 2 — Clarifying Questions

Ask in batches of 3–5, not a wall. Prioritize questions that unblock estimation.

### Business & Scope
- What problem does this solve for the end user?
- What does success look like — is there a metric, a deadline, a stakeholder sign-off?
- Must-have vs nice-to-have? What's explicitly *out* of scope?
- Is this a one-shot delivery or ongoing work?

### Users & Stakeholders
- Who uses this feature? (roles, rough volume)
- Who approves it? Who tests it before launch?
- Any external party involved (client's client, third-party API owner)?

### Tech & Constraints
- Existing stack or greenfield? Any non-negotiable tech choice?
- Integrations — which external services, APIs, SSO, payment providers?
- Environments — dev, staging, prod? Any access missing?
- Data — what's PII, what's subject to GDPR/KVKK, what has retention rules?

### Delivery & Ops
- Deadline + any hard milestones in between
- Hosting / deployment target — do I own it or does the client?
- Who handles post-launch support and monitoring?
- Budget shape — fixed price, hourly, retainer?

Prune irrelevant questions for smaller tasks. Hold back questions that can be answered by reading the repo — don't waste the client's attention.

## Step 3 — Edge Case Sweep

Run the `edge-cases` skill checklist over the ask. Capture at least 5 concrete edge cases specific to this task (not generic).

Do not skip this step, even under time pressure. Missed edge cases become post-launch hotfixes — the most expensive kind of work.

## Step 4 — Write the Intake Brief

Output to `docs/intake/{YYYY-MM-DD}-{slug}.md` (create the directory if missing). Keep under ~200 lines.

```markdown
# Intake Brief — {Task Title}

**Date:** {YYYY-MM-DD}
**Client / Project:** {name}
**Status:** Draft | Awaiting Answers | Approved
**Scope estimate:** S (<1 day) | M (1–3 days) | L (>3 days) | XL (needs spec)

## 1. Summary
One short paragraph — what, for whom, why.

## 2. Goals & Success Criteria
- Primary goal: {one sentence}
- Success metrics: {measurable, or "no metric — judgment call"}
- Deadline: {date or "flexible"}

## 3. Stakeholders
| Role | Who | Responsibility |
|------|-----|----------------|
| Requester | | writes the request |
| Approver | | signs off on delivery |
| End user | | actually uses it |
| Third-party | | external dependency (if any) |

## 4. Scope
### In scope
- {item}

### Out of scope (explicit)
- {item — what I will NOT do}

## 5. Edge Cases (from `edge-cases` skill)
- {concrete, task-specific edge case}
- {…}
- {at least 5}

## 6. Open Questions
- {question → blocks what}
- {…}

## 7. Risks & Dependencies
| Risk / Dep | Likelihood | Impact | Mitigation |
|------------|------------|--------|------------|
| | L/M/H | L/M/H | |

## 8. Recommended Next Step
- [ ] Proceed to `spec-writing` (XL / complex)
- [ ] Proceed to `plan-mode` (S / M — clear enough)
- [ ] Need answers first — see Open Questions
- [ ] Decline / renegotiate — {reason}

## 9. Proposed Workflow
- Entry skill: `new-feature` | `bug-fix` | `hotfix` | other
- Skills likely to trigger: {list}
- Agents involved: {architect / builder / reviewer / designer}
```

## Step 5 — Present for Confirmation

Share the brief with the user. Do not proceed to spec / plan / build until:
- All "blocks what" Open Questions are answered
- Scope estimate + Out-of-scope list are confirmed
- Recommended Next Step is approved

If the client won't give answers, record that explicitly in the brief ("assumed X because Y, flag for validation later") — never silently assume.

## Step 6 — Hand-off

Based on the approved Recommended Next Step:
- **XL** → `spec-writing` → `@architect` produces `docs/requirements.md` + `docs/tech-spec.md`
- **M/L** → `plan-mode`
- **S** → direct to `@builder` with the brief as context
- **Hotfix triage** → `hotfix`

The intake brief travels with the task — link it from the plan, spec, PR body, and final delivery report.

## Anti-Patterns

- Skipping intake because "the client was clear" — they almost never are
- Asking 15 questions in one message — cognitive overload, low response rate
- Treating the brief as paperwork — it's the contract + the edge-case insurance
- Starting to code while "waiting for answers" — that's how scope creep begins

## Companion Skills

- `edge-cases` — the systematic checklist for Step 3
- `spec-writing` — full spec when scope estimate is XL
- `plan-mode` — plan discipline after intake is approved
- `client-report` — status updates and delivery reports referencing the brief
- `orchestration` — where intake sits in the multi-agent loop

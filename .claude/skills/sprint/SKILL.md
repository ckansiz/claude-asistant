---
name: sprint
description: This skill should be used when the user asks to "start a sprint", "init a sprint folder", "open a new delivery", "close a sprint", or whenever a `new-feature`, `bug-fix`, or `hotfix` workflow begins. Owns the sprint lifecycle — folder setup, decisions log protocol, and close checklist. Delivery-based, not time-based.
version: 1.0.0
---

# Sprint Lifecycle

Every M+ job flows through a sprint folder. A sprint is a **delivery unit** — start when work begins, close when the PR merges and the retro is done. No calendar cadence.

Read `docs/sprints/README.md` for the complete folder layout and naming rules. This skill covers **how to run the lifecycle**: init, live log discipline, and close checklist.

## When a sprint is required

| Situation | Sprint folder |
|-----------|---------------|
| `new-feature` (M/L/XL) | Required |
| `bug-fix` with root cause investigation | Required |
| `hotfix` | Required (mini layout) |
| S-size work: <4h, typo, copy, single-file config bump | Skip |

When in doubt, open a folder. Closing an empty sprint is cheaper than reconstructing lost context.

## Step 1 — Init (at sprint start)

The orchestrator (@architect in loop mode) runs this before any implementation begins.

### 1a. Decide size
Map the incoming work to S / M / L / XL / Hotfix using the table in `docs/sprints/README.md`. Size determines the layout (full vs mini) and whether retro is full or mini.

### 1b. Create folder from template
```bash
cp -r docs/sprints/_template docs/sprints/{YYYY-MM-DD}-{client}-{slug}
```

- Date = today (sprint start)
- Client slug: `qoommerce`, `oltan`, `asfire`, `wcard`, `arzisi`, `kanser-tedavi`, `serkan-tayar`, `qretna`, `loodos`, or `internal` for eng-team itself
- Slug: short kebab-case hint (`checkout-refund`, `auth-500`, `seo-audit`)

### 1c. Fill `00-sprint.md`
Required fields (non-negotiable):
- **Goal** — one sentence, what shipping looks like
- **Size** — M / L / XL / Hotfix
- **Client** — from the list above
- **Deliverable** — concrete artifact (PR URL format, deploy target, client handoff doc)
- **Roles** — which agents touch this sprint
- **Kickoff decision** — first line in the decisions log, explaining why this sprint was opened now

### 1d. Create the empty live log
`04-decisions.md` starts with a header and one kickoff line. Every agent is expected to append to it during the sprint.

### 1e. Reference the sprint in handoffs
From this point, every handoff report (builder, review, test) must include the sprint folder path as context — orchestration artifacts live inside the sprint, not floating in the repo.

## Step 2 — Live log discipline (`04-decisions.md`)

This is the most frequently-skipped file and the one that makes retros actually useful. The rule is simple: **every key decision, one line, timestamped, with why**.

### Format

```
[YYYY-MM-DD HH:MM] <agent>: <decision> — <why> (rejected: <alternatives, if any>)
```

### What counts as a "key decision"

Write a line when:
- A scope boundary moves (added / removed item)
- A library, pattern, or approach is chosen over alternatives
- A trade-off is made (performance vs readability, strict vs lenient, etc.)
- A blocker is hit and worked around
- A plan item is deferred to a follow-up sprint

What does NOT need a line:
- Routine implementation (naming a variable, picking a file location)
- Trivial style tweaks
- Things already captured in the commit message

### Who writes

Every agent that makes a decision. Builder appends for implementation trade-offs. Reviewer appends when a finding shifts scope. Designer appends for UX trade-offs. Architect adds the summary pass during sprint close.

If a decision has **no line** and comes up in retro as a pain point, that's itself a retro finding — undocumented decision.

## Step 3 — Close (before retro)

The orchestrator runs the close checklist. Do not start the retro until every item is PASS or explicitly waived with a note in `04-decisions.md`.

```
## Sprint Close Checklist
- [ ] 00-sprint.md filled (goal, size, client, deliverable, roles)
- [ ] 03-plan.md present and approved (if M/L/XL) — hotfix uses 01-fix.md
- [ ] 04-decisions.md has ≥3 lines (any size); hotfix allowed ≥1
- [ ] 05-handoffs/ contains builder + review + test reports (M/L/XL only)
- [ ] 06-delivery.md has PR link + commit SHA + deploy status
- [ ] Quality gates (type check, tests, build) — all PASS per orchestration skill
- [ ] No loose scope drift outside what 04-decisions.md captured
```

If any item fails, the sprint stays open. Write a `[timestamp] architect: sprint close blocked — <reason>` line and address the gap before proceeding.

## Step 4 — Retro handoff

Once close checklist is clean, invoke the `retro` skill to produce `07-retro.md`. The retro is not optional for M+ sprints. For hotfixes, the mini-retro variant is mandatory.

The retro skill produces actions. The sprint is not **fully** closed until those actions are applied and linked from `08-system-updates/SUMMARY.md`.

## Step 5 — Applied status

After `08-system-updates/SUMMARY.md` contains links for every retro action (or `backlogged` notes for ones deferred with user approval), the sprint is closed.

Add one final line to `04-decisions.md`:

```
[YYYY-MM-DD HH:MM] architect: sprint closed — actions applied, linked in 08-system-updates/
```

## Sprint sizing — deciding M vs L vs XL

Rough heuristics for the orchestrator at the Intake Gate:

| Signal | Size hint |
|--------|-----------|
| Single endpoint/component change, known pattern | M |
| Multi-component, touches 2-3 files across layers | M–L |
| New integration, new data model, cross-client impact | L |
| New product area, new stack pattern, spec required | XL |
| Production fire, users affected right now | Hotfix |

When borderline, size up — an M that turns into L mid-sprint needs a sprint-update line in `04-decisions.md`, but the folder stays the same.

## Anti-patterns

- **Empty decisions log** — sprint is "done" but nobody logged anything. Retro becomes guesswork. Fix at next sprint init: require kickoff line.
- **Multiple deliveries per folder** — two features crammed into one sprint to avoid admin. Split the folder or admit it is L-sized work.
- **Retro with no system update** — wrote the retro, never applied aksiyonlar. `08-system-updates/` stays empty. Sprint stays open.
- **Sprint folder created post-hoc** — documentation after the fact, not live capture. The decisions log loses the "why" because memory fades. Open the folder at start, even if it feels heavy.

## Companion skills

- `retro` — produces `07-retro.md` and drives `08-system-updates/` aksiyonlar
- `orchestration` — Phase 0 (Sprint Init) and Phase 9 (Retro) wrap around this skill
- `new-feature` / `bug-fix` / `hotfix` — workflow entry points that run inside a sprint
- `intake`, `spec-writing`, `plan-mode` — fill `01-intake.md`, `02-spec.md`, `03-plan.md` respectively
- `code-review`, `testing` — produce the files under `05-handoffs/`

$ARGUMENTS

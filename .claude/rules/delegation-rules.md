# Smurf Delegation Rules

## SDLC Pipeline (Mandatory for New Projects)

```
Phase 1: Discovery
  → Poet Smurf (requirements.md + tech-spec.md)
  → Dreamy Smurf (research open questions)
  ⛳ CHECKPOINT 1: User approves spec + stack — WAIT before proceeding

Phase 2: Design
  → Vanity Smurf (design-a.html, design-b.html, design-c.html)
  ⛳ CHECKPOINT 2: User selects design A/B/C — WAIT before proceeding

Phase 3: Development
  → Hefty Smurf (scaffold)
  → Painter Smurf + Handy Smurf (parallel)
  → Clumsy Smurf (if mobile, after stack confirmed)
  → Brainy Smurf (review)
  ⛳ CHECKPOINT 3: Delivery report → User business review → Release
```

## Checkpoint Rules

- **NEVER skip a checkpoint** — user is always the client and must approve
- **Present clearly**: what was produced, what decision is needed
- **Wait for explicit response** before dispatching next phase
- If user rejects: revise with the relevant smurf, re-present

## Other Mandatory Chains

1. **ANY UI/CSS work** → Painter Smurf → Brainy Smurf (review MANDATORY, never skip)
2. **New design needed** → Vanity Smurf → CHECKPOINT → Painter Smurf → Brainy Smurf
3. **Unknown approach** → Dreamy Smurf → (implementation smurf)
4. **Mobile work** → Dreamy Smurf (stack decision first) → Clumsy Smurf → Brainy Smurf
5. **Backend + Frontend together** → Handy + Painter (parallel) → Brainy (review both)
6. **Image/visual asset needed** → Smurfette (can run parallel with Painter or Handy)
7. **Client social media content** → Smurfette (standalone, no review needed for generated images)

## Parallel Dispatch (use background: true)

These combinations are safe to run in parallel:
- Painter (frontend) + Handy (backend) — independent work areas
- Painter (frontend) + Smurfette (images) — UI code + visual assets simultaneously
- Smurfette (images) + Handy (backend) — assets + API work simultaneously
- Poet (spec) + Dreamy (research) — if research topics are known upfront
- Dreamy (research) + Hefty (scaffold) — if tasks don't depend on each other
- Multiple Painter dispatches to DIFFERENT projects — batch updates across clients

## Single Project Rule

Each smurf dispatch targets exactly ONE project directory. Never mix projects in a single dispatch.

## Learning Protocol

Every smurf that has Write access MUST append to `.claude/project-learnings.md` when:
- A new pattern was established that other projects could reuse
- A client-specific preference was discovered (colors, fonts, layout preferences)
- A tricky bug was solved that could recur elsewhere
- A new library/tool was integrated and configured

Format:
```markdown
## [YYYY-MM-DD] - [Topic]
**Smurf:** [agent name]
**Pattern:** [what was learned]
**Applicable to:** [which stacks/projects benefit]
```

## Memory Update Triggers

After a smurf reports completion, Papa Smurf should update central memory if:
- A reusable pattern emerged → update `memory/patterns/{stack}-patterns.md`
- Client preference discovered → update `memory/clients/{client}.md`
- Architecture decision made → update `memory/decisions/`

## Escalation

If a smurf reports failure or uncertainty:
1. First: dispatch Dreamy Smurf to research the problem
2. Then: re-dispatch the original smurf with research findings
3. If still stuck: report to user with findings and ask for guidance

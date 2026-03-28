# Smurf Delegation Rules

## SDLC Pipeline (Mandatory for New Projects)

```
Phase 1: Discovery
  → Poet Smurf (requirements.md + tech-spec.md)
  → Dreamy Smurf: Tech Research (open questions from spec)
  ⛳ CHECKPOINT 1: User approves spec + stack — WAIT before proceeding

Phase 2: Design (3-step — never skip steps)

  Step 2a: Design Research
    → Dreamy Smurf: UI/UX Design Research mode
      • Searches Dribbble, Behance, Awwwards, Lapa.ninja, live competitors
      • Produces Design Brief: trends, inspiration refs, layout direction options
      • Documents what to avoid (anti-patterns, AI-generic clichés)
    ⛳ CHECKPOINT 2a: User reviews Design Brief + confirms visual direction — WAIT

  Step 2b: Wireframes
    → Vanity Smurf: Wireframes only (gray boxes, layout structure, no color)
      • wireframe-a.html — Direction A from brief
      • wireframe-b.html — Direction B from brief
    ⛳ CHECKPOINT 2b: User selects wireframe structure — WAIT

  Step 2c: Full Design Alternatives
    → Vanity Smurf: Full HTML mockups based on approved wireframe + Design Brief
      • design-a.html — Visual direction A
      • design-b.html — Visual direction B
    ⛳ CHECKPOINT 2c: User selects final design A/B — WAIT before proceeding

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
2. **New design needed** → Dreamy (design research) → CHECKPOINT 2a → Vanity (wireframes) → CHECKPOINT 2b → Vanity (full designs) → CHECKPOINT 2c → Painter → Brainy
3. **Unknown approach** → Dreamy Smurf Tech Research → (implementation smurf)
4. **E2E test / UAT / pre-release** → Brainy Smurf dispatched with `model: opus` (Super Mode)
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

# Smurf Delegation Rules

## Mandatory Chains

1. **ANY UI/CSS work** -> Painter Smurf -> Brainy Smurf (review is MANDATORY, never skip)
2. **New project setup** -> Hefty Smurf -> (then appropriate smurf for actual work)
3. **Unknown approach / "how should we..."** -> Dreamy Smurf -> (then implementation smurf)
4. **Backend + Frontend together** -> Handy + Painter (parallel) -> Brainy (review both)

## Parallel Dispatch (use background: true)

These combinations are safe to run in parallel:
- Painter (frontend) + Handy (backend) — independent work areas
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
- A reusable pattern emerged -> update `memory/patterns/{stack}-patterns.md`
- Client preference discovered -> update `memory/clients/{client}.md`
- Architecture decision made -> update `memory/decisions/`

## Escalation

If a smurf reports failure or uncertainty:
1. First: dispatch Dreamy Smurf to research the problem
2. Then: re-dispatch the original smurf with research findings
3. If still stuck: report to user with findings and ask for guidance

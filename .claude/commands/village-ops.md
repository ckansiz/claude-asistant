# Village Operations Reference

Use this when adding new smurfs, running sync operations, or maintaining village health.

## Adding a New Smurf — 7-Step Checklist

```
[ ] 1. Create .claude/agents/{name}.md
      - Frontmatter: name, description, model, disallowedTools (if needed)
      - Workflow, Best Practices, Known Issues, Completion Format sections

[ ] 2. Update CLAUDE.md Delegation Rules
      - Add section: @{smurf-name} — when to dispatch, short mission statement

[ ] 3. Update README.md agent table
      - Add row: name, file path, model, role summary, write access (yes/no)

[ ] 4. Update .claude/rules/delegation-rules.md
      - If agent can run in parallel with others, add safe combinations to the parallelization table
      - Update mandatory chains if this agent is part of any pipeline

[ ] 5. Update global .claude/memory/MEMORY.md
      - Add pointer line in appropriate section: `- [Agent Name](agents/{name}.md) — one-liner`

[ ] 6. Update CLAUDE.md Workspace Map or tools section (if applicable)
      - If agent needs special config or tool setup, document it

[ ] 7. Deploy to target projects via sync-push
      - If applicable: ./claude/scripts/sync-push.sh ~/workspace/wesoco/works/{client}
```

**README must be updated before the smurf is considered "added".**

---

## Sync Protocol — Knowledge Flow

### Pull (project → central)

```bash
./.claude/scripts/sync-pull.sh ~/workspace/wesoco/works/{client}
```

**What it does:**
1. Reads `{project}/.claude/project-learnings.md`
2. Appends content to central `.claude/memory/patterns/{stack}-patterns.md`
3. Marks project's learnings as "synced"

**Trigger:** After Handy/Painter/Brainy complete work, append learnings to project's `project-learnings.md`, then Papa runs sync-pull.

---

### Push (central → projects)

```bash
./.claude/scripts/sync-push.sh ~/workspace/wesoco/works/{client}
```

**What it does:**
1. Copies master agent files to `{project}/.claude/agents/`
2. Merges central patterns to `{project}/.claude/rules/shared-patterns.md`
3. Does NOT touch project's existing `rules/` or `CLAUDE.md`

**Trigger:** When a smurf agent is significantly updated, push to target projects to keep them in sync.

---

## Trigger → Action Reference

| Trigger | Action |
|---------|--------|
| New agent .md created | Update README table + CLAUDE.md + MEMORY.md pointer |
| Smurf failed / workaround found | Add to agent .md "Known Issues" + create `feedback_*.md` memory |
| Smurf discovered successful pattern | Add to agent .md "Best Practices" + update `.claude/memory/patterns/{stack}-patterns.md` |
| API key / system dependency issue solved | Create/update `project_*_architecture.md` memory |
| Client preference discovered | Create/update `.claude/memory/clients/{client}.md` |
| sync-pull.sh executed | Distribute learned patterns to relevant agent .md files |
| New tool added to pipeline | Update README Tools section |

---

## Memory File Locations

All canonical memory lives in: `smurfs/.claude/memory/`

**Memory hierarchy:**

```
.claude/memory/
  MEMORY.md                    # Global index (always loaded)
  user_profile.md              # User identity + preferences
  smurfs/
    papa-smurf.md              # Papa's personal state + dispatch rules
    handy-smurf.md             # Handy's learned patterns
    painter-smurf.md           # Painter's learned patterns
    [other smurfs]
  clients/
    {client}.md                # Client brand colors, preferences, git URLs
  patterns/
    dotnet-patterns.md         # .NET stack reusable patterns
    astro-patterns.md          # Astro stack patterns
    nextjs-patterns.md         # Next.js patterns
    tailwind-patterns.md       # Tailwind patterns
  decisions/
    {decision-topic}.md        # Architecture decisions with rationale
  feedback_*.md                # User guidance rules
```

Projects receive a copy: `{project}/.claude/memory/MEMORY.md` via sync-push (read-only for projects).

**`~/.claude/` is NOT used** — it's machine-local and not device-agnostic.

---

## README Accuracy Checklist

Before any release, verify README reflects current state:

- [ ] Tüm aktif smurflar README agent tablosunda
- [ ] Agent sayısı `.claude/agents/` folder'daki .md dosya sayısıyla eşleşiyor
- [ ] Tools bölümü pipeline'daki tüm araçları listeliyor
- [ ] "Adding a New Smurf" checklist güncel adım sayısı içeriyor (şu an 7 adım)

---

## Agent File Standard Sections

Every agent .md should follow this structure:

```markdown
---
name: {agent-name}
description: "{one-liner role description}"
model: {sonnet/opus/haiku}
memory: local/global
disallowedTools: [list if any]
---

# {Full Name} - {Short Role Title}

## Role (2-3 sentences describing when/why to dispatch)

## Workflow (numbered steps for the agent's standard work process)

## Best Practices / Proven Patterns (learned from experience, not theory)

## Known Issues (failure modes with workarounds — discover these during use)

## Learning Protocol (when to write to project-learnings.md or central memory)

## Completion Format (standard output/report structure for this agent)
```

---

## Sample Learning Entry

After completing work, if patterns are discovered:

```markdown
## [YYYY-MM-DD] - [Topic]

**Smurf:** [Agent Name]

**Pattern:** [What was learned — specific enough to reuse]

**Applicable to:** [Which stacks/projects benefit from this]
```

Example:
```markdown
## [2026-04-04] - Tailwind custom property syntax for shadcn colors

**Smurf:** Painter Smurf

**Pattern:** shadcn color tokens accessed via `hsl(from var(--color-primary) / alpha / 1)` in Tailwind v4. Define base colors in globals.css with `--color-primary: oklch(...)`.

**Applicable to:** All Tailwind v4 + shadcn projects
```

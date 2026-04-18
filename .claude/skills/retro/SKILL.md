---
name: retro
description: This skill should be used when the user asks to "run a retro", "do a sprint retrospective", "close the sprint", "write a postmortem", or whenever a sprint folder reaches its close checklist. Produces `07-retro.md` (full — İyi / Kötü / Aksiyon) or `02-mini-retro.md` (hotfix — root cause + prevention) and drives `08-system-updates/` actions.
version: 1.0.0
---

# Retrospective

A retro is not a diary. It is a contract: every retro produces **≤3 concrete actions** that change the system (skill, `CLAUDE.md`, or memory). If the retro has no actions applied, the sprint stays open.

Two variants:
- **Full retro** — M/L/XL sprints. Structured as İyi / Kötü / Aksiyon.
- **Mini retro** — hotfix only. Structured as Root cause / Why missed / Prevention.

Both are mandatory within their scope. S-sized work has no retro (no sprint folder exists).

## When to run

| Sprint type | Retro variant | File |
|-------------|---------------|------|
| M / L / XL (`new-feature`, `bug-fix`) | Full | `07-retro.md` |
| Hotfix | Mini | `02-mini-retro.md` |
| S (typo, config, <4h) | — | No retro, no folder |

Trigger: sprint close checklist passed (see `sprint` skill, Step 3). Do not run a retro while handoffs or delivery are still in motion.

## Full retro — format (`07-retro.md`)

```markdown
# Retro — {sprint-folder-name}

## Context
- Goal: {from 00-sprint.md}
- Size: M / L / XL
- Duration (calendar): {start date → close date}
- Delivery: {PR URL from 06-delivery.md}

## İyi (what went well — keep doing)
- {Concrete thing that worked. Reference file/decision line if useful.}
- {Another. 3–5 bullets max.}

## Kötü (what went poorly — avoid next time)
- {Concrete friction. Reference where it showed up — 04-decisions.md line, handoff section, etc.}
- {Another. 3–5 bullets max.}

## Patterns observed (from @reviewer)
- {Reviewer-appended note: "3. defa aynı validation unutuldu" / "migration plan sürekli plan sonrası değişiyor" / etc.}
- {If none observed, write "none" — don't fabricate.}

## Aksiyonlar (max 3)

| # | Action | Type | Target | Owner | Applied |
|---|--------|------|--------|-------|---------|
| 1 | {short imperative: "Add X check to edge-cases skill"} | skill / CLAUDE.md / memory | `.claude/skills/edge-cases/SKILL.md` | architect | link to commit/PR |
| 2 | {...} | {...} | {...} | {...} | {...} |
| 3 | {...} | {...} | {...} | {...} | {...} |

### Backlog (not applied this sprint)
- {Anything that came up but exceeds the 3-action cap. Listed but not implemented until a later retro promotes it.}
```

### Rules for the full retro

- **Max 3 aksiyonlar**. Anything past 3 goes to Backlog. Forces prioritization and prevents retro-action enflasyonu.
- **Every aksiyon is typed** — `skill` / `CLAUDE.md` / `memory`. No vague "improve process" bullets.
- **Every aksiyon has a concrete target** — file path or memory file name. If you can't name a target, the aksiyon isn't real.
- **İyi section is not optional**. Saving only corrections makes the system drift toward over-caution. Confirm what worked so it gets reinforced.
- **Patterns observed** comes from @reviewer's cross-sprint memory, not the current one. If this is the first retro since rollout, write "baseline — no prior patterns yet".

### Writing the retro

1. Re-read `04-decisions.md` start to finish.
2. Re-read `05-handoffs/` reports — what did builder flag, what did reviewer flag, what did testing catch?
3. Ask: what would I do differently if I had the sprint to run again? That's Kötü.
4. Ask: what was surprising in a good way — a decision that paid off, a shortcut that worked, a pattern worth repeating? That's İyi.
5. Pick the 3 highest-leverage changes. Not the 3 easiest — the 3 that most reduce the chance of the Kötü items recurring.
6. Fill the table. Leave "Applied" blank; it fills in Step 6 of this skill.

## Mini retro — format (`02-mini-retro.md`)

Hotfixes move fast, but **every hotfix has a lesson or it's just debt**. The mini retro forces the three questions:

```markdown
# Mini Retro — {hotfix-folder-name}

## Hotfix summary
- What broke: {1 sentence}
- When detected: {timestamp}
- Time to mitigate: {minutes/hours}
- User impact: {segment + volume if known}
- Fix: {rollback / flag-off / forward fix, link to PR}

## Root cause
{2–4 sentences. What was the actual defect? Not "X didn't work" — why X didn't work. Cite commit or file:line if relevant.}

## Why we missed it
{Pick one or more: missing test, missing review, skipped gate, unclear requirement, environment drift, rushed prior sprint. Be honest, not generous.}

## Prevention (aksiyon — 1 zorunlu)

| Action | Type | Target | Owner | Applied |
|--------|------|--------|-------|---------|
| {1 concrete change that would have caught this} | skill / CLAUDE.md / memory / test | {path} | architect | link |

{Optional: 1 more if there's a clear second lever. Max 2.}
```

### Rules for the mini retro

- **1 aksiyon zorunlu**, max 2. If you can't name even one prevention action, you didn't find the root cause — go back to "Root cause".
- **Prevention ≠ "be more careful next time"**. Prevention is an artifact: a test, a lint rule, a checklist item, a memory line.
- **"Why missed" cannot be "unknown"** — if truly unknown, log that fact as the aksiyon ("Add observability to X so we can detect Y next time").
- **Post-merge only**. Don't pause the hotfix to write a retro. Merge, verify, then write this within 24 hours.

## Step 6 — Apply actions & close `08-system-updates/SUMMARY.md`

The retro table has an "Applied" column. That column stays blank until each aksiyon is actually merged.

For each aksiyon:

1. **Implement the change.**
   - `skill` type → edit the target SKILL.md file, commit on a branch like `chore/retro-{sprint-slug}-{n}`
   - `CLAUDE.md` type → edit the repo CLAUDE.md, same branch style
   - `memory` type → write to `~/.claude/projects/.../memory/{name}.md` and update `MEMORY.md` index
   - `test` type (mini retro) → add the regression test to the affected project
2. **Open a small PR** (or commit directly to `main` if the change is memory-only and repo policy allows). Conventional Commit format: `chore(retro): <action summary>`.
3. **Append a line to `08-system-updates/SUMMARY.md`**:

   ```
   ## {action #} — {short action title}
   - Type: skill / CLAUDE.md / memory / test
   - Target: {path}
   - Change: {1 sentence}
   - Link: {commit SHA or PR URL}
   - Applied: {YYYY-MM-DD}
   ```

4. **Update the "Applied" cell** in `07-retro.md` (or `02-mini-retro.md`) with the commit/PR link.

When every aksiyon row has a link (or explicit "backlogged by user on {date}"), the sprint is closed. Add the final line to `04-decisions.md` per the `sprint` skill close protocol.

## Accumulating patterns across sprints

`@reviewer` accumulates a cross-sprint "patterns observed" note. This is not stored in any one sprint folder — it lives in reviewer memory:

- After each review, if a finding reminds the reviewer of a **prior** sprint's finding, log it as a memory entry (`feedback_reviewer_patterns.md` or similar) with file reference.
- At next retro, the reviewer dumps recent pattern entries into the "Patterns observed" section.
- If the same pattern shows up in 2+ consecutive retros, promote it to a **mandatory aksiyon** — the pattern is systemic.

## Anti-patterns

- **Retro with 10 aksiyon** — nothing gets applied, system doesn't change. Cap at 3 (full) / 2 (mini).
- **Vague aksiyon** ("be better at testing") — no target, no artifact. Reject and rewrite concretely.
- **Hotfix without mini retro** — the whole reason hotfix exists is that full review is deferred. The mini retro IS the compensation. Skipping it = pure tech debt.
- **Retro before close checklist** — writing retro while reports are missing gives bad data. Run close first.
- **Applied column left blank** — sprint folder "looks" done. It isn't. Block close.
- **İyi section empty** — drift toward over-correction over time. Force at least one bullet.

## Companion skills

- `sprint` — owns the folder lifecycle; invokes this skill after close checklist passes
- `orchestration` — Phase 9 (Retro) sits at the end of the loop and calls this skill
- `hotfix` — mandates the mini retro variant after merge
- `commits` — format for the `chore(retro): ...` commits when applying aksiyonlar
- `edge-cases` — frequent target of retro actions (adding new rows to the checklist)

$ARGUMENTS

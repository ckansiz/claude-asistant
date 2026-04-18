# Mini Retro — {sprint-folder-name}

Mandatory within 24h of merge. Produced by `retro` skill (mini variant).

## Root cause

{2–4 sentences. Not "X didn't work" — *why* X didn't work. Cite commit or file:line if relevant.}

## Why we missed it

{Pick one or more: missing test, missing review, skipped gate, unclear requirement, environment drift, rushed prior sprint. Be honest, not generous.}

## Prevention (aksiyon — 1 zorunlu, max 2)

| # | Action | Type | Target | Owner | Applied |
|---|--------|------|--------|-------|---------|
| 1 | | skill / CLAUDE.md / memory / test | {path} | architect | {commit/PR link} |
| 2 | | | | | |

"Be more careful next time" is not an action. Prevention is an artifact: a test, a lint rule, a checklist item, a memory line.

## Postmortem (only if >1h user-facing impact)

### Timeline

- **Broke**: {YYYY-MM-DD HH:MM}
- **Detected**: {YYYY-MM-DD HH:MM}
- **Mitigated**: {YYYY-MM-DD HH:MM}
- **Resolved (full fix deployed)**: {YYYY-MM-DD HH:MM}

### Communication

- **User/client informed**: when, where, what was said

### Additional action items

- {alerts, runbooks, process changes beyond the prevention aksiyonu}

## Close

- [ ] Prevention aksiyonu applied and linked
- [ ] `08-system-updates/SUMMARY.md` updated (create if needed)
- [ ] Follow-up `bug-fix` task opened

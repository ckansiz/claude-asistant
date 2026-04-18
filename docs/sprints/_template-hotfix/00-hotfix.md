# Hotfix — {sprint-folder-name}

Mini sprint layout. Fill during or immediately after the hotfix rush. See `hotfix` skill for steps, `retro` skill (mini variant) for `02-mini-retro.md`.

## Summary

- **What broke**: {1 sentence — symptom as user saw it}
- **When detected**: {YYYY-MM-DD HH:MM}
- **When mitigated**: {YYYY-MM-DD HH:MM}
- **User impact**: {segment + approximate volume if known}
- **Detection**: {monitoring / user report / internal / accidental}

## Triage

- **Affected component**: {auth / payments / checkout / API / frontend / etc.}
- **Last deploy before incident**: {SHA + time}
- **Decision**: {rollback / feature flag off / forward fix}
- **Why this decision**: {1–2 sentences}

## Approver

- [ ] User acknowledged the incident and the chosen mitigation

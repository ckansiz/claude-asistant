# Project Memory

**This folder is project-local.** Everything under `.claude/memory/` (except this README) is gitignored and **never touched by `scripts/sync-eng-team.sh`**. Put project-specific context here; it stays with your project forever.

## What goes here

Lightweight, curated context that Claude should read to stay grounded on *your* project. Read the file you need — do not preload everything.

### Suggested layout

```
.claude/memory/
├── README.md              # This file (the only tracked one)
├── profile.md             # Developer/team identity, language, delegation preferences
├── workspace.md           # Project roots, keyword → path map, per-project stack
├── clients/               # One file per client (stack, branding, deploy, constraints)
│   ├── _template.md
│   └── {client-slug}.md
└── decisions/             # ADRs — why we picked X over Y
    └── adr-NNN-{slug}.md
```

None of this is mandatory — create only what your workflow needs. Recommended starters:

- **`profile.md`** — who you are, preferred language, stack defaults that override `CLAUDE.md`, what you delegate vs do yourself.
- **`workspace.md`** — paths you type as "qoommerce" / "client-x" / etc., mapped to absolute directories and stacks. Claude uses this to resolve keywords.
- **`clients/{slug}.md`** — per-client context so Claude doesn't re-ask every time: stack, brand colors, deploy target, known gotchas.
- **`decisions/adr-NNN-{slug}.md`** — immutable record of a non-obvious technical choice. Supersede with a new ADR instead of rewriting.

## When to update

| Trigger | File |
|---------|------|
| New client onboarded | `clients/{slug}.md` (copy from a template) + add row to `workspace.md` |
| New architecture decision | `decisions/adr-NNN-{slug}.md` |
| Change to developer preferences / stack defaults | `profile.md` |
| New project root, keyword, or alias | `workspace.md` |

## What NOT to put here

- Conversation logs or ephemeral task notes — use sprint folders for that
- Credentials, API keys, secrets — use `.env` (gitignored)
- Anything derivable from code, git history, or `CLAUDE.md`
- Content that belongs in a sprint folder (`docs/sprints/{YYYY-MM-DD}-*/`)

## Conventions

- Paths in links relative to `.claude/memory/`
- Filenames lowercase, kebab-case
- ADRs immutable once accepted — supersede with a new ADR rather than rewriting
- Keep each file short. If a file grows beyond ~200 lines, split it.

## Why this folder is not synced

The template (`scripts/sync-eng-team.sh`) updates agents, skills, hooks, and `CLAUDE.md` from upstream. If memory were synced, every update would wipe your project's context. Keeping memory strictly project-local is what makes the sync model safe.

# /review — Code Review Mode

Activate **@reviewer** for this session.

Read the relevant context for what is being reviewed:
- Frontend (Astro/Next.js): `.claude/context/typescript.md`
- Backend (.NET): `.claude/context/dotnet.md`
- API contract changes: `.claude/context/api-contract.md`

## Review Scope

Default: review the files/PR specified in `$ARGUMENTS`.

If no specific scope given, ask: what changed and what should be reviewed?

## Output

```
### Status: APPROVED | ISSUES FOUND | REJECTED

### Findings
🟢 [good]
🟡 [suggestion — not blocking]
🔴 [critical — must fix before merge]

### Details
[file — line — issue — suggested fix]
```

Reviewer is read-only. Reports findings; does not edit files.

$ARGUMENTS

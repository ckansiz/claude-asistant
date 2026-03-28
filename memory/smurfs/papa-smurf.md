# Papa Smurf — Personal Memory

## Role
Central orchestrator. Turkish with user, English for code/commits/docs.

## Dispatch Pattern (CRITICAL)
Always pass `model:` explicitly in every Agent tool call — belt-and-suspenders against frontmatter expand bugs:
```
subagent_type: "dreamy-smurf"
model: "sonnet"   ← always include
```

## Smurf → Model Table
| Smurf | Model |
|-------|-------|
| dreamy-smurf | opus |
| papa-smurf | opus |
| brainy-smurf (normal) | sonnet |
| brainy-smurf (UAT/E2E) | opus |
| vanity-smurf | sonnet |
| painter-smurf | sonnet |
| handy-smurf | sonnet |
| poet-smurf | sonnet |
| hefty-smurf | haiku |
| clumsy-smurf | sonnet |
| smurfette | sonnet |

## User Preferences
- Hates CSS — delegate ALL visual work to Painter without hesitation
- Prefers shadcn/ui + Tailwind for all web UI (no exceptions unless stated)
- Design pipeline must NOT be skipped: Dreamy research → wireframes → full designs
- Works via @papa-smurf agent, not raw Claude sessions

## SDLC Checkpoint Rules
Never skip checkpoints. Always WAIT for explicit user approval before proceeding.
- CHECKPOINT 1: After spec + stack (Phase 1)
- CHECKPOINT 2a/b/c: Design research → wireframes → full designs (Phase 2, 3 steps)
- CHECKPOINT 3: After dev + Brainy review (Phase 3)

## Known Issues
- Smurfette direct dispatch sometimes fails — fallback to Bash pipeline in `tools/image-generator/`
- All dispatches require explicit `model:` in tool call (see dispatch pattern above)

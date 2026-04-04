# /design — Design Mode

Activate **@designer** for this session.

## Workflow

**Step 1: Understand the brief**
- What is the product? Who is it for?
- Does a requirements doc or design brief already exist? (`docs/requirements.md`, `docs/design-brief.md`)
- Client-specific preferences? (check `.claude/memory/clients/{client}.md` if exists)

**Step 2: Wireframes first**
- Produce 2 layout alternatives as gray-box HTML files
- No color, no decoration — structure only
- Get user approval before proceeding

**Step 3: Full HTML designs (after wireframe direction approved)**
- 2 genuinely different visual directions
- Standalone HTML (no build step, Tailwind CDN, DM Sans font)
- Realistic content, no lorem ipsum
- Mobile-first (375px + 1280px)

## Output convention
- `docs/designs/wireframe-a.html`, `wireframe-b.html`
- `docs/designs/design-a.html`, `design-b.html`

$ARGUMENTS

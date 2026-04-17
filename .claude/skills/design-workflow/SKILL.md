---
name: design-workflow
description: This skill should be used when the user asks to "design a page", "make wireframes", "create mockups", "produce HTML design alternatives", "explore design directions", or invokes /design. Owns the wireframe-first → full HTML mockup pipeline (handed to @designer).
version: 1.0.0
---

# Design Workflow (Wireframes → HTML Mockups)

Apply when producing UI prototypes for human approval. Output is a standalone HTML file that opens by double-click in any browser — never production code.

## Step 1: Understand the brief (always first)

Before producing anything, confirm:
- What is the product? Who is it for?
- Does a requirements doc or design brief already exist? (`docs/requirements.md`, `docs/design-brief.md`)
- Client-specific preferences? (check `.claude/memory/clients/{client}.md` if exists)

## Step 2: Wireframes (always first deliverable)

Layout structure only — no color, no decorative elements.
- Gray boxes labeled `[HERO]`, `[NAV]`, `[FEATURE GRID]`, `[CTA]` etc.
- Typography hierarchy shown (big/medium/small) but no font styling
- Tailwind CDN, all colors `bg-gray-100/200/300`, `text-gray-400/500`
- Produce **2 layout alternatives** as separate files

**Output:** `docs/designs/wireframe-a.html`, `docs/designs/wireframe-b.html`

Stop and present wireframes to the user before proceeding to full designs.

## Step 3: Full HTML Designs (after wireframe direction approved)

Two genuinely different visual directions. Each must differ in at least 3 dimensions — hero approach, layout rhythm, color application, typography weight, or component density. Reference real design sources in code comments.

**Technical rules:**
1. No build step — opens directly in browser
2. `<script src="https://cdn.tailwindcss.com"></script>` from CDN
3. Google Fonts via `<link>` (DM Sans is the project default)
4. Mobile-first, responsive at 375px and 1280px
5. No JS frameworks — vanilla JS only for demo interactions
6. No lorem ipsum — use realistic believable content

**Output:** `docs/designs/design-a.html`, `docs/designs/design-b.html`

## Dual-Viewport Layout (web + mobile in one file)

Every wireframe and design HTML **must** render both desktop and mobile versions side by side in a single page. The user opens one file and sees both viewports at a glance.

### Structure template

```html
<!DOCTYPE html>
<html lang="en" style="min-width: 1800px;">
<head>
  <meta charset="UTF-8">
  <title>Wireframe A — [Direction Name]</title>
  <script src="https://cdn.tailwindcss.com"></script>
</head>
<body class="bg-gray-50 p-6">
  <h1 class="text-center text-xl font-bold mb-6">Wireframe A — [Direction Name]</h1>

  <div class="flex gap-8 justify-center items-start">
    <!-- Desktop viewport -->
    <div>
      <p class="text-sm text-gray-500 mb-2 text-center">Desktop (1280px)</p>
      <div class="border border-gray-300 rounded-lg overflow-hidden bg-white" style="width:1280px;">
        <!-- Desktop content rendered at 1280px width -->
      </div>
    </div>

    <!-- Mobile viewport -->
    <div>
      <p class="text-sm text-gray-500 mb-2 text-center">Mobile (375px)</p>
      <div class="border border-gray-300 rounded-lg overflow-hidden bg-white" style="width:375px;">
        <!-- Mobile content rendered at 375px width -->
      </div>
    </div>
  </div>
</body>
</html>
```

### Implementation approach

**Preferred — separate explicit sections:** Write desktop and mobile layouts as two distinct `<div>` containers, each constrained to its target width (1280px / 375px). Gives full control over layout differences (bottom nav on mobile, sidebar on desktop, reordered sections, etc.).

**Alternative — shared source via iframes:** If the design is purely responsive with no structural differences, write one responsive HTML blob and embed it in two `<iframe srcdoc="...">` elements at different widths. Use only when mobile is a direct reflow of desktop.

The outer page is a review artifact, not production code. Horizontal scroll on smaller screens is expected.

## Completion Format

```
### Wireframes done
- wireframe-a.html — [Direction A: layout description]
- wireframe-b.html — [Direction B: layout description]

Which structure should I proceed with?
```

or (for full designs):

```
### Designs done
- design-a.html — [visual direction description]
- design-b.html — [visual direction description]
```

## Delegation

This workflow is owned by **@designer**. Implementation should be delegated to that agent.

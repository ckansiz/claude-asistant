---
name: Design Process — Research-First, Wireframes Before Mockups
description: Design must start with real research (Dribbble/Behance/trends), then wireframes, then full HTML. Never jump straight to colored mockups.
type: feedback
---

**Rule:** The design phase is always 3 steps: Research → Wireframes → Full Designs. Never collapse into one step.

**Why:** Previous mockups for Blocero landed in "AI-generic" territory — same centered hero, same feature grid cards, same gradient buttons. User explicitly rejected this pattern and asked for real design research from Dribbble, Behance, Awwwards before producing anything visual.

**How to apply:**

1. **Dreamy Smurf — Design Research mode** (before any visual work):
   - Search Dribbble, Behance, Awwwards, Lapa.ninja, Mobbin
   - Document real-world inspiration with specific references
   - Identify layout trends for the specific product type
   - Explicitly list what to AVOID (anti-patterns, AI-generic clichés)
   - Output: `docs/designs/research-brief.md` or inline brief

2. **CHECKPOINT 2a** — user reviews brief, confirms visual direction

3. **Vanity Smurf — Wireframes** (gray boxes only, NO color, NO styling):
   - Shows layout structure only: section order, nav placement, grid rhythm
   - Produces wireframe-a.html + wireframe-b.html
   - Mobile + desktop views in same file

4. **CHECKPOINT 2b** — user selects wireframe structure

5. **Vanity Smurf — Full HTML designs** (based on brief + approved wireframe):
   - Each design must cite specific inspiration references in code comments
   - Alternatives differ in hero type, layout rhythm, color application, density
   - shadcn/ui visual language (token system, radius, component feel)

6. **CHECKPOINT 2c** — user selects final design

**Never:** Jump from requirements directly to colored mockups.
**Never:** Produce two "alternatives" that only differ in accent color.
**Always:** Every design decision should be explainable by pointing to a real reference.

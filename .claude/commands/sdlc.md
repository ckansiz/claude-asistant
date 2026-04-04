# SDLC Pipeline — Full Reference

## Phase 1: Discovery

**Goal:** Clarify requirements and choose the tech stack.

**Actors:** Poet Smurf (spec + PRD) + Dreamy Smurf (tech research)

**Workflow:**
1. Poet Smurf produces `docs/requirements.md` and `docs/tech-spec.md`
   - User story mapping, acceptance criteria, out-of-scope clarification
2. Dreamy Smurf researches open technical questions from the spec
   - Library selection, architecture patterns, integration approach
   - Produces research findings as markdown
3. User reviews and approves spec + stack choice

**CHECKPOINT 1:** User says "okay, I approve the spec and stack." → Wait for explicit response before Phase 2.

---

## Phase 2: Design (3 steps — NEVER collapse into one)

**Goal:** Create approved visual designs before any frontend code starts.

### Step 2a: Design Research

**Actor:** Dreamy Smurf (UI/UX Design Research mode)

**Sources:**
- Dribbble.com (filter by product type, interaction pattern, visual style)
- Behance.net (real case studies, not stock templates)
- Awwwards.com (award-winning sites, design trends)
- Lapa.ninja (component-focused design reference)
- Mobbin.com (mobile app UI patterns)
- Live competitor websites (if applicable)

**Output:** `docs/designs/research-brief.md`
- Key visual trends identified (2026 aesthetic: minimalism, depth, custom illustrations, ...)
- 3-5 inspiration references with screenshots + what works well
- Layout direction options (e.g. "hero + cards" vs "split hero" vs "scrollytelling")
- What to avoid (AI-generic clichés, oversaturated colors, bad typography)
- Recommended color palette direction (if applicable)
- Font pairing ideas

**CHECKPOINT 2a:** User confirms visual direction based on brief. → "Yes, I like direction A" or "Combine A + B". → Wait before step 2b.

---

### Step 2b: Wireframes (Gray Boxes Only)

**Actor:** Vanity Smurf

**Output:** `wireframe-a.html` + `wireframe-b.html`

**What wireframes are:**
- Gray boxes + text labels for structure
- No color, no visual design, no assets
- Pure layout and content organization
- Two alternatives showing different content hierarchy or flow

**What wireframes are NOT:**
- Visual mockups with colors and typography
- Full HTML with images
- Code-ready prototypes

**CHECKPOINT 2b:** User selects wireframe structure. → "I prefer wireframe A" → Wait before step 2c.

---

### Step 2c: Full Design Alternatives

**Actor:** Vanity Smurf (based on approved wireframe + Design Brief from 2a)

**Output:** `design-a.html` + `design-b.html`

**What full designs include:**
- HTML + Tailwind CSS (no framework, standalone)
- Visual design applied to approved wireframe
- 2 distinct visual directions (e.g. A = bold + saturated, B = minimal + serif)
- Real content placeholders, actual color tokens, typography applied
- Responsive thinking (mobile breakpoints tested)

**CHECKPOINT 2c:** User selects final design A or B.
→ "I like design A, but with B's color palette"
→ Vanity refines into approved-final design
→ Wait before Phase 3.

---

## Phase 3: Development

**Sequence:**
1. **Hefty Smurf** scaffolds project structure, CLAUDE.md, dependencies
2. **Painter Smurf + Handy Smurf** work in parallel:
   - Painter: implement approved design in real framework (Astro/Next.js) + components
   - Handy: implement API, database, backend services
3. **Clumsy Smurf** (if mobile): React Native / Expo implementation
4. **Brainy Smurf** code review (MANDATORY after Painter and/or Handy complete)

**CHECKPOINT 3:** Brainy reports findings.
→ If blockers: fix with relevant smurf + re-review
→ If clean: user accepts delivery
→ Release or deploy

---

## Mandatory Chains

These workflows are NOT optional — each phase gates the next:

1. **NEW DESIGN PHASE:** Dreamy (research) → CHECKPOINT → Vanity (wireframes) → CHECKPOINT → Vanity (full designs) → CHECKPOINT
2. **ANY UI/CSS WORK:** Painter → Brainy (review MANDATORY)
3. **Backend + Frontend together:** Handy + Painter (parallel) → Brainy
4. **Mobile work:** Dreamy (stack decision) → CHECKPOINT → Clumsy → Brainy
5. **E2E/UAT/pre-release test:** Brainy dispatched with `model: opus` (Super Mode)

**CHECKPOINT RULE:** At every checkpoint, stop and present findings. Wait for explicit user approval before the next phase. This is not a formality — it prevents weeks of rework.

---

## Checkpoint Presentation Template

**When presenting to user at a checkpoint:**

```
## CHECKPOINT {N}: {Phase} Complete

**What was produced:**
- [list deliverables with file paths]
- [summary of decisions made]

**What the user needs to decide:**
1. Option A → [consequence]
2. Option B → [consequence]
3. Option C → [consequence]

**Next step after decision:**
[What smurf does next, and when]

Ask explicitly: "Which direction should we take?"
```

Never assume the user wants "Option A." Present the trade-offs clearly and wait for a response.

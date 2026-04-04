# Vanity Smurf - Wireframe & Design Templates

Use these HTML templates when creating wireframes and full design mockups.

## Wireframe HTML Template

```html
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Wireframe A — [Layout Direction Name]</title>
  <script src="https://cdn.tailwindcss.com"></script>
</head>
<body class="bg-white font-sans text-gray-500 text-sm">

  <!-- WIREFRAME LABEL -->
  <div class="fixed top-2 right-2 bg-gray-900 text-white text-xs px-3 py-1 rounded z-50">
    Wireframe A — [Direction Name]
  </div>

  <!-- NAV -->
  <div class="border-b border-gray-200 bg-gray-50 px-8 h-14 flex items-center justify-between">
    <div class="bg-gray-300 h-6 w-24 rounded">[LOGO]</div>
    <div class="flex gap-4">
      <div class="bg-gray-200 h-4 w-16 rounded">[NAV LINK]</div>
      <div class="bg-gray-200 h-4 w-16 rounded">[NAV LINK]</div>
      <div class="bg-gray-300 h-8 w-24 rounded">[PRIMARY CTA]</div>
    </div>
  </div>

  <!-- HERO -->
  <div class="bg-gray-100 px-8 py-24 text-center">
    <div class="text-xs text-gray-400 mb-6 uppercase tracking-widest">[HERO — editorial headline layout]</div>
    <div class="bg-gray-300 h-12 w-2/3 mx-auto rounded mb-4">[H1 HEADLINE — large]</div>
    <div class="bg-gray-200 h-6 w-1/2 mx-auto rounded mb-8">[SUBHEADLINE — medium]</div>
    <div class="flex gap-3 justify-center">
      <div class="bg-gray-400 h-10 w-36 rounded">[PRIMARY CTA BUTTON]</div>
      <div class="bg-gray-200 h-10 w-32 rounded border border-gray-300">[SECONDARY CTA]</div>
    </div>
  </div>

  <!-- FEATURE SECTION -->
  <div class="bg-white px-8 py-16">
    <div class="text-xs text-gray-400 mb-12 uppercase tracking-widest text-center">[FEATURES]</div>
    <div class="grid grid-cols-3 gap-8">
      <div class="text-center">
        <div class="bg-gray-200 h-12 w-12 mx-auto mb-4 rounded">[ICON]</div>
        <div class="bg-gray-300 h-5 w-full rounded mb-2">[FEATURE TITLE]</div>
        <div class="bg-gray-100 h-4 w-full rounded">[FEATURE DESC]</div>
      </div>
      <!-- Repeat grid item x3 -->
    </div>
  </div>

  <!-- FOOTER -->
  <div class="bg-gray-50 border-t border-gray-200 px-8 py-12">
    <div class="bg-gray-300 h-6 w-24 mb-8 rounded">[LOGO]</div>
    <div class="grid grid-cols-3 gap-8">
      <div><div class="bg-gray-300 h-4 w-20 mb-3 rounded">[FOOTER COL 1]</div></div>
      <div><div class="bg-gray-300 h-4 w-20 mb-3 rounded">[FOOTER COL 2]</div></div>
      <div><div class="bg-gray-300 h-4 w-20 mb-3 rounded">[FOOTER COL 3]</div></div>
    </div>
  </div>

  <!-- MOBILE VIEW SIMULATION (375px) -->
  <hr class="my-12">
  <div class="mx-auto bg-gray-50 p-4" style="width: 375px;">
    <p class="text-xs text-gray-400 mb-4">Mobile view simulation (375px):</p>
    <div class="bg-white rounded border border-gray-200">
      <!-- Repeat all sections above but in mobile stack layout -->
      <div class="bg-gray-50 px-4 h-12 flex items-center justify-between border-b">
        <div class="bg-gray-300 h-5 w-16 rounded"></div>
        <div class="bg-gray-300 h-4 w-4 rounded"></div>
      </div>
      <!-- Continue with mobile-stacked versions of each section -->
    </div>
  </div>

</body>
</html>
```

### Wireframe Technical Rules

1. Standalone HTML, no build step
2. Tailwind via CDN only: `<script src="https://cdn.tailwindcss.com"></script>`
3. All colors: `bg-gray-100`, `bg-gray-200`, `bg-gray-300`, `text-gray-400/500` (grayscale only)
4. Label every block clearly in brackets: `[HERO]`, `[NAV]`, `[STATS ROW]`, `[FEATURE SECTION]`
5. Include mobile view simulation at bottom (375px width)
6. No decorative elements, shadows, gradients, or images
7. Focus on: grid/flex, spacing rhythm, navigation structure, typography hierarchy

---

## Design Reference Comment Block

Add this at the top of every full design HTML file:

```html
<!--
  DESIGN [A/B/C] — [Direction Name, e.g. "Editorial Dark" / "Bento Minimal"]

  Design Research references used:
  - [Source 1, e.g. Dribbble shot name]: borrowed [specific element]
  - [Source 2, e.g. Awwwards site]: borrowed [specific element]

  Layout decisions:
  - Hero: [describe the deliberate choice and why]
  - Feature section: [describe]
  - CTA zone: [describe]

  What makes this non-generic:
  - [Specific differentiator 1]
  - [Specific differentiator 2]
-->
```

### Full Design Technical Rules

1. **No build step** — double-click to open in browser
2. **Tailwind via CDN**: `<script src="https://cdn.tailwindcss.com"></script>`
3. **Google Fonts**: `<link href="https://fonts.googleapis.com/css2?family=DM+Sans:wght@400;500;700" rel="stylesheet">`
4. **Mobile-first, responsive** — works at 375px and 1280px
5. **Realistic content** — no "Lorem ipsum", use real product copy
6. **shadcn/ui visual language** — simulate with CSS custom properties:
   - `--radius: 0.5rem` (default radius)
   - `--border: 1px solid hsl(from #e5e7eb / alpha / 1)` (border color)
   - `--muted: hsl(from #f3f4f6 / alpha / 1)` (muted bg)
7. **Reference Dreamy's brief** — every design choice should cite an inspiration

### What Makes a Good Design Alternative

Each must differ in **at least 3 of these dimensions**:

1. **Hero approach** — editorial text-only vs product screenshot vs abstract graphic
2. **Layout rhythm** — uniform grid vs asymmetric vs bento grid vs magazine columns
3. **Color application** — brand-dominant vs white-dominant vs dark mode accent sections
4. **Typography weight** — heavy/bold statements vs light/airy minimalism
5. **Component density** — sparse and breathable vs rich and data-forward
6. **Feature presentation** — icon cards vs scrolling demo vs side-by-side comparison

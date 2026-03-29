---
name: UI Stack — shadcn/ui + Tailwind Default
description: All web UI must use shadcn/ui + Tailwind CSS. No custom CSS frameworks. Applies to every surface including admin panels and dashboards.
type: feedback
---

**Rule:** All web UI work (marketing sites, admin panels, dashboards, any Next.js surface) must use **shadcn/ui + Tailwind CSS** as the component foundation. This applies by default unless the user explicitly states otherwise.

**Why:** User explicitly confirmed this during Blocero project design phase when the admin panel mockup used custom CSS instead of shadcn. Corrected immediately.

**How to apply:**
- Painter Smurf: always scaffold with shadcn/ui + Tailwind. Never use plain CSS, Bootstrap, MUI, or Chakra unless explicitly requested.
- Vanity Smurf: HTML mockups should simulate shadcn/ui visual language (zinc token scale, --radius: 0.5rem, Button/Card/Badge/Table components)
- Component set: Button (default, outline, ghost, destructive, secondary), Card (CardHeader, CardContent, CardFooter), Badge, Table, Tabs, Avatar, Input, Select, Dialog, Sheet, Separator
- Token colors: map `--primary` to navy `#1B2B5E`, `--destructive` to red `#E32B2B` in `tailwind.config.ts`
- Icons: Lucide React (already bundled with shadcn)
- Font: DM Sans (project-level, defined in layout)

**Mobile:** React Native Paper or NativeBase for mobile (Expo) — shadcn is web-only. Decision per project.

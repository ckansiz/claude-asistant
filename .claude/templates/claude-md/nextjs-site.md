# {PROJECT_NAME}

## Quick Reference
- **Type**: Client website (wesoco)
- **Stack**: Next.js 15, React 19, TypeScript, Tailwind CSS
- **Path**: ~/workspace/wesoco/works/{SLUG}/
- **Package Manager**: npm
- **Deploy Target**: {DEPLOY_TARGET}

## Project Structure
```
src/
├── app/           # App Router pages and layouts
├── components/    # Reusable UI components
├── lib/           # Utilities and helpers
└── styles/        # Global styles (if any)
public/            # Static assets
```

## Commands
- Dev: `npm run dev`
- Build: `npm run build`
- Lint: `npm run lint`
- Start: `npm start`

## Design System
- Primary Color: {PRIMARY_COLOR}
- Font: {FONT}
- Brand Guidelines: {NOTES}

## Conventions
- App Router (not Pages Router)
- Server Components by default, "use client" only when needed
- next/image for all images
- next/font for font loading

## Dependencies on Other Projects
- {e.g., "Uses centralized PostgreSQL from ~/workspace/docker/" if applicable}

## Known Issues / Gotchas
- {Add as discovered}

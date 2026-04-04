# /mobile — Mobile Development Mode

Stack decision: **React Native / Expo** (default). Flutter if the project already uses it.

Standards to apply for this session:
- **React Native / Expo**: Use Expo SDK, Expo Router for navigation, NativeWind for styling (Tailwind-like)
- **TypeScript strict mode** — read `.claude/context/typescript.md`
- **Commits** — read `.claude/context/commits.md`

Key principles:
- Navigation: Expo Router (file-based, like Next.js App Router)
- Styling: NativeWind (Tailwind class names on native components) — shadcn/ui is not applicable
- State: Zustand for global state, TanStack Query for server state
- API calls: match backend API contract — if .NET backend, use generated types from `api.generated.ts`
- Platform differences: handle iOS and Android edge cases (safe areas, back button, keyboard behavior)

Delegate implementation to **@builder**.

$ARGUMENTS

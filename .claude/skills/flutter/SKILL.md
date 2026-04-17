---
name: flutter
description: This skill should be used when the user asks to "build a Flutter app", "add a Riverpod provider", "use GoRouter", "configure Dio", or works on Flutter mobile projects (secondary mobile stack — only when the project already uses Flutter).
version: 1.0.0
---

# Flutter Standards (Secondary Mobile Option)

Flutter is the secondary mobile option — apply only when the project already uses Flutter. Default is React Native / Expo (`react-native` skill).

## Project Structure

```
lib/
├── main.dart
├── app/
│   ├── routes/              # GoRouter route definitions
│   └── theme/               # ThemeData, colors, typography
├── features/
│   └── {feature}/
│       ├── presentation/    # Screens + widgets
│       ├── domain/          # Models, repository interfaces
│       └── data/            # API calls, repository implementations
├── shared/
│   ├── widgets/             # Reusable UI components
│   ├── services/            # HTTP client, storage, etc.
│   └── utils/               # Helpers, extensions
└── l10n/                    # Localization
```

## State Management

- **Riverpod** (preferred) — compile-safe, testable
- Existing projects may use Bloc/Cubit or Provider — match what's there

## Navigation

- **GoRouter** — declarative, deep-link support
- Define routes in a central `routes.dart` file

## Networking

- **Dio** for HTTP — interceptors for auth tokens, logging
- Generate models from API spec when possible (`json_serializable` or `freezed`)

## Styling

- Use `ThemeData` for consistent styling — no hardcoded colors
- Match project design tokens: `--primary` navy `#1B2B5E`, DM Sans font
- Material 3 widgets as base

## Code Style

- Dart analysis: `flutter_lints` or `very_good_analysis`
- `const` constructors where possible
- Prefer `StatelessWidget` — use `StatefulWidget` only when local state is needed
- async/await (no raw Future chains)
- Named parameters for widget constructors with >2 parameters

## Testing

- `flutter_test` for widget tests
- `mockito` or `mocktail` for mocking
- `integration_test` package for E2E

## Build & Deploy

```bash
flutter run                          # Development
flutter build apk --release          # Android
flutter build ios --release          # iOS
```

## Companion Skills

- `commits` — commit conventions
- `api-contract` — load when project has .NET backend

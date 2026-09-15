# Workspace Guidelines & Rules

## 1. Testing Policy (CRITICAL - User Explicit Preference)
- **DO NOT run automated test cases or execute `flutter test`**.
- The user has explicitly requested to skip test cases during development and verification.
- **NEVER** launch background `flutter test` or run test suites unless explicitly commanded by the user.
- For verification, strictly use:
  - Static code analysis (`flutter analyze`) to guarantee 0 errors and 0 warnings.
  - Visual fidelity checks against Figma and user screenshots.

## 2. State Management Rules
- **STRICTLY ZERO `setState()`**: Do not use `setState()` anywhere in the application.
- Use BLoC / Cubit for application and screen-level state, or `ValueListenableBuilder` / `ValueNotifier` for local input controllers.
- Keep widgets reactive and decoupled.

## 3. Design System & Theme Architecture
- **Centralized Colors**: Never hardcode colors inline (e.g. `Color(0xFF...)`). All color tokens and gradients must reside in `AppColors` (`lib/core/theme/app_colors.dart`).
- **Typography & Icons**: Always use `GoogleFonts.plusJakartaSans` and SVGs from `assets/icons/` through `AppIcons`.
- **Pixel-Perfect Figma Fidelity**: Match Figma dimensions, weights, corner radii, borders, and paddings exactly.

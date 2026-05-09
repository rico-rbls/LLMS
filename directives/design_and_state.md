# Design and State Management (Flutter)

## Goal
Implement the core visual identity and global state management for the LibLog Flutter app. This includes building the dual-theme setup (Light Mode and the signature Dark Purple Mode) and configuring Riverpod with `shared_preferences` for session persistence.

## Inputs
- **BRANDING.md**: Design system specs (Colors, Typography, Dark Mode rules, Elevation rules).
- **OVERVIEW.md**: State management rules, explicitly defining what is and is not persisted across sessions.

## Tools & Scripts
- `execution/scaffold_theme.py` (To be implemented): A script to inject the completed `ThemeData` and `AppColors` classes into the codebase.
- `execution/scaffold_providers.py` (To be implemented): A script to generate the Riverpod providers wired to the `StorageService`.

## Step-by-Step Instructions

### Phase 1: ThemeData Implementation (Light & Dark Purple Mode)
1. **Define Brand Colors** (`lib/config/colors.dart`):
   - Map out the primary palette, specifically Lib Purple (`#652D90`).
   - Define the Light Mode semantic colors: Page background (`#f2f2fa`), Card surface (`#FFFFFF`).
   - Define the Dark Purple Mode semantic colors: Page background (`#110a1e`), Card surface (`#1a0e2e`).
2. **Construct Light Theme** (`lib/config/theme.dart`):
   - Build `ThemeData(brightness: Brightness.light)`.
   - Set `scaffoldBackgroundColor` to `#f2f2fa`.
   - Implement the **Flat Design** philosophy: ensure cards and primary surfaces have 0px elevation and no drop shadows (except for the bottom navigation and QR scan button).
3. **Construct Dark Purple Theme** (`lib/config/theme.dart`):
   - Build `ThemeData(brightness: Brightness.dark)`.
   - Set `scaffoldBackgroundColor` to the deep purple-black (`#110a1e`).
   - Set `cardColor` to the dark purple surface (`#1a0e2e`).
   - Implement the **Depth** philosophy: use subtle BoxShadows to separate the dark purple cards from the dark purple background, and apply translucent white overlays (`Colors.white.withOpacity(0.05/0.10)`) for interactive surfaces.
4. **Apply Typography**: Configure the `TextTheme` to use `GoogleFonts.inter()` (or equivalent system fonts), mapping the specific 30px–14px scale to standard Flutter text styles (e.g., `displayLarge`, `bodyMedium`).

### Phase 2: Riverpod & Session Persistence Setup
1. **Implement Storage Service** (`lib/services/storage_service.dart`):
   - Create a singleton wrapper around `shared_preferences`.
   - Use the `liblog-store` namespace for all keys to prevent collisions (e.g., `liblog-store:user`).
   - Create explicit read/write/clear methods for the **only** four persisted fields: `user` (full UserState), `onboardingStep` (int), `onboardingData` (JSON string), and `favorites` (List of resource IDs).
2. **Wire Startup Sequence** (`lib/main.dart`):
   - Call `WidgetsFlutterBinding.ensureInitialized()`.
   - `await StorageService.init()` to ensure SharedPreferences is loaded synchronously before the app runs.
   - Wrap `LibLogApp` in a `ProviderScope`.
3. **Configure Riverpod Providers** (`lib/providers/`):
   - Create `themeProvider` to manage and toggle between Light/Dark modes.
   - Create `authProvider`. **Crucial Security Rule:** The provider must always initialize `isAuthenticated = false` and `currentScreen = login` upon app startup, ignoring any previous session state.
   - Create the transient data providers (`resourcesProvider`, `borrowProvider`, etc.) to handle API data without local disk persistence.

## Outputs
- `lib/config/colors.dart` populated with the complete `#652D90` purple palette.
- `lib/config/theme.dart` exposing `AppTheme.light` and `AppTheme.dark`.
- `lib/services/storage_service.dart` functioning as the central persistence layer.
- A Riverpod `ProviderScope` fully initialized at the root of the app.

## Edge Cases & Error Handling
- **Dark Mode Contrast**: If text becomes unreadable in Dark Mode, verify that text colors are explicitly overriding defaults using the foreground semantic colors mapped to `TextTheme`.
- **Rehydration Leaks**: If the app opens to the Home screen instead of Login, check `authProvider` to ensure `isAuthenticated` is not accidentally being restored from `StorageService`.
- **Theme Toggling**: Ensure changes to `themeProvider` result in an immediate UI rebuild without requiring an app restart.

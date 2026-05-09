# Authentication and Onboarding (Flutter)

## Goal
Implement the client-side Authentication flow for the LibLog app. This includes the transient Riverpod `authProvider`, SHA-256 password hashing, the visual `login_screen.dart` with an animated gradient and pulsing logo, and the 5-step registration wizard (`onboarding_screen.dart`) with draft persistence.

## Inputs
- **FEATURES.md**: Specs for the Login Screen (animated header, demo button) and the 5-Step Onboarding flow.
- **OVERVIEW.md**: Architecture rules demanding that `isAuthenticated` and `currentScreen` remain strictly non-persistent (transient memory only).

## Tools & Scripts
- `execution/scaffold_auth.js` (To be implemented): Script to generate the Dart logic for the Riverpod auth state, SHA-256 utilities, and the UI layout for the login and onboarding screens.

## Step-by-Step Instructions

### Phase 1: Auth State & Security Logic
1. **Transient Auth Provider** (`lib/providers/auth_provider.dart`):
   - Implement `AuthNotifier` using Riverpod.
   - **Critical Rule**: Do *not* read `isAuthenticated` or `currentScreen` from `StorageService`. State must always initialize to `false` and `login` on a fresh app start.
   - The provider should hold the current `User` object only after a successful login.
2. **SHA-256 Hashing** (`lib/utils/auth.dart`):
   - Implement a utility function `hashPassword(String input)` using the `crypto` package.
   - Ensure passwords are hashed client-side before any verification or backend transmission.
3. **Auth Service** (`lib/services/auth_service.dart`):
   - Scaffold the `login(email, hashedPassword)` and `register(userData)` API calls via Dio.

### Phase 2: Login UI Implementation
1. **Build `login_screen.dart`**:
   - Create a clean, mobile-first layout (constrained by the 430px global wrapper).
   - **Gradient Header**: Implement a dynamic, animated gradient background at the top of the screen using standard Flutter tools or `flutter_animate`.
   - **Pulsing Logo**: Use the `flutter_animate` package to apply a slow, infinite `.scale()` and `.fade()` pulse effect to the central LibLog logo/icon.
   - **Form Fields**: Add Email and Password inputs using `flutter_form_builder`.
   - **Demo Button**: Include a "Demo Mode" button to bypass authentication for UI testing.

### Phase 3: 5-Step Onboarding Wizard
1. **Build `onboarding_screen.dart`**:
   - Implement a horizontal `PageView` (with disabled swipe) or a step-based state machine to track progress.
   - **Step 1: Account**: Email and Password creation.
   - **Step 2: University Details**: University ID Number input.
   - **Step 3: Persona**: Role selection (Student, Faculty, Visitor).
   - **Step 4: Academic Details**: Program and Department input (conditionally visible based on Step 3).
   - **Step 5: Review & Finish**: Summary of inputted data and final "Create Account" submission.
2. **Draft Persistence**:
   - As the user completes each step, save the accumulator JSON and current step index to `StorageService` (`saveOnboardingData`, `saveOnboardingStep`).
   - If the app is closed mid-registration, rehydrate the wizard from `StorageService` upon reopening.
   - Clear these keys upon successful registration completion.

## Outputs
- `lib/providers/auth_provider.dart` with transient session state.
- `lib/utils/auth.dart` containing `hashPassword`.
- `lib/screens/login_screen.dart` with animations.
- `lib/screens/onboarding_screen.dart` with the 5-step wizard.

## Edge Cases & Error Handling
- **Hot Reload Behavior**: Because `authProvider` is transient, hot restarting the app will log the user out. This is expected and strictly enforces the security architecture.
- **Validation Errors**: Use `form_builder_validators` to ensure passwords meet complexity requirements before applying SHA-256.
- **Orphaned Draft Data**: If a user abandons registration and logs in with an existing account instead, ensure `clearOnboarding()` is called upon successful login to prevent stale data.

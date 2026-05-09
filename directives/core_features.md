# Core Features & Navigation (Flutter)

## Goal
Implement the main application layout and the first two core screens for the LibLog app: the Riverpod-driven `BottomNavigationBar` (5 tabs), the Dashboard (`home_screen.dart`), and the Catalog Browser (`search_screen.dart`).

## Inputs
- **FEATURES.md**: Specifically §2.3 (Home), §2.4 (Search), and §9 (Navigation & Layout).
- **OVERVIEW.md**: Navigation architecture relying on Riverpod state rather than standard push/pop routing for the main tabs.

## Tools & Scripts
- `execution/scaffold_core_features.js` (To be implemented): Script to generate the root navigation layout, the home screen, and the search screen with all required packages and state wiring.

## Step-by-Step Instructions

### Phase 1: Root Navigation Architecture
1. **Create `lib/screens/main_layout.dart`**:
   - Serve as the primary wrapper after successful login.
   - Use a Riverpod `StateProvider<int>` to track the current selected tab index (0 to 4).
   - Implement `Scaffold` where `body` is an `IndexedStack` or `PageView` to preserve the state of the 5 tabs: Home, Search, Scan, Borrowed, Profile.
2. **Bottom Navigation Bar**:
   - Use `BottomNavigationBar` with `BottomNavigationBarType.fixed` to ensure all 5 icons are visible.
   - **Tab Definitions**:
     - 0: Home (`Icons.home`)
     - 1: Search (`Icons.search`)
     - 2: Scan (`Icons.qr_code_scanner`) — Implement this as an elevated/floating action button style overlapping the nav bar, with a purple circle background and drop shadow.
     - 3: Borrowed (`Icons.book`)
     - 4: Profile (`Icons.person`)
   - Include a bounce animation (using `flutter_animate`) when a tab becomes active.

### Phase 2: Search Screen (Catalog Browser)
1. **Create `lib/screens/search_screen.dart`**:
   - **State**: Create a `StateProvider<String>` for the search query and another for the selected category.
   - **Debounce Logic**: Implement a `Timer` in the `onChange` callback of the `TextField` to enforce a **300ms debounce** before updating the search state/triggering an API call.
   - **UI Elements**:
     - Search Input with a clear (X) button.
     - Popular Tags (Algorithms, Deep Learning, Database, etc.) wrapped in a `Wrap` widget.
     - Category filter pills (ActionChips) with a scale animation on tap.
2. **Shimmer Loading**:
   - Use the `shimmer` package to create a `SkeletonCard` widget.
   - When the search query updates (and is actively fetching), display 4 `SkeletonCard` widgets with a staggered fade-in effect to replace the standard loading spinner.

### Phase 3: Home Screen (Dashboard)
1. **Create `lib/screens/home_screen.dart`**:
   - Implement a scrollable layout wrapped in a `RefreshIndicator` for pull-to-refresh functionality.
   - **User Greeting**: Implement the time-of-day greeting using `RichText`. The greeting text must be standard weight (e.g., "Good morning, ") and the user's first name must be bold ("**Juan!**").
   - **Top Bar**: Streak pill counter (orange), Notification bell, and Settings gear.
   - **Announcements Carousel**: Use a `PageView` with an auto-advancing `Timer` (5s interval) for announcements. Include dot navigation indicators.
   - **Content Sections**: Stub out the "Today's Highlight", "Current Borrow" (with gradient left border), and "Recommended for You" horizontal scroll lists.

## Outputs
- `lib/screens/main_layout.dart`
- `lib/screens/home_screen.dart`
- `lib/screens/search_screen.dart`
- Updates to `pubspec.yaml` for `shimmer` (if not already present).

## Edge Cases & Error Handling
- **Debounce memory leaks**: Ensure the `Timer` used for debouncing in `search_screen.dart` is properly canceled in the `dispose()` method.
- **Carousel memory leaks**: Ensure the 5s auto-rotating timer in the Home screen is canceled on dispose.
- **BottomNav overflow**: The central QR Scan button must be properly constrained so it does not overflow or cause layout exceptions on smaller devices. Use `Stack` or `FloatingActionButtonLocation.centerDocked` appropriately.

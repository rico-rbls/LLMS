# User Interactions & Remaining Core Screens (Flutter)

## Goal
Implement the final three core tabs of the bottom navigation shell: the QR Scanner (`qr_scan_screen.dart`), the active loans/borrowed books view (`borrowed_screen.dart`), and the user profile dashboard (`profile_screen.dart`). These screens rely heavily on micro-interactions, animations, and specialized UI components.

## Inputs
- **FEATURES.md**: Specifically §2.8 (QR Scanner), §2.6 (My Loans), and §2.7 (Profile).
- **OVERVIEW.md**: State management and integration points for user data and reading statistics.

## Tools & Scripts
- `execution/scaffold_user_interactions.js` (To be implemented): Script to generate the Dart logic for these three screens, incorporating animations, chart dependencies, and Riverpod state integration.

## Step-by-Step Instructions

### Phase 1: QR Scan Simulator (`qr_scan_screen.dart`)
1. **Styling**: Implement a dedicated dark theme for this screen (Background: `#0d0d1a`).
2. **Viewfinder UI**: Create a 256x256 boxed area with corner brackets and an animated, looping scan line (using `flutter_animate` to move a linear gradient up and down).
3. **5-Second Simulation Logic**:
   - Instead of using the real camera, implement a sequenced `Timer`-based simulation upon screen entry or "Start Scan" tap.
   - **0s - 2s**: "Waiting for QR code..."
   - **2s - 5s**: "Scanning..." (Accelerate scan line animation).
   - **5s**: Success trigger. Stop animation and display a bottom sheet modal.
4. **Success Modal**: Show a spring-animated green checkmark, a success message ("Attendance Logged" or "Book Checkout Successful"), timestamp, and "Done" button.

### Phase 2: Borrowed Books (`borrowed_screen.dart`)
1. **Tabs & Layout**: Implement a `DefaultTabController` with two tabs: "Active" and "History".
2. **Fines Summary Card**:
   - Conditionally render a red-themed alert card if overdue items exist.
   - Include the `AlertTriangle` icon, total fines calculated at **₱5.00/day** per overdue item, and overdue item count.
3. **Color-Coded Book Cards**:
   - Add a thick left border to book cards.
   - Use Red gradient for overdue items, Amber for items due in 1-3 days, and Purple for standard active loans.
4. **Return Action & Confetti**:
   - Implement a "Return Book" button.
   - Upon tap, trigger a 2-second success overlay: show a centered green checkmark and fire a `ConfettiWidget` blast.
   - After the 2-second delay, update the Riverpod state to move the book to "History".

### Phase 3: Profile Dashboard (`profile_screen.dart`)
1. **Header & Stats**: Build the purple gradient header with the user's avatar, name, and role. Below it, place a 3-column grid for basic stats (Borrowed, Visits, Streak).
2. **Circular Reading Goal**:
   - Implement a `CustomPainter` or use a package to draw a circular progress ring representing the user's annual reading goal (e.g., 5/24 books read).
   - Add a "Change" button that opens a bottom sheet to select from predefined goals (12, 24, 36, 48).
3. **Animated Bar Chart**:
   - Utilize the `fl_chart` package to build a 7-month reading history bar chart.
   - **Animation Requirement**: Implement staggered height growth when the chart becomes visible (0.4s duration per bar, staggered by 0.05s).
4. **Additional Cards**: Implement the "Attendance History" and "Member Since" informational cards at the bottom.

## Outputs
- `lib/screens/qr_scan_screen.dart`
- `lib/screens/borrowed_screen.dart`
- `lib/screens/profile_screen.dart`

## Edge Cases & Error Handling
- **Animation Cleanup**: The 5-second QR simulation uses `Timer`s. Ensure these are canceled in the `dispose()` method if the user switches tabs before the scan completes.
- **Chart Rendering**: Ensure `fl_chart` handles empty or zero-value data gracefully without throwing layout exceptions.
- **State Segregation**: Returning a book should only optimistically update the local borrow state (moving it from active to history) and avoid full API refetches unless necessary.

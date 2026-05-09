# Deep Content & Interactions (Flutter)

## Goal
Implement the secondary content screens that users drill down into from the main navigation shell. Specifically, this covers the `resource_detail_screen.dart` (catalog items), the 5-star review mechanism, and the user's `notifications_screen.dart`.

## Inputs
- **FEATURES.md**: Specifically §2.5 (Book Detail / Reviews) and §2.10 (Notifications).
- **OVERVIEW.md**: Context on Riverpod providers and shared state.

## Tools & Scripts
- `execution/scaffold_deep_content.js` (To be implemented): Script to generate the Dart logic for the resource detail screen, the review modal, and the notification center.

## Step-by-Step Instructions

### Phase 1: Resource Detail Screen (`resource_detail_screen.dart`)
1. **Header & Layout**:
   - Implement a sliver layout or a scrollable list with a static purple gradient header containing decorative circle accents.
   - The book cover should overlap the header negatively (e.g., `-mt-12` or `-48px` offset).
   - Include a "Back" button and a "Share" button. Tapping share should trigger a toast notification reading "Copied to clipboard!".
2. **Metadata & Status**:
   - Display the Title, Author, Shelf Location (`MapPin` icon), and a dynamic Availability badge.
   - **Favorite Toggle**: Implement a heart icon button with a scale animation and color change (grey to red/purple) when toggled.
3. **Dynamic Action Button**:
   - Evaluate the resource's `availableCopies` state.
   - If available: Render a solid purple **"Borrow"** button.
   - If unavailable: Render an outlined or alternate-colored **"Reserve"** button.

### Phase 2: Ratings & Reviews Section
1. **Summary UI**:
   - Below the description, create a summary card showing the average rating, total review count, and a distribution bar chart representing 5★ down to 1★ counts.
2. **Inline Form / Modal**:
   - Implement a "Write a Review" interaction.
   - Use `flutter_rating_bar` for the interactive 1–5 star selector.
   - Include a text area for the comment (enforce a 200-character maximum).
   - Provide "Submit" and "Cancel" actions.
3. **Review List**:
   - Display a list of existing reviews showing the user's avatar initials, name, star rating, date, and comment. Include a delete icon for the current user's own reviews.

### Phase 3: Notifications Center (`notifications_screen.dart`)
1. **Header & Filters**:
   - Add a "Mark all read" text button in the top right.
   - Implement filter tabs: `All`, `Unread` (with dynamic count badge), and `Mentions` (for reservations).
2. **Grouped List**:
   - Group the notification cards by timeframes: "Today", "Yesterday", "This Week", and "Earlier".
3. **Notification Cards**:
   - Include a color-coded left accent border and icon based on the notification type:
     - `orange` = due_date reminder
     - `purple` = reservation updates
     - `blue` = general announcements
   - Include an unread dot indicator for new notifications.
4. **Swipe-to-Dismiss**:
   - Wrap each card in a `Dismissible` widget.
   - Configure a drag threshold (e.g., swipe > 100px to dismiss, otherwise spring back).
   - On dismiss, update the Riverpod provider state to remove or mark the notification as deleted.

## Outputs
- `lib/screens/resource_detail_screen.dart`
- `lib/screens/notifications_screen.dart`
- Updates to models and providers required to support reviews and notifications.

## Edge Cases & Error Handling
- **Review Duplication**: Ensure the UI blocks or changes the "Write Review" button to "Edit Review" if the user has already submitted a rating.
- **Hero Transitions**: Consider implementing `Hero` tags for the book cover image if navigating from the Search or Home screens to provide a seamless visual transition.
- **Dismissible State**: When a notification is swiped away, ensure the local provider state is updated immediately before making any simulated/actual API calls to avoid UI stutter.

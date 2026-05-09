# SOP: Search & Resource Detail Implementation

## 1. Goal
Implement pixel-perfect Search and Resource Detail screens based on prototype screenshots, adhering to the updated "Soft Elevation" design pattern while strictly excluding mascot assets.

## 2. Visual Standards
- **Typography:** Always use `GoogleFonts.inter()`.
- **Shadow System:** Use a high-blur, low-opacity shadow for all cards to create a "floating" effect:
  ```dart
  boxShadow: [
    BoxShadow(
      color: Colors.black.withOpacity(0.05),
      blurRadius: 20,
      offset: const Offset(0, 4),
    ),
  ]
  ```
- **Constraint:** DO NOT include the Kuwago mascot or any mascot-related assets/logic.

## 3. Search Screen Implementation (`search_screen.dart`)
- **Layout Structure:**
  - Sticky header with a `Column` containing:
    - Screen title ("Search Catalog").
    - `TextField` with `BorderRadius.circular(12)`, prefix search icon, and clear button.
    - Horizontal scrollable `Row` of category pills (All, Books, Research, Magazines).
  - Main body: `ListView` of result cards.
- **Logic:**
  - **Debounce:** Implement a 300ms `Timer` debounce on `onChanged` to prevent excessive state rebuilds while typing.
  - **Filtering:** Use Riverpod to filter the `resourcesProvider` by both the search query and the selected category pill.
  - **Empty State:** Use a centered `Column` with a descriptive icon and text (no mascot).

## 4. Search Result Card (`widgets/search_result_card.dart`)
- **Visuals:**
  - White card background with `boxShadow` (as defined above).
  - Horizontal layout: Book cover on the left (16px radius), metadata on the right.
  - Metadata includes: Title (Bold), Author (Muted), Category Badge (Purple Tint), and a Status Badge (Green/Red).

## 5. Resource Detail Screen Implementation (`resource_detail_screen.dart`)
- **Layout Structure:**
  - `Scaffold` containing a `Stack`.
  - Background layer: `CustomScrollView` with:
    - `SliverAppBar`:
      - `expandedHeight: 300`.
      - `flexibleSpace`: `FlexibleSpaceBar` with the book cover image.
      - `pinned: true` to ensure the title/back button stays visible.
    - `SliverList`:
      - Metadata grid (ISBN, Publication Date, Subject, shelf location).
      - "About this book" description.
      - Tags/Pills section.
      - Reviews section (using `ReviewsWidget`).
  - Foreground layer: `Align(alignment: Alignment.bottomCenter)` containing the **Sticky Bottom Action Bar**.
- **Action Bar Logic:**
  - Dynamic button text: 
    - If `availableCopies > 0` → "Borrow Book".
    - If `availableCopies == 0` → "Reserve Book".
  - Secondary "Share" button.

## 6. Verification Checklist
- [ ] Search results trigger 300ms after typing stops.
- [ ] Category pills filter the list correctly.
- [ ] SliverAppBar collapses cover image behind the title on scroll.
- [ ] Bottom action bar remains sticky and visible above the scroll content.
- [ ] Worklog updated with Task ID `UI-CONTENT-01`.
- [ ] No mascot assets are used in any layout.

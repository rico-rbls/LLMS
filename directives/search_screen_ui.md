# SOP: Search Screen UI Implementation

This document details the visual hierarchy, widget mapping, and state management logic for the Search Screen (`search_screen.dart`), based on the provided design references and application guidelines.

## 1. Search Header & Input

The header section provides the main title, the search input field, and a list of popular search tags.

### Widget Mapping:
- **Root Layout**: A `SingleChildScrollView` or a `CustomScrollView` with slivers to allow the entire page to scroll, including the header.
- **Title**: `Text` widget displaying "Search Catalog" (large font, e.g., `fontSize: 24, fontWeight: FontWeight.w700`).
- **Search Bar**:
  - A `TextField` wrapped in a `Container` or using `InputDecoration`.
  - **Styling**: White background, rounded corners (`BorderRadius.circular(16)`), subtle light gray border.
  - **Prefix Icon**: A search/magnifying glass icon (`Icons.search`, colored gray).
  - **Placeholder**: "Search books, research, magazines..." (`color: AppColors.mutedForeground`).
- **Popular Tags Section**:
  - **Section Title**: A `Row` containing a trending icon (`Icons.trending_up`) and the text "POPULAR" (small, uppercase, gray, bold letter-spacing).
  - **Tags**: A `Wrap` widget containing multiple `Container` pills.
  - **Pill Styling**: Light purple background (`AppColors.purple50`), rounded corners (`BorderRadius.circular(9999)`), and purple text (`AppColors.libPurple`).

## 2. Horizontal Category Pills

Below the popular tags, a horizontally scrollable list (or a constrained `Row` if it fits) of category filters allows users to narrow down their search.

### Widget Mapping:
- **Root**: `SingleChildScrollView` with `scrollDirection: Axis.horizontal` or a `SizedBox` with a horizontal `ListView`.
- **Pill Item**: A `GestureDetector` wrapping a `Container`.
- **Selected State ("All")**: 
  - Background: Solid purple (`AppColors.libPurple`).
  - Content: A `Row` with an icon (e.g., `Icons.search`) and text ("All") colored white.
- **Unselected State ("Books", "Research", "Magazines")**:
  - Background: Light gray/white.
  - Content: A `Row` with an icon (`Icons.menu_book`, `Icons.article`, etc.) and text colored dark gray.

## 3. Search Results & Recently Viewed

The results area is divided into a "Recently Viewed" horizontal carousel and a vertical list of search results.

### Widget Mapping:
- **Recently Viewed Section**:
  - **Title Row**: Clock icon (`Icons.access_time`) and "Recently Viewed" text.
  - **Horizontal List**: `SizedBox` with a fixed height containing a `ListView.builder` (`scrollDirection: Axis.horizontal`).
  - **Card Item**: A vertical `Column` containing:
    1. A large book cover image inside a rounded `Container` (with a soft shadow).
    2. Title text (bold, max 2 lines, centered).
    3. Author/Publisher text (small, gray, centered).
- **Search Results List**:
  - **Vertical List**: `ListView.builder` (with `shrinkWrap: true, physics: NeverScrollableScrollPhysics()` if inside a master scroll view).
  - **Result Card**: A `Container` with a white background, rounded corners (`BorderRadius.circular(24)`), and a soft elevation shadow (`BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20)`).
  - **Card Layout**: A `Row` containing:
    - **Left**: Book cover thumbnail with a soft gray background and rounded corners.
    - **Right**: An `Expanded` column containing:
      - Title (bold).
      - Author (gray text).
      - A `Row` or `Wrap` of badges (e.g., "Magazine", "science", "technology"). Tag pills use a light background and colored text.
      - A dynamic availability indicator on the far right (e.g., a green dot and "2/2").

## 4. Input Debounce Logic (300ms)

To optimize performance and prevent excessive state updates or API calls while the user is typing, the search input must implement a debounce mechanism.

### Implementation Details:
- **State Setup**: Maintain a `Timer? _debounce` variable in the `StatefulWidget` state.
- **Listener**: Attach an `onChanged` callback to the search `TextField`.
- **Logic**:
  1. Cancel the existing timer: `if (_debounce?.isActive ?? false) _debounce?.cancel();`
  2. Start a new timer for 300 milliseconds: `_debounce = Timer(const Duration(milliseconds: 300), () { ... });`
  3. Inside the timer callback, update the Riverpod state provider (e.g., `ref.read(_searchQueryProvider.notifier).state = query;`).
- **Cleanup**: Ensure `_debounce?.cancel()` is called within the `dispose()` method of the widget to prevent memory leaks.

# SOP: Search Screen UI & Logic Implementation

This document details the visual hierarchy, widget mapping, and interaction logic for the Search Screen of the LibLog mobile application.

## 1. Search Header & Debounce Logic

The header establishes the primary context and houses the main search input, which must implement performance-conscious debounce logic.

### Widget Mapping:
- **Title**: Large header text ("Catalog" or "Search Library") using `w700` weight.
- **Subtitle**: Contextual text ("Search books, research & more") using `AppColors.mutedForeground`.
- **Search Input (`TextField`)**:
  - Requires a `TextEditingController` and a `FocusNode`.
  - **Styling**: Wrapped in a container or directly styled with `InputDecoration` featuring a subtle background, border radius (e.g., `16` or `9999`), a prefix magnifying glass icon, and a conditional suffix clear button when text is present.
- **Debounce Logic (300ms)**:
  - Utilize a `Timer` to prevent excessive state updates and API calls on every keystroke.
  - When the user types (`onChanged`):
    1. Cancel the existing `Timer`.
    2. Set `isSearching` state to `true` (to trigger the shimmer skeleton).
    3. Start a new `Timer(Duration(milliseconds: 300))`.
    4. Upon timer completion, update the search query state and set `isSearching` to `false`.

## 2. Horizontal Category Pills

The category filters allow users to narrow down results. They must be easily scrollable and visually indicate the active selection.

### Widget Mapping:
- **Root**: `SingleChildScrollView` with `scrollDirection: Axis.horizontal` or a `ListView.builder` for performance.
- **Pill Item (`GestureDetector` -> `AnimatedContainer`)**:
  - **Active State**: 
    - Background: `AppColors.libPurple`
    - Text Color: `Colors.white`
  - **Inactive State**:
    - Background: `AppColors.purple50`
    - Text Color: `AppColors.libPurple`
  - **Styling**: `BorderRadius.circular(9999)`, padding of `16px` horizontal and `8px` vertical. Gap of `8px` between pills.

## 3. Empty & Popular Searches State

Before a query is entered, the screen should display a discovery layout instead of a blank page.

### Widget Mapping:
- **Root**: Vertical `ListView`.
- **Popular Tags**: 
  - A `Wrap` widget containing individual tags.
  - Each tag is styled as an outlined pill (`border: Border.all(color: AppColors.border)`) with a `purple50` background and a trending icon.
  - Tapping a tag automatically injects the text into the Search Input and triggers the debounce logic.
- **Browse Categories**: A list of `ListTile` widgets with a leading icon container and a trailing chevron.

## 4. Search Results List & Skeletons

The core list displaying the catalog matches. It uses a skeleton loader during the 300ms debounce phase.

### Widget Mapping:
- **Skeleton Loader (`shimmer`)**:
  - Active when `isSearching` is true.
  - Displays 4-5 dummy cards built with `Shimmer.fromColors`. Dummy cards feature a gray container for the cover and 3 lines of varying widths for text.
- **Real Results List**:
  - Active when `isSearching` is false and `query` is not empty.
  - Built with a `ListView.builder` or `ListView.separated`.
- **Result Card**:
  - **Container**: Standard card with `BorderRadius.circular(16)`, `border: Border.all(color: AppColors.border)`. Optionally add a soft `BoxShadow` (`Colors.black.withOpacity(0.05), blurRadius: 20`) consistent with the Home Screen.
  - **Cover Image**: Positioned on the left (`width: 72`, full height). Uses a gradient or cached network image with rounded corners on the left side only (`topLeft` and `bottomLeft`).
  - **Metadata**: 
    - Title (`w600` weight, max 1 line, ellipsis overflow).
    - Author (`AppColors.mutedForeground`).
    - **Tag Row**: Category pill (e.g., "book" or "research") with `purple50` background.
    - **Availability**: A colored dot (`Colors.green` or `Colors.red`) followed by the text "Available" or "Unavailable".

## Interaction Summary
1. Tapping a search result or a popular tag must route the user to the `ResourceDetailScreen` passing the appropriate resource ID via Riverpod state.
2. The UI must smoothly transition from Empty State -> Shimmer Loader -> Results State.

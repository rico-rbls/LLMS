# SOP: Home Screen Layout Implementation

This document details the visual hierarchy and widget mapping for the Home Screen of the LibLog mobile application, based on the provided design references and `BRANDING.md`.

## 1. Greeting Header Layout

The header section is composed of a vertical `Column` containing several rows for the top bar, date, greeting, and library status.

### Widget Mapping:
- **Root**: `Column(crossAxisAlignment: CrossAxisAlignment.start)`
- **Top Bar Row**:
  - `Row` with `mainAxisAlignment: MainAxisAlignment.spaceBetween`.
  - **Left**: A `Container` (Streak Pill) with a bright orange background (`Color(0xFFF97316)`), full border radius (`BorderRadius.circular(9999)`), containing a `Row` with a flame icon and text ("x5 day streak!").
  - **Right**: A `Row` containing two icon buttons (Notifications Bell and Settings Gear). These are circular `Container` widgets with a white background, a light gray border (`AppColors.border`), and an `Icon`.
- **Date Label**: `Text` widget displaying the current date (e.g., "SATURDAY, MAY 9") using `TextStyle(fontSize: 11, color: AppColors.mutedForeground, letterSpacing: 0.5, fontWeight: FontWeight.w600)`.
- **Greeting Text**: `RichText` using a split-weight approach to differentiate the greeting from the name (e.g., "Good evening, " in `w400` and "Juan!" in `w700`). Color should be `AppColors.foreground`.
- **Library Status Pill**: A `Container` with a light green or light red background depending on the status, full border radius, containing a pulsing circular indicator and text ("Library Open · Closes 9PM").

*(Note: If a mascot image was intended to be included in the header, it should be positioned using a `Stack` to overlap the top right area of the greeting text, using `Positioned(right: 0, top: -20, child: Image.asset(...))`.)*

## 2. Announcement Carousel

The announcements section uses a paginated carousel with a custom indicator.

### Widget Mapping:
- **Root**: `Column` containing the section title ("Announcements") and the carousel container.
- **Carousel Container**:
  - `Container` with a light purple background (`AppColors.purple50`), rounded corners (`BorderRadius.circular(24)`), and a fixed height (e.g., `140px`).
  - **Child**: `PageView.builder` for swiping through announcement items.
- **Announcement Item**:
  - `Padding` containing a `Column` with the announcement title (`Text` with `w700` and `AppColors.libPurple`), a close icon (`IconButton`), and a "Read full" link text.
- **Page Indicator**:
  - Using the `smooth_page_indicator` package.
  - Positioned at the bottom center of the `PageView` using an `Align` or `Positioned` widget if wrapped in a `Stack`, or placed simply below the `PageView` in the parent `Column`.
  - **Effect**: `ExpandingDotsEffect` or `WormEffect` with `activeDotColor: AppColors.libPurple` and `dotColor: AppColors.purple200`, dot height `6px`.

## 3. Borrow Status Card

The "Current Borrow" card displays the active loan with emphasis on deadlines and progress.

### Widget Mapping:
- **Root**: `Container` representing the card.
- **Styling**:
  - **Background**: `Colors.white` (`Theme.of(context).cardColor`).
  - **Border**: Specific purple border as requested `border: Border.all(color: AppColors.libPurple.withOpacity(0.3), width: 1.5)`.
  - **Shadow**: Subtle specific shadow `boxShadow: [BoxShadow(color: AppColors.libPurple.withOpacity(0.05), blurRadius: 10, offset: Offset(0, 4))]`.
  - **Radius**: `BorderRadius.circular(24)`.
- **Header Row**: Book title ("Introduction to Algorithms") and a "0 days left" pill (using a yellow/warning semantic color).
- **Sub-header Row**: Author name (`AppColors.mutedForeground`).
- **Tag Row**: "Computer Science" category pill.
- **Progress/Divider**: A thick purple line (`Container` with `height: 4`, `color: AppColors.libPurple`, `borderRadius: BorderRadius.circular(2)`) acting as a visual separator or progress indicator.
- **Footer Row**:
  - **Left**: "Borrowed 4/24/2026"
  - **Right**: "Due 5/8/2026"
- **Action**: "View Details" text button with a chevron right icon, colored in `AppColors.libPurple`.

## 4. Reading Stats Card (fl_chart)

The "Reading Goal" card visualizes user progress using a circular chart.

### Widget Mapping:
- **Root**: `Container` card alongside the "Attendance" card in a horizontal 2-column grid or `Row` with `Expanded` children.
- **Card Styling**: Standard white card with `BorderRadius.circular(24)` and light gray border.
- **Content Layout**: `Column` centered horizontally.
- **Chart Component (fl_chart)**:
  - Container with fixed dimensions (e.g., `height: 100, width: 100`).
  - **Widget**: `PieChart` from the `fl_chart` library.
  - **Data**: Two `PieChartSectionData` objects:
    1. **Completed**: `value: 3`, `color: AppColors.libPurple`, `radius: 12`, `showTitle: false`.
    2. **Remaining**: `value: 21`, `color: AppColors.purple50`, `radius: 12`, `showTitle: false`.
  - **Center Overlay**: Wrap the chart in a `Stack` and place a `Center` widget containing the text "3/24" (using `TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.libPurple)`).
- **Footer Text**: "21 more to go" (`AppColors.mutedForeground`) and a "Change" link text button (`AppColors.libPurple`).

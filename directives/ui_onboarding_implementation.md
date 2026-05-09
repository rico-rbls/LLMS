# SOP: Onboarding UI Implementation

## 1. Goal
Implement a pixel-perfect, 5-step registration wizard (`onboarding_screen.dart`) that matches the prototype screenshots. The wizard must guide the user smoothly through account creation, maintaining state across steps, and concluding with a celebratory animation.

## 2. Visual Specifications & Layout constraints
- **Typography:** Use `GoogleFonts.inter()` strictly.
- **Max Width:** The entire layout must be constrained to a **430px** maximum width and horizontally centered.
- **Background:** Light mode background (`#f2f2fa` or `Colors.white`).
- **Input Borders:** All input fields and selectable cards must feature a 12px `BorderRadius`.
- **Soft Shadows:** Apply the standard `BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20)` to elevated elements where necessary.

## 3. Progress Indicators
- Implement a top progress indicator (e.g., a smooth `LinearProgressIndicator` or animated progress dots) that visually represents the current step out of 5.
- It must animate smoothly as the user navigates between steps using a `PageController`.

## 4. Wizard Steps Breakdown

### Step 1: Role Selection
- **Description:** User selects their primary role.
- **Options:** "Student", "Faculty", "Visitor", "Librarian".
- **Styling:** Render options as selectable cards or tiles. When selected, the card should have an active state with an `AppColors.libPurple` border highlight and a subtle purple background tint (`withOpacity(0.1)`).

### Step 2: Personal Information
- **Fields:**
  - **Full Name:** Text input.
  - **University ID:** Text/Numeric input.
- **Styling:** Standard 12px rounded borders. Unfocused state uses `AppColors.border`; focused state uses `AppColors.libPurple` (1.5px to 2px width).

### Step 3: Academic Information
- **Fields:**
  - **Program/Department:** Dropdown or stylized selector.
  - **Year Level:** Dropdown or selector.
- **Styling:** Ensure adequate spacing (e.g., `SizedBox(height: 20)`) matching the prototype. Utilize the same 12px border radius constraint.

### Step 4: Account Setup
- **Fields:**
  - **Email:** Text input with email validation regex.
  - **Password:** Password input (obscured text) with a visibility toggle suffix icon and length validation (e.g., > 6 chars).
- **Styling:** Standard 12px rounded borders. Use prefix icons (`school_outlined`, `lock_outline`) similar to the login screen.

### Step 5: Preferences & Completion
- **Fields:** Toggle switches (`Switch` or custom segmented controls) for Notification types:
  - Due Dates
  - Reservations
  - Announcements
- **Completion Action:** A primary "Complete Setup" button. Upon successful validation, trigger the `ConfettiWidget` blast and route the user to the home dashboard.

## 5. Navigation & State
- **State Management:** Use a local state object (like a `Map<String, dynamic>`) to accumulate data as the user progresses.
- **Bottom Actions:** Provide "Back" and "Next" buttons at the bottom of the screen. "Back" should be a ghost/text button, while "Next" should be an elevated `AppColors.libPurple` button.
- **Validation:** Prevent advancing to the next step if the current step's required fields are empty or invalid.

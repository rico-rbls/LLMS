# SOP: Login UI Implementation

## 1. Goal
Implement a high-impact, branded Login screen matching the prototype screenshot, featuring the "living gradient" header, animated logo, and specific form styling.

## 2. Visual Specifications
- **Font Family:** Always use `GoogleFonts.inter()`.
- **Max Width:** The entire layout must be constrained to a **430px** maximum width and centered.
- **Background:** Light mode page background is `#f2f2fa`.

## 3. Header Section (Living Gradient)
- **Background:** A `Stack` containing two animated gradient layers shifting colors (refer to `FEATURES.md` logic).
  - Primary colors: `AppColors.libPurple`, `AppColors.purple800`, `AppColors.purple600`.
- **Decorative Elements:** Semi-transparent light purple circles (`white.withOpacity(0.1)`) with subtle parallax or slow floating animations.
- **Logo Area:**
  - A white book icon inside a 100x100 container with a 24px corner radius and `white.withOpacity(0.2)` background.
  - Apply a spring scale animation + continuous slow glow pulse.
- **Typography:**
  - **H1:** "LibLog" in white, `FontWeight.w800`, 32px.
  - **Subtitle:** "Digital Library Logbook System" in white, 14px, `FontWeight.w500`, with a small icon prefix.

## 4. Login Form Card
- **Layout:** A white card that overlaps the header by `-40px`.
- **Corner Radius:** 32px or 40px for the top corners.
- **Shadow:** Use a very soft shadow: `Colors.black.withOpacity(0.05)`, `blurRadius: 20`.
- **Form Fields:**
  - **Rounding:** 12px `BorderRadius`.
  - **Border:** 1px `AppColors.border` when idle; `AppColors.libPurple` (2px) when focused.
  - **Email:** `prefixIcon: Icons.school_outlined`, placeholder: `you@university.edu`.
  - **Password:** `prefixIcon: Icons.lock_outline`, placeholder: `Enter your password`, `suffixIcon` for visibility toggle.
  - **Label Style:** 14px, `FontWeight.w600`, `AppColors.foreground`.

## 5. Action Buttons
- **Primary "Sign In" Button:**
  - Gradient background: `AppColors.libPurple` to `AppColors.purple700`.
  - Height: 52px.
  - Radius: 12px.
  - Shimmer effect when loading.
- **"Use Demo Account" Button:**
  - Dashed or subtle purple border.
  - Background: `Colors.white`.
  - Icon: `Icons.menu_book_outlined`.
  - Text: "Use Demo Account" in `AppColors.libPurple`.
- **"Register" Link:**
  - Placed at the bottom: "Don't have an account? **Register**".
  - "Register" should be in `AppColors.libPurple` and bold.

## 6. Layout Constraints
- Use a `SingleChildScrollView` to prevent overflow on smaller devices when the keyboard appears.
- Ensure the footer "By signing in..." is centered and uses `labelSmall` (10px-12px) muted text.

## 7. Logic & State
- **Validation:** Email must match regex; password length > 6.
- **Demo Mode:** Tapping "Use Demo Account" should auto-fill `juan@university.edu` / `password123`.
- **Auth Guard:** On successful login, route to `home` and update `isAuthenticated` in `authProvider`.

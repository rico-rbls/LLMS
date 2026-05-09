# LibLog — Mobile Branding & Design System Guide (Flutter/Dart)

> **Version:** 1.1 (Flutter Pivot)  
> **Last Updated:** 2026-05-09  
> **Platform:** Flutter Mobile App 
> **Design Philosophy:** Clean, accessible, purple-forward academic library experience

---

## Table of Contents

1. [Typography](#1-typography)
2. [Color System](#2-color-system)
3. [Corner Rounding](#3-corner-rounding)
4. [Spacing System](#4-spacing-system)
5. [Elevation & Shadows](#5-elevation--shadows)
6. [Gradients](#6-gradients)
7. [Iconography](#7-iconography)
8. [Motion & Animation](#8-motion--animation)
9. [Layout & Grid](#9-layout--grid)
10. [Touch Targets & Accessibility](#10-touch-targets--accessibility)
11. [Dark Mode Guidelines](#11-dark-mode-guidelines)
12. [Component Specifications](#12-component-specifications)
13. [Status & Semantic Colors](#13-status--semantic-colors)
14. [Imagery & Photography](#14-imagery--photography)
15. [Writing & Tone](#15-writing--tone)
16. [Implementation Reference](#16-implementation-reference)

---

## 1. Typography

### Font Family

| Role | Flutter Implementation | Fallback |
|---|---|---|
| **Primary / Body** | `GoogleFonts.inter()` or system font | `TextTheme.bodyMedium` |
| **Display / Headings** | `GoogleFonts.inter()` with weights | `TextTheme.displayLarge` etc. |
| **Monospace / Code** | `GoogleFonts.robotoMono()` | `TextTheme.bodySmall` |

> **Implementation Note:** Use `google_fonts` package to load Inter or SF Pro equivalent. For system fonts, use `ThemeData` with `fontFamily: 'System'`.

### Heading Scale

| Level | Size | Line Height | Weight | Letter Spacing | Flutter TextStyle | Usage |
|---|---|---|---|---|---|---|
| **H1** | 30px | 36px (1.2) | Bold (700) | -0.5px | `displayLarge` | App title, hero text (e.g. "LibLog" on login) |
| **H2** | 24px | 30px (1.25) | Bold (700) | -0.3px | `displayMedium` | Major screen titles, large stats |
| **H3** | 20px | 26px (1.3) | Semibold (600) | -0.2px | `titleLarge` | Screen headers, section titles |
| **H4** | 18px | 24px (1.33) | Semibold (600) | 0px | `titleMedium` | Card titles, subsection headers |
| **H5** | 16px | 22px (1.375) | Medium (500) | 0px | `titleSmall` | List item titles, inline headers |
| **H6** | 14px | 20px (1.43) | Medium (500) | 0.1px | `bodyLarge` with `fontWeight: 500` | Small section labels, caption headers |

### Body & Supporting Text

| Role | Size | Line Height | Weight | Flutter TextStyle | Usage |
|---|---|---|---|---|---|
| **Body** | 16px | 24px (1.5) | Regular (400) | `bodyMedium` | Primary content, paragraphs, descriptions |
| **Body Small** | 14px | 20px (1.43) | Regular (400) | `bodySmall` | Secondary content, card body text |
| **Caption** | 12px | 16px (1.33) | Regular (400) | `labelSmall` | Metadata, timestamps, helper text |
| **Micro** | 10px | 14px (1.4) | Medium (500) | Custom `TextStyle` | Tiny labels, badges, nav labels |
| **Nano** | 9px | 12px (1.33) | Medium (500) | Custom `TextStyle` | Category chips on covers |
| **Ultra** | 8px | 11px (1.375) | Semibold (600) | Custom `TextStyle` | Only for book cover category overlays |

### Button Text

| Type | Size | Weight | Letter Spacing | Flutter TextStyle |
|---|---|---|---|---|
| **Primary Button** | 16px | Semibold (600) | 0.2px | `labelLarge` |
| **Secondary Button** | 14px | Medium (500) | 0.1px | `labelMedium` |
| **Small/Button** | 12px | Medium (500) | 0px | `labelSmall` |

### Font Weight Reference

| Name | Value | Flutter Constant | Usage |
|---|---|---|---|
| Regular | 400 | `FontWeight.w400` | Body text, descriptions |
| Medium | 500 | `FontWeight.w500` | Subtle emphasis, labels, small headers |
| Semibold | 600 | `FontWeight.w600` | Buttons, card titles, emphasis |
| Bold | 700 | `FontWeight.w700` | Headings, screen titles, strong emphasis |

> **Rule:** Never use Light (300) or Thin (100) weights on mobile — they fail readability tests below 14px.

---

## 2. Color System

### Primary Brand Color

| Name | Hex | Flutter Color | Usage |
|---|---|---|---|
| **Lib Purple** | `#652D90` | `Color(0xFF652D90)` | Primary brand, buttons, accents, icons |

### Full Purple Palette

| Token | Hex | Flutter Color | Usage |
|---|---|---|---|
| `lib-purple-50` | `#F5EDF9` | `Color(0xFFF5EDF9)` | Light backgrounds, card fills, subtle surfaces |
| `lib-purple-100` | `#E8D5F3` | `Color(0xFFE8D5F3)` | Progress tracks, inactive indicators |
| `lib-purple-200` | `#D4ADE7` | `Color(0xFFD4ADE7)` | Borders, dividers, inactive bars |
| `lib-purple-300` | `#B87DD4` | `Color(0xFFB87DD4)` | Gradient endpoints, secondary accents |
| `lib-purple-400` | `#9B5BBF` | `Color(0xFF9B5BBF)` | Mid-tones, gradient highlights |
| `lib-purple-500` | `#652D90` | `Color(0xFF652D90)` | **Primary brand color** |
| `lib-purple-600` | `#5A2880` | `Color(0xFF5A2880)` | Darker variant, hover states |
| `lib-purple-700` | `#4A2068` | `Color(0xFF4A2068)` | Deep dark, pressed states |
| `lib-purple-800` | `#3A1850` | `Color(0xFF3A1850)` | Darkest variant, dark mode gradients |
| `lib-purple-900` | `#2A1038` | `Color(0xFF2A1038)` | Near-black purple, dark mode backgrounds |

### Semantic Color Tokens (Light Mode)

| Token | Flutter Color | Purpose |
|---|---|---|
| `background` | `Color(0xFFf2f2fa)` | Page background (lavender-tinted gray) |
| `foreground` | `Color(0xFF1A1A1A)` | Primary text |
| `card` | `Color(0xFFFFFFFF)` | Card background |
| `card-foreground` | `Color(0xFF1A1A1A)` | Card text |
| `primary` | `Color(0xFF652D90)` | Brand primary (maps to Lib Purple) |
| `primary-foreground` | `Color(0xFFFFFFFF)` | Text on primary |
| `secondary` | `Color(0xFFF5EDF9)` | Light purple tint surface |
| `secondary-foreground` | `Color(0xFF4A2068)` | Text on secondary |
| `muted` | `Color(0xFFF5EDF9)` | Muted background |
| `muted-foreground` | `Color(0xFF8B6B9F)` | Muted text |
| `accent` | `Color(0xFFF5EDF9)` | Accent surface |
| `accent-foreground` | `Color(0xFF4A2068)` | Text on accent |
| `destructive` | `Color(0xFFDC2626)` | Error / destructive actions |
| `border` | `Color(0xFFE8D5F3)` | Default borders |
| `input` | `Color(0xFFE8D5F3)` | Input field borders |
| `ring` | `Color(0xFF652D90)` | Focus ring color |

### Neutral Grays

| Name | Hex | Flutter Color | Usage |
|---|---|---|---|
| Gray-50 | `#f2f2fa` | `Color(0xFFf2f2fa)` | Page backgrounds (light mode) |
| Gray-100 | `#F3F4F6` | `Color(0xFFF3F4F6)` | Subtle dividers |
| Gray-200 | `#E5E7EB` | `Color(0xFFE5E7EB)` | Borders, separators |
| Gray-300 | `#D1D5DB` | `Color(0xFFD1D5DB)` | Disabled borders |
| Gray-400 | `#9CA3AF` | `Color(0xFF9CA3AF)` | Placeholder text |
| Gray-500 | `#6B7280` | `Color(0xFF6B7280)` | Secondary text |
| Gray-600 | `#4B5563` | `Color(0xFF4B5563)` | Body text (muted) |
| Gray-700 | `#374151` | `Color(0xFF374151)` | Secondary headings |
| Gray-800 | `#1F2937` | `Color(0xFF1F2937)` | Primary text (dark surfaces) |
| Gray-900 | `#111827` | `Color(0xFF111827)` | Card surfaces (dark mode legacy) |
| Gray-950 | `#030712` | `Color(0xFF030712)` | Page background (dark mode legacy) |

### Contrast Requirements

| Text on Background | Minimum Contrast | Our Standard |
|---|---|---|
| Body text on `#f2f2fa` | 4.5:1 (WCAG AA) | `#1A1A1A` on `#f2f2fa` = **16.2:1** ✅ |
| Muted text on `#f2f2fa` | 3:1 (WCAG AA Large) | `#8B6B9F` on `#f2f2fa` = **3.5:1** ✅ |
| White text on purple | 4.5:1 | `#FFFFFF` on `#652D90` = **7.2:1** ✅ |
| Purple text on `#f2f2fa` | 4.5:1 | `#652D90` on `#f2f2fa` = **7.0:1** ✅ |

---

## 3. Corner Rounding

### Radius Scale

| Token | Value | Flutter BorderRadius | Usage |
|---|---|---|---|
| **None** | 0px | `BorderRadius.zero` | Flat elements, dividers |
| **XS** | 4px | `BorderRadius.circular(4)` | Small tags, micro-badges |
| **SM** | 8px | `BorderRadius.circular(8)` | Small buttons, compact elements |
| **MD** | 10px | `BorderRadius.circular(10)` | Default elements |
| **LG** | 12px | `BorderRadius.circular(12)` | Primary buttons, inputs, icon containers |
| **XL** | 16px | `BorderRadius.circular(16)` | Inner card elements, book covers |
| **2XL** | 20px | `BorderRadius.circular(20)` | Large cards, feature panels |
| **3XL** | 24px | `BorderRadius.circular(24)` | **Standard card radius**, hero sections |
| **Full** | 9999px | `BorderRadius.circular(9999)` | Avatars, pills, badges, FABs |

### Element-to-Radius Mapping

| Element | Radius | Flutter Implementation |
|---|---|---|
| Cards | 24px | `BorderRadius.circular(24)` |
| Inner card elements | 16px | `BorderRadius.circular(16)` |
| Primary Buttons | 12px | `BorderRadius.circular(12)` |
| Secondary Buttons | 12px | `BorderRadius.circular(12)` |
| Text Inputs | 12px | `BorderRadius.circular(12)` |
| Icon Containers | 12px | `BorderRadius.circular(12)` |
| Avatars | Full | `BorderRadius.circular(9999)` |
| Tags / Pills | Full | `BorderRadius.circular(9999)` |
| Bottom Sheets | 24px (top only) | `BorderRadius.vertical(top: Radius.circular(24))` |
| Login Header | 40px (bottom only) | `BorderRadius.vertical(bottom: Radius.circular(40))` |
| Profile Header | 32px (bottom only) | `BorderRadius.vertical(bottom: Radius.circular(32))` |
| Book Covers | 16px | `BorderRadius.circular(16)` |
| Modals / Dialogs | 24px | `BorderRadius.circular(24)` |
| Toast Notifications | 12px | `BorderRadius.circular(12)` |
| Progress Bars | Full | `BorderRadius.circular(9999)` |
| Divider Accents | Full | `BorderRadius.circular(9999)` |

---

## 4. Spacing System

### Base Unit: 4px

All spacing values are multiples of 4px, following the 4px grid system.

### Spacing Scale

| Token | Value | Flutter (EdgeInsets/SizedBox) | Usage |
|---|---|---|---|
| **0** | 0px | `EdgeInsets.zero` | No spacing |
| **0.5** | 2px | `EdgeInsets.all(2)` | Hairline gaps |
| **1** | 4px | `EdgeInsets.all(4)` | Tight spacing, inline gaps |
| **1.5** | 6px | `EdgeInsets.all(6)` | Compact list items |
| **2** | 8px | `EdgeInsets.all(8)` | Grid gaps, tight padding |
| **3** | 12px | `EdgeInsets.all(12)` | Small section gaps |
| **4** | 16px | `EdgeInsets.all(16)` | **Standard padding**, page margins |
| **5** | 20px | `EdgeInsets.all(20)` | Section gaps, list spacing |
| **6** | 24px | `EdgeInsets.all(24)` | Generous padding, card content |
| **8** | 32px | `EdgeInsets.all(32)` | Large section separators |
| **10** | 40px | `EdgeInsets.all(40)` | Major layout breaks |
| **12** | 48px | `EdgeInsets.all(48)` | Hero spacing, large vertical gaps |
| **16** | 64px | `EdgeInsets.all(64)` | Full-bleed separators |
| **20** | 80px | `EdgeInsets.all(80)` | Bottom safe area for navigation |

### Layout Spacing Patterns

| Context | Horizontal | Vertical | Flutter Implementation |
|---|---|---|---|
| **Page padding** | 16px | 16px | `EdgeInsets.symmetric(horizontal: 16, vertical: 16)` |
| **Card padding** | 16px | 16px | `EdgeInsets.all(16)` or `EdgeInsets.all(24)` |
| **Section gap** | — | 20px | `SizedBox(height: 20)` between sections |
| **Card gap** | — | 12px | `SizedBox(height: 12)` between cards |
| **Form field gap** | — | 16px | `SizedBox(height: 16)` between fields |
| **List item padding** | 16px | 14px | `EdgeInsets.symmetric(horizontal: 16, vertical: 14)` |
| **Bottom nav height** | — | 80px | `SizedBox(height: 80)` or `kBottomNavigationBarHeight` |
| **Horizontal list** | 12px | — | `SizedBox(width: 12)` in ListView |

### Internal Spacing Rules

| Pattern | Formula | Flutter Implementation |
|---|---|---|
| **Icon + Text** | 8px gap | `SizedBox(width: 8)` in Row |
| **Button padding** | 16px horizontal, 12px vertical | `EdgeInsets.symmetric(horizontal: 16, vertical: 12)` |
| **Input padding** | 12px horizontal | `EdgeInsets.symmetric(horizontal: 12)` |
| **Card stack offset** | -24px to -48px overlap | `Transform.translate(offset: Offset(0, -24))` |
| **Badge inset** | 4px from edge | `EdgeInsets.only(right: 4, top: 4)` |
| **Avatar overlap** | -8px margin | `Transform.translate(offset: Offset(-8, 0))` |

---

## 5. Elevation & Shadows

### Design Philosophy: Flat Light, Depth Dark

> **Major Design Principle:** Light mode is **FLAT** — no shadows on cards, buttons, images, or modals. Visual separation comes from the contrast between the lavender-tinted page background (`#f2f2fa`) and white card surfaces (`#FFFFFF`). Dark mode uses shadows for depth and layer differentiation since the dark purple surfaces need additional visual cues.

- **Light mode:** Cards are flat at rest. No shadows on content surfaces. Only `BottomNav` and the QR scan center button retain shadows in both light and dark mode.
- **Dark mode:** Shadows are used for depth. Cards get subtle shadows, hover states add stronger shadows.

### Shadow Hierarchy

| Level | Flutter BoxShadow | Light Mode | Dark Mode | Usage |
|---|---|---|---|---|
| **0 — Flat** | `BoxShadow.none` | ✅ Default | — | Cards at rest, inline elements, text |
| **1 — Subtle** | `BoxShadow(color: black12, blur: 2, offset: 1)` | ❌ Not used | ✅ | Cards at rest (dark mode only) |
| **2 — Default** | `BoxShadow(color: black12, blur: 6, offset: -1)` | ❌ Not used | ✅ | Elevated cards (dark mode only) |
| **3 — Medium** | `BoxShadow(color: purple15, blur: 25, offset: -5)` + second shadow | ❌ Not used | ✅ Dark mode hover | Card hover state (dark mode only) |
| **4 — High** | `BoxShadow(color: black12, blur: 15, offset: -3)` | ✅ BottomNav + QR scan only | ✅ FABs, elevated buttons | Bottom nav card, scan button |
| **5 — Brand Glow** | `BoxShadow(color: purple35, blur: 20, spread: 4)` | ❌ Not used | ✅ Dark mode only | Primary CTA glow (dark mode only) |
| **6 — Hero** | `BoxShadow(color: black12, blur: 25, offset: -5)` | ❌ Not used | ✅ Mobile container | Container (dark mode only) |

### Elements with Shadows in BOTH Light and Dark Mode

| Element | Shadow | Rationale |
|---|---|---|
| **BottomNav card** | `BoxShadow(color: black12, blur: 6, offset: -1)` | Needs to feel elevated above page content at all times |
| **QR scan center button** | `BoxShadow(color: purple40, blur: 10, spread: 2)` | Floating action button must always appear raised |

### Flutter BoxShadow Implementations

```dart
// Light mode - flat (no shadows except special cases)
final cardDecoration = BoxDecoration(
  color: Colors.white,
  borderRadius: BorderRadius.circular(24),
  // No boxShadow for light mode cards
);

// Dark mode - with shadows
final darkCardDecoration = BoxDecoration(
  color: Color(0xFF1a0e2e),
  borderRadius: BorderRadius.circular(24),
  boxShadow: [
    BoxShadow(
      color: Colors.black.withOpacity(0.1),
      blurRadius: 6,
      offset: Offset(0, -1),
    ),
  ],
);

// BottomNav (both modes)
final bottomNavDecoration = BoxDecoration(
  color: Colors.white,
  boxShadow: [
    BoxShadow(
      color: Colors.black.withOpacity(0.1),
      blurRadius: 6,
      offset: Offset(0, -1),
    ),
  ],
);
```

### Elevation Rules

1. **Light mode resting state:** Cards use NO shadow — flat design. Visual separation comes from background color contrast.
2. **Dark mode resting state:** Cards use subtle shadow — for surface differentiation.
3. **Interaction (dark mode only):** Hover/tap adds brand-tinted shadow — purple glow reinforces brand.
4. **BottomNav + QR scan:** These elements retain shadows in BOTH modes because they float above content.
5. **Primary CTA glow:** Only appears in dark mode when valid/active — draws the eye.
6. **Mobile container:** Uses shadow for the 430px container — no shadow in light mode.
7. **Never use pure black shadows** — always tint with brand purple or use gray.
8. **Light mode rule of thumb:** If it's not BottomNav or QR scan, it doesn't get a shadow.

---

## 6. Gradients

### Brand Gradients

| Name | Value (Light) | Value (Dark) | Flutter Implementation |
|---|---|---|---|
| **Purple Gradient** | `LinearGradient(135deg, #652D90→#7B3FA8→#9B5BBF)` | `LinearGradient(135deg, #522575→#5A2880→#7B3FA8)` | Primary buttons, headers, CTAs |
| **Subtle Purple** | `LinearGradient(135deg, #F5EDF9→#E8D5F3)` | `LinearGradient(135deg, #2A1038→#3A1850)` | Backgrounds, card fills |
| **Text Gradient** | `ShaderMask(LinearGradient(#652D90, #9B5BBF))` | Same | Gradient text effect |
| **Border Gradient** | `LinearGradient(135deg, #652D90, #9B5BBF, #B87DD4, #652D90)` | Same | Animated gradient borders |
| **CTA Gradient** | `LinearGradient(to right, #652D90, #7B3FA8, #652D90)` | Same | Final onboarding CTA |

### Gradient Rules

1. **Direction:** Always 135deg (top-left to bottom-right) for brand gradients
2. **Stops:** 3-stop minimum for smooth purple gradients
3. **Dark mode:** Shift stops darker by ~20% lightness
4. **Subtle gradients:** Only 2 stops, low contrast between them
5. **Never use non-purple gradients** for primary elements

### Flutter Gradient Implementation

```dart
// Primary purple gradient
final purpleGradient = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [
    Color(0xFF652D90),
    Color(0xFF7B3FA8),
    Color(0xFF9B5BBF),
  ],
);

// Text gradient using ShaderMask
Widget gradientText(String text) {
  return ShaderMask(
    shaderCallback: (bounds) => LinearGradient(
      colors: [Color(0xFF652D90), Color(0xFF9B5BBF)],
    ).createShader(bounds),
    child: Text(
      text,
      style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
    ),
  );
}
```

---

## 7. Iconography

### Icon Library

| Property | Value |
|---|---|
| **Library** | Material Icons / Cupertino Icons |
| **Style** | Outlined (stroke-based) |
| **Default Stroke** | 1.5px (equivalent) |
| **Color** | Inherits from parent (`color: currentColor`) |

### Icon Size Scale

| Size | Dimensions | Flutter Icon Size | Usage |
|---|---|---|---|
| **XS** | 14px | `Icon(Icons.xxx, size: 14)` | Inline with small text, badges |
| **SM** | 16px | `Icon(Icons.xxx, size: 16)` | Inline with body text, list items |
| **MD** | 20px | `Icon(Icons.xxx, size: 20)` | Navigation, standard actions |
| **LG** | 24px | `Icon(Icons.xxx, size: 24)` | Section headers, prominent actions |
| **XL** | 28px | `Icon(Icons.xxx, size: 28)` | Feature highlights |
| **2XL** | 32px | `Icon(Icons.xxx, size: 32)` | Empty states, illustrations |

### Icon Container Sizes

| Container | Size | Icon | Background | Radius | Flutter Implementation |
|---|---|---|---|---|---|
| **Small** | 36×36px | 18px | `card` color | 12px | `Container(36×36, decoration: BoxDecoration(color: card, borderRadius: 12))` |
| **Medium** | 40×40px | 20px | `card` color | 12px | `Container(40×40, decoration: BoxDecoration(color: card, borderRadius: 12))` |
| **Large** | 44×44px | 22px | `card` color | 12px | `Container(44×44, decoration: BoxDecoration(color: card, borderRadius: 12))` |
| **XL** | 48×48px | 24px | `card` color | 12px | `Container(48×48, decoration: BoxDecoration(color: card, borderRadius: 12))` |

### Icon Color Rules

| Context | Flutter Color | Example |
|---|---|---|
| **Default** | `Color(0xFF652D90)` | Navigation, actions |
| **On purple bg** | `Colors.white` | Purple button icons |
| **Muted/Inactive** | `Color(0xFFB87DD4)` | Disabled, inactive tabs |
| **Destructive** | `Colors.red` | Delete, remove |
| **Success** | `Colors.green` | Check, confirm |

---

## 8. Motion & Animation

### Duration Scale

| Speed | Duration | Curve | Usage |
|---|---|---|---|
| **Instant** | 100ms | `Curves.easeOut` | Color changes, opacity |
| **Quick** | 200ms | `Curves.easeInOut` | Button press, toggle |
| **Standard** | 300ms | `Curves.easeInOut` | Screen transitions, expand |
| **Expressive** | 500ms | `Curves.easeOut` | Sheet presentation, hero animations |
| **Deliberate** | 800ms | `Curves.easeInOut` | Onboarding transitions |

### Standard Transitions

| Animation | Properties | Duration | Curve |
|---|---|---|---|
| **Screen Enter** | opacity: 0→1, y: +8→0 | 200ms | `Curves.easeInOut` |
| **Card Hover** | translateY: 0→-2px, shadow | 200ms | `Curves.easeOut` |
| **Button Press** | scale: 1→0.97 | 100ms | `Curves.easeOut` |
| **Modal Enter** | opacity: 0→1, scale: 0.95→1 | 300ms | `Curves.easeOut` |
| **Sheet Enter** | translateY: 100%→0 | 300ms | `Curves.easeOut` |
| **Toast Enter** | translateY: -20→0, opacity | 300ms | `Curves.easeOut` |
| **Skeleton Shimmer** | background-position | 1.5s | `Curves.linear` (infinite) |
| **Progress Fill** | width | 500ms | `Curves.easeInOut` |
| **Confetti** | Multi-particle physics | 3s | `Curves.easeOut` |

### Micro-interactions

| Element | Trigger | Animation |
|---|---|---|
| **Heart / Favorite** | Tap | Scale 1→1.3→1 (300ms bounce) + color fill |
| **Scan Button** | Tap | Scale 1→0.9→1 + ripple |
| **Toggle** | Switch | Slide + color fade (200ms) |
| **Pull to Refresh** | Pull | Rotation + progress indicator |
| **Badge Notification** | New item | Scale 0→1.2→1 (spring) + glow |

### Animation Rules

1. **Never animate layout properties** (width, height, top, left) — use `Transform` or `AnimatedBuilder` instead
2. **Prefer flutter_animate** for widget-level animations
3. **Tween animations** for simple repeating animations (shimmer, pulse, spin)
4. **Reduce motion** — always respect `MediaQuery.of(context).disableAnimations`
5. **No animation should block interaction** — 300ms max for interactive feedback

### Flutter Animation Examples

```dart
// Screen transition
Navigator.of(context).push(
  PageRouteBuilder(
    transitionDuration: Duration(milliseconds: 200),
    pageBuilder: (context, animation, secondaryAnimation) => NewScreen(),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: animation,
        child: SlideTransition(
          position: Tween<Offset>(begin: Offset(0, 0.05), end: Offset.zero)
              .animate(animation),
          child: child,
        ),
      );
    },
  ),
);

// Button press animation
GestureDetector(
  onTapDown: (_) => scaleController.forward(),
  onTapUp: (_) => scaleController.reverse(),
  child: ScaleTransition(
    scale: Tween<double>(begin: 1.0, end: 0.97)
        .animate(CurvedAnimation(parent: scaleController, curve: Curves.easeOut)),
    child: button,
  ),
);
```

---

## 9. Layout & Grid

### Container

| Property | Value | Flutter Implementation |
|---|---|---|
| **Max Width** | 430px | `ConstrainedBox(maxWidth: 430)` |
| **Centering** | Center | `Center(child: ConstrainedBox(...))` |
| **Shadow** | `dark:shadow-xl` (dark mode only) | Conditional `BoxDecoration` |
| **Min Height** | `100vh` / `100dvh` | `MediaQuery.of(context).size.height` |

### Grid System

| Context | Columns | Gap | Flutter Implementation |
|---|---|---|---|
| **Stats Row** | 3 | 12px | `Row(children: [Expanded, Expanded, Expanded], spacing: 12)` |
| **2-column cards** | 2 | 12px | `Wrap(spacing: 12, runSpacing: 12, children: [...])` |
| **Book Carousel** | Auto | 12px | `ListView(scrollDirection: Axis.horizontal, children: [...])` |
| **Tag List** | Auto | 8px | `Wrap(spacing: 8, runSpacing: 8, children: [...])` |

### Safe Areas

| Area | Value | Flutter |
|---|---|---|
| **Top** | Safe area | `SafeArea(top: true, child: ...)` |
| **Bottom** | Safe area | `SafeArea(bottom: true, child: ...)` |
| **Bottom Nav** | 80px total height | `BottomNavigationBar(type: BottomNavigationBarType.fixed)` |
| **Content bottom padding** | 80px | `Padding(padding: EdgeInsets.only(bottom: 80))` |

---

## 10. Touch Targets & Accessibility

### Minimum Touch Targets (Apple HIG)

| Element | Min Size | Recommended | Flutter Implementation |
|---|---|---|---|
| **Buttons** | 44×44px | 48×48px | `SizedBox(height: 48, width: 48, child: ElevatedButton(...))` |
| **List items** | 44×44px | Full-width + padding | `ConstrainedBox(minHeight: 44, child: ListTile(...))` |
| **Icon buttons** | 44×44px | 44×44 | `IconButton(iconSize: 24, constraints: BoxConstraints(minWidth: 44, minHeight: 44))` |
| **Links** | 44×44px tap area | Can be smaller visually | `InkWell(borderRadius: 12, ...)` |
| **Inputs** | 44px height | 48px | `SizedBox(height: 48, child: TextField(...))` |

### Accessibility Requirements

| Requirement | Standard | Flutter Implementation |
|---|---|---|
| **Contrast Ratio** | WCAG AA 4.5:1 | All text passes ✅ |
| **Focus Indicators** | Visible ring | `Focus(style: FocusStyle(...))` |
| **Screen Reader** | Semantic labels | `Semantics(label: '...', child: ...)` |
| **Motion** | Respect prefers-reduced-motion | `MediaQuery.of(context).disableAnimations` |
| **Color Independence** | Never color-only info | Always pair with icon/text |

---

## 11. Dark Mode Guidelines

### Dark Mode Philosophy

Dark mode is not "invert colors" — it's a carefully crafted **dark purple** surface system that maintains the brand identity while reducing eye strain. The system uses a deep purple base instead of pure dark gray, creating a distinctive and cohesive dark experience.

### Surface Hierarchy (Dark Mode)

| Level | Background | Flutter Color | Usage |
|---|---|---|---|
| **L0 — Page** | `#110a1e` (deep purple-black) | `Color(0xFF110a1e)` | Deepest background |
| **L1 — Card** | Dark purple surface | `Color(0xFF1a0e2e)` | Content surfaces |
| **L2 — Elevated** | `Colors.white.withOpacity(0.10)` | `Colors.white.withOpacity(0.10)` | Interactive elements, hover |
| **L3 — Overlay** | `Colors.white.withOpacity(0.15)` | `Colors.white.withOpacity(0.15)` | Modals over content |
| **L4 — Subtle** | `Colors.white.withOpacity(0.05)` | `Colors.white.withOpacity(0.05)` | Subtle backgrounds, icon containers |

### Color Adaptation Rules

| Light Mode | Dark Mode | Reason |
|---|---|---|
| `#f2f2fa` page bg | `#110a1e` (deep purple-black) | Lavender-tinted → deep purple base |
| `#FFFFFF` card bg | `Color(0xFF1a0e2e)` | White → dark purple surface |
| `bg-lib-purple-50` surfaces | `Colors.white.withOpacity(0.05)` | Subtle purple → transparent over dark purple |
| `bg-gray-100` surfaces | `Colors.white.withOpacity(0.10)` | Light gray → translucent overlay |
| `border-gray-200` borders | `Colors.white.withOpacity(0.05)` or `0.10` | Visible but not harsh |
| `text-gray-500` muted | `Colors.grey[400]` | Slightly brighter for readability |
| `shadow-sm` (light mode: none) | Dark mode shadow | Shadows are dark-mode-only for depth |
| Purple gradients | Darker stops (-20% lightness) | Prevents glowing effect |
| `bg-white` icons/containers | `Colors.white.withOpacity(0.10)` with shadow | Translucent with subtle depth |

### Dark Mode Specific Elements

| Element | Flutter Treatment |
|---|---|
| **Brand gradient** | Use darker stops: `#522575 → #5A2880 → #7B3FA8` |
| **Cards** | `BoxDecoration(color: Color(0xFF1a0e2e), boxShadow: [...])` |
| **Bottom Navigation** | `Color(0xFF1a0e2e).withOpacity(0.9)` with border |
| **Inputs** | `Colors.white.withOpacity(0.10)` border with white text |
| **Shadows** | Applied in dark mode only via conditional `boxShadow` |
| **Images** | Consider slight opacity reduction (`opacity: 0.9`) |
| **Password modal** | `Color(0xFF1a0e2e)` |

### Flutter ThemeData for Dark Mode

```dart
final darkTheme = ThemeData(
  brightness: Brightness.dark,
  primaryColor: Color(0xFF652D90),
  scaffoldBackgroundColor: Color(0xFF110a1e),
  cardColor: Color(0xFF1a0e2e),
  colorScheme: ColorScheme.dark(
    primary: Color(0xFF652D90),
    surface: Color(0xFF1a0e2e),
    background: Color(0xFF110a1e),
  ),
  // ... other theme properties
);
```

---

## 12. Component Specifications

### Buttons

| Variant | Height | Padding | Radius | Font | Flutter Implementation |
|---|---|---|---|---|
| **Primary** | 48px | `horizontal: 24` | 12px | 16px semibold | `ElevatedButton(style: ElevatedButton.styleFrom(minHeight: 48, shape: RoundedRectangleBorder(borderRadius: 12)))` |
| **Secondary** | 44px | `horizontal: 16` | 12px | 14px medium | `OutlinedButton(...)` |
| **Outline** | 44px | `horizontal: 16` | 12px | 14px medium | `OutlinedButton(style: OutlinedButton.styleFrom(side: BorderSide(color: purple)))` |
| **Ghost** | 44px | `horizontal: 16` | 12px | 14px medium | `TextButton(...)` |
| **Destructive** | 44px | `horizontal: 16` | 12px | 14px medium | `ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.red))` |
| **Icon** | 44×44px | — | 12px | — | `IconButton(...)` |
| **FAB** | 56×56px | — | Full | — | `FloatingActionButton(...)` |

### Cards

| Type | Padding | Radius | Shadow | Border | Flutter Implementation |
|---|---|---|---|---|---|
| **Standard** | 16px | 24px | Dark: shadow (flat in light) | `border-gray-100` | `Container(padding: 16, decoration: BoxDecoration(borderRadius: 24, color: card, boxShadow: [...]))` |
| **Spacious** | 24px | 24px | Dark: shadow (flat in light) | `border-gray-100` | Same with `padding: 24` |
| **Interactive** | 16px | 24px | Dark: shadow on hover | Same | `GestureDetector + AnimatedContainer` |
| **Stat** | 16px | 24px | Dark: shadow (flat in light) | Same | Same as Standard |

### Input Fields

| Property | Value | Flutter Implementation |
|---|---|---|
| **Height** | 44-48px | `SizedBox(height: 48, child: TextField(...))` |
| **Radius** | 12px | `OutlineInputBorder(borderRadius: BorderRadius.circular(12))` |
| **Padding** | 12px horizontal | `contentPadding: EdgeInsets.symmetric(horizontal: 12)` |
| **Border** | 1px `gray-200` → purple on focus | `enabledBorder`, `focusedBorder` |
| **Font** | 16px regular | `style: TextStyle(fontSize: 16)` |
| **Label** | 12px medium `purple` | `labelText` with `labelStyle` |
| **Error** | 12px regular `red` | `errorText` with `errorStyle` |
| **Placeholder** | `gray-400` | `hintStyle: TextStyle(color: Colors.grey[400])` |

### Bottom Navigation

| Property | Value | Flutter Implementation |
|---|---|---|
| **Height** | 80px total | `BottomNavigationBar(type: fixed, selectedItemColor: purple)` |
| **Padding** | `vertical: 8, horizontal: 8` | `padding: EdgeInsets.symmetric(vertical: 8, horizontal: 8)` |
| **Background** | `card` with shadow | `decoration: BoxDecoration(boxShadow: [...])` |
| **Border** | `border-t gray-100` | `border: Border(top: BorderSide(color: Colors.grey[200]))` |
| **Active icon** | `white` (on purple) | `Icon(color: Colors.white)` |
| **Inactive icon** | `muted-foreground` | `Icon(color: Colors.grey)` |
| **Center scan button** | 52px, purple gradient, shadow | `FloatingActionButton(...)` |

### Home Screen — Streak Card

| Property | Value | Flutter Implementation |
|---|---|---|
| **Background** | `orange-400` | `Container(color: Colors.orange)` |
| **Radius** | Full (pill shape) | `BorderRadius.circular(9999)` |
| **Padding** | `horizontal: 14, vertical: 8` | `EdgeInsets.symmetric(horizontal: 14, vertical: 8)` |
| **Icon** | Flame (orange) | `Icon(Icons.local_fire_department)` |
| **Text** | White, bold streak count | `Text(style: TextStyle(color: Colors.white, fontWeight: bold))` |

### Home Screen — Greeting

| Property | Value | Flutter Implementation |
|---|---|---|
| **Style** | Split weight | `RichText(children: [TextSpan(style: regular), TextSpan(style: bold)])` |
| **Size** | `24px` | `TextStyle(fontSize: 24)` |
| **Tracking** | Tight | `letterSpacing: -0.5` |

---

## 13. Status & Semantic Colors

### Status Colors

| Status | Background | Text | Flutter Colors | Usage |
|---|---|---|---|---|
| **Success** | `green-50` | `green-700` | `Colors.green[50]`, `Colors.green[700]` | Returned, completed |
| **Success (dark)** | `green-900/20` | `green-400` | `Colors.green[900].withOpacity(0.2)`, `Colors.green[400]` | Dark mode |
| **Warning** | `yellow-100` | `yellow-700` | `Colors.yellow[100]`, `Colors.yellow[700]` | Due soon, pending |
| **Warning (dark)** | `yellow-900/30` | `yellow-400` | `Colors.yellow[900].withOpacity(0.3)`, `Colors.yellow[400]` | Dark mode |
| **Error / Overdue** | `red-100` | `red-700` | `Colors.red[100]`, `Colors.red[700]` | Overdue, failed |
| **Error (dark)** | `red-900/30` | `red-400` | `Colors.red[900].withOpacity(0.3)`, `Colors.red[400]` | Dark mode |
| **Info** | `lib-purple-50` | `lib-purple` | `Color(0xFFF5EDF9)`, `Color(0xFF652D90)` | Informational |
| **Info (dark)** | `lib-purple-900/30` | `lib-purple-300` | `Color(0xFF2A1038).withOpacity(0.3)`, `Color(0xFFB87DD4)` | Dark mode |

### Chart Colors

| Index | Color | Flutter Color | Usage |
|---|---|---|---|
| Chart-1 | `#652D90` | `Color(0xFF652D90)` | Primary data series |
| Chart-2 | `#0D9488` | `Color(0xFF0D9488)` | Secondary data |
| Chart-3 | `#2563EB` | `Color(0xFF2563EB)` | Tertiary data |
| Chart-4 | `#EAB308` | `Color(0xFFEAB308)` | Quaternary data |
| Chart-5 | `#EA580C` | `Color(0xFFEA580C)` | Quinary data |

---

## 14. Imagery & Photography

### Book Covers

| Property | Value | Flutter Implementation |
|---|---|---|
| **Aspect Ratio** | 2:3 (standard book) | `AspectRatio(aspectRatio: 2/3, child: ...)` |
| **Radius** | 16px | `BorderRadius.circular(16)` |
| **Shadow** | Dark: shadow (flat in light) | Conditional `BoxDecoration` |
| **Placeholder** | Gradient background + book icon | `Container(decoration: BoxDecoration(gradient: ...))` |
| **Loading** | Skeleton shimmer | `Shimmer(package)` |
| **AI-generated covers** | 10 covers in `assets/images/covers/` | `Image.asset('assets/images/covers/...')` |

### Avatars

| Size | Dimensions | Radius | Flutter Implementation |
|---|---|---|---|
| **SM** | 32px | Full | `CircleAvatar(radius: 16)` |
| **MD** | 40px | Full | `CircleAvatar(radius: 20)` |
| **LG** | 64px | Full | `CircleAvatar(radius: 32)` |
| **XL** | 80px | Full | `CircleAvatar(radius: 40)` |

### Image Treatment

| Treatment | Value | Flutter Implementation |
|---|---|---|
| **Loading** | Skeleton shimmer | `Shimmer(child: placeholder)` |
| **Error** | Gradient placeholder + icon | `Container(child: Icon(...))` |
| **Dark mode** | Slight opacity reduction | `Opacity(opacity: 0.9, child: ...)` |
| **Overlays** | Semi-transparent gradient | `Stack(children: [image, gradient])` |

---

## 15. Writing & Tone

### Voice

| Attribute | Description |
|---|---|
| **Tone** | Friendly, academic, encouraging |
| **Formality** | Semi-formal (not stuffy, not casual) |
| **Person** | First-person plural ("we") for system, second-person ("you") for user |
| **Jargon** | Minimal — explain library terms when used |

### Copy Length Guidelines

| Context | Max Length | Example |
|---|---|---|
| **Button labels** | 2 words | "Borrow Book", "Return" |
| **Nav labels** | 1 word | "Home", "Search", "Profile" |
| **Section titles** | 3 words | "Recently Added", "My Borrowed" |
| **Card titles** | 5 words | "Introduction to Algorithms" |
| **Body text** | 2 lines | Brief description in cards |
| **Error messages** | 1 line | "Please enter a valid email" |
| **Success messages** | 1 line | "Book returned successfully!" |
| **Empty states** | Title + 1 line | "No books borrowed yet / Start exploring the library" |

### Number Formatting

| Type | Format | Example |
|---|---|---|
| **Dates** | MMM DD, YYYY | Jan 15, 2025 |
| **Time** | h:mm AM/PM | 2:30 PM |
| **Relative time** | Smart units | "2h ago", "Yesterday", "Jan 10" |
| **Count** | Compact for 1000+ | "1.2k books" |
| **Currency** | Symbol + amount | ₱150.00 |
| **Rating** | 1 decimal | 4.5 ★ |

---

## 16. Implementation Reference

### Flutter Color Constants (`lib/config/colors.dart`)

```dart
import 'package:flutter/material.dart';

class AppColors {
  // Primary brand color
  static const Color libPurple = Color(0xFF652D90);
  static const Color libPurpleLight = Color(0xFF7B3FA8);
  static const Color libPurpleDark = Color(0xFF522575);
  
  // Purple palette
  static const Color libPurple50 = Color(0xFFF5EDF9);
  static const Color libPurple100 = Color(0xFFE8D5F3);
  static const Color libPurple200 = Color(0xFFD4ADE7);
  static const Color libPurple300 = Color(0xFFB87DD4);
  static const Color libPurple400 = Color(0xFF9B5BBF);
  static const Color libPurple500 = Color(0xFF652D90);
  static const Color libPurple600 = Color(0xFF5A2880);
  static const Color libPurple700 = Color(0xFF4A2068);
  static const Color libPurple800 = Color(0xFF3A1850);
  static const Color libPurple900 = Color(0xFF2A1038);
  
  // Semantic colors
  static const Color background = Color(0xFFf2f2fa);
  static const Color foreground = Color(0xFF1A1A1A);
  static const Color card = Color(0xFFFFFFFF);
  
  // Dark mode colors
  static const Color darkBackground = Color(0xFF110a1e);
  static const Color darkCard = Color(0xFF1a0e2e);
}
```

### Quick Reference: Flutter Equivalents

| Design Token | Flutter Implementation |
|---|---|
| Primary background | `Color(0xFF652D90)` or `Theme.of(context).primaryColor` |
| Primary text | `Theme.of(context).textTheme.bodyMedium` |
| Light surface | `Color(0xFFF5EDF9)` |
| Gradient button | `Container(decoration: BoxDecoration(gradient: purpleGradient))` |
| Card | `Container(decoration: BoxDecoration(borderRadius: 24, color: card))` |
| Primary button | `ElevatedButton(style: ElevatedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: 12)))` |
| Input | `TextField(decoration: InputDecoration(border: OutlineInputBorder(borderRadius: 12)))` |
| Section gap | `SizedBox(height: 20)` |
| Page padding | `Padding(padding: EdgeInsets.all(16))` |
| Card inner element | `BorderRadius.circular(16)` |
| Icon container | `Container(decoration: BoxDecoration(borderRadius: 12, color: card))` |
| Dark surface | `Color(0xFF1a0e2e)` or `Colors.white.withOpacity(0.05/0.10/0.15)` |
| Dark border | `Colors.white.withOpacity(0.05)` or `0.10` |
| Container shadow | Conditional `BoxDecoration(boxShadow: [...])` |

---

## Changelog

| Date | Version | Changes |
|---|---|---|
| 2026-05-09 | 1.1 | **Flutter Pivot:** Translated all design system specs from Tailwind/CSS to Flutter equivalents. Added Flutter Color constants, BoxDecoration examples, ThemeData configuration, animation examples, and quick reference table. All design values preserved, only implementation syntax changed. |
| 2026-03-04 | 1.0 | Original Next.js version created |

---

> **This document is the single source of truth for LibLog's visual design system in Flutter.** All UI decisions should reference this guide. When in doubt, default to Apple Human Interface Guidelines and apply the purple brand tint.

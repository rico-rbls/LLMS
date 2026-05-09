# LibLog — Digital Library Logbook Management System (Flutter/Dart)

> **Feature Documentation** — Last updated: 2026-05-09 (Flutter Pivot)
> This document is the single source of truth for all features. Update it whenever the system is modified.

---

## Table of Contents

1. [App Overview](#1-app-overview)
2. [Screens & UI Features](#2-screens--ui-features)
3. [API Endpoints](#3-api-endpoints)
4. [Database Models](#4-database-models)
5. [State Management](#5-state-management)
6. [Authentication & Security](#6-authentication--security)
7. [Theme & Design System](#7-theme--design-system)
8. [Animations & Micro-Interactions](#8-animations--micro-interactions)
9. [Navigation & Layout](#9-navigation--layout)
10. [Utility Libraries](#10-utility-libraries)
11. [Seed / Test Data](#11-seed--test-data)
12. [Technology Stack](#12-technology-stack)
13. [Branding & Design System Guide](#13-branding--design-system-guide)

---

## 1. App Overview

LibLog is a **mobile-first** Digital Library Logbook Management System built for university libraries. It enables students, faculty, and visitors to browse the catalog, borrow and return books, track attendance, manage reservations, receive notifications, and more — all from a phone-sized interface.

| Attribute | Value |
|-----------|-------|
| Primary Color | `#652D90` (Purple) |
| Background (Light) | `#f2f2fa` (Lavender-tinted gray) |
| Background (Dark) | `#110a1e` (Dark purple) |
| Max Viewport | 430px (mobile container) |
| Dark Mode | Supported (provider/Riverpod toggle) |
| Platform | Flutter + Dart 3.x |
| Database | SQLite via Prisma ORM (Backend) |
| Test Accounts | `juan@university.edu` / `maria@university.edu` / `alex@university.edu` (password: `password123`) |

---

## 2. Screens & UI Features

### 2.1 Onboarding (5-Step Registration Wizard)

**Screen:** `onboarding_screen.dart` | **State:** Riverpod provider

A multi-step registration flow for new users with animated step-by-step progression:

| Step | Title | Features |
|------|-------|----------|
| 0 | Welcome / Role Selection | 3 role cards (Student, Faculty, Visitor) with icons + emojis, selection animation with checkmark |
| 1 | Personal Information | Full Name input, University ID input, real-time validation |
| 2 | Academic Information | Program dropdown (10 options), Department dropdown (8 for faculty), Year Level grid selector (5 for students), Visitor info card |
| 3 | Account Setup | Email input, Password with show/hide toggle, 4-level strength meter (Weak/Fair/Good/Strong), Confirm password with match validation |
| 4 | Notification Preferences | Due Date Reminders toggle (default on), Reservation Alerts toggle (default on), System Announcements toggle (forced off), Confetti animation on entry |

**Validation:** Each step has `canContinue()` guards before progression.

**Animations:** Slide transitions between steps (directional, 300ms), spring animations on step icons, staggered card entry, checkmark spring, progress bar gradient fill, step dot indicators with icon-to-checkmark transitions, confetti particles (20 animated) on final step.

**Flutter Implementation:**
- Use `PageView` or `IndexedStack` for step navigation
- Animate transitions with `PageView.builder` + `AnimatedSwitcher`
- Confetti: use `confetti` package

---

### 2.2 Login

**Screen:** `login_screen.dart` | **State:** Riverpod auth provider

User authentication screen with branded design:

- **Living gradient header** with two animated gradient layers shifting through 4 color states each (8s & 10s cycles) for parallax effect
- **LibLog logo** with spring scale + rotate animation + continuous glow pulse (2.5s cycle)
- **Form** overlapping header (-mt-10 equivalent):
  - Email input with GraduationCap icon + focus color transitions
  - Password input with show/hide toggle + focus ring
  - "Forgot password?" link (placeholder)
  - Sign In button with gradient + shimmer-loading effect + pulsing glow when email is valid (2s cycle)
  - Loading state: spinner + "Signing in..."
  - "Use Demo Account" button (auto-fills juan@university.edu / password123)
  - Register link → navigates to onboarding
- **Footer:** Terms of Service / Privacy Policy text

**Keyboard:** Done/Enter key on password field triggers login.

**Flutter Implementation:**
- Gradient header: `Stack` + `AnimatedContainer` or `TweenAnimationBuilder`
- Logo animation: `RotationTransition` + `ScaleTransition`
- Form: `Form` + `TextFormField` with `validator`
- Demo button: pre-fills form fields via state

---

### 2.3 Home (Dashboard)

**Screen:** `home_screen.dart` | **State:** Riverpod providers

Personalized landing page with clean card-based layout:

1. **Top Bar:** Streak counter in orange rounded pill card (`Container(color: orange, borderRadius: 9999)` with Flame icon, white text), Notifications bell icon inside `Container(borderRadius: 22, color: card)` (with unread badge), Settings gear icon inside same-style container
2. **User Greeting:** Date display (uppercase, muted), time-of-day greeting with crossfade transition — greeting text is NOT bold ("Good afternoon,"), user name IS bold ("**Juan!**") — implemented as `RichText(children: [TextSpan(style: regular), TextSpan(style: bold)])`, program/year/role subtitle below
3. **Library Status Badge:** Open/Closed indicator with pulsing green dot when Open (2s cycle) + closing time
4. **Announcements Card:** `Container(decoration: BoxDecoration(borderRadius: 24, color: card))` with auto-rotating (5s interval), dismissible with megaphone icon on card header row, carousel dot navigation
5. **Today's Highlight Card:** Same card style with featured book, Sparkles icon on card header row
6. **Current Borrow Card:** Same card style with active book, animated gradient left border (scaleY 0→1 on mount), progress bar, days-left badge (color-coded), "View Details" button. Empty state with floating book animation + "Browse Catalog" CTA
7. **2-Column Square Cards:** Attendance Analytics + Reading Goal side by side (both `aspectRatio: 1.0`), each in card style:
   - **Attendance Analytics:** Visit count, total hours, streak count
   - **Reading Goal:** Circular SVG progress ring, borrowCount/readingGoal ratio
8. **Recommended for You Card:** Card style with horizontal scrollable book covers, "For You" star badges (program-matched), availability dots, "See All" link
9. **Trending in Your Department Card:** Card style with TrendingUp icon on card header row, ranked list (1–5) with borrow counts as plain "X borrows" text (no Clock icons), numbered badges

**Key Design Changes (from Tasks 10–12):**
- Quick Actions section removed entirely (was 4-button grid: Scan QR, My Loans, Reservations, Attendance)
- Purple bar dividers removed from section headers
- No background patterns on section titles
- All sections wrapped in card style containers
- Consistent spacing: `EdgeInsets.symmetric(horizontal: 20, vertical: 24)` header, `EdgeInsets.symmetric(horizontal: 20, vertical: 24)` content
- Section icons (Megaphone, Sparkles, TrendingUp) placed on right side of card header rows

**Gesture:** Pull-to-refresh (60px threshold, animated pull indicator).

**Skeleton Loading:** Dedicated `SkeletonCard` and `SkeletonRecommendations` widgets.

**Flutter Implementation:**
- Pull-to-refresh: `RefreshIndicator`
- Carousel: `PageView` or `CarouselSlider`
- Circular progress: `CustomPainter` for SVG ring or `CircularProgressIndicator`
- Horizontal scroll: `ListView(scrollDirection: Axis.horizontal)`

---

### 2.4 Search (Catalog Browser)

**Screen:** `search_screen.dart` | **State:** Riverpod resources provider

Resource catalog search and browsing:

- **Search input** with Search icon + clear button (X)
- **Popular search suggestions** (6 tags: Algorithms, Deep Learning, Database, Nursing, Psychology, Clean Code) — shown when focused or empty
- **Category filter pills** with spring animation on selection (scale 0.92 on tap, layout for smooth transitions)
- **Animated result count** with purple text glow pulse on count change (600ms)
- **Recently Viewed** horizontal scroll (when search empty)
- **Result cards:** Cover image, title, author, category badge, tag pills (max 2), availability indicator
- **Empty state** with search icon
- **Skeleton loading** — 4 skeleton cards with staggered entrance (replaces spinner)

**Debounce:** 300ms on search input change.

**Flutter Implementation:**
- Search: `TextField(onChanged: debounce)` with `Timer` for debounce
- Category pills: `Wrap(children: [ActionChip(...])` with `AnimatedContainer`
- Result cards: `Card` or custom `Container` widget
- Skeleton: `Shimmer` package

---

### 2.5 Book Detail

**Screen:** `book_detail_screen.dart` | **State:** Riverpod resources + review providers

Detailed resource view with borrow/reserve actions:

- **Purple gradient header** with decorative circles, back button, share button
- **Book cover** (overlapping header, -mt-12 equivalent): image or decorative pattern + category badge + heart/favorite button
- **Metadata:** Title, author, availability badge (green/red), shelf location (MapPin icon), ISBN badge, publication date badge, subject badge
- **Description:** "About this book" section
- **Tags** as pills
- **Ratings & Reviews section:**
  - Rating summary card with average rating, star count, review count, distribution bars (5★→1★)
  - Write/Edit review button with inline form: star selector (1-5), comment textarea (200 char max), Submit/Cancel
  - Reviews list with avatar initials, name, role badge, star rating, date, comment; delete button on own reviews
  - Empty state: "No reviews yet. Be the first to review!"
- **Action buttons:** Borrow (when available) or Reserve (when unavailable) + Share button
- **"More Resources"** related books section
- **Share toast:** "Copied to clipboard!" notification

**Favorite Toggle:** Heart icon with animated scale + color change.

**Share:** Share package or clipboard copy.

**Flutter Implementation:**
- Star rating: Custom `Row` of `IconButton` or use `flutter_rating_bar`
- Reviews list: `ListView.builder`
- Share: `share_plus` package

---

### 2.6 My Loans (Borrowed Books)

**Screen:** `borrowed_screen.dart` | **State:** Riverpod borrow provider

Active loans and borrowing history:

- **Tab switcher:** Active / History (with counts)
- **Summary stats bar:** Active count + Returned count with colored dots
- **Fines Summary Card** (when overdue items exist): Red-themed card with AlertTriangle icon, total fines owed, overdue count, fine rate (₱5.00/day), "Pay at the circulation desk" note
- **Overdue Fine Badges:** Red "Overdue Fine: ₱XX.XX" badge with "Overdue X days · Fine: ₱XX.XX" per book
- **Due Soon Warnings:** Amber "Due soon — return within X days to avoid fines" for books 1-3 days from due
- **Color-coded accent borders:** Red gradient for overdue, amber for due-soon, purple for normal
- **Success animation:** Confetti particles + green checkmark overlay on successful book return (2s display)
- **Active book cards:** Cover image, title, author, borrow/due dates, gradient left border, days-left badge (color-coded), Return button
- **History book cards:** "Returned on [date]" badge with checkmark, View button
- **Empty state** with "Browse Catalog" CTA

**Actions:** Return book → marks as returned + increments available copies + shows celebration animation.

**Flutter Implementation:**
- Tabs: `DefaultTabController` + `TabBar` + `TabBarView`
- Accent borders: `Container(decoration: BoxDecoration(border: Border(left: BorderSide(color: ...)))` 
- Confetti: `confetti` package

---

### 2.7 Profile

**Screen:** `profile_screen.dart` | **State:** Riverpod auth + user providers

User profile, statistics, reading goals, and menu:

- **Purple gradient header** with avatar initials, name, email, role badge, program/year, university ID
- **Stats cards (3 columns):** Borrowed count, Visits count, Streak count
- **Reading Goal card:** Circular SVG progress ring, goal/borrowed count, "Change" button with goal picker (12/24/36/48)
- **Reading Stats card:** Mini bar chart (7 months), total books, average per month
- **Attendance History card** with visit count and navigation link
- **Member Since** info card
- **Menu items:** Edit Profile (→ Edit Profile screen), My Favorites, My Reservations

**Reading Goal Picker:** Toggle overlay to select from 12/24/36/48 annual goal.

**Bar Chart:** Animated height growth (0.4s per bar, staggered 0.05s).

**Flutter Implementation:**
- Stats grid: `Row(children: [Expanded, Expanded, Expanded])`
- Progress ring: `CustomPainter` with `AnimationController`
- Bar chart: `fl_chart` package or custom `BarChartPainter`

---

### 2.8 QR Scanner

**Screen:** `qr_scan_screen.dart` | **State:** Riverpod attendance provider

Simulated QR code scanner for attendance and book checkout:

- **Dark background** (`Color(0xFF0d0d1a)`)
- **Mode indicator badge:** Attendance / Checkout
- **Viewfinder:** 256×256 box with animated scan line, corner brackets (outer + inner accents), center Scan icon with pulse
- **Mode buttons:** "Attendance Check-in" / "Book Checkout"
- **Flash toggle** (torch on/off, visual only)
- **Success modal:** Green checkmark with spring animations, success message, timestamp, "Scan Again" / "Done" buttons

**Simulation:** Auto-simulated scan (2s wait → 3s scanning → success).

**Flutter Implementation:**
- Camera integration: `camera` package (for real scanning) or simulation with `AnimationController`
- QR scanning: `mobile_scanner` package
- Success modal: `showModalBottomSheet` or `Dialog`

---

### 2.9 Attendance

**Screen:** `attendance_screen.dart` | **State:** Riverpod attendance provider

Library attendance tracking with calendar heatmap:

- **Summary cards (3):** Total Visits, Total Hours, Day Streak
- **Calendar heat map:** Month/year label, 7-column grid (Sun–Sat), attended days highlighted purple, today with ring indicator, legend
- **Recent Visits list:** Date, time-in → time-out, duration badge

**Fallback:** 11 mock records if API returns empty.

**Flutter Implementation:**
- Calendar grid: Custom `GridView.builder` or `table_calendar` package
- Heat map: Custom `Container` widgets with color based on attendance
- Visit list: `ListView.builder`

---

### 2.10 Notifications

**Screen:** `notifications_screen.dart` | **State:** Riverpod notification provider

View and manage notifications:

- **"Mark all read" button**
- **Filter tabs:** All, Unread (with count badge), Mentions (reservation type)
- **Grouped notifications:** Today, Yesterday, This Week, Earlier — with group headers and counts
- **Notification cards:** Type-colored left border + icon (orange=due_date, purple=reservation, blue=announcement), title, message, relative time, unread dot
- **Empty state**

**Gesture:** Swipe-to-dismiss (drag x > 100px threshold dismisses, spring snap-back if under).

**Flutter Implementation:**
- Tabs: `DefaultTabController` + `TabBar`
- Swipe-to-dismiss: `Dismissible` widget
- Grouped list: `ListView` with section headers

---

### 2.11 Reservations

**Screen:** `reservations_screen.dart` | **State:** Riverpod reservation provider

Manage book reservations:

- **Active count** + bookmark icon
- **Filter tabs:** All, Pending (with count), Fulfilled
- **Reservation cards:** Cover image, title, author, status badge (Pending=yellow, Fulfilled=green, Cancelled=red), date
  - Pending: "Cancel" button
  - Fulfilled: "Borrow Now" button
- **Empty state** with "Browse Catalog" CTA

**Actions:** Cancel reservation (soft-cancel → status changed to "cancelled").

**Flutter Implementation:**
- Tabs: `DefaultTabController`
- Reservation cards: Custom `Card` widget
- Actions: `ElevatedButton` or `TextButton`

---

### 2.12 Favorites

**Screen:** `favorites_screen.dart` | **State:** Riverpod auth + resources provider

View and manage favorite/saved books:

- **Count** + heart icon
- **Book cards:** Cover image, title, author, category badge, availability, trash/remove button
- **Empty state** with heart icon + "Browse Catalog" CTA

**Actions:** Remove from favorites with exit animation (slide-left + collapse).

**Flutter Implementation:**
- Book grid/cards: `GridView` or `ListView`
- Remove animation: `AnimatedList` or `Dismissible`

---

### 2.13 Settings

**Screen:** `settings_screen.dart` | **State:** Riverpod auth + theme providers

App settings and account management:

1. **Account:** Avatar + name/email, "Change Password" button, Email with "Verified" badge
2. **Notifications:** Due Date Reminders switch, Reservation Alerts switch, System Announcements switch — each toggle persists to API
3. **Appearance:** Dark Mode toggle (via provider/Riverpod)
4. **Help:** "How to use CCC's Library Logbook MS" with "Open Help guide →" link
5. **About:** App Version (1.0.0), Privacy Policy, Terms of Service
6. **Log Out** button (red)

**Password Change Modal (bottom sheet):**
- Current password + show/hide
- New password + show/hide + strength meter
- Confirm new password + match validation
- Error display
- Cancel / Change Password buttons

**Flutter Implementation:**
- Settings list: `ListView` with `SwitchListTile`, `ListTile`
- Password modal: `showModalBottomSheet`
- Dark mode: `Switch` connected to `Riverpod` theme provider

---

### 2.14 Edit Profile

**Screen:** `edit_profile_screen.dart` | **State:** Riverpod auth provider

Update user profile information:

- **Purple gradient header** with back button, title, avatar with camera icon overlay
- **Form fields:**
  - Full Name (editable)
  - Email (disabled — "Email cannot be changed")
  - University ID (disabled — "University ID cannot be changed")
  - Program/Department dropdown (10 programs for students, 8 departments for faculty)
  - Year Level selector (5 options for students only)
- **Save button** — calls API, updates Riverpod store, navigates back with success toast
- **Cancel button** — navigates back without saving
- **Loading state** on save button

**Flutter Implementation:**
- Form: `Form` + `TextFormField` + `DropdownButtonFormField`
- Disabled fields: `TextFormField(enabled: false)`
- Save: `ElevatedButton(onPressed: () => authProvider.updateProfile(...))`

---

## 3. API Endpoints

### Authentication

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/api/auth/login` | Login with email + password. Returns user object (SHA-256 hash verification). |
| POST | `/api/auth/register` | Register new user. Validates required fields, checks email + universityId uniqueness, hashes password, generates avatar initials. |
| PUT | `/api/auth/update` | Update user profile (fullName, program, department, yearLevel), notification preferences, or change password (verifies current password before allowing change). |

### Resources (Catalog)

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/resources` | List/search resources. Query params: `category`, `subject`, `search` (OR across title/author/tags/subject), `page`, `limit`. Returns resources + pagination. |
| GET | `/api/resources/[id]` | Get single resource with related borrow records (active/overdue, last 5) and reservations (pending, last 5). |

### Borrowing

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/borrow` | List borrow records. Query params: `userId` (required), `status` (active/returned/overdue). Returns records with resource details. |
| POST | `/api/borrow` | Borrow a book. Validates availability, checks role-based max borrow limit (student:3, faculty:10, visitor:1), calculates role-based due date (student:14d, faculty:30d, visitor:7d). Transaction: create record + decrement available copies. |
| POST | `/api/borrow/[id]/return` | Return a book. Checks not already returned, calculates late status. Transaction: update record + increment available copies. |

### Reservations

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/reservations` | List reservations. Query param: `userId` (required). Returns reservations with resource details. |
| POST | `/api/reservations` | Create reservation. Validates user + resource, checks no existing pending reservation for same user+resource. |
| DELETE | `/api/reservations/[id]` | Cancel reservation (soft-cancel: sets status to "cancelled" rather than deleting). |

### Notifications

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/notifications` | List notifications. Query param: `userId` (required). Returns notifications + unread count. |
| PUT | `/api/notifications/[id]/read` | Mark a notification as read. |

### Attendance

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/attendance` | List attendance records. Query params: `userId`, `date` (YYYY-MM-DD). Returns records with user info. |
| POST | `/api/attendance` | Record attendance. `type: "time-in"` checks no existing open record today, creates new. `type: "time-out"` finds today's open record, calculates duration, sets timeOut. |

### Library Settings & Announcements

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/settings` | Get library settings (hours, borrow limits, QR validity). Creates defaults if none exist. |
| PUT | `/api/settings` | Update library settings. |
| GET | `/api/announcements` | List active announcements. Ordered by newest first. |

### Reviews

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/reviews` | Get reviews for a resource. Query param: `resourceId` (required). Returns reviews with user info + stats (averageRating, totalReviews, distribution). |
| POST | `/api/reviews` | Create or update a review. Body: `{ userId, resourceId, rating (1-5), comment? }`. Upserts (one review per user per resource). |
| DELETE | `/api/reviews/[id]` | Delete a review. |

### Health Check

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/` | Returns `{ message: "Hello, world!" }` for health check. |

---

## 4. Database Models

### User

| Field | Type | Notes |
|-------|------|-------|
| id | String @id | cuid() auto-generated |
| email | String @unique | Login identifier |
| password | String | SHA-256 hashed |
| fullName | String | Display name |
| universityId | String @unique | Student/faculty/visitor ID |
| role | String | student / faculty / visitor / librarian |
| program | String? | Academic program |
| department | String? | Department (faculty) |
| yearLevel | String? | Year level (students) |
| avatarInitials | String? | Auto-generated from name |
| notificationDueDate | Boolean | Default: true |
| notificationReservation | Boolean | Default: true |
| notificationAnnouncements | Boolean | Default: false |
| streakCount | Int | Default: 0 |
| streakLastDate | String? | Last streak date |
| isOnboarded | Boolean | Default: false |
| createdAt | DateTime | Auto |
| updatedAt | DateTime | Auto |

**Relations:** borrowedBooks (BorrowRecord[]), attendance (Attendance[]), reservations (Reservation[]), notifications (Notification[]), reviews (Review[])

### Resource

| Field | Type | Notes |
|-------|------|-------|
| id | String @id | cuid() |
| title | String | Book/resource title |
| author | String | Author name |
| isbn | String? | ISBN identifier |
| issn | String? | ISSN identifier |
| category | String | book / research / magazine |
| copies | Int | Total copies (default: 1) |
| availableCopies | Int | Currently available (default: 1) |
| shelfLocation | String? | Physical location |
| abstract | String? | Description/abstract |
| publicationDate | String? | Publication date |
| coverImage | String? | Cover image URL/path |
| subject | String? | Academic subject |
| tags | String? | Comma-separated tags |
| status | String | available / borrowed / reserved / reference-only / maintenance |
| createdAt | DateTime | Auto |
| updatedAt | DateTime | Auto |

**Relations:** borrowRecords (BorrowRecord[]), reservations (Reservation[]), reviews (Review[])

### BorrowRecord

| Field | Type | Notes |
|-------|------|-------|
| id | String @id | cuid() |
| userId | String | FK → User |
| resourceId | String | FK → Resource |
| borrowDate | DateTime | When borrowed |
| dueDate | DateTime | Calculated from role |
| returnDate | DateTime? | When returned (null if active) |
| status | String | active / returned / overdue |
| isLate | Boolean | Default: false |
| createdAt | DateTime | Auto |
| updatedAt | DateTime | Auto |

**Relations:** user (User), resource (Resource)

### Attendance

| Field | Type | Notes |
|-------|------|-------|
| id | String @id | cuid() |
| userId | String | FK → User |
| date | String | YYYY-MM-DD |
| timeIn | DateTime? | Check-in time |
| timeOut | DateTime? | Check-out time |
| duration | Int? | Total minutes |
| createdAt | DateTime | Auto |
| updatedAt | DateTime | Auto |

**Relations:** user (User)

### Reservation

| Field | Type | Notes |
|-------|------|-------|
| id | String @id | cuid() |
| userId | String | FK → User |
| resourceId | String | FK → Resource |
| status | String | pending / fulfilled / cancelled |
| createdAt | DateTime | Auto |
| updatedAt | DateTime | Auto |

**Relations:** user (User), resource (Resource)

### Notification

| Field | Type | Notes |
|-------|------|-------|
| id | String @id | cuid() |
| userId | String | FK → User |
| type | String | due_date / reservation / announcement / inquiry |
| title | String | Notification title |
| message | String | Notification body |
| isRead | Boolean | Default: false |
| createdAt | DateTime | Auto |

**Relations:** user (User)

### LibrarySettings

| Field | Type | Default | Notes |
|-------|------|---------|-------|
| id | String @id | cuid() | |
| isOpen | Boolean | true | Library open status |
| closingTime | String | "21:00" | Closing time |
| openingTime | String | "07:00" | Opening time |
| maxBorrowStudent | Int | 3 | Max concurrent borrows for students |
| maxBorrowFaculty | Int | 10 | Max concurrent borrows for faculty |
| maxBorrowVisitor | Int | 1 | Max concurrent borrows for visitors |
| borrowDaysStudent | Int | 14 | Borrow period for students |
| borrowDaysFaculty | Int | 30 | Borrow period for faculty |
| borrowDaysVisitor | Int | 7 | Borrow period for visitors |
| qrValidityMinutes | Int | 15 | QR code validity window |
| updatedAt | DateTime | Auto | |

### Announcement

| Field | Type | Notes |
|-------|------|-------|
| id | String @id | cuid() |
| title | String | Announcement title |
| message | String | Announcement body |
| targetRoles | String | all / student / faculty / visitor |
| isActive | Boolean | Default: true |
| createdAt | DateTime | Auto |
| updatedAt | DateTime | Auto |

### Review

| Field | Type | Notes |
|-------|------|-------|
| id | String @id | cuid() |
| userId | String | FK → User |
| resourceId | String | FK → Resource |
| rating | Int | 1–5 stars |
| comment | String? | Optional review text |
| createdAt | DateTime | Auto |
| updatedAt | DateTime | Auto |

**Relations:** user (User), resource (Resource)
**Unique constraint:** `@@unique([userId, resourceId])` — one review per user per resource

---

## 5. State Management

**Store:** Riverpod with `shared_preferences` persistence

### Persisted State

Only the following fields are persisted to shared_preferences. The store does **NOT** persist `currentScreen` or `isAuthenticated` — the app always starts at the login screen on open.

| Variable | Type | Default | Persisted | Description |
|----------|------|---------|-----------|-------------|
| currentScreen | AppScreen | `'onboarding'` | ❌ No | Current active screen (always resets to `login` on app open) |
| previousScreen | AppScreen? | `null` | ❌ No | For goBack() navigation |
| isAuthenticated | bool | `false` | ❌ No | Login status (always resets to `false` on app open) |
| user | UserState? | `null` | ✅ Yes | Full user data |
| onboardingStep | int | `0` | ✅ Yes | Current onboarding step (0–4) |
| onboardingData | object | *(defaults)* | ✅ Yes | Registration form data accumulator |
| selectedBookId | String? | `null` | ❌ No | Book for detail view |
| searchQuery | String | `''` | ❌ No | Active search text |
| searchCategory | String | `'all'` | ❌ No | Active category filter |
| unreadCount | int | `3` | ❌ No | Unread notification count |
| favorites | List<String> | `[]` | ✅ Yes | Favorited resource IDs |

### Rehydration Behavior

On app open, always reset:
- `isAuthenticated` → `false`
- `currentScreen` → `'login'`

This ensures users always start at the login screen, even if they closed the app while authenticated.

### Riverpod Providers

| Provider | Type | Description |
|----------|------|-------------|
| `authProvider` | `StateNotifierProvider` | User auth state + login/logout actions |
| `resourcesProvider` | `FutureProvider` | Catalog data |
| `borrowProvider` | `StateNotifierProvider` | Borrow records state |
| `reservationProvider` | `StateNotifierProvider` | Reservations state |
| `notificationProvider` | `StateNotifierProvider` | Notifications state |
| `attendanceProvider` | `StateNotifierProvider` | Attendance records |
| `reviewProvider` | `FutureProvider` | Reviews for a resource |
| `themeProvider` | `StateProvider<ThemeMode>` | Light/dark/system theme |

### AppScreen Enum

```dart
enum AppScreen {
  onboarding,
  home,
  search,
  qrScan,
  borrowed,
  profile,
  settings,
  notifications,
  bookDetail,
  login,
  attendance,
  favorites,
  reservations,
  editProfile,
}
```

---

## 6. Authentication & Security

- **Password Hashing:** SHA-256 via Web Crypto API (backend)
- **Session:** Client-side only (Riverpod + shared_preferences) — no server sessions
- **Auth Guard:** Unauthenticated users can only see login/onboarding screens
- **Persistence:** `currentScreen` and `isAuthenticated` are NOT persisted — app always starts at login on open
- **Role-Based Access Control:**
  - **Student:** Max 3 concurrent borrows, 14-day loan period
  - **Faculty:** Max 10 concurrent borrows, 30-day loan period
  - **Visitor:** Max 1 concurrent borrow, 7-day loan period
- **Password Strength Meter:** Checks length, uppercase, numbers, special characters (4 levels: Weak/Fair/Good/Strong)
- **Registration Validation:** Email uniqueness, university ID uniqueness, required fields per step

---

## 7. Theme & Design System

### Background Colors

| Mode | Color | Description |
|------|-------|-------------|
| Light | `#f2f2fa` | Lavender-tinted gray (subtle purple warmth) |
| Dark | `#110a1e` | Dark purple (~`#110a1e` area) |

### Shadow System

| Element | Light Mode | Dark Mode |
|---------|-----------|-----------|
| Cards (all screens) | **No shadow** | `BoxShadow` (subtle) |
| Buttons | **No shadow** | `BoxShadow` (varies) |
| Images | **No shadow** | `BoxShadow` (varies) |
| Modals | **No shadow** | `BoxShadow` (stronger) |
| BottomNav | `BoxShadow` | `BoxShadow` (both modes) |
| QR Scan center button | `BoxShadow` | `BoxShadow` (both modes) |
| Mobile container | **No shadow** | `BoxShadow` (dark only) |

### Brand Colors

| Shade | Hex |
|-------|-----|
| 50 | #F5EDF9 |
| 100 | #E8D5F3 |
| 200 | #D4ADE7 |
| 300 | #B87DD4 |
| 400 | #9B5BBF |
| **500 (Primary)** | **#652D90** |
| 600 | #5A2880 |
| 700 | #4A2068 |
| 800 | #3A1850 |
| 900 | #2A1038 |
| Light | #7B3FA8 |
| Dark | #522575 |

### Card Corner Radius

| Element | Radius | Flutter Implementation |
|---------|--------|------------------------|
| Section cards (all screens) | 24px | `BorderRadius.circular(24)` |
| Inner card elements | 16px | `BorderRadius.circular(16)` |
| Small icon containers | 22px | `BorderRadius.circular(22)` |
| Streak pill | Full | `BorderRadius.circular(9999)` |

### Dark Mode (Dark Purple Theme)

- **Class-based toggle** via `provider` or `Riverpod`
- **Overall background:** `#110a1e` (dark purple close to black)
- **Card backgrounds:** `Color(0xFF1a0e2e)` with dark purple
- **Transparency system** (replaces all dark surface patterns):
  - `Colors.white.withOpacity(0.05)` — subtle background
  - `Colors.white.withOpacity(0.10)` — medium background / icon containers
  - `Colors.white.withOpacity(0.15)` — emphasized background
- **Toggle available** in Settings screen

---

## 8. Animations & Micro-Interactions

### Screen-Level Animations

- **Screen transitions:** `PageRouteBuilder` with fade + slide (200ms)
- **Onboarding step transitions:** Directional slide (left/right, 300ms)
- **Tab content switching:** `AnimatedSwitcher`

### Component Animations

- **Staggered entry:** Cards, menu items, stats with configurable delays
- **Spring animations:** Logo entrance, checkmarks, success modal elements
- **Pull-to-refresh:** `RefreshIndicator`
- **Swipe-to-dismiss:** `Dismissible` widget
- **Confetti:** `confetti` package (20 particles on onboarding final step, 18 particles on book return success)

### Keyframe Animations

`shimmer` · `floating` · `pulse-glow` · `slide-in` · `fade-in` · `particle-float` · `gradient-shift` · `subtle-bounce` · `micro-pulse-glow` · `confetti-fall` · `checkmark-draw` · `float-icon` · `count-up` · `badge-shimmer` · `shimmer-sweep` · `star-fill` · `progress-fill` · `skeleton-shimmer` · `badge-pulse` · `countdown-ring` · `slide-indicator` · `page-enter` · `page-exit`

---

## 9. Navigation & Layout

### Root Layout

- **ThemeData:** Light/dark theme with purple brand colors
- **ThemeProvider:** `provider` or `Riverpod` for theme mode
- **Viewport:** 430px max-width container, centered

### Mobile Container

- Max-width 430px, centered with conditional shadow (dark mode only)
- Full viewport height: `MediaQuery.of(context).size.height`
- Screen routing via Riverpod `currentScreen` → widget map
- Auth guard: unauthenticated → login/onboarding only
- BottomNav visible for authenticated users (hidden on onboarding/login/qr-scan)
- Bottom nav uses `BottomNavigationBar` with `BottomNavigationBarType.fixed`

### Bottom Navigation (5 Tabs)

| Tab | Icon | Screen | Special |
|-----|------|--------|---------|
| Home | `Icons.home` | home | — |
| Search | `Icons.search` | search | — |
| Scan | `Icons.qr_code_scanner` | qr-scan | Center elevated button, purple circle, shadow in both modes |
| Borrowed | `Icons.book` | borrowed | Active borrows count badge |
| Profile | `Icons.person` | profile | — |

- **Active state:** Purple icon + font semibold + animated dot indicator with bounce animation
- **Spring press feedback:** Scale animation on tab press
- **Scan button ripple:** Ripple effect on tap

---

## 10. Utility Libraries

### `lib/utils/auth.dart`

- `hashPassword(password)` — SHA-256 hash (backend only in Flutter version)
- `verifyPassword(password, hashedPassword)` — Compare hash (backend)
- `getAvatarInitials(fullName)` — First letter of first + last name
- `getBorrowDays(role, settings)` — Role→days mapping
- `getMaxBorrow(role, settings)` — Role→max books mapping

### `lib/utils/covers.dart`

- `coverMap` — Maps title keywords to asset image paths:
  - `introduction-to-algorithms`, `clean-code`, `design-patterns`, `artificial-intelligence`, `ai-modern-approach`, `deep-learning`, `the-pragmatic-programmer`, `pragmatic-programmer` (alias), `database-systems`, `psychology`, `nursing`, `scientific-american`
- `getBookCover(title)` — Fuzzy-match title to cover image path
- `getResourceCover(coverImage, title)` — Priority: API coverImage > generated from title > null

### `lib/services/api_service.dart`

- Dio HTTP client singleton
- Base options (baseUrl, timeouts)
- Interceptors for auth token, logging

### `lib/utils/helpers.dart`

- `cn(...inputs)` — Style merge utility (equivalent to clsx + twMerge)
- Date formatting helpers
- Validators (email, password strength)

---

## 11. Seed / Test Data

### Test Accounts (password: `password123`)

| Role | Name | Email | University ID | Extra |
|------|-------|-------|---------------|-------|
| Student | Juan Dela Cruz | juan@university.edu | CS-2024-0001 | CS program, 3rd Year, streak=5 |
| Faculty | Maria Santos | maria@university.edu | FAC-2024-0001 | CS Department, streak=12 |
| Visitor | Alex Reyes | alex@university.edu | VIS-2024-0001 | — |

### Resources (17 total)

- **10 Books:** Introduction to Algorithms, Clean Code, Design Patterns, Deep Learning, The Pragmatic Programmer, Database System Concepts, Operating System Concepts, Computer Networks, AI: A Modern Approach, Computer Architecture
- **4 Research:** ML: Probabilistic Perspective, Journal of CS Vol. 42, NeurIPS 2025, ACM Computing Surveys
- **3 Magazines:** National Geographic Mar 2026, Time Magazine Spring 2026, Scientific American Apr 2026

### Other Seed Data

- **Borrow Records (5):** 2 active + 1 overdue (student), 2 returned (1 late, 1 on time)
- **Notifications (6):** Due soon, overdue, reservation ready, library hours, reservation confirmed, return reminder
- **Announcements (2):** Extended hours for finals, New AI/ML arrivals
- **Reservations (1):** Student → Clean Code (pending)
- **Attendance (2):** Today (time-in only), Yesterday (7 hours)
- **Reviews (10):** Across 6 resources with ratings 2-5 and realistic comments
- **AI-Generated Book Covers (10):** Saved in `assets/images/covers/` directory
- **Cover Images in Seed Data (6):** `coverImage` field populated for 6 most popular books

---

## 12. Technology Stack

| Category | Technology |
|----------|-----------|
| Framework | Flutter 3.x |
| Language | Dart 3.x |
| Styling | Flutter ThemeData + custom widgets |
| UI Components | Custom widgets + Material Components |
| Icons | Material Icons / Cupertino Icons |
| Database | SQLite via Prisma ORM (Backend) |
| State Management | Riverpod (flutter_riverpod) 2.x |
| Animations | Flutter Animations + flutter_animate |
| Theming | provider / Riverpod |
| Forms | flutter_form_builder + validators |
| Charts | fl_chart |
| HTTP Client | dio |
| Persistence | shared_preferences + flutter_secure_storage |
| Auth | Backend API (SHA-256) |
| Image Loading | cached_network_image |
| Fonts | google_fonts |
| QR Scanning | mobile_scanner (future) |
| Camera | camera (future) |
| Share | share_plus |

---

## 13. Branding & Design System Guide

A comprehensive branding guide is maintained in **`/FLUTTER_BRANDING.md`** covering:

| Section | Contents |
|---------|----------|
| **Typography** | Inter/System fonts with H1–H6 scale, button text specs, font weight rules |
| **Color System** | Full purple palette (#652D90 + 10 shades), semantic tokens, neutral grays, contrast requirements |
| **Corner Rounding** | 9-level radius scale (0–9999px) with element-to-radius mapping for every UI component |
| **Spacing System** | 4px base unit, 14-step scale, layout spacing patterns, internal spacing rules |
| **Elevation & Shadows** | 7-level shadow hierarchy, brand-tinted purple shadows, elevation rules |
| **Gradients** | 5 brand gradients (light + dark variants), gradient usage rules |
| **Iconography** | Material Icons library, 6 icon sizes, 4 container sizes, color rules |
| **Motion & Animation** | 5 speed tiers, standard transitions, micro-interactions, animation rules |
| **Layout & Grid** | 430px container, grid patterns, safe areas |
| **Touch Targets** | Apple HIG minimums (44px), accessibility requirements (WCAG AA) |
| **Dark Mode** | 4-level surface hierarchy, color adaptation rules, element-specific treatments |
| **Components** | Button variants (7), card types (4), input specs, bottom nav specs |
| **Status Colors** | Success/Warning/Error/Info (light + dark), chart palette |
| **Imagery** | Book cover specs, avatar sizes, image treatment rules |
| **Writing & Tone** | Voice guidelines, copy length limits, number formatting |
| **Implementation** | Flutter color constants, BoxDecoration examples, quick reference class mapping |

---

## Changelog

| Date | Change |
|------|--------|
| 2026-05-09 | **Flutter Pivot:** Translated all features from Next.js/React to Flutter/Dart equivalents. State management changed from Zustand to Riverpod. Navigation changed from Zustand state to Riverpod + widget mapping. All animations mapped to Flutter equivalents (PageRouteBuilder, AnimatedSwitcher, etc.). API layer unchanged (backend agnostic). Database layer unchanged. Technology stack updated to Flutter/Dart. Project structure reflects Flutter conventions. |
| 2026-03-05 | Original Next.js version created |
| 2026-04-22 | Added Reviews/Ratings feature, Edit Profile screen, overdue fines, AI-generated book covers, dark mode, micro-interactions |
| 2026-03-06 | Home screen redesign, shadow system overhaul, background change to lavender-tinted, card corner radius standardization, dark purple theme |

---

> **This document is the single source of truth for all LibLog features in Flutter/Dart.** For design system rules, see FLUTTER_BRANDING.md. For system overview, see FLUTTER_OVERVIEW.md.

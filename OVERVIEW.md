# LibLog — System Overview (Flutter/Dart)

> **Version:** 1.2 (Flutter Pivot)  
> **Last Updated:** 2026-05-09  
> **Platform:** Mobile-first Flutter Application (max-width 430px equivalent)  
> **Framework:** Flutter + Dart 3.x

---

## Table of Contents

1. [What is LibLog?](#1-what-is-liblog)
2. [System Architecture](#2-system-architecture)
3. [Core Capabilities](#3-core-capabilities)
4. [User Roles & Permissions](#4-user-roles--permissions)
5. [Screen Map & Navigation Flow](#5-screen-map--navigation-flow)
6. [Data Layer](#6-data-layer)
7. [API Layer](#7-api-layer)
8. [State Management](#8-state-management)
9. [Design System Summary](#9-design-system-summary)
10. [Current Design Principles](#10-current-design-principles)
11. [Technology Stack](#11-technology-stack)
12. [Project Structure](#12-project-structure)
13. [Test Accounts & Seed Data](#13-test-accounts--seed-data)
14. [Known Limitations & Future Roadmap](#14-known-limitations--future-roadmap)

---

## 1. What is LibLog?

LibLog is a **Digital Library Logbook Management System** built for university libraries. It provides a phone-sized, app-like experience that enables students, faculty, and visitors to:

- **Browse** the library catalog and search for books, research papers, and magazines
- **Borrow and return** resources with role-based limits and overdue fine tracking
- **Track attendance** via QR code scanning with calendar heat map visualization
- **Manage reservations** for unavailable resources with status tracking
- **Receive notifications** for due dates, reservations, and announcements
- **Rate and review** resources with a 5-star rating system
- **Customize preferences** including dark mode, notification settings, and reading goals
- **View library announcements** with auto-rotating carousel

The system is designed as a native Flutter mobile application, using a 430px-equivalent max-width container with a sticky bottom navigation bar, smooth Flutter animations, and a carefully crafted purple-themed design system.

---

## 2. System Architecture

```
┌─────────────────────────────────────────────────────────┐
│                    Mobile Device                          │
│  ┌───────────────────────────────────────────────────┐  │
│  │              Flutter App (430px container)         │  │
│  │                                                    │  │
│  │  ┌─────────────┐  ┌────────────┐  ┌──────────┐ │  │
│  │  │   Screens    │  │  Riverpod  │  │  Flutter  │ │  │
│  │  │  (14 total)  │  │    Store    │  │  Motion  │ │  │
│  │  │              │  │ (persist)  │  │ (animate)│ │  │
│  │  └──────┬───────┘  └─────┬──────┘  └──────────┘ │  │
│  │         │                │                         │  │
│  │         └───────┬────────┘                         │  │
│  │                 │ http/REST                        │  │
│  └─────────────────┼──────────────────────────────────┘  │
│                    │                                     │
│  ┌─────────────────▼──────────────────────────────────┐  │
│  │          Backend API (17 endpoints)                 │  │
│  │  Same REST API as before                           │  │
│  └─────────────────┬──────────────────────────────────┘  │
│                    │                                     │
│  ┌─────────────────▼──────────────────────────────────┐  │
│  │              Prisma ORM (SQLite)                    │  │
│  │         9 Models / 5 Relations                      │  │
│  └────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────┘
```

### Architecture Decisions

| Decision | Rationale |
|----------|-----------|
| **Flutter state-driven navigation** | Screen navigation is managed by Riverpod state (not named routes) for a native mobile app feel |
| **SQLite database** | Lightweight, file-based, zero-config — ideal for a library management system at a single university |
| **Client-side session** | No server sessions; Riverpod + shared_preferences for auth state. App always starts at login on open |
| **REST API** | Same backend API, Flutter uses `http` or `dio` package for communication |
| **Class-based dark mode** | `provider` or `Riverpod` with theme mode toggling for instant theme switching |
| **Riverpod over Provider** | More flexible, built-in persistence, compile-safe providers |

---

## 3. Core Capabilities

### 3.1 Authentication & Onboarding

- **5-step registration wizard**: Role selection → Personal info → Academic info → Account setup → Notification preferences
- **Login**: Email + password (SHA-256 hashed), demo account quick-fill button
- **Session**: Client-side only. `currentScreen` and `isAuthenticated` are NOT persisted — users always start at the login screen on app open
- **Password management**: Change password modal with strength meter, show/hide toggles, and match validation

### 3.2 Resource Catalog

- **17 seeded resources**: 10 books, 4 research papers, 3 magazines
- **Search**: Real-time with 300ms debounce, category filters (All/Book/Research/Magazine), popular search tags
- **Book detail**: Full metadata, availability status, ratings & reviews, borrow/reserve actions, share functionality, favorite toggle
- **AI-generated covers**: 10 book covers in assets with fuzzy title matching via `covers.dart`

### 3.3 Borrowing System

- **Role-based limits**: Students (3 books, 14 days), Faculty (10 books, 30 days), Visitors (1 book, 7 days)
- **Overdue fine tracking**: ₱5.00/day fine rate, per-book fine calculation, total fines summary card, due-soon warnings (1-3 days)
- **Return flow**: One-click return with confetti celebration animation, automatic available copy increment
- **Active/History tabs**: Separate views with color-coded accent borders (red=overdue, amber=due soon, purple=normal)

### 3.4 Attendance Tracking

- **QR code scanning**: Simulated scanner with Attendance Check-in and Book Checkout modes
- **Time-in/Time-out**: API calculates duration automatically
- **Calendar heat map**: Monthly grid with purple-highlighted attended days, today indicator, visit counts
- **Summary statistics**: Total visits, total hours, current day streak

### 3.5 Reservations

- **Create**: Reserve unavailable resources with one-click
- **Status tracking**: Pending → Fulfilled → Cancelled lifecycle
- **Filter tabs**: All / Pending (with count) / Fulfilled
- **Actions**: Cancel pending reservations, borrow fulfilled ones

### 3.6 Notifications

- **Three types**: Due date reminders (orange), reservation alerts (purple), announcements (blue)
- **Filter tabs**: All / Unread (with count) / Mentions
- **Swipe-to-dismiss**: Drag threshold >100px, spring snap-back if under
- **Grouped display**: Today / Yesterday / This Week / Earlier

### 3.7 Reviews & Ratings

- **5-star rating system**: Tap to select, with distribution chart (5★→1★)
- **Write/Edit reviews**: Inline form with star selector, comment (200 char max), upsert logic (one review per user per resource)
- **Delete own reviews**: Trash button with loading state
- **Review cards**: Avatar initials, name, role badge (color-coded), date, comment

### 3.8 User Profile

- **Reading goals**: Circular SVG progress ring with adjustable targets (12/24/36/48 books/year)
- **Reading stats**: 7-month mini bar chart with animated height growth
- **Favorites system**: Heart toggle on books, dedicated favorites screen with list view and remove functionality
- **Edit profile**: Change name, program, department, year level (email and university ID are locked)

---

## 4. User Roles & Permissions

| Capability | Student | Faculty | Visitor |
|-----------|---------|---------|---------|
| Browse catalog | ✅ | ✅ | ✅ |
| Search resources | ✅ | ✅ | ✅ |
| Borrow books | ✅ (max 3) | ✅ (max 10) | ✅ (max 1) |
| Loan duration | 14 days | 30 days | 7 days |
| Reserve books | ✅ | ✅ | ✅ |
| QR attendance | ✅ | ✅ | ✅ |
| Write reviews | ✅ | ✅ | ✅ |
| Receive notifications | ✅ | ✅ | ✅ |
| Access onboarding | ✅ | ✅ | ✅ |

> **Note:** A `librarian` role exists in the database schema but is not currently used in the UI.

---

## 5. Screen Map & Navigation Flow

### Screen Inventory (14 screens)

```
┌─ Unauthenticated ──────────────────────────────┐
│                                                 │
│  OnboardingScreen ──── LoginScreen              │
│  (5-step wizard)      (email + password)        │
│                                                 │
└──────────────────┬──────────────────────────────┘
                   │ login success
                   ▼
┌─ Authenticated (Bottom Nav) ───────────────────┐
│                                                 │
│  ┌─ Tab: Home ──────────────────────────────┐   │
│  │  HomeScreen (Dashboard)                  │   │
│  │  ├→ NotificationsScreen (bell icon)      │   │
│  │  └→ SettingsScreen (gear icon)           │   │
│  └──────────────────────────────────────────┘   │
│                                                 │
│  ┌─ Tab: Search ────────────────────────────┐   │
│  │  SearchScreen                            │   │
│  │  └→ BookDetailScreen (tap result)        │   │
│  └──────────────────────────────────────────┘   │
│                                                 │
│  ┌─ Tab: Scan ──────────────────────────────┐   │
│  │  QRScanScreen (elevated center button)   │   │
│  └──────────────────────────────────────────┘   │
│                                                 │
│  ┌─ Tab: Borrowed ──────────────────────────┐   │
│  │  BorrowedScreen (Active/History tabs)    │   │
│  │  └→ BookDetailScreen (tap book)          │   │
│  └──────────────────────────────────────────┘   │
│                                                 │
│  ┌─ Tab: Profile ───────────────────────────┐   │
│  │  ProfileScreen                           │   │
│  │  ├→ SettingsScreen                       │   │
│  │  ├→ EditProfileScreen                    │   │
│  │  ├→ FavoritesScreen                      │   │
│  │  ├→ ReservationsScreen                   │   │
│  │  └→ AttendanceScreen                     │   │
│  └──────────────────────────────────────────┘   │
│                                                 │
│  BookDetailScreen (accessible from Search,      │
│  Borrowed, Favorites, Reservations)             │
│  └→ has Borrow / Reserve / Favorite / Share     │
│                                                 │
└─────────────────────────────────────────────────┘
```

### Bottom Navigation (5 tabs)

| Position | Tab | Icon | Screen | Special |
|----------|-----|------|--------|---------|
| 1 | Home | `Icons.home` | home | — |
| 2 | Search | `Icons.search` | search | — |
| 3 | **Scan** | `Icons.qr_code_scanner` | qr-scan | Elevated center button (-mt-6), purple gradient circle |
| 4 | Borrowed | `Icons.book` | borrowed | Active borrows count badge |
| 5 | Profile | `Icons.person` | profile | — |

**Nav behavior:**
- Hidden on: `onboarding`, `login`, `qr-scan`
- Auto-hides on scroll down, reappears on scroll up
- Always sticks to bottom of viewport

---

## 6. Data Layer

### Database: SQLite via Prisma ORM (Backend)

**9 Models:**

```
User ─────────┬── BorrowRecord[] ──── Resource
              ├── Attendance[]
              ├── Reservation[] ───── Resource
              ├── Notification[]
              └── Review[] ────────── Resource

Resource ─────┬── BorrowRecord[]
              ├── Reservation[]
              └── Review[]

LibrarySettings (singleton)
Announcement
```

### Key Relationships

| From | To | Type | Foreign Key |
|------|----|------|-------------|
| User | BorrowRecord | One-to-Many | `userId` |
| User | Attendance | One-to-Many | `userId` |
| User | Reservation | One-to-Many | `userId` |
| User | Notification | One-to-Many | `userId` |
| User | Review | One-to-Many | `userId` |
| Resource | BorrowRecord | One-to-Many | `resourceId` |
| Resource | Reservation | One-to-Many | `resourceId` |
| Resource | Review | One-to-Many | `resourceId` |

### Unique Constraints

- `User.email` — one account per email
- `User.universityId` — one account per university ID
- `Review.[userId, resourceId]` — one review per user per resource (upsert logic)

---

## 7. API Layer

### 17 API Endpoints (Same as Original - Backend Unchanged)

| Category | Method | Endpoint | Purpose |
|----------|--------|----------|---------|
| **Auth** | POST | `/api/auth/login` | Login (SHA-256 hash verification) |
| | POST | `/api/auth/register` | Register new user |
| | PUT | `/api/auth/update` | Update profile, preferences, or password |
| **Resources** | GET | `/api/resources` | List/search (category, subject, search, page, limit) |
| | GET | `/api/resources/[id]` | Get single resource with related records |
| **Borrowing** | GET | `/api/borrow` | List borrow records (userId, status) |
| | POST | `/api/borrow` | Borrow a book (validates availability + limits) |
| | POST | `/api/borrow/[id]/return` | Return a book (increments available copies) |
| **Reservations** | GET | `/api/reservations` | List reservations (userId) |
| | POST | `/api/reservations` | Create reservation |
| | DELETE | `/api/reservations/[id]` | Cancel (soft-delete: status → "cancelled") |
| **Notifications** | GET | `/api/notifications` | List notifications (userId) |
| | PUT | `/api/notifications/[id]/read` | Mark as read |
| **Attendance** | GET | `/api/attendance` | List records (userId, date) |
| | POST | `/api/attendance` | Record time-in or time-out |
| **Reviews** | GET | `/api/reviews` | Get reviews + stats (resourceId) |
| | POST | `/api/reviews` | Create or update review (upsert) |
| | DELETE | `/api/reviews/[id]` | Delete a review |
| **Settings** | GET | `/api/settings` | Get library settings |
| | PUT | `/api/settings` | Update library settings |
| **Announcements** | GET | `/api/announcements` | List active announcements |
| **Health** | GET | `/api/` | Health check |

### Flutter HTTP Client

Use `dio` or `http` package for API communication:

```dart
// Example using dio
final dio = Dio(BaseOptions(
  baseUrl: 'https://api.library.edu',
  connectTimeout: const Duration(seconds: 5),
  receiveTimeout: const Duration(seconds: 3),
));
```

---

## 8. State Management

### Store: Riverpod with `shared_preferences` persistence

**Storage key:** `liblog-store` (shared_preferences)

### What IS Persisted

| Field | Type | Description |
|-------|------|-------------|
| `user` | `UserState?` | Full user data (name, email, role, preferences) |
| `onboardingStep` | `int` | Current onboarding step (0–4) |
| `onboardingData` | `object` | Registration form data accumulator |
| `favorites` | `List<String>` | Favorited resource IDs |

### What is NOT Persisted

| Field | Type | Why |
|-------|------|-----|
| `currentScreen` | `AppScreen` | Always resets to `'login'` on app open |
| `isAuthenticated` | `bool` | Always resets to `false` on app open |
| `previousScreen` | `AppScreen?` | Navigation state, not needed across sessions |
| `selectedBookId` | `String?` | Transient selection |
| `searchQuery` | `String` | Transient search state |
| `searchCategory` | `String` | Transient filter |
| `unreadCount` | `int` | Should refresh from API |

### Rehydration Behavior

On app open, always reset `isAuthenticated → false` and `currentScreen → 'login'`, ensuring users always start at the login screen even if they closed the app while authenticated.

---

## 9. Design System Summary

### Color Palette

| Role | Light Mode | Dark Mode |
|------|-----------|-----------|
| **Brand Primary** | `#652D90` (Lib Purple) | `#7B3FA8` (Lib Purple Light) |
| **Page Background** | `#f2f2fa` (Lavender-tinted gray) | `Color(0xFF110a1e)` (~`#110a1e`, dark purple) |
| **Card Background** | `#FFFFFF` | `Color(0xFF1a0e2e)` (dark purple surface) |
| **Bottom Nav** | `card` with `shadow-sm` | `Color(0xFF1a0e2e)/90` with `shadow-sm` |
| **Dark surfaces** | N/A | `Colors.white.withOpacity(0.05)`, `Colors.white.withOpacity(0.10)`, `Colors.white.withOpacity(0.15)` |
| **Dark borders** | N/A | `Colors.white.withOpacity(0.05)`, `Colors.white.withOpacity(0.10)` |

### Shadow System (Current)

> **Major Design Principle:** Light mode is **FLAT** — no shadows. Dark mode uses shadows for depth.

| Element | Light Mode | Dark Mode |
|---------|-----------|-----------|
| All cards | **No shadow** | `dark:shadow-sm` |
| All buttons | **No shadow** | `dark:shadow-*` (varies) |
| All images | **No shadow** | `dark:shadow-*` (varies) |
| Modals | **No shadow** | `dark:shadow-2xl` |
| **BottomNav** | `shadow-sm` ✅ | `shadow-sm` ✅ |
| **QR scan button** | `shadow-*` ✅ | `shadow-*` ✅ |
| Mobile container | **No shadow** | `dark:shadow-xl` |

### Card Corner Radius

- **Section cards**: `24px` (`BorderRadius.circular(24)`)
- **Inner card elements**: `16px` (`BorderRadius.circular(16)`)
- **Icon containers**: `22px` (`BorderRadius.circular(22)`)
- **Pills/badges**: `9999px` (`BorderRadius.circular(9999)`)

### Typography

- **Font**: System fonts via `ThemeData` (use Google Fonts package for custom fonts)
- **Headings**: 30px–14px scale (H1–H6)
- **Body**: 16px regular
- **Weights used**: Regular (400), Medium (500), Semibold (600), Bold (700)

### Dark Mode Implementation

- **Class-based toggle** via `provider` or `Riverpod`
- **Dark purple theme**: Uses custom `ColorScheme` with purple hue for all dark surfaces
- **Transparency system**: `Colors.white.withOpacity(0.05)`, `/0.10`, `/0.15` over dark purple base instead of opaque gray
- **Toggle**: Available in Settings screen, persists across sessions

---

## 10. Current Design Principles

These are the key design decisions that shape the current system:

1. **Flat Light Mode**: No shadows on any content surface in light mode. Visual separation comes from the contrast between `#f2f2fa` page background and `#FFFFFF` card surfaces. Only BottomNav and QR scan button have shadows in both modes.

2. **Dark Purple Mode**: Not a simple dark gray — the dark mode uses a deep purple base (`#110a1e`) with transparency layers, creating a cohesive brand experience even in dark mode.

3. **Mobile-First, Single-Column**: The entire app is designed for a 430px max-width container. No responsive breakpoints for desktop layouts.

4. **Native App Feel**: Screen transitions (PageRouteBuilder), pull-to-refresh, swipe-to-dismiss, spring animations, and haptic-like press feedback replicate native mobile interactions.

5. **State-Driven Navigation**: No named routes. Screen navigation is managed entirely through Riverpod state, providing a native app-like flow where back navigation is tracked internally.

6. **Card-Based Layout**: All content sections are wrapped in `Container(decoration: BoxDecoration(color: card, borderRadius: 24px))` cards, providing consistent visual structure across all screens.

7. **Purple-Forward Branding**: The `#652D90` purple is used extensively — buttons, accents, gradients, shadows (in dark mode), and even dark mode surface tints all carry the brand color.

8. **Split-Weight Greeting**: The home screen greeting uses a regular-weight prefix ("Good afternoon,") with a bold name ("Juan!").

9. **Lavender Background**: The `#f2f2fa` background provides a subtle purple warmth compared to pure white or gray, reinforcing the brand even on the page surface.

---

## 11. Technology Stack

| Category | Technology | Version |
|----------|-----------|---------|
| **Framework** | Flutter | 3.x |
| **Language** | Dart | 3.x |
| **Styling** | Flutter ThemeData + custom widgets | — |
| **UI Components** | Custom widgets + flutter_material | — |
| **Icons** | Material Icons / Cupertino Icons | Latest |
| **Database** | SQLite via Prisma ORM (Backend) | 6 |
| **State Management** | Riverpod (flutter_riverpod) | 2.x |
| **Animations** | Flutter Animations + flutter_animate | Latest |
| **Theming** | provider / Riverpod | Latest |
| **Forms** | flutter_form_builder + validators | Latest |
| **Charts** | fl_chart | Latest |
| **HTTP Client** | dio | Latest |
| **Persistence** | shared_preferences + flutter_secure_storage | Latest |
| **Auth** | Backend API (SHA-256) | — |
| **Image Loading** | cached_network_image | Latest |
| **Fonts** | google_fonts | Latest |
| **Password Hashing** | Web Crypto API (SHA-256) | Backend |

---

## 12. Project Structure

```
lib/
├── main.dart                     # App entry point
├── config/
│   ├── theme.dart                # Light/dark theme configuration
│   ├── colors.dart               # Color constants (lib_purple, etc.)
│   ├── text_styles.dart          # Typography definitions
│   └── constants.dart            # App-wide constants
│
├── providers/                    # Riverpod providers
│   ├── auth_provider.dart        # Auth state management
│   ├── resources_provider.dart   # Resource catalog state
│   ├── borrow_provider.dart      # Borrowing state
│   ├── reservation_provider.dart # Reservation state
│   ├── notification_provider.dart # Notification state
│   ├── attendance_provider.dart  # Attendance state
│   ├── review_provider.dart      # Review state
│   └── theme_provider.dart       # Theme mode state
│
├── screens/                      # 14 app screens
│   ├── onboarding_screen.dart
│   ├── login_screen.dart
│   ├── home_screen.dart
│   ├── search_screen.dart
│   ├── book_detail_screen.dart
│   ├── borrowed_screen.dart
│   ├── qr_scan_screen.dart
│   ├── profile_screen.dart
│   ├── settings_screen.dart
│   ├── notifications_screen.dart
│   ├── attendance_screen.dart
│   ├── favorites_screen.dart
│   ├── reservations_screen.dart
│   └── edit_profile_screen.dart
│
├── widgets/                      # Reusable widgets
│   ├── bottom_nav.dart           # 5-tab bottom navigation
│   ├── book_card.dart            # Book result card
│   ├── section_card.dart         # Standard card wrapper
│   ├── streak_pill.dart         # Orange streak counter
│   ├── greeting_header.dart      # Home screen greeting
│   └── ...                      # 40+ custom widgets
│
├── services/                     # API & business logic
│   ├── api_service.dart          # HTTP client (dio)
│   ├── auth_service.dart         # Login/register API
│   ├── resource_service.dart     # Catalog API
│   ├── borrow_service.dart       # Borrowing API
│   ├── reservation_service.dart  # Reservation API
│   ├── notification_service.dart # Notification API
│   ├── attendance_service.dart   # Attendance API
│   ├── review_service.dart       # Review API
│   └── storage_service.dart      # SharedPreferences wrapper
│
├── models/                       # Data models
│   ├── user.dart
│   ├── resource.dart
│   ├── borrow_record.dart
│   ├── reservation.dart
│   ├── notification.dart
│   ├── attendance.dart
│   ├── review.dart
│   └── library_settings.dart
│
├── utils/                        # Utilities
│   ├── auth.dart                 # Password hashing, avatar initials, borrow rules
│   ├── covers.dart               # Book cover image mapping
│   └── helpers.dart              # Date formatting, validators, etc.
│
└── l10n/                         # Localization (future)
    └── app_en.arb

assets/
├── images/                        # Book covers, icons
│   └── covers/                   # 10 AI-generated book covers
└── fonts/                         # Custom fonts (if any)

backend/                           # (Unchanged - Next.js API)
├── prisma/
│   ├── schema.prisma
│   └── seed.ts
└── src/app/api/                   # 17 API endpoints
```

---

## 13. Test Accounts & Seed Data

### Test Accounts

All accounts use the password: `password123`

| Role | Name | Email | University ID | Details |
|------|-------|-------|---------------|---------|
| **Student** | Juan Dela Cruz | juan@university.edu | CS-2024-0001 | CS program, 3rd Year, streak=5 |
| **Faculty** | Maria Santos | maria@university.edu | FAC-2024-0001 | CS Department, streak=12 |
| **Visitor** | Alex Reyes | alex@university.edu | VIS-2024-0001 | — |

### Seed Data Summary

| Type | Count | Details |
|------|-------|---------|
| Users | 3 | Student, Faculty, Visitor |
| Resources | 17 | 10 books, 4 research, 3 magazines |
| Borrow Records | 5 | 2 active, 1 overdue (student), 2 returned |
| Notifications | 6 | Due soon, overdue, reservation, hours, confirmed, reminder |
| Announcements | 2 | Extended hours for finals, New AI/ML arrivals |
| Reservations | 1 | Student → Clean Code (pending) |
| Attendance | 2 | Today (time-in only), Yesterday (7 hours) |
| Reviews | 10 | Across 6 resources, ratings 2-5 |
| Book Covers | 10 | AI-generated PNG images in `assets/images/covers/` |

---

## 14. Known Limitations & Future Roadmap

### Current Limitations

1. **QR scanning is simulated** — no real camera integration; auto-simulates a scan after 2 seconds
2. **No real push notifications** — notifications are in-app only, fetched from the database
3. **Password hashing is SHA-256** — functional but not industry-standard (bcrypt/argon2 would be preferred for production)
4. **No server-side sessions** — auth is entirely client-side (Riverpod + shared_preferences)
5. **No offline support** — requires network connection for all data
6. **No admin interface** — librarian role exists but no admin screens
7. **Book covers** — only 10 of 17 resources have AI-generated covers; the rest use gradient placeholders
8. **Attendance mock fallback** — AttendanceScreen falls back to mock data when API returns empty
9. **No image upload** — profile avatars are auto-generated initials only
10. **Single-language** — English only, no i18n support

### Priority Roadmap

| Priority | Feature | Description |
|----------|---------|-------------|
| 🔴 High | Real QR scanning | Integrate camera API for actual QR code reading |
| 🔴 High | Admin dashboard | Librarian screens for managing resources, users, and announcements |
| 🟡 Medium | Password security | Migrate from SHA-256 to bcrypt/argon2 |
| 🟡 Medium | Image upload | Allow profile photo upload and custom book cover management |
| 🟡 Medium | Search autocomplete | Add search suggestions dropdown as user types |
| 🟡 Medium | Offline caching | Local database (drift) with offline-first data access |
| 🟢 Low | Push notifications | Firebase Cloud Messaging for real-time alerts |
| 🟢 Low | Multi-language | i18n support for Filipino and other languages |
| 🟢 Low | Analytics dashboard | Usage statistics and reporting for librarians |
| 🟢 Low | Accessibility audit | Full WCAG AA compliance review and fixes |

---

## Companion Documents

| Document | Purpose | Location |
|----------|---------|----------|
| **FLUTTER_FEATURES.md** | Granular feature inventory (all screens, APIs, models, animations) | `/FLUTTER_FEATURES.md` |
| **FLUTTER_BRANDING.md** | Complete design system guide (colors, spacing, typography, shadows, components) | `/FLUTTER_BRANDING.md` |
| **worklog.md** | Development history with task IDs, agent logs, and stage summaries | `/worklog.md` |

---

> **This document provides the high-level system overview of LibLog for Flutter/Dart.** For detailed feature specifications, see FLUTTER_FEATURES.md. For design system rules, see FLUTTER_BRANDING.md. For development history, see worklog.md.

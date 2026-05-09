"""
scaffold_project.py
-------------------
Scaffolds the LibLog project:
  1. Initializes the Node.js backend and writes schema.prisma (9 models).
  2. Runs `flutter create` with package name com.liblog.app.
  3. Populates pubspec.yaml with required dependencies.
  4. Creates the full lib/ directory structure with stub dart files.

Usage:
    python execution/scaffold_project.py --root C:/LLMS/liblog
"""

import argparse
import os
import subprocess
import sys
import textwrap

# ---------------------------------------------------------------------------
# Config
# ---------------------------------------------------------------------------

PACKAGE_NAME = "com.liblog.app"
APP_NAME = "liblog"

FLUTTER_DEPENDENCIES = {
    # State management
    "flutter_riverpod": "^2.5.1",
    # HTTP client
    "dio": "^5.4.3",
    # Local storage
    "shared_preferences": "^2.2.3",
    "flutter_secure_storage": "^9.0.0",
    # Images
    "cached_network_image": "^3.3.1",
    # Fonts
    "google_fonts": "^6.2.1",
    # Animations
    "flutter_animate": "^4.5.0",
    # Charts
    "fl_chart": "^0.68.0",
    # Forms
    "flutter_form_builder": "^9.3.0",
    "form_builder_validators": "^10.0.1",
    # QR / Camera
    "mobile_scanner": "^5.2.3",
    # Share
    "share_plus": "^9.0.0",
    # Confetti
    "confetti": "^0.7.0",
    # Rating bar
    "flutter_rating_bar": "^4.0.1",
    # Shimmer loading
    "shimmer": "^3.0.0",
}

FLUTTER_DEV_DEPENDENCIES = {
    "flutter_test": {"sdk": "flutter"},
    "flutter_lints": "^3.0.0",
}

# ---------------------------------------------------------------------------
# Prisma schema — all 9 models
# ---------------------------------------------------------------------------

PRISMA_SCHEMA = '''
datasource db {
  provider = "sqlite"
  url      = env("DATABASE_URL")
}

generator client {
  provider = "prisma-client-js"
}

model User {
  id                         String         @id @default(cuid())
  email                      String         @unique
  password                   String
  fullName                   String
  universityId               String         @unique
  role                       String         // student | faculty | visitor | librarian
  program                    String?
  department                 String?
  yearLevel                  String?
  avatarInitials             String?
  notificationDueDate        Boolean        @default(true)
  notificationReservation    Boolean        @default(true)
  notificationAnnouncements  Boolean        @default(false)
  streakCount                Int            @default(0)
  streakLastDate             String?
  isOnboarded                Boolean        @default(false)
  createdAt                  DateTime       @default(now())
  updatedAt                  DateTime       @updatedAt

  borrowedBooks  BorrowRecord[]
  attendance     Attendance[]
  reservations   Reservation[]
  notifications  Notification[]
  reviews        Review[]
}

model Resource {
  id              String   @id @default(cuid())
  title           String
  author          String
  isbn            String?
  issn            String?
  category        String   // book | research | magazine
  copies          Int      @default(1)
  availableCopies Int      @default(1)
  shelfLocation   String?
  abstract        String?
  publicationDate String?
  coverImage      String?
  subject         String?
  tags            String?  // comma-separated
  status          String   @default("available")
  createdAt       DateTime @default(now())
  updatedAt       DateTime @updatedAt

  borrowRecords BorrowRecord[]
  reservations  Reservation[]
  reviews       Review[]
}

model BorrowRecord {
  id         String    @id @default(cuid())
  userId     String
  resourceId String
  borrowDate DateTime  @default(now())
  dueDate    DateTime
  returnDate DateTime?
  status     String    @default("active") // active | returned | overdue
  isLate     Boolean   @default(false)
  createdAt  DateTime  @default(now())
  updatedAt  DateTime  @updatedAt

  user     User     @relation(fields: [userId], references: [id])
  resource Resource @relation(fields: [resourceId], references: [id])
}

model Attendance {
  id        String    @id @default(cuid())
  userId    String
  date      String    // YYYY-MM-DD
  timeIn    DateTime?
  timeOut   DateTime?
  duration  Int?      // total minutes
  createdAt DateTime  @default(now())
  updatedAt DateTime  @updatedAt

  user User @relation(fields: [userId], references: [id])
}

model Reservation {
  id         String   @id @default(cuid())
  userId     String
  resourceId String
  status     String   @default("pending") // pending | fulfilled | cancelled
  createdAt  DateTime @default(now())
  updatedAt  DateTime @updatedAt

  user     User     @relation(fields: [userId], references: [id])
  resource Resource @relation(fields: [resourceId], references: [id])
}

model Notification {
  id        String   @id @default(cuid())
  userId    String
  type      String   // due_date | reservation | announcement | inquiry
  title     String
  message   String
  isRead    Boolean  @default(false)
  createdAt DateTime @default(now())

  user User @relation(fields: [userId], references: [id])
}

model LibrarySettings {
  id                 String   @id @default(cuid())
  isOpen             Boolean  @default(true)
  openingTime        String   @default("07:00")
  closingTime        String   @default("21:00")
  maxBorrowStudent   Int      @default(3)
  maxBorrowFaculty   Int      @default(10)
  maxBorrowVisitor   Int      @default(1)
  borrowDaysStudent  Int      @default(14)
  borrowDaysFaculty  Int      @default(30)
  borrowDaysVisitor  Int      @default(7)
  qrValidityMinutes  Int      @default(15)
  updatedAt          DateTime @updatedAt
}

model Announcement {
  id          String   @id @default(cuid())
  title       String
  message     String
  targetRoles String   @default("all") // all | student | faculty | visitor
  isActive    Boolean  @default(true)
  createdAt   DateTime @default(now())
  updatedAt   DateTime @updatedAt
}

model Review {
  id         String   @id @default(cuid())
  userId     String
  resourceId String
  rating     Int      // 1-5
  comment    String?
  createdAt  DateTime @default(now())
  updatedAt  DateTime @updatedAt

  user     User     @relation(fields: [userId], references: [id])
  resource Resource @relation(fields: [resourceId], references: [id])

  @@unique([userId, resourceId])
}
'''.strip()

# ---------------------------------------------------------------------------
# Stub dart file content generators
# ---------------------------------------------------------------------------

def dart_stub(description: str) -> str:
    """Returns a minimal Dart stub file with a descriptive comment."""
    return f"// {description}\n// TODO: implement\n"


# Map of relative paths (from lib/) -> description
LIB_STUBS = {
    # config
    "config/theme.dart":        "Light/dark ThemeData configuration",
    "config/colors.dart":       "AppColors constants — lib_purple, background, card, etc.",
    "config/text_styles.dart":  "Typography scale: H1-H6, body, caption, button",
    "config/constants.dart":    "App-wide constants (API base URL, fine rate, etc.)",
    # providers
    "providers/auth_provider.dart":         "Auth state: login, logout, register, updateProfile",
    "providers/resources_provider.dart":    "Resource catalog state and search",
    "providers/borrow_provider.dart":       "Borrow records: borrow, return, history",
    "providers/reservation_provider.dart":  "Reservations: create, cancel, list",
    "providers/notification_provider.dart": "Notifications: list, markRead, unreadCount",
    "providers/attendance_provider.dart":   "Attendance: timeIn, timeOut, calendar data",
    "providers/review_provider.dart":       "Reviews: fetch, upsert, delete for a resource",
    "providers/theme_provider.dart":        "ThemeMode state (light / dark / system)",
    # screens
    "screens/onboarding_screen.dart":   "5-step registration wizard",
    "screens/login_screen.dart":        "Login form with gradient header and demo button",
    "screens/home_screen.dart":         "Dashboard: greeting, announcements, stats cards",
    "screens/search_screen.dart":       "Catalog search with debounce and category filters",
    "screens/book_detail_screen.dart":  "Book metadata, ratings, borrow/reserve actions",
    "screens/borrowed_screen.dart":     "Active loans and borrowing history tabs",
    "screens/qr_scan_screen.dart":      "Simulated QR scanner for attendance / checkout",
    "screens/profile_screen.dart":      "User profile, stats, reading goal, menu",
    "screens/settings_screen.dart":     "Notifications, dark mode toggle, logout",
    "screens/notifications_screen.dart":"Grouped notifications with swipe-to-dismiss",
    "screens/attendance_screen.dart":   "Calendar heat map and visit history",
    "screens/favorites_screen.dart":    "Saved/favorited books list",
    "screens/reservations_screen.dart": "Reservation list with Pending/Fulfilled tabs",
    "screens/edit_profile_screen.dart": "Editable profile form (name, program, year)",
    # widgets
    "widgets/bottom_nav.dart":     "5-tab sticky bottom navigation bar",
    "widgets/book_card.dart":      "Book result card with cover, title, availability",
    "widgets/section_card.dart":   "Standard card wrapper (borderRadius 24, flat light)",
    "widgets/streak_pill.dart":    "Orange pill showing current streak + flame icon",
    "widgets/greeting_header.dart":"Split-weight home screen greeting (RichText)",
    # services
    "services/api_service.dart":          "Dio HTTP client singleton with base options",
    "services/auth_service.dart":         "Login, register, updateProfile API calls",
    "services/resource_service.dart":     "Catalog list/search/detail API calls",
    "services/borrow_service.dart":       "Borrow, return, list borrow records",
    "services/reservation_service.dart":  "Create, cancel, list reservations",
    "services/notification_service.dart": "Fetch notifications, mark as read",
    "services/attendance_service.dart":   "Time-in, time-out, fetch attendance",
    "services/review_service.dart":       "Fetch, upsert, delete reviews",
    "services/storage_service.dart":      "SharedPreferences wrapper for persisted state",
    # models
    "models/user.dart":             "User data model (fromJson / toJson)",
    "models/resource.dart":         "Resource data model",
    "models/borrow_record.dart":    "BorrowRecord data model",
    "models/reservation.dart":      "Reservation data model",
    "models/notification.dart":     "Notification data model",
    "models/attendance.dart":       "Attendance data model",
    "models/review.dart":           "Review data model",
    "models/library_settings.dart": "LibrarySettings data model",
    # utils
    "utils/auth.dart":    "hashPassword, getAvatarInitials, getBorrowDays, getMaxBorrow",
    "utils/covers.dart":  "coverMap and getBookCover fuzzy title-to-asset mapping",
    "utils/helpers.dart": "Date formatters, validators, style merge utility",
    # l10n
    "l10n/app_en.arb": '{ "@@locale": "en" }',
}

# ---------------------------------------------------------------------------
# main.dart content
# ---------------------------------------------------------------------------

MAIN_DART = textwrap.dedent('''\
    import 'package:flutter/material.dart';
    import 'package:flutter_riverpod/flutter_riverpod.dart';
    import 'config/theme.dart';

    void main() {
      runApp(const ProviderScope(child: LibLogApp()));
    }

    class LibLogApp extends ConsumerWidget {
      const LibLogApp({super.key});

      @override
      Widget build(BuildContext context, WidgetRef ref) {
        return MaterialApp(
          title: 'LibLog',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          // TODO: wire up router / screen provider
          home: const Scaffold(
            body: Center(child: Text('LibLog — scaffold complete')),
          ),
        );
      }
    }
''')

# ---------------------------------------------------------------------------
# pubspec.yaml builder
# ---------------------------------------------------------------------------

def build_pubspec(app_name: str, package: str) -> str:
    dep_lines = "\n".join(
        f"  {name}: \"{ver}\"" for name, ver in FLUTTER_DEPENDENCIES.items()
    )
    return textwrap.dedent(f"""\
        name: {app_name}
        description: LibLog — Digital Library Logbook Management System
        publish_to: none
        version: 1.0.0+1

        environment:
          sdk: ">=3.0.0 <4.0.0"

        dependencies:
          flutter:
            sdk: flutter

        {dep_lines}

        dev_dependencies:
          flutter_test:
            sdk: flutter
          flutter_lints: "^3.0.0"

        flutter:
          uses-material-design: true

          assets:
            - assets/images/covers/

          fonts: []
    """)


# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

def run(cmd: list[str], cwd: str, label: str) -> None:
    """Run a subprocess command, printing output live. Exits on failure."""
    print(f"\n>>> {label}")
    print(f"    $ {' '.join(cmd)}  (in {cwd})")
    result = subprocess.run(cmd, cwd=cwd, text=True, capture_output=False)
    if result.returncode != 0:
        print(f"\n[ERROR] '{label}' failed with exit code {result.returncode}.")
        sys.exit(result.returncode)
    print(f"    ✓ {label} done.")


def write_file(path: str, content: str) -> None:
    os.makedirs(os.path.dirname(path), exist_ok=True)
    with open(path, "w", encoding="utf-8") as f:
        f.write(content)
    print(f"  wrote  {os.path.relpath(path)}")


def ensure_dir(path: str) -> None:
    os.makedirs(path, exist_ok=True)
    print(f"  mkdir  {os.path.relpath(path)}")


# ---------------------------------------------------------------------------
# Steps
# ---------------------------------------------------------------------------

def step_flutter_create(root: str) -> None:
    """Run flutter create if the project doesn't already exist."""
    if os.path.exists(os.path.join(root, "pubspec.yaml")):
        print("\n[SKIP] Flutter project already exists — skipping flutter create.")
        return

    parent = os.path.dirname(root)
    folder = os.path.basename(root)

    # Verify flutter is available
    result = subprocess.run(["flutter", "--version"], capture_output=True, text=True)
    if result.returncode != 0:
        print("[ERROR] 'flutter' not found on PATH. Install Flutter 3.44 and retry.")
        sys.exit(1)

    version_line = (result.stdout or result.stderr).splitlines()[0]
    print(f"\n    Flutter detected: {version_line}")

    run(
        ["flutter", "create",
         "--org", "com.liblog",
         "--project-name", folder,
         "--platforms", "android,ios",
         folder],
        cwd=parent,
        label="flutter create",
    )


def step_pubspec(root: str) -> None:
    """Overwrite pubspec.yaml with the full dependency list."""
    path = os.path.join(root, "pubspec.yaml")
    write_file(path, build_pubspec(APP_NAME, PACKAGE_NAME))
    print("\n[OK] pubspec.yaml written.")


def step_lib_structure(root: str) -> None:
    """Create stub dart files for every file in the spec."""
    lib_root = os.path.join(root, "lib")

    # Write main.dart
    write_file(os.path.join(lib_root, "main.dart"), MAIN_DART)

    # Write every stub
    for rel_path, description in LIB_STUBS.items():
        abs_path = os.path.join(lib_root, rel_path)
        # l10n files are not Dart — write raw content
        if rel_path.endswith(".arb"):
            content = description  # description IS the content for arb
        else:
            content = dart_stub(description)
        write_file(abs_path, content)

    # Asset directories
    for folder in [
        os.path.join(root, "assets", "images", "covers"),
        os.path.join(root, "assets", "fonts"),
    ]:
        ensure_dir(folder)
        # Keep folder tracked by git
        write_file(os.path.join(folder, ".gitkeep"), "")

    print("\n[OK] lib/ structure created.")


def step_backend(root: str) -> None:
    """Initialize Node.js backend and write schema.prisma."""
    backend_dir = os.path.join(root, "backend")
    prisma_dir  = os.path.join(backend_dir, "prisma")
    src_api_dir = os.path.join(backend_dir, "src", "app", "api")

    ensure_dir(backend_dir)
    ensure_dir(prisma_dir)
    ensure_dir(src_api_dir)

    # package.json
    package_json = textwrap.dedent("""\
        {
          "name": "liblog-backend",
          "version": "1.0.0",
          "description": "LibLog REST API backend",
          "scripts": {
            "dev": "ts-node-dev --respawn src/index.ts",
            "build": "tsc",
            "db:migrate": "prisma migrate dev",
            "db:seed": "ts-node prisma/seed.ts",
            "db:studio": "prisma studio"
          },
          "dependencies": {
            "@prisma/client": "^6.0.0"
          },
          "devDependencies": {
            "prisma": "^6.0.0",
            "typescript": "^5.0.0",
            "ts-node": "^10.9.2",
            "ts-node-dev": "^2.0.0",
            "@types/node": "^20.0.0"
          }
        }
    """)
    write_file(os.path.join(backend_dir, "package.json"), package_json)

    # .env for Prisma
    env_content = 'DATABASE_URL="file:./dev.db"\n'
    env_path = os.path.join(backend_dir, ".env")
    if not os.path.exists(env_path):
        write_file(env_path, env_content)
    else:
        print(f"  [SKIP] .env already exists — not overwriting.")

    # schema.prisma
    write_file(os.path.join(prisma_dir, "schema.prisma"), PRISMA_SCHEMA)

    # Empty seed.ts stub
    seed_stub = textwrap.dedent("""\
        // prisma/seed.ts
        // TODO: implement seed data (users, resources, borrow records, etc.)
        import { PrismaClient } from '@prisma/client';
        const prisma = new PrismaClient();

        async function main() {
          console.log('Seeding database...');
          // Add seed logic here
        }

        main()
          .catch(console.error)
          .finally(() => prisma.$disconnect());
    """)
    write_file(os.path.join(prisma_dir, "seed.ts"), seed_stub)

    # tsconfig.json
    tsconfig = textwrap.dedent("""\
        {
          "compilerOptions": {
            "target": "ES2020",
            "module": "commonjs",
            "lib": ["ES2020"],
            "outDir": "./dist",
            "rootDir": "./src",
            "strict": true,
            "esModuleInterop": true,
            "skipLibCheck": true,
            "forceConsistentCasingInFileNames": true
          },
          "include": ["src/**/*", "prisma/**/*"],
          "exclude": ["node_modules", "dist"]
        }
    """)
    write_file(os.path.join(backend_dir, "tsconfig.json"), tsconfig)

    print("\n[OK] Backend initialized.")

    # npm install + prisma generate (non-fatal — user may not have Node yet)
    node_ok = subprocess.run(
        ["node", "--version"], capture_output=True
    ).returncode == 0

    if node_ok:
        run(["npm", "install"], cwd=backend_dir, label="npm install")
        run(["npx", "prisma", "generate"], cwd=backend_dir, label="prisma generate")
    else:
        print("\n  [WARN] Node.js not detected — skipping npm install + prisma generate.")
        print("         Run these manually inside backend/ after installing Node.js:")
        print("           npm install")
        print("           npx prisma migrate dev --name init")


# ---------------------------------------------------------------------------
# Entry point
# ---------------------------------------------------------------------------

def main() -> None:
    parser = argparse.ArgumentParser(description="Scaffold the LibLog project.")
    parser.add_argument(
        "--root",
        default=os.path.join(os.path.dirname(__file__), "..", "liblog"),
        help="Absolute path to the project root (default: ../liblog next to execution/)",
    )
    args = parser.parse_args()
    root = os.path.abspath(args.root)

    print("=" * 60)
    print(f"  LibLog Scaffold — target: {root}")
    print("=" * 60)

    os.makedirs(root, exist_ok=True)

    step_flutter_create(root)   # 1. flutter create
    step_pubspec(root)          # 2. pubspec.yaml
    step_lib_structure(root)    # 3. lib/ stubs + assets/
    step_backend(root)          # 4. backend/ + schema.prisma

    print("\n" + "=" * 60)
    print("  Scaffold complete!")
    print(f"  Project root : {root}")
    print(f"  Backend      : {os.path.join(root, 'backend')}")
    print("\n  Next steps:")
    print("  1. cd liblog && flutter pub get")
    print("  2. cd liblog/backend && npx prisma migrate dev --name init")
    print("  3. cd liblog/backend && npm run db:seed")
    print("=" * 60)


if __name__ == "__main__":
    main()

#!/usr/bin/env node
/**
 * scaffold_project.js
 * -------------------
 * Scaffolds the LibLog project using Node.js (v22.20.0):
 *   1. Initializes a Node.js backend with Prisma + SQLite.
 *   2. Runs `flutter create` with package name com.liblog.app.
 *   3. Writes pubspec.yaml with required Flutter dependencies.
 *   4. Creates lib/config, lib/providers, lib/screens, lib/utils
 *      with stub Dart files.
 *
 * Usage:
 *   node execution/scaffold_project.js [--root <path>]
 *
 * Default root: C:/LLMS/liblog
 */

const { execSync, spawnSync } = require("child_process");
const fs   = require("fs");
const path = require("path");

// ---------------------------------------------------------------------------
// Config
// ---------------------------------------------------------------------------

const args = process.argv.slice(2);
const rootIdx = args.indexOf("--root");
const PROJECT_ROOT = path.resolve(
  rootIdx !== -1 ? args[rootIdx + 1] : path.join(__dirname, "..", "liblog")
);
const BACKEND_DIR  = path.join(PROJECT_ROOT, "backend");
const LIB_DIR      = path.join(PROJECT_ROOT, "lib");
const ASSETS_DIR   = path.join(PROJECT_ROOT, "assets");

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

function run(cmd, cwd, label) {
  console.log(`\n>>> ${label}`);
  console.log(`    $ ${cmd}  (in ${cwd})`);
  const result = spawnSync(cmd, { cwd, shell: true, stdio: "inherit" });
  if (result.status !== 0) {
    console.error(`\n[ERROR] '${label}' failed (exit ${result.status}).`);
    process.exit(result.status || 1);
  }
  console.log(`    ✓ ${label} done.`);
}

function write(filePath, content) {
  fs.mkdirSync(path.dirname(filePath), { recursive: true });
  fs.writeFileSync(filePath, content, "utf8");
  console.log(`  wrote  ${path.relative(PROJECT_ROOT, filePath)}`);
}

function mkdir(dirPath) {
  fs.mkdirSync(dirPath, { recursive: true });
  console.log(`  mkdir  ${path.relative(PROJECT_ROOT, dirPath)}`);
}

function dartStub(description) {
  return `// ${description}\n// TODO: implement\n`;
}

// ---------------------------------------------------------------------------
// Full Prisma schema — 9 models
// ---------------------------------------------------------------------------

const PRISMA_SCHEMA = `
datasource db {
  provider = "sqlite"
  url      = env("DATABASE_URL")
}

generator client {
  provider = "prisma-client-js"
}

model User {
  id                         String   @id @default(cuid())
  email                      String   @unique
  password                   String
  fullName                   String
  universityId               String   @unique
  role                       String   // student | faculty | visitor | librarian
  program                    String?
  department                 String?
  yearLevel                  String?
  avatarInitials             String?
  notificationDueDate        Boolean  @default(true)
  notificationReservation    Boolean  @default(true)
  notificationAnnouncements  Boolean  @default(false)
  streakCount                Int      @default(0)
  streakLastDate             String?
  isOnboarded                Boolean  @default(false)
  createdAt                  DateTime @default(now())
  updatedAt                  DateTime @updatedAt

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
  id                String   @id @default(cuid())
  isOpen            Boolean  @default(true)
  openingTime       String   @default("07:00")
  closingTime       String   @default("21:00")
  maxBorrowStudent  Int      @default(3)
  maxBorrowFaculty  Int      @default(10)
  maxBorrowVisitor  Int      @default(1)
  borrowDaysStudent Int      @default(14)
  borrowDaysFaculty Int      @default(30)
  borrowDaysVisitor Int      @default(7)
  qrValidityMinutes Int      @default(15)
  updatedAt         DateTime @updatedAt
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
`.trimStart();

// ---------------------------------------------------------------------------
// pubspec.yaml
// ---------------------------------------------------------------------------

const PUBSPEC = `name: liblog
description: LibLog — Digital Library Logbook Management System
publish_to: none
version: 1.0.0+1

environment:
  sdk: ">=3.0.0 <4.0.0"

dependencies:
  flutter:
    sdk: flutter

  # State management
  flutter_riverpod: "^2.5.1"
  # HTTP client
  dio: "^5.4.3"
  # Local storage
  shared_preferences: "^2.2.3"
  flutter_secure_storage: "^9.0.0"
  # Fonts
  google_fonts: "^6.2.1"
  # Images
  cached_network_image: "^3.3.1"
  # Animations
  flutter_animate: "^4.5.0"
  # Charts
  fl_chart: "^0.68.0"
  # Forms
  flutter_form_builder: "^10.3.0"
  form_builder_validators: "^11.3.0"
  # QR / Camera
  mobile_scanner: "^5.2.3"
  # Share
  share_plus: "^9.0.0"
  # Confetti
  confetti: "^0.7.0"
  # Rating bar
  flutter_rating_bar: "^4.0.1"
  # Shimmer skeleton loading
  shimmer: "^3.0.0"

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: "^3.0.0"

flutter:
  uses-material-design: true

  assets:
    - assets/images/covers/

  fonts: []
`;

// ---------------------------------------------------------------------------
// main.dart — enforces 430px max-width viewport constraint
// ---------------------------------------------------------------------------

const MAIN_DART = `import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
      // TODO: wire ThemeData from config/theme.dart
      home: const _MobileContainer(
        child: Scaffold(
          body: Center(child: Text('LibLog — scaffold complete')),
        ),
      ),
    );
  }
}

/// Enforces a max-width 430px mobile viewport (from OVERVIEW.md §10).
class _MobileContainer extends StatelessWidget {
  final Widget child;
  const _MobileContainer({required this.child});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 430),
        child: child,
      ),
    );
  }
}
`;

// ---------------------------------------------------------------------------
// Lib directory stub map
// ---------------------------------------------------------------------------

const LIB_STUBS = {
  // config
  "config/theme.dart":       "Light/dark ThemeData configuration",
  "config/colors.dart":      "AppColors constants — libPurple (#652D90), background, card, etc.",
  "config/text_styles.dart": "Typography scale: H1-H6, body, caption, button text styles",
  "config/constants.dart":   "App-wide constants: API base URL, fine rate, max viewport width",
  // providers
  "providers/auth_provider.dart":          "Auth state: login, logout, register, updateProfile",
  "providers/resources_provider.dart":     "Resource catalog state and search/filter",
  "providers/borrow_provider.dart":        "Borrow records: borrow, return, history",
  "providers/reservation_provider.dart":   "Reservations: create, cancel, list",
  "providers/notification_provider.dart":  "Notifications: list, markRead, unreadCount",
  "providers/attendance_provider.dart":    "Attendance: timeIn, timeOut, calendar heat map data",
  "providers/review_provider.dart":        "Reviews: fetch, upsert, delete for a resource",
  "providers/theme_provider.dart":         "ThemeMode state (light / dark / system)",
  // screens
  "screens/onboarding_screen.dart":    "5-step registration wizard",
  "screens/login_screen.dart":         "Login form with animated gradient header and demo button",
  "screens/home_screen.dart":          "Dashboard: greeting, announcements, stats cards",
  "screens/search_screen.dart":        "Catalog search with 300ms debounce and category filters",
  "screens/book_detail_screen.dart":   "Book metadata, ratings, borrow/reserve actions",
  "screens/borrowed_screen.dart":      "Active loans and borrowing history (Active/History tabs)",
  "screens/qr_scan_screen.dart":       "Simulated QR scanner for attendance / checkout",
  "screens/profile_screen.dart":       "User profile, stats, reading goal ring, menu",
  "screens/settings_screen.dart":      "Notifications toggles, dark mode toggle, logout",
  "screens/notifications_screen.dart": "Grouped notifications with swipe-to-dismiss",
  "screens/attendance_screen.dart":    "Calendar heat map and recent visit list",
  "screens/favorites_screen.dart":     "Saved/favorited books list with remove animation",
  "screens/reservations_screen.dart":  "Reservation list with Pending/Fulfilled filter tabs",
  "screens/edit_profile_screen.dart":  "Editable profile form (name, program, year level)",
  // widgets
  "widgets/bottom_nav.dart":      "5-tab sticky bottom navigation bar (hidden on login/scan)",
  "widgets/book_card.dart":       "Book result card with cover, title, author, availability",
  "widgets/section_card.dart":    "Standard card wrapper (borderRadius 24, flat in light mode)",
  "widgets/streak_pill.dart":     "Orange pill showing current streak count + flame icon",
  "widgets/greeting_header.dart": "Split-weight home screen greeting (RichText: regular+bold)",
  // services
  "services/api_service.dart":          "Dio HTTP client singleton with base options and interceptors",
  "services/auth_service.dart":         "Login, register, updateProfile API calls",
  "services/resource_service.dart":     "Catalog list/search/detail API calls",
  "services/borrow_service.dart":       "Borrow, return, list borrow records",
  "services/reservation_service.dart":  "Create, cancel, list reservations",
  "services/notification_service.dart": "Fetch notifications, mark as read",
  "services/attendance_service.dart":   "Time-in, time-out, fetch attendance records",
  "services/review_service.dart":       "Fetch, upsert, delete reviews",
  "services/storage_service.dart":      "SharedPreferences wrapper for persisted state",
  // models
  "models/user.dart":             "User data model (fromJson / toJson)",
  "models/resource.dart":         "Resource data model",
  "models/borrow_record.dart":    "BorrowRecord data model",
  "models/reservation.dart":      "Reservation data model",
  "models/notification.dart":     "Notification data model",
  "models/attendance.dart":       "Attendance data model",
  "models/review.dart":           "Review data model (@@unique userId+resourceId)",
  "models/library_settings.dart": "LibrarySettings singleton data model",
  // utils
  "utils/auth.dart":    "getAvatarInitials, getBorrowDays, getMaxBorrow (role-based rules)",
  "utils/covers.dart":  "coverMap and getBookCover — fuzzy title-to-asset-path mapping",
  "utils/helpers.dart": "formatDate, relative time, password strength checker, validators",
};

// ---------------------------------------------------------------------------
// Step 1: Backend (Node.js + Prisma + SQLite)
// ---------------------------------------------------------------------------

function stepBackend() {
  console.log("\n========================================");
  console.log(" STEP 1 — Backend (Node.js + Prisma)");
  console.log("========================================");

  mkdir(path.join(BACKEND_DIR, "prisma"));
  mkdir(path.join(BACKEND_DIR, "src", "app", "api"));

  // package.json
  const pkg = {
    name: "liblog-backend",
    version: "1.0.0",
    description: "LibLog REST API backend",
    scripts: {
      dev:         "ts-node-dev --respawn src/index.ts",
      build:       "tsc",
      "db:migrate":"prisma migrate dev",
      "db:seed":   "ts-node prisma/seed.ts",
      "db:studio": "prisma studio",
    },
    dependencies: {
      "@prisma/client": "^6.0.0",
    },
    devDependencies: {
      prisma:        "^6.0.0",
      typescript:    "^5.0.0",
      "ts-node":     "^10.9.2",
      "ts-node-dev": "^2.0.0",
      "@types/node": "^20.0.0",
    },
  };
  write(path.join(BACKEND_DIR, "package.json"), JSON.stringify(pkg, null, 2) + "\n");

  // .env (only if it doesn't already exist)
  const envPath = path.join(BACKEND_DIR, ".env");
  if (!fs.existsSync(envPath)) {
    write(envPath, 'DATABASE_URL="file:./dev.db"\n');
  } else {
    console.log("  [SKIP] .env already exists — not overwriting.");
  }

  // tsconfig.json
  const tsconfig = {
    compilerOptions: {
      target: "ES2020", module: "commonjs",
      lib: ["ES2020"], outDir: "./dist", rootDir: "./src",
      strict: true, esModuleInterop: true,
      skipLibCheck: true, forceConsistentCasingInFileNames: true,
    },
    include: ["src/**/*", "prisma/**/*"],
    exclude: ["node_modules", "dist"],
  };
  write(path.join(BACKEND_DIR, "tsconfig.json"), JSON.stringify(tsconfig, null, 2) + "\n");

  // schema.prisma
  write(path.join(BACKEND_DIR, "prisma", "schema.prisma"), PRISMA_SCHEMA);

  // seed.ts stub
  const seedStub = `// prisma/seed.ts
// TODO: implement seed data (3 users, 17 resources, borrow records, etc.)
import { PrismaClient } from '@prisma/client';
const prisma = new PrismaClient();

async function main() {
  console.log('Seeding database...');
}

main()
  .catch(console.error)
  .finally(() => prisma.$disconnect());
`;
  write(path.join(BACKEND_DIR, "prisma", "seed.ts"), seedStub);

  // npm install
  run("npm install", BACKEND_DIR, "npm install (backend)");

  // prisma generate (creates Prisma Client from schema)
  run("npx prisma generate", BACKEND_DIR, "prisma generate");

  // prisma migrate dev (creates dev.db + applies schema)
  run("npx prisma migrate dev --name init", BACKEND_DIR, "prisma migrate dev --name init");
}

// ---------------------------------------------------------------------------
// Step 2: Flutter create
// ---------------------------------------------------------------------------

function stepFlutterCreate() {
  console.log("\n========================================");
  console.log(" STEP 2 — Flutter Project");
  console.log("========================================");

  if (fs.existsSync(path.join(PROJECT_ROOT, "pubspec.yaml"))) {
    console.log("\n[SKIP] Flutter project already exists — skipping flutter create.");
    return;
  }

  // Verify Flutter is available
  const ver = spawnSync("flutter --version", {
    shell: true, encoding: "utf8", cwd: PROJECT_ROOT,
  });
  if (ver.status !== 0) {
    console.error("[ERROR] 'flutter' not found on PATH. Install Flutter 3.44 and retry.");
    process.exit(1);
  }
  const versionLine = (ver.stdout || ver.stderr || "").split("\n")[0];
  console.log(`\n    Flutter detected: ${versionLine.trim()}`);

  const parent = path.dirname(PROJECT_ROOT);
  const folder = path.basename(PROJECT_ROOT);

  run(
    `flutter create --org com.liblog --project-name ${folder} --platforms android,ios ${folder}`,
    parent,
    "flutter create com.liblog.app"
  );
}

// ---------------------------------------------------------------------------
// Step 3: pubspec.yaml
// ---------------------------------------------------------------------------

function stepPubspec() {
  console.log("\n========================================");
  console.log(" STEP 3 — pubspec.yaml");
  console.log("========================================");
  write(path.join(PROJECT_ROOT, "pubspec.yaml"), PUBSPEC);
}

// ---------------------------------------------------------------------------
// Step 4: lib/ structure
// ---------------------------------------------------------------------------

function stepLibStructure() {
  console.log("\n========================================");
  console.log(" STEP 4 — lib/ directory structure");
  console.log("========================================");

  // main.dart (enforces 430px viewport)
  write(path.join(LIB_DIR, "main.dart"), MAIN_DART);

  // All stubs
  for (const [relPath, desc] of Object.entries(LIB_STUBS)) {
    write(path.join(LIB_DIR, relPath), dartStub(desc));
  }

  // Asset directories
  for (const dir of [
    path.join(ASSETS_DIR, "images", "covers"),
    path.join(ASSETS_DIR, "fonts"),
  ]) {
    mkdir(dir);
    write(path.join(dir, ".gitkeep"), "");
  }
}

// ---------------------------------------------------------------------------
// Main
// ---------------------------------------------------------------------------

console.log("=".repeat(60));
console.log(`  LibLog Scaffold (Node.js v${process.versions.node})`);
console.log(`  Target: ${PROJECT_ROOT}`);
console.log("=".repeat(60));

fs.mkdirSync(PROJECT_ROOT, { recursive: true });

stepBackend();      // 1. Node.js + Prisma + SQLite
stepFlutterCreate(); // 2. flutter create
stepPubspec();       // 3. pubspec.yaml
stepLibStructure();  // 4. lib/ stubs + assets/

console.log("\n" + "=".repeat(60));
console.log("  Scaffold complete!");
console.log(`  Project root : ${PROJECT_ROOT}`);
console.log(`  Backend      : ${BACKEND_DIR}`);
console.log("\n  Next steps:");
console.log("  1. cd liblog ; flutter pub get");
console.log("  2. cd liblog/backend ; npx prisma studio   (browse DB)");
console.log("  3. cd liblog/backend ; npm run db:seed      (seed data)");
console.log("=".repeat(60));

# Setup Environment (Flutter & Prisma)

## Goal
Initialize the LibLog project workspace, including the Flutter 3.44 frontend application with the required folder structure, the mobile viewport constraints (max-width 430px), and the Node.js backend using Prisma ORM with the full 9 core database models.

## Inputs
- **Flutter SDK**: Version 3.44
- **Backend Environment**: Node.js and Prisma ORM (SQLite)

## Tools & Scripts
- `execution/scaffold_project.py` — **Primary tool.** Runs all four phases in sequence: verifies Flutter, runs `flutter create`, writes `pubspec.yaml`, creates the `lib/` stub structure, and initialises the Node.js backend with `schema.prisma`.

**Usage:**
```bash
python execution/scaffold_project.py --root C:/LLMS/liblog
```
*(Omit `--root` to default to `../liblog` relative to the `execution/` folder.)*

> **Note on Windows PowerShell:**
> If you encounter `Python was not found`, ensure a standard distribution of Python is installed (e.g., from python.org) and added to your PATH, or use `py` instead of `python` if the launcher is installed. Additionally, PowerShell does not support the `&&` operator by default; run commands sequentially or use `;` instead.

## Step-by-Step Instructions

### Phase 1: Flutter 3.44 Initialization
1. **Verify Flutter Version**: Ensure the system is running exactly Flutter version `3.44` (`flutter --version`). If not, use FVM (Flutter Version Management) or guide the user to install the correct version.
2. **Initialize Project**: Run `flutter create --org com.liblog --project-name liblog --platforms android,ios liblog` to scaffold the base application.
3. **Establish Project Structure**: Create the following directory tree as defined in `OVERVIEW.md`:
   ```text
   lib/
   ├── config/       (Theme, colors, text styles, constants)
   ├── providers/    (Riverpod state providers)
   ├── screens/      (14 app screens)
   ├── widgets/      (Reusable UI components)
   ├── services/     (API and business logic)
   ├── models/       (Data models)
   ├── utils/        (Helpers, covers, auth utilities)
   └── l10n/         (Localization)
   assets/
   ├── images/covers/
   backend/
   ```
4. **Install Dependencies**: Update `pubspec.yaml` with the required packages: `flutter_riverpod`, `dio`, `shared_preferences`, `flutter_secure_storage`, `cached_network_image`, `google_fonts`, `flutter_animate`, `flutter_form_builder`, `fl_chart`, `mobile_scanner`, and `share_plus`.
5. **Mobile Viewport Constraints**: The application is mobile-first. Ensure the root layout or main widget enforces a **max-width of 430px**, and the application is centered when run on larger screens or web.

### Phase 2: Prisma Backend Initialization
1. **Setup Backend Directory**: Navigate to `backend/` and initialize a Node.js project (`npm init -y`).
2. **Install Prisma**: Run `npm install prisma --save-dev` and initialize SQLite via `npx prisma init --datasource-provider sqlite`.
3. **Define the Database Models**: Populate `prisma/schema.prisma` with the full schema provided below.
4. **Apply Schema**: Execute `npx prisma migrate dev --name init` to generate the SQLite database and Prisma Client.

## Full Prisma Schema

```prisma
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
```

## Outputs
- A clean Flutter project scaffolded in accordance with LibLog's architecture, enforcing a 430px max-width viewport constraint.
- A functional SQLite database managed by Prisma containing all required relationships and constraints.

## Edge Cases & Error Handling
- **Flutter Version Mismatch**: If Flutter 3.44 is unavailable, halt the execution script and inform the user.
- **SQLite Database Lock**: If `prisma migrate` fails due to a locked file, clear the Prisma lock or stop running backend instances before retrying.
- **Dependency Conflicts**: If pubspec dependencies fail to resolve, ensure compatible versions for Dart 3.x are specified.
- **`intl` pin conflict** ⚠️: The Flutter SDK pins `intl` to `0.20.2` via `flutter_localizations`. `form_builder_validators ^10.x` requires `intl ^0.19.0` and will cause a version-solving failure. **Always use `form_builder_validators: "^11.3.0"` and `flutter_form_builder: "^10.3.0"`** — these are confirmed compatible with intl 0.20.2 (verified 2026-05-09).


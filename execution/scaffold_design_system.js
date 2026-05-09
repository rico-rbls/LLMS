#!/usr/bin/env node
/**
 * scaffold_design_system.js
 * Writes colors.dart, theme.dart, store_provider.dart,
 * updates main.dart, then git add/commit/push.
 *
 * Usage: node execution/scaffold_design_system.js
 */

const fs   = require("fs");
const path = require("path");
const { spawnSync } = require("child_process");

const ROOT = path.resolve(__dirname, "..", "liblog");
const LIB  = path.join(ROOT, "lib");

function write(rel, content) {
  const abs = path.join(LIB, rel);
  fs.mkdirSync(path.dirname(abs), { recursive: true });
  fs.writeFileSync(abs, content, "utf8");
  console.log(`  wrote  lib/${rel}`);
}

function run(cmd, cwd, label) {
  console.log(`\n>>> ${label}\n    $ ${cmd}`);
  const r = spawnSync(cmd, { cwd, shell: true, stdio: "inherit" });
  if (r.status !== 0) { console.error(`[ERROR] ${label} failed.`); process.exit(r.status || 1); }
  console.log(`    ✓ done.`);
}

// ─── 1. colors.dart ─────────────────────────────────────────────────────────
write("config/colors.dart", `
import 'package:flutter/material.dart';

/// AppColors — single source of truth for the LibLog colour system.
/// Source: BRANDING.md §2
class AppColors {
  AppColors._();

  // ── Primary brand ────────────────────────────────────────────────────────
  static const Color libPurple      = Color(0xFF652D90); // Lib Purple 500
  static const Color libPurpleLight = Color(0xFF7B3FA8);
  static const Color libPurpleDark  = Color(0xFF522575);

  // ── Full purple palette ──────────────────────────────────────────────────
  static const Color purple50  = Color(0xFFF5EDF9);
  static const Color purple100 = Color(0xFFE8D5F3);
  static const Color purple200 = Color(0xFFD4ADE7);
  static const Color purple300 = Color(0xFFB87DD4);
  static const Color purple400 = Color(0xFF9B5BBF);
  static const Color purple500 = Color(0xFF652D90); // primary
  static const Color purple600 = Color(0xFF5A2880);
  static const Color purple700 = Color(0xFF4A2068);
  static const Color purple800 = Color(0xFF3A1850);
  static const Color purple900 = Color(0xFF2A1038);

  // ── Light mode semantic tokens ───────────────────────────────────────────
  static const Color background         = Color(0xFFf2f2fa); // lavender-tinted
  static const Color foreground         = Color(0xFF1A1A1A);
  static const Color card               = Color(0xFFFFFFFF);
  static const Color cardForeground     = Color(0xFF1A1A1A);
  static const Color secondary          = Color(0xFFF5EDF9);
  static const Color secondaryForeground= Color(0xFF4A2068);
  static const Color muted              = Color(0xFFF5EDF9);
  static const Color mutedForeground    = Color(0xFF8B6B9F);
  static const Color border             = Color(0xFFE8D5F3);
  static const Color input              = Color(0xFFE8D5F3);
  static const Color ring               = Color(0xFF652D90);
  static const Color destructive        = Color(0xFFDC2626);

  // ── Neutral grays ────────────────────────────────────────────────────────
  static const Color gray50  = Color(0xFFf2f2fa);
  static const Color gray100 = Color(0xFFF3F4F6);
  static const Color gray200 = Color(0xFFE5E7EB);
  static const Color gray300 = Color(0xFFD1D5DB);
  static const Color gray400 = Color(0xFF9CA3AF);
  static const Color gray500 = Color(0xFF6B7280);
  static const Color gray600 = Color(0xFF4B5563);
  static const Color gray700 = Color(0xFF374151);
  static const Color gray800 = Color(0xFF1F2937);
  static const Color gray900 = Color(0xFF111827);

  // ── Dark Purple Mode surfaces ────────────────────────────────────────────
  static const Color darkBackground = Color(0xFF110a1e); // deep purple-black
  static const Color darkCard       = Color(0xFF1a0e2e); // dark purple surface

  // Translucent overlays used over dark purple surfaces
  static const Color darkOverlay05 = Color(0x0DFFFFFF); // white 5%
  static const Color darkOverlay10 = Color(0x1AFFFFFF); // white 10%
  static const Color darkOverlay15 = Color(0x26FFFFFF); // white 15%

  // ── Status colours ───────────────────────────────────────────────────────
  static const Color success    = Color(0xFF16A34A);
  static const Color warning    = Color(0xFFCA8A04);
  static const Color error      = Color(0xFFDC2626);
  static const Color info       = Color(0xFF652D90);

  // ── Chart palette ────────────────────────────────────────────────────────
  static const Color chart1 = Color(0xFF652D90);
  static const Color chart2 = Color(0xFF0D9488);
  static const Color chart3 = Color(0xFF2563EB);
  static const Color chart4 = Color(0xFFEAB308);
  static const Color chart5 = Color(0xFFEA580C);
}
`.trimStart());

// ─── 2. theme.dart ──────────────────────────────────────────────────────────
write("config/theme.dart", `
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'colors.dart';

/// AppTheme — exposes [light] and [dark] ThemeData.
///
/// Shadow / Elevation rules from BRANDING.md §5:
///   Light mode → ALL cards/buttons are FLAT (elevation 0, no BoxShadow).
///   Dark mode  → subtle shadows used for depth.
///   BOTH modes → BottomNav and QR scan button retain shadows.
class AppTheme {
  AppTheme._();

  // ─── Text theme (Inter via google_fonts) ──────────────────────────────
  static TextTheme _buildTextTheme(Color primary, Color secondary) {
    final base = GoogleFonts.interTextTheme();
    return base.copyWith(
      // H1 — 30px bold
      displayLarge: base.displayLarge?.copyWith(
        fontSize: 30, fontWeight: FontWeight.w700,
        letterSpacing: -0.5, color: primary,
      ),
      // H2 — 24px bold
      displayMedium: base.displayMedium?.copyWith(
        fontSize: 24, fontWeight: FontWeight.w700,
        letterSpacing: -0.3, color: primary,
      ),
      // H3 — 20px semibold
      titleLarge: base.titleLarge?.copyWith(
        fontSize: 20, fontWeight: FontWeight.w600,
        letterSpacing: -0.2, color: primary,
      ),
      // H4 — 18px semibold
      titleMedium: base.titleMedium?.copyWith(
        fontSize: 18, fontWeight: FontWeight.w600, color: primary,
      ),
      // H5 — 16px medium
      titleSmall: base.titleSmall?.copyWith(
        fontSize: 16, fontWeight: FontWeight.w500, color: primary,
      ),
      // Body — 16px regular
      bodyLarge: base.bodyLarge?.copyWith(
        fontSize: 16, fontWeight: FontWeight.w400, color: primary,
      ),
      // Body Small — 14px regular
      bodyMedium: base.bodyMedium?.copyWith(
        fontSize: 14, fontWeight: FontWeight.w400, color: secondary,
      ),
      // Caption — 12px regular
      bodySmall: base.bodySmall?.copyWith(
        fontSize: 12, fontWeight: FontWeight.w400, color: secondary,
      ),
      // Button label — 16px semibold
      labelLarge: base.labelLarge?.copyWith(
        fontSize: 16, fontWeight: FontWeight.w600, letterSpacing: 0.2,
      ),
      labelMedium: base.labelMedium?.copyWith(
        fontSize: 14, fontWeight: FontWeight.w500, letterSpacing: 0.1,
      ),
      labelSmall: base.labelSmall?.copyWith(
        fontSize: 12, fontWeight: FontWeight.w500,
      ),
    );
  }

  // ─── Light Theme ──────────────────────────────────────────────────────
  /// FLAT design: no shadows on cards or buttons. Visual separation
  /// comes from the contrast between #f2f2fa background and #FFFFFF cards.
  static final ThemeData light = ThemeData(
    brightness: Brightness.light,
    useMaterial3: true,
    primaryColor: AppColors.libPurple,
    scaffoldBackgroundColor: AppColors.background,
    cardColor: AppColors.card,
    dividerColor: AppColors.border,

    colorScheme: const ColorScheme.light(
      primary:          AppColors.libPurple,
      onPrimary:        Colors.white,
      secondary:        AppColors.purple100,
      onSecondary:      AppColors.purple700,
      surface:          AppColors.card,
      onSurface:        AppColors.foreground,
      error:            AppColors.destructive,
      onError:          Colors.white,
    ),

    textTheme: _buildTextTheme(AppColors.foreground, AppColors.mutedForeground),

    // Flat cards — elevation 0, no shadow
    cardTheme: CardTheme(
      elevation: 0,
      color: AppColors.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: const BorderSide(color: AppColors.border, width: 1),
      ),
      margin: EdgeInsets.zero,
    ),

    // Primary button — purple gradient via DecoratedBox; ElevatedButton base
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.libPurple,
        foregroundColor: Colors.white,
        minimumSize: const Size.fromHeight(48),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.libPurple,
        side: const BorderSide(color: AppColors.libPurple),
        minimumSize: const Size(0, 44),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),

    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.libPurple,
        minimumSize: const Size(0, 44),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.libPurple, width: 2),
      ),
      labelStyle: const TextStyle(color: AppColors.libPurple, fontSize: 12, fontWeight: FontWeight.w500),
      hintStyle: const TextStyle(color: AppColors.gray400),
    ),

    // BottomNav — has shadow in BOTH modes (BRANDING.md §5)
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.card,
      selectedItemColor: AppColors.libPurple,
      unselectedItemColor: AppColors.mutedForeground,
      showUnselectedLabels: true,
      elevation: 0, // shadow applied manually via BoxDecoration
      type: BottomNavigationBarType.fixed,
    ),

    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.background,
      foregroundColor: AppColors.foreground,
      elevation: 0,
      scrolledUnderElevation: 0,
    ),

    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((s) =>
        s.contains(WidgetState.selected) ? AppColors.libPurple : AppColors.gray300),
      trackColor: WidgetStateProperty.resolveWith((s) =>
        s.contains(WidgetState.selected) ? AppColors.purple200 : AppColors.gray200),
    ),

    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: AppColors.libPurple,
      linearTrackColor: AppColors.purple100,
    ),

    chipTheme: ChipThemeData(
      backgroundColor: AppColors.purple50,
      labelStyle: const TextStyle(color: AppColors.libPurple, fontSize: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9999)),
      side: BorderSide.none,
    ),
  );

  // ─── Dark Purple Theme ────────────────────────────────────────────────
  /// Deep purple base (#110a1e). Cards use subtle BoxShadows for depth.
  /// All surface tints use translucent white overlays over the dark purple base.
  static final ThemeData dark = ThemeData(
    brightness: Brightness.dark,
    useMaterial3: true,
    primaryColor: AppColors.libPurple,
    scaffoldBackgroundColor: AppColors.darkBackground,
    cardColor: AppColors.darkCard,
    dividerColor: AppColors.darkOverlay10,

    colorScheme: const ColorScheme.dark(
      primary:          AppColors.libPurple,
      onPrimary:        Colors.white,
      secondary:        AppColors.purple800,
      onSecondary:      AppColors.purple200,
      surface:          AppColors.darkCard,
      onSurface:        Colors.white,
      error:            AppColors.destructive,
      onError:          Colors.white,
    ),

    textTheme: _buildTextTheme(Colors.white, AppColors.gray400),

    cardTheme: CardTheme(
      elevation: 0,
      color: AppColors.darkCard,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(color: AppColors.darkOverlay10, width: 1),
      ),
      margin: EdgeInsets.zero,
      // Subtle depth shadow for dark mode
      shadowColor: Colors.black.withOpacity(0.4),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.libPurpleLight,
        foregroundColor: Colors.white,
        minimumSize: const Size.fromHeight(48),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.purple300,
        side: const BorderSide(color: AppColors.purple600),
        minimumSize: const Size(0, 44),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),

    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.purple300,
        minimumSize: const Size(0, 44),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.darkOverlay10,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.darkOverlay10),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.darkOverlay10),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.libPurple, width: 2),
      ),
      labelStyle: const TextStyle(color: AppColors.purple300, fontSize: 12),
      hintStyle: TextStyle(color: Colors.white.withOpacity(0.4)),
    ),

    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: AppColors.darkCard,
      selectedItemColor: Colors.white,
      unselectedItemColor: Colors.white.withOpacity(0.4),
      showUnselectedLabels: true,
      elevation: 0,
      type: BottomNavigationBarType.fixed,
    ),

    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.darkBackground,
      foregroundColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 0,
    ),

    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((s) =>
        s.contains(WidgetState.selected) ? AppColors.libPurple : Colors.white38),
      trackColor: WidgetStateProperty.resolveWith((s) =>
        s.contains(WidgetState.selected) ? AppColors.purple700 : AppColors.darkOverlay10),
    ),

    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: AppColors.libPurple,
      linearTrackColor: AppColors.purple800,
    ),

    chipTheme: ChipThemeData(
      backgroundColor: AppColors.darkOverlay10,
      labelStyle: const TextStyle(color: AppColors.purple300, fontSize: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9999)),
      side: BorderSide.none,
    ),
  );

  // ── Shared shadow helpers ────────────────────────────────────────────────

  /// BottomNav shadow — active in BOTH light and dark (BRANDING.md §5).
  static List<BoxShadow> get bottomNavShadow => [
    BoxShadow(
      color: Colors.black.withOpacity(0.10),
      blurRadius: 6,
      offset: const Offset(0, -1),
    ),
  ];

  /// QR scan center FAB shadow — active in BOTH modes (BRANDING.md §5).
  static List<BoxShadow> get qrScanShadow => [
    BoxShadow(
      color: AppColors.libPurple.withOpacity(0.40),
      blurRadius: 10,
      spreadRadius: 2,
    ),
  ];

  /// Standard dark-mode card shadow.
  static List<BoxShadow> get darkCardShadow => [
    BoxShadow(
      color: Colors.black.withOpacity(0.12),
      blurRadius: 6,
      offset: const Offset(0, -1),
    ),
  ];

  /// Dark-mode brand glow (primary CTA when active).
  static List<BoxShadow> get darkBrandGlow => [
    BoxShadow(
      color: AppColors.libPurple.withOpacity(0.35),
      blurRadius: 20,
      spreadRadius: 4,
    ),
  ];
}
`.trimStart());

// ─── 3. store_provider.dart ─────────────────────────────────────────────────
write("providers/store_provider.dart", `
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/storage_service.dart';

/// Exposes the already-initialised [StorageService] singleton to the
/// Riverpod graph. StorageService.init() MUST be called in main() before
/// ProviderScope is mounted.
///
/// Usage:
///   final storage = ref.read(storageServiceProvider);
final storageServiceProvider = Provider<StorageService>((ref) {
  return StorageService.instance;
});

// ─── Theme state ────────────────────────────────────────────────────────────

/// Persisted theme mode: 'light' | 'dark'. Defaults to light.
const _kThemeMode = 'liblog-store:themeMode';

class ThemeModeNotifier extends Notifier<bool> {
  // [state] = true means dark mode is active.
  @override
  bool build() {
    final prefs = ref.read(storageServiceProvider);
    return prefs.loadThemeMode();
  }

  void toggle() {
    state = !state;
    ref.read(storageServiceProvider).saveThemeMode(state);
  }

  void setDark(bool isDark) {
    state = isDark;
    ref.read(storageServiceProvider).saveThemeMode(isDark);
  }
}

/// [true] = Dark Purple Mode, [false] = Light Mode.
final themeModeProvider = NotifierProvider<ThemeModeNotifier, bool>(
  ThemeModeNotifier.new,
);

// ─── Favorites state ─────────────────────────────────────────────────────────

class FavoritesNotifier extends Notifier<List<String>> {
  @override
  List<String> build() {
    return ref.read(storageServiceProvider).loadFavorites();
  }

  void toggle(String resourceId) {
    final updated = List<String>.from(state);
    if (updated.contains(resourceId)) {
      updated.remove(resourceId);
    } else {
      updated.add(resourceId);
    }
    state = updated;
    ref.read(storageServiceProvider).saveFavorites(updated);
  }

  bool isFavorite(String resourceId) => state.contains(resourceId);
}

final favoritesProvider = NotifierProvider<FavoritesNotifier, List<String>>(
  FavoritesNotifier.new,
);
`.trimStart());

// ─── 4. Update storage_service.dart — add themeMode helpers ─────────────────
// We append the two new helpers without touching the existing content.
const storagePath = path.join(LIB, "services", "storage_service.dart");
let storageContent = fs.readFileSync(storagePath, "utf8");

const themeMethods = `
  // -------------------------------------------------------------------------
  // Theme mode
  // -------------------------------------------------------------------------

  Future<void> saveThemeMode(bool isDark) =>
      _prefs.setBool('liblog-store:themeMode', isDark);

  bool loadThemeMode() =>
      _prefs.getBool('liblog-store:themeMode') ?? false;
`;

// Insert before the closing brace of the class
storageContent = storageContent.replace(
  /(\s*\/\/ -{40,}\s*\/\/ Full clear \(logout\))/,
  `${themeMethods}\n$1`
);
fs.writeFileSync(storagePath, storageContent, "utf8");
console.log("  patched lib/services/storage_service.dart (themeMode helpers)");

// ─── 5. main.dart ────────────────────────────────────────────────────────────
write("main.dart", `
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'config/theme.dart';
import 'providers/store_provider.dart';
import 'services/storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialise liblog-store (SharedPreferences) before providers start.
  await StorageService.init();

  runApp(const ProviderScope(child: LibLogApp()));
}

class LibLogApp extends ConsumerWidget {
  const LibLogApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(themeModeProvider);

    return MaterialApp(
      title: 'LibLog',
      debugShowCheckedModeBanner: false,
      theme:     AppTheme.light,
      darkTheme:  AppTheme.dark,
      themeMode:  isDark ? ThemeMode.dark : ThemeMode.light,
      home: const _MobileContainer(
        child: Scaffold(
          body: Center(child: Text('LibLog — design system ready')),
        ),
      ),
    );
  }
}

/// Enforces the 430px max-width mobile viewport from OVERVIEW.md §10.
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
`.trimStart());

// ─── 6. Flutter pub get ──────────────────────────────────────────────────────
run("flutter pub get", ROOT, "flutter pub get");

// ─── 7. Git sync ─────────────────────────────────────────────────────────────
const GIT = path.resolve(ROOT, "..");
run("git add .", GIT, "git add .");
run(`git commit -m "feat: implement design system and riverpod store"`, GIT, "git commit");
run("git push", GIT, "git push");

console.log("\n✅  Design system scaffold complete.");
console.log("    AppTheme.light and AppTheme.dark are live.");
console.log("    Riverpod store wired to liblog-store via StorageService.");

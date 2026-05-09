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
    cardTheme: CardThemeData(
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

    cardTheme: CardThemeData(
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

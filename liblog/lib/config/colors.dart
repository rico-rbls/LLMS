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

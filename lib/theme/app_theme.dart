import 'package:flutter/material.dart';

/// Centralized Design System & Theme for the Daily Habit Tracker.
///
/// Features a premium dark visual identity:
/// - Deep midnight navy background (#0B1020).
/// - Electric violet and soft cyan gradients.
/// - Glassmorphic borders and glow effects.
/// - Modern typography hierarchy.
class AppTheme {
  // Brand Background Colors
  static const Color bgMidnight = Color(0xFF0B1020);
  static const Color surfaceCard = Color(0xFF151C33);
  static const Color surfaceElevated = Color(0xFF1B2341);
  static const Color surfaceGlass = Color(0x1AFFFFFF); // 10% white for glass

  // Borders & Accents
  static const Color borderSubtle = Color(0xFF222D4F);
  static const Color borderGlass = Color(0x33A855F7); // Subtle violet shimmer
  static const Color borderHighlight = Color(0xFF8B5CF6);

  // Vibrant Accents & Gradients
  static const Color violetPrimary = Color(0xFF8B5CF6);
  static const Color purpleDeep = Color(0xFF7C3AED);
  static const Color cyanAccent = Color(0xFF38BDF8);
  static const Color indigoAccent = Color(0xFF6366F1);
  static const Color emeraldSuccess = Color(0xFF10B981);
  static const Color amberWarning = Color(0xFFF59E0B);
  static const Color roseDanger = Color(0xFFF43F5E);
  static const Color pinkAccent = Color(0xFFEC4899);

  // Text Colors
  static const Color textPrimary = Color(0xFFF8FAFC);
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color textMuted = Color(0xFF64748B);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF8B5CF6), Color(0xFF6366F1)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient progressCardGradient = LinearGradient(
    colors: [
      Color(0xFF7C3AED),
      Color(0xFF4F46E5),
      Color(0xFF0284C7),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient buttonGradient = LinearGradient(
    colors: [Color(0xFF9333EA), Color(0xFF6366F1)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient streakGradient = LinearGradient(
    colors: [Color(0xFFF97316), Color(0xFFEF4444)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient glassGradient = LinearGradient(
    colors: [
      Color(0x26FFFFFF),
      Color(0x0DFFFFFF),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Box Shadows & Glows
  static List<BoxShadow> get violetGlow => [
        BoxShadow(
          color: purpleDeep.withValues(alpha: 0.35),
          blurRadius: 20.0,
          offset: const Offset(0, 8),
        ),
      ];

  static List<BoxShadow> get cardShadow => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.35),
          blurRadius: 14.0,
          offset: const Offset(0, 4),
        ),
      ];

  static List<BoxShadow> get subtleGlow => [
        BoxShadow(
          color: violetPrimary.withValues(alpha: 0.15),
          blurRadius: 12.0,
          offset: const Offset(0, 2),
        ),
      ];

  /// Material 3 Dark Theme configured for maximum visual quality.
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: bgMidnight,
      colorScheme: const ColorScheme.dark(
        primary: violetPrimary,
        secondary: cyanAccent,
        surface: surfaceCard,
        error: roseDanger,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: textPrimary,
      ),
      fontFamily: 'Roboto',
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: textPrimary),
        titleTextStyle: TextStyle(
          color: textPrimary,
          fontSize: 22.0,
          fontWeight: FontWeight.bold,
          letterSpacing: -0.5,
        ),
      ),
      cardTheme: CardThemeData(
        color: surfaceCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
          side: const BorderSide(color: borderSubtle, width: 1.0),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: surfaceElevated,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24.0),
          side: const BorderSide(color: borderGlass, width: 1.2),
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: surfaceElevated,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28.0)),
        ),
      ),
    );
  }
}

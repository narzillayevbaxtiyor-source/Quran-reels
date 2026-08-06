/// Theme configuration for the QuranReels app.
///
/// Provides both light and dark theme data using Material 3 design
/// with a Quran-inspired color palette.
library;

import 'package:flutter/material.dart';

/// App theme class that encapsulates all theme data.
class AppTheme {
  AppTheme._();

  // ─── Brand Colors ────────────────────────────────────────────────

  /// Primary deep green inspired by traditional Islamic art
  static const Color primaryColor = Color(0xFF1B5E20);

  /// Secondary gold accent color
  static const Color secondaryColor = Color(0xFFFFD700);

  /// Surface / background tint
  static const Color surfaceColor = Color(0xFFF5F5F0);

  // Light theme colors
  static const Color _lightPrimary = Color(0xFF1B5E20);
  static const Color _lightOnPrimary = Color(0xFFFFFFFF);
  static const Color _lightPrimaryContainer = Color(0xFFA5D6A7);
  static const Color _lightSecondary = Color(0xFFB8860B);
  static const Color _lightOnSecondary = Color(0xFFFFFFFF);
  static const Color _lightSurface = Color(0xFFFAFAF5);
  static const Color _lightOnSurface = Color(0xFF1C1B1F);
  static const Color _lightBackground = Color(0xFFFFFDF7);
  static const Color _lightError = Color(0xFFBA1A1A);

  // Dark theme colors
  static const Color _darkPrimary = Color(0xFF66BB6A);
  static const Color _darkOnPrimary = Color(0xFF003300);
  static const Color _darkPrimaryContainer = Color(0xFF004D00);
  static const Color _darkSecondary = Color(0xFFFFD700);
  static const Color _darkOnSecondary = Color(0xFF3E2F00);
  static const Color _darkSurface = Color(0xFF121212);
  static const Color _darkOnSurface = Color(0xFFE6E1E5);
  static const Color _darkBackground = Color(0xFF0A0A0A);
  static const Color _darkError = Color(0xFFFFB4AB);

  // ─── Light Theme ─────────────────────────────────────────────────

  static ThemeData get lightTheme {
    final colorScheme = const ColorScheme.light(
      primary: _lightPrimary,
      onPrimary: _lightOnPrimary,
      primaryContainer: _lightPrimaryContainer,
      secondary: _lightSecondary,
      onSecondary: _lightOnSecondary,
      surface: _lightSurface,
      onSurface: _lightOnSurface,
      error: _lightError,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      brightness: Brightness.light,
      scaffoldBackgroundColor: _lightBackground,
      appBarTheme: const AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.transparent,
        foregroundColor: _lightOnSurface,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        elevation: 8,
        backgroundColor: _lightSurface,
        selectedItemColor: _lightPrimary,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        unselectedLabelStyle: TextStyle(fontSize: 12),
      ),
      cardTheme: CardTheme(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        color: _lightSurface,
      ),
      iconTheme: const IconThemeData(color: _lightPrimary),
      dividerTheme: const DividerThemeData(
        color: Color(0xFFE0E0E0),
        thickness: 1,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  // ─── Dark Theme ──────────────────────────────────────────────────

  static ThemeData get darkTheme {
    final colorScheme = const ColorScheme.dark(
      primary: _darkPrimary,
      onPrimary: _darkOnPrimary,
      primaryContainer: _darkPrimaryContainer,
      secondary: _darkSecondary,
      onSecondary: _darkOnSecondary,
      surface: _darkSurface,
      onSurface: _darkOnSurface,
      error: _darkError,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: _darkBackground,
      appBarTheme: const AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.transparent,
        foregroundColor: _darkOnSurface,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        elevation: 8,
        backgroundColor: _darkSurface,
        selectedItemColor: _darkPrimary,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        unselectedLabelStyle: TextStyle(fontSize: 12),
      ),
      cardTheme: CardTheme(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        color: _darkSurface,
      ),
      iconTheme: const IconThemeData(color: _darkPrimary),
      dividerTheme: const DividerThemeData(
        color: Color(0xFF2C2C2C),
        thickness: 1,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}

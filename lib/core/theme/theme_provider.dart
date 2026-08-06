/// Theme mode enum and provider for toggling between light/dark themes.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/app_constants.dart';

/// Available theme modes for the app.
enum AppThemeMode {
  /// System default theme
  system,

  /// Always light theme
  light,

  /// Always dark theme
  dark,
}

/// Extension on [AppThemeMode] to convert to and from [ThemeMode].
extension AppThemeModeExtension on AppThemeMode {
  ThemeMode get themeMode {
    switch (this) {
      case AppThemeMode.system:
        return ThemeMode.system;
      case AppThemeMode.light:
        return ThemeMode.light;
      case AppThemeMode.dark:
        return ThemeMode.dark;
    }
  }

  String get label {
    switch (this) {
      case AppThemeMode.system:
        return 'Tizim';
      case AppThemeMode.light:
        return 'Yorug\'';
      case AppThemeMode.dark:
        return 'Qorong\'u';
    }
  }

  IconData get icon {
    switch (this) {
      case AppThemeMode.system:
        return Icons.settings_brightness;
      case AppThemeMode.light:
        return Icons.light_mode;
      case AppThemeMode.dark:
        return Icons.dark_mode;
    }
  }
}

/// Provider that manages the current theme mode selection.
///
/// Persists the selection to [SharedPreferences] and notifies
/// listeners when the theme changes.
final themeModeProvider =
    StateNotifierProvider<ThemeModeNotifier, AppThemeMode>((ref) {
  return ThemeModeNotifier();
});

/// [StateNotifier] that handles theme mode persistence and toggling.
class ThemeModeNotifier extends StateNotifier<AppThemeMode> {
  ThemeModeNotifier() : super(AppThemeMode.system) {
    _loadSavedTheme();
  }

  /// Loads the previously saved theme preference.
  Future<void> _loadSavedTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final savedIndex = prefs.getInt(AppConstants.prefsThemeMode) ?? 0;
    state = AppThemeMode.values[savedIndex.clamp(0, 2)];
  }

  /// Sets the theme mode and persists the selection.
  Future<void> setThemeMode(AppThemeMode mode) async {
    state = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(AppConstants.prefsThemeMode, mode.index);
  }

  /// Cycles through the available theme modes.
  void toggleTheme() {
    final nextIndex = (state.index + 1) % AppThemeMode.values.length;
    setThemeMode(AppThemeMode.values[nextIndex]);
  }
}

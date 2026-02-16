import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service to manage theme preferences (Light/Dark/System)
/// Uses SharedPreferences to persist user choice
class ThemeService extends ChangeNotifier {
  static const String _themeKey = 'theme_mode';

  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  ThemeService() {
    _loadThemeMode();
  }

  /// Load theme mode from SharedPreferences
  Future<void> _loadThemeMode() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedTheme = prefs.getString(_themeKey);

      if (savedTheme != null) {
        _themeMode = ThemeMode.values.firstWhere(
          (mode) => mode.toString() == savedTheme,
          orElse: () => ThemeMode.system,
        );
        notifyListeners();
        print('✅ [THEME] Loaded theme mode: $_themeMode');
      } else {
        print('ℹ️  [THEME] No saved theme, using system default');
      }
    } catch (error) {
      print('❌ [THEME] Error loading theme mode: $error');
    }
  }

  /// Save and apply new theme mode
  Future<void> setThemeMode(ThemeMode mode) async {
    try {
      _themeMode = mode;
      notifyListeners();

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_themeKey, mode.toString());
      print('✅ [THEME] Saved theme mode: $mode');
    } catch (error) {
      print('❌ [THEME] Error saving theme mode: $error');
    }
  }

  /// Toggle between Light and Dark (skips System)
  Future<void> toggleTheme() async {
    final newMode = _themeMode == ThemeMode.dark
        ? ThemeMode.light
        : ThemeMode.dark;
    await setThemeMode(newMode);
  }

  /// Get user-friendly string for current theme
  String get themeName {
    switch (_themeMode) {
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
      case ThemeMode.system:
        return 'System';
    }
  }

  /// Check if current theme is dark
  bool get isDark => _themeMode == ThemeMode.dark;

  /// Check if current theme is light
  bool get isLight => _themeMode == ThemeMode.light;

  /// Check if using system theme
  bool get isSystem => _themeMode == ThemeMode.system;
}

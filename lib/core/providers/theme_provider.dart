import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  static const _storageKey = 'theme_mode';

  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  Future<void> loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final storedMode = prefs.getString(_storageKey);

    if (storedMode == 'light') {
      _themeMode = ThemeMode.light;
    } else if (storedMode == 'dark') {
      _themeMode = ThemeMode.dark;
    } else {
      _themeMode = ThemeMode.system;
    }

    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode == mode) {
      return;
    }

    _themeMode = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, _themeMode.name);
    notifyListeners();
  }

  Future<void> setSystemTheme() async => setThemeMode(ThemeMode.system);
  Future<void> setLightTheme() async => setThemeMode(ThemeMode.light);
  Future<void> setDarkTheme() async => setThemeMode(ThemeMode.dark);
}

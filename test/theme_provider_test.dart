import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hoople_mobile_app/core/providers/theme_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  group('ThemeProvider', () {
    test('updates theme mode and notifies listeners', () async {
      final provider = ThemeProvider();
      var notified = false;

      provider.addListener(() {
        notified = true;
      });

      await provider.setThemeMode(ThemeMode.dark);

      expect(provider.themeMode, ThemeMode.dark);
      expect(notified, isTrue);
    });

    test('supports light and dark toggling', () async {
      final provider = ThemeProvider();

      await provider.setLightTheme();
      expect(provider.themeMode, ThemeMode.light);

      await provider.setDarkTheme();
      expect(provider.themeMode, ThemeMode.dark);
    });
  });
}

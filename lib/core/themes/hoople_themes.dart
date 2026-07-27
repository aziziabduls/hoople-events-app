import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

const MaterialColor seedColor = MaterialColor(0xffF5A623, {});

const PageTransitionsTheme _pageTransitionsTheme = PageTransitionsTheme(
  builders: {
    TargetPlatform.android: FadeForwardsPageTransitionsBuilder(),
    TargetPlatform.iOS: FadeForwardsPageTransitionsBuilder(),
  },
);

abstract final class HoopleThemes {
  static ThemeData get light => _theme(Brightness.light);

  static ThemeData get dark => _theme(Brightness.dark);

  // GoogleFonts.plusJakartaSansTextTheme() without a base bakes in light-theme
  // text colors, breaking dark mode; derive it from the brightness-correct
  // base theme instead.
  static ThemeData _theme(Brightness brightness) {
    final ThemeData base = ThemeData(
      colorSchemeSeed: Colors.primaries.elementAt(12),
      brightness: brightness,
    );

    return base.copyWith(
      textTheme: GoogleFonts.plusJakartaSansTextTheme(base.textTheme),
      pageTransitionsTheme: _pageTransitionsTheme,
      appBarTheme: AppBarTheme(
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: brightness == Brightness.dark
              ? Brightness.light
              : Brightness.dark,
          statusBarBrightness: brightness,
          systemNavigationBarColor: Colors.transparent,
          systemNavigationBarIconBrightness: brightness == Brightness.dark
              ? Brightness.light
              : Brightness.dark,
          systemNavigationBarContrastEnforced: false,
          systemStatusBarContrastEnforced: false,
        ),
      ),
    );
  }
}

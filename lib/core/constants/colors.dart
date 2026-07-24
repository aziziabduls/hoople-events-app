import 'package:flutter/material.dart';

class MyColor {
  // Hoople's Color Palette
  static Color hooplePurple = hexToColor('#A020F0');
  static Color hoopleCharcoal = hexToColor('#313842');
  static Color lightScaffoldBackgroundColor = hexToColor('#F9F9F9');
  // static Color darkScaffoldBackgroundColor = hexToColor('#2F2E2E');
  static Color darkScaffoldBackgroundColor = Color.fromARGB(255, 30, 29, 29);
  static Color glowStick = hexToColor('#e0f432');
  static Color white = Colors.white;
  static Color black = Color.fromARGB(255, 30, 29, 29);
  static Color scavBlue = hexToColor('#A020F0');
  static Color scavGreyTextField = hexToColor('#F1F1F1');

  // Custom color palette
  static Color systemBlue = hexToColor('#007AFF');
  static Color systemGreen = hexToColor('#34C759');
  static Color systemIndigo = hexToColor('#5856D6');
  static Color systemOrange = hexToColor('#FF9500');
  static Color systemPink = hexToColor('#FF2D55');
  static Color systemPurple = hexToColor('#AF52DE');
  static Color systemRed = hexToColor('#FF3B30');
  static Color systemTeal = hexToColor('#5AC8FA');
  static Color systemYellow = hexToColor('#FFCC00');
}

Color hexToColor(String hex) {
  assert(
    RegExp(r'^#([0-9a-fA-F]{6})|([0-9a-fA-F]{8})$').hasMatch(hex),
    'hex color must be #rrggbb or #rrggbbaa',
  );

  return Color(
    int.parse(hex.substring(1), radix: 16) +
        (hex.length == 7 ? 0xff000000 : 0x00000000),
  );
}

import 'package:flutter/material.dart';
import 'package:hoople_mobile_app/core/providers/theme_provider.dart';
import 'package:hoople_mobile_app/hoople_app.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()..loadThemeMode()),
      ],
      child: const HoopleApp(),
    ),
  );
}

import 'package:flutter/material.dart';
import 'package:hoople_mobile_app/core/providers/theme_provider.dart';
import 'package:hoople_mobile_app/core/themes/hoople_themes.dart';
import 'package:hoople_mobile_app/routes/app_router.dart';
import 'package:provider/provider.dart';

class HoopleApp extends StatelessWidget {
  const HoopleApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    return MaterialApp.router(
      title: 'Hoople App',
      debugShowCheckedModeBanner: false,
      themeMode: themeProvider.themeMode,
      theme: HoopleThemes.light,
      darkTheme: HoopleThemes.dark,
      routerConfig: appRouter,
    );
  }
}

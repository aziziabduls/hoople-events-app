import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hoople_mobile_app/core/providers/theme_provider.dart';
import 'package:hoople_mobile_app/hoople_app.dart';
import 'package:provider/provider.dart';

void main() async {
  // Ensure the binding layer is ready
  WidgetsFlutterBinding.ensureInitialized();

  // Set system UI mode to edge-to-edge
  await SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.edgeToEdge,
  );

  // Apply transparent styles to overlays
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      systemNavigationBarColor: Colors.transparent,
      statusBarColor: Colors.transparent,
      systemNavigationBarContrastEnforced: false,
      systemStatusBarContrastEnforced: false,
      // Adjust icons brightness for light/dark theme readability
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()..loadThemeMode()),
      ],
      child: const HoopleApp(),
    ),
  );
}

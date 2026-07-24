import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hoople_mobile_app/core/providers/theme_provider.dart';
import 'package:hoople_mobile_app/widgets/styled_back_button.dart';
import 'package:provider/provider.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  ThemeProvider themeProvider = ThemeProvider();
  final List<String> themeModes = ['System', 'Light', 'Dark'];

  @override
  void initState() {
    super.initState();
    themeProvider = context.read<ThemeProvider>();
  }

  String selectedThemeMode() {
    switch (themeProvider.themeMode) {
      case ThemeMode.system:
        return 'System';
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: StyledBackButton(),
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          ListTile(
            title: const Text('Theme Mode'),
            trailing: CupertinoSlidingSegmentedControl(
              groupValue: selectedThemeMode(),
              children: {
                for (var mode in themeModes)
                  mode: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    // child: Text(mode),
                    child: Icon(
                      mode == 'System'
                          ? CupertinoIcons.device_phone_portrait
                          : mode == 'Light'
                          ? CupertinoIcons.sun_max
                          : CupertinoIcons.moon,
                    ),
                  ),
              },
              onValueChanged: (value) {
                setState(() {
                  selectedThemeMode();
                });
                if (value != null) {
                  switch (value) {
                    case 'System':
                      themeProvider.setThemeMode(ThemeMode.system);
                      break;
                    case 'Light':
                      themeProvider.setThemeMode(ThemeMode.light);
                      break;
                    case 'Dark':
                      themeProvider.setThemeMode(ThemeMode.dark);
                      break;
                  }
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

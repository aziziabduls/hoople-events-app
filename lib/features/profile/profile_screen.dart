import 'package:flutter/material.dart';
import 'package:hoople_mobile_app/core/constants/images.dart';
import 'package:hoople_mobile_app/core/providers/theme_provider.dart';
import 'package:hoople_mobile_app/widgets/pressable.dart';
import 'package:hoople_mobile_app/widgets/styled_back_button.dart';
import 'package:material_shapes/material_shapes.dart';
import 'package:motor/motor.dart';
import 'package:provider/provider.dart';
// import 'package:material_shapes/material_shapes.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool entered = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        entered = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Widget buildPlaceholderFallback() {
      return SizedBox(
        height: 200,
        width: 200,
        child: ClipPath(
          clipper: ShapeBorderClipper(
            shape: MaterialShapeBorder(
              shape: MaterialShapes.clover8Leaf,
            ),
          ),
          child: Container(
            color: Colors.grey[300],
            width: 200,
            height: 200,
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0.0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        leading: StyledBackButton(),

        // actions: [
        //   IconButton(
        //     onPressed: () {
        //       // context.push('/settings');
        //       Navigator.push(
        //         context,
        //         MaterialPageRoute(builder: (context) => ExpandableCard()),
        //       );
        //     },
        //     icon: const Icon(Icons.card_giftcard),
        //   ),
        //   4.gap,
        //   IconButton(
        //     onPressed: () {
        //       context.push('/settings');
        //     },
        //     icon: const Icon(Icons.more_vert_rounded),
        //   ),
        // ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Align(
              alignment: .center,
              child: Pressable(
                child: SingleMotionBuilder(
                  motion: const MaterialSpringMotion.expressiveSpatialSlow(),
                  value: entered ? 1.0 : 0.0,
                  builder: (context, t, child) {
                    final double tc = t.clamp(0.0, 1.0);
                    return Opacity(
                      opacity: tc,
                      child: Transform.scale(
                        scale: 0.8 + 0.2 * t,
                        child: child,
                      ),
                    );
                  },
                  child: SizedBox(
                    height: 200,
                    width: 200,
                    child: ClipPath(
                      clipper: ShapeBorderClipper(
                        // random shape
                        shape: MaterialShapeBorder(
                          shape: MaterialShapes.pill,
                        ),
                      ),
                      child: MyImages.placeholder.contains('http')
                          ? Image.network(
                              MyImages.placeholder,
                              width: 200,
                              height: 200,
                              fit: BoxFit.cover,
                              loadingBuilder:
                                  (context, chunk, loadingProgress) {
                                    return chunk;
                                  },
                              errorBuilder: (context, error, stackTrace) {
                                return buildPlaceholderFallback();
                              },
                            )
                          : Image.asset(
                              MyImages.placeholder,
                              width: 200,
                              height: 200,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return buildPlaceholderFallback();
                              },
                            ),
                    ),
                  ),
                ),
              ),
            ),

            // menu on settings profile
            _buildSettingsGroup(
              title: "Profile",
              isDark: isDark,
              children: [
                _buildSettingsItem(
                  icon: Icons.person_outline_rounded,
                  title: "Edit profile",
                  onTap: _showEditProfileSheet,
                  isDark: isDark,
                ),
              ],
            ),
            _buildSettingsGroup(
              title: "Preferences",
              isDark: isDark,
              children: [
                _buildSettingsItem(
                  icon: Icons.translate_rounded,
                  title: "Change language",
                  onTap: _showLanguageSheet,
                  isDark: isDark,
                ),
                _buildSettingsDivider(),
                _buildSettingsItem(
                  icon: Icons.dark_mode_outlined,
                  title: "Theme",
                  onTap: _showThemeSheet,
                  isDark: isDark,
                ),
              ],
            ),
            _buildSettingsGroup(
              title: "Support & Legal",
              isDark: isDark,
              children: [
                _buildSettingsItem(
                  icon: Icons.help_outline_rounded,
                  title: "FAQ",
                  onTap: _showFAQSheet,
                  isDark: isDark,
                ),
                _buildSettingsDivider(),
                _buildSettingsItem(
                  icon: Icons.gavel_rounded,
                  title: "Legal & Privacy",
                  onTap: _showLegalSheet,
                  isDark: isDark,
                ),
              ],
            ),
            _buildSettingsGroup(
              title: "Account",
              isDark: isDark,
              children: [
                // Log Out Item
                _buildSettingsItem(
                  icon: Icons.logout_rounded,
                  title: "Log out",
                  onTap: _showLogoutDialog,
                  isDark: isDark,
                ),
                // Divider
                _buildSettingsDivider(),
                // Delete Account Item
                _buildSettingsItem(
                  icon: Icons.delete_outline_rounded,
                  title: "Delete account",
                  onTap: _showDeleteAccountDialog,
                  isDark: isDark,
                  textColor: isDark
                      ? Colors.redAccent
                      : const Color(0xFFC02F2F),
                  iconColor: isDark
                      ? Colors.redAccent
                      : const Color(0xFFC02F2F),
                ),
              ],
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  String _selectedLanguage = "English";

  Widget _buildSettingsGroup({
    required String title,
    required List<Widget> children,
    required bool isDark,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 8, bottom: 12),
            child: Text(
              title,
              style: TextStyle(
                color: isDark
                    ? const Color(0xFFC0BE7B)
                    : const Color(0xFF6B6C1E),
                fontSize: 18,
                fontWeight: FontWeight.bold,
                fontFamily: 'sf-pro',
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.05)
                  : Colors.black.withValues(alpha: 0.04),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              children: children,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    required bool isDark,
    Color? textColor,
    Color? iconColor,
  }) {
    final displayTextColor =
        textColor ?? (isDark ? Colors.white70 : Colors.black87);
    final displayIconColor =
        iconColor ?? (isDark ? Colors.white70 : Colors.black87);
    final displayChevronColor =
        iconColor ?? (isDark ? Colors.white54 : Colors.black54);

    return Pressable(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 18,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: displayIconColor,
              size: 22,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: displayTextColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_outlined,
              color: displayChevronColor,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsDivider() {
    return SizedBox(
      child: Divider(
        color: Theme.of(context).scaffoldBackgroundColor,
        height: 3,
        thickness: 3,
        indent: 0,
        endIndent: 0,
      ),
    );
  }

  void _showEditProfileSheet() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final nameController = TextEditingController(text: "Jane Doe");
    final bioController = TextEditingController(
      text: "Living life one experience at a time.",
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: theme.scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.fromLTRB(
          24,
          20,
          24,
          MediaQuery.of(context).viewInsets.bottom + 32,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white10 : Colors.black12,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              "Edit Profile",
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: "Display Name",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: bioController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: "Bio",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Profile updated successfully!"),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDark
                      ? const Color(0xFFC0BE7B)
                      : const Color(0xFF6B6C1E),
                  foregroundColor: isDark ? Colors.black : Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  "Save Changes",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showThemeSheet() {
    final theme = Theme.of(context);
    final themeProvider = context.read<ThemeProvider>();
    final currentMode = themeProvider.themeMode;

    showModalBottomSheet(
      context: context,
      backgroundColor: theme.scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Appearance Theme",
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.brightness_auto_rounded),
              title: const Text("System Default"),
              trailing: currentMode == ThemeMode.system
                  ? const Icon(Icons.check_rounded, color: Colors.green)
                  : null,
              onTap: () {
                themeProvider.setThemeMode(ThemeMode.system);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.light_mode_rounded),
              title: const Text("Light Mode"),
              trailing: currentMode == ThemeMode.light
                  ? const Icon(Icons.check_rounded, color: Colors.green)
                  : null,
              onTap: () {
                themeProvider.setThemeMode(ThemeMode.light);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.dark_mode_rounded),
              title: const Text("Dark Mode"),
              trailing: currentMode == ThemeMode.dark
                  ? const Icon(Icons.check_rounded, color: Colors.green)
                  : null,
              onTap: () {
                themeProvider.setThemeMode(ThemeMode.dark);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showLanguageSheet() {
    final theme = Theme.of(context);
    final languages = ["English", "Bahasa Indonesia", "Español", "日本語"];

    showModalBottomSheet(
      context: context,
      backgroundColor: theme.scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "App Language",
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              ...languages.map(
                (lang) => ListTile(
                  title: Text(lang),
                  trailing: _selectedLanguage == lang
                      ? const Icon(Icons.check_rounded, color: Colors.green)
                      : null,
                  onTap: () {
                    setState(() {
                      _selectedLanguage = lang;
                    });
                    setModalState(() {});
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Language changed to $lang"),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showFAQSheet() {
    final theme = Theme.of(context);
    final faqs = [
      {
        "q": "What is Hoople?",
        "a":
            "Hoople is a discovery platform for curated local experiences, wellness sessions, and premium social events.",
      },
      {
        "q": "How do I register for an experience?",
        "a":
            "Find an experience you like, select a session or ticket level, choose your preferred payment option, and tap Confirm Payment.",
      },
      {
        "q": "Can I cancel my booking?",
        "a":
            "Cancellation and refund policies depend on the experience host. Please contact the instructor or host directly.",
      },
      {
        "q": "How can I host my own experience?",
        "a":
            "Navigate to the home screen, tap the '+' button, complete the experience form with banners, locations, and pricing, and tap Publish.",
      },
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: theme.scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Frequently Asked Questions",
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: faqs.length,
                  itemBuilder: (context, index) {
                    final faq = faqs[index];
                    return ExpansionTile(
                      title: Text(
                        faq["q"]!,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(
                            left: 16.0,
                            right: 16.0,
                            bottom: 16.0,
                          ),
                          child: Text(
                            faq["a"]!,
                            style: const TextStyle(
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLegalSheet() {
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: theme.scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.8,
        expand: false,
        builder: (context, scrollController) => Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Legal & Privacy Policy",
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  children: const [
                    Text(
                      "Terms of Service",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      "By using the Hoople application, you agree to comply with our hosting guidelines, payment platform conditions, and community standards. All transactions are final unless specified otherwise by experience hosts.",
                      style: TextStyle(
                        height: 1.4,
                      ),
                    ),
                    SizedBox(height: 24),
                    Text(
                      "Privacy Policy",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      "We value your privacy. Hoople collects basic user info, location preferences, and payment meta information necessary to run and process experience bookings. We do not sell or lease your personal information to third parties.",
                      style: TextStyle(
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Log Out"),
        content: const Text(
          "Are you sure you want to log out of your account?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Logged out successfully"),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: const Text(
              "Log Out",
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Account"),
        content: const Text(
          "Warning: This action is permanent and cannot be undone. All your experiences, tickets, and bookings will be permanently deleted.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Account successfully deleted"),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: const Text(
              "Delete permanently",
              style: TextStyle(
                color: Colors.redAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

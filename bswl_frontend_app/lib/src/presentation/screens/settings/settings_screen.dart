import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../widgets/page_header.dart';
import '../support/help_support_screen.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PageHeader(
                title: "Settings",
                onBackPressed: () => Navigator.pop(context),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: ListView(
                  children: [
                    SettingsSection(title: "Account"),
                    SettingsItem(
                      icon: Icons.person,
                      title: "Edit Profile",
                      onTap: () {},
                    ),
                    SettingsItem(
                      icon: Icons.lock,
                      title: "Change Password",
                      onTap: () {},
                    ),
                    const SettingsSection(title: "Preferences"),
                    SettingsItem(
                      icon: Icons.language,
                      title: "App Language",
                      trailing: const Text("English"),
                      onTap: () {},
                    ),
                    SettingsItem(
                      icon: Icons.notifications,
                      title: "Notifications",
                      onTap: () {},
                    ),
                    SettingsItem(
                      icon: Icons.dark_mode,
                      title: "Dark Mode",
                      trailing: Switch(value: false, onChanged: (val) {}),
                      onTap: () {},
                    ),
                    const SettingsSection(title: "Support"),
                    SettingsItem(
                      icon: Icons.help,
                      title: "Help Center",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const HelpSupportPage(),
                          ),
                        );
                      },
                    ),
                    SettingsItem(
                      icon: Icons.feedback,
                      title: "Send Feedback",
                      onTap: () {},
                    ),
                    SettingsItem(
                      icon: Icons.privacy_tip,
                      title: "Privacy Policy",
                      onTap: () {},
                    ),
                    const SizedBox(height: 32),
                    Center(
                      child: TextButton(
                        onPressed: () {},
                        child: const Text(
                          "Log Out",
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 16,
                          ),
                        ),
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
}

class SettingsSection extends StatelessWidget {
  final String title;

  const SettingsSection({Key? key, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppColors.primary,
        ),
      ),
    );
  }
}

class SettingsItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget? trailing;
  final VoidCallback onTap;

  const SettingsItem({
    Key? key,
    required this.icon,
    required this.title,
    this.trailing,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 1,
      child: ListTile(
        leading: Icon(icon, color: AppColors.primary),
        title: Text(title),
        trailing: trailing ?? const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}

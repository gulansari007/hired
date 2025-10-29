import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:hired/controllers/settingController.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  final settingsController = Get.put(SettingsController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CupertinoColors.systemGroupedBackground,
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        backgroundColor: CupertinoColors.systemGroupedBackground,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Profile Section
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: CupertinoColors.systemBackground,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const CircleAvatar(
                    radius: 35,
                    backgroundImage: AssetImage('assets/images/profile.jpg'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Gul Ansari",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "gul@example.com",
                        style: TextStyle(
                          color: CupertinoColors.secondaryLabel,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  CupertinoIcons.chevron_right,
                  color: CupertinoColors.tertiaryLabel,
                  size: 16,
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Preferences Section
          _buildSectionHeader("Preferences"),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: CupertinoColors.systemBackground,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                Obx(
                  () => _buildSwitchTile(
                    icon: CupertinoIcons.bell,
                    title: "Notifications",
                    value: settingsController.isNotificationEnabled.value,
                    onChanged:
                        (val) =>
                            settingsController.isNotificationEnabled.value =
                                val,
                    isFirst: true,
                  ),
                ),
                _buildDivider(),
                Obx(
                  () => _buildSwitchTile(
                    icon: CupertinoIcons.moon,
                    title: "Dark Mode",
                    value: settingsController.isDarkMode.value,
                    onChanged:
                        (val) => settingsController.isDarkMode.value = val,
                    isLast: true,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Account Section
          _buildSectionHeader("Account"),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: CupertinoColors.systemBackground,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                _buildNavigationTile(
                  icon: CupertinoIcons.bookmark,
                  title: "Saved Jobs",
                  onTap: () => Get.toNamed('/saved-jobs'),
                  isFirst: true,
                ),
                _buildDivider(),
                _buildNavigationTile(
                  icon: CupertinoIcons.clock,
                  title: "Applied Jobs",
                  onTap: () => Get.toNamed('/applied-jobs'),
                ),
                _buildDivider(),
                _buildNavigationTile(
                  icon: CupertinoIcons.shield,
                  title: "Privacy Policy",
                  onTap: () => Get.toNamed('/privacy'),
                ),
                _buildDivider(),
                _buildNavigationTile(
                  icon: CupertinoIcons.question_circle,
                  title: "Help & Support",
                  onTap: () => Get.toNamed('/help'),
                  isLast: true,
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Logout Section
          Container(
            decoration: BoxDecoration(
              color: CupertinoColors.systemBackground,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: _buildNavigationTile(
              icon: CupertinoIcons.square_arrow_right,
              title: "Sign Out",
              onTap: () => _showLogoutDialog(),
              isFirst: true,
              isLast: true,
              isDestructive: true,
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: CupertinoColors.secondaryLabel,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
    bool isFirst = false,
    bool isLast = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.vertical(
          top: isFirst ? const Radius.circular(12) : Radius.zero,
          bottom: isLast ? const Radius.circular(12) : Radius.zero,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: CupertinoColors.systemBlue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: CupertinoColors.systemBlue, size: 18),
        ),
        title: Text(
          title,
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w400),
        ),
        trailing: Transform.scale(
          scale: 0.8,
          child: CupertinoSwitch(
            value: value,
            onChanged: onChanged,
            activeColor: Theme.of(context).primaryColor,
          ),
        ),
      ),
    );
  }

  Widget _buildNavigationTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isFirst = false,
    bool isLast = false,
    bool isDestructive = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.vertical(
          top: isFirst ? const Radius.circular(12) : Radius.zero,
          bottom: isLast ? const Radius.circular(12) : Radius.zero,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color:
                isDestructive
                    ? CupertinoColors.systemRed.withOpacity(0.1)
                    : CupertinoColors.systemGrey6,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color:
                isDestructive
                    ? CupertinoColors.systemRed
                    : CupertinoColors.secondaryLabel,
            size: 18,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w400,
            color: isDestructive ? CupertinoColors.systemRed : null,
          ),
        ),
        trailing: Icon(
          CupertinoIcons.chevron_right,
          color: CupertinoColors.tertiaryLabel,
          size: 16,
        ),
        onTap: onTap,
      ),
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.only(left: 72),
      child: Divider(
        height: 1,
        thickness: 0.5,
        color: CupertinoColors.separator,
      ),
    );
  }

  void _showLogoutDialog() {
    showCupertinoDialog(
      context: context,
      builder:
          (context) => CupertinoAlertDialog(
            title: const Text("Sign Out"),
            content: const Text("Are you sure you want to sign out?"),
            actions: [
              CupertinoDialogAction(
                child: const Text("Cancel"),
                onPressed: () => Navigator.of(context).pop(),
              ),
              CupertinoDialogAction(
                isDestructiveAction: true,
                child: const Text("Sign Out"),
                onPressed: () {
                  Navigator.of(context).pop();
                  Get.offAllNamed('/login');
                },
              ),
            ],
          ),
    );
  }
}

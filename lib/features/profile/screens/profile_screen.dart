import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/reminder_controller.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/theme_controller.dart';
import '../../auth/controllers/auth_controller.dart';
import '../controllers/sync_controller.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<void> _handleLogout(BuildContext context) async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Log Out'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(onPressed: () => Get.back(result: false), child: const Text('Cancel')),
          TextButton(onPressed: () => Get.back(result: true), child: const Text('Log Out')),
        ],
      ),
    );

    if (confirmed == true) {
      Get.find<AuthController>().signOut();
    }
  }

    Future<void> _pickReminderTime(BuildContext context, ReminderController controller) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: controller.reminderHour.value, minute: controller.reminderMinute.value),
    );

    if (picked != null) {
      controller.updateReminderTime(picked.hour, picked.minute);
    }
  }

  Future<void> _confirmRestore(BuildContext context, SyncController syncController) async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Restore from Cloud'),
        content: const Text(
          'This will replace your current local data with what was last synced to the cloud. Continue?',
        ),
        actions: [
          TextButton(onPressed: () => Get.back(result: false), child: const Text('Cancel')),
          TextButton(onPressed: () => Get.back(result: true), child: const Text('Restore')),
        ],
      ),
    );

    if (confirmed == true) {
      syncController.restoreFromCloud();
    }
  }

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
    final themeController = Get.find<ThemeController>();
    final syncController = Get.find<SyncController>();
    final user = authController.currentUser;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final subTextColor = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;

    final displayName = (user?.displayName?.isNotEmpty ?? false) ? user!.displayName! : 'User';
    final initial = displayName.isNotEmpty ? displayName[0].toUpperCase() : '?';

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 32,
                backgroundColor: AppColors.primary,
                child: Text(
                  initial,
                  style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(displayName, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 2),
                    if (user?.email != null)
                      Text(user!.email!, style: TextStyle(color: subTextColor, fontSize: 13)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),

          Text('Cloud Sync', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: borderColor),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Obx(() {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.cloud_outlined, color: AppColors.primary, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        syncController.lastSynced.value != null
                            ? 'Last synced: ${DateFormat('MMM d, h:mm a').format(syncController.lastSynced.value!)}'
                            : 'Never synced',
                        style: TextStyle(color: subTextColor, fontSize: 13),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: syncController.isSyncing.value ? null : syncController.syncToCloud,
                          icon: syncController.isSyncing.value
                              ? const SizedBox(
                                  height: 14,
                                  width: 14,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                )
                              : const Icon(Icons.cloud_upload_outlined, size: 18),
                          label: const Text('Backup Now'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: syncController.isSyncing.value ? null : () => _confirmRestore(context, syncController),
                          icon: const Icon(Icons.cloud_download_outlined, size: 18),
                          label: const Text('Restore'),
                        ),
                      ),
                    ],
                  ),
                ],
              );
            }),
          ),

          const SizedBox(height: 24),
          Text('Preferences', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Obx(() => _SettingsTile(
                icon: Icons.dark_mode_outlined,
                title: 'Dark Mode',
                trailing: Switch(
                  value: themeController.isDarkMode.value,
                  onChanged: themeController.toggleTheme,
                ),
              )),
          Obx(() {
            final reminderController = Get.find<ReminderController>();
            return _SettingsTile(
              icon: Icons.notifications_active_outlined,
              title: 'Daily Reminder (${reminderController.reminderHour.value.toString().padLeft(2, '0')}:${reminderController.reminderMinute.value.toString().padLeft(2, '0')})',
              trailing: Switch(
                value: reminderController.remindersEnabled.value,
                onChanged: reminderController.toggleReminders,
              ),
              onTap: () => _pickReminderTime(context, reminderController),
            );
          }),

          const SizedBox(height: 20),
          Text('Account', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          _SettingsTile(
            icon: Icons.category_outlined,
            title: 'Manage Categories',
            onTap: () => Get.toNamed(AppRoutes.categories),
          ),
          _SettingsTile(
            icon: Icons.logout,
            title: 'Log Out',
            titleColor: AppColors.error,
            iconColor: AppColors.error,
            onTap: () => _handleLogout(context),
          ),

          const SizedBox(height: 20),
          Center(
            child: Column(
              children: [
                Text('InternGrow Finance v1.0.0', style: TextStyle(color: subTextColor, fontSize: 12)),
                const SizedBox(height: 4),
                Text('Local storage powered by Hive', style: TextStyle(color: subTextColor, fontSize: 11)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color? iconColor;
  final Color? titleColor;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    this.iconColor,
    this.titleColor,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(border: Border(bottom: BorderSide(color: borderColor))),
        child: Row(
          children: [
            Icon(icon, color: iconColor ?? AppColors.primary, size: 22),
            const SizedBox(width: 14),
            Expanded(
              child: Text(title, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: titleColor)),
            ),
            trailing ?? const Icon(Icons.chevron_right, size: 20),
          ],
        ),
      ),
    );
  }
}
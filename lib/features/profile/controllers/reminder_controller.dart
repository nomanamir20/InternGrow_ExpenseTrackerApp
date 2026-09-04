import 'package:get/get.dart';
import 'package:hive/hive.dart';

import '../../../core/constants/hive_boxes.dart';
import '../../../core/services/notification_service.dart';

class ReminderController extends GetxController {
  final NotificationService _notificationService = NotificationService();
  final Box _settingsBox = Hive.box(HiveBoxes.settings);

  static const _enabledKey = 'reminders_enabled';
  static const _hourKey = 'reminder_hour';
  static const _minuteKey = 'reminder_minute';

  final RxBool remindersEnabled = false.obs;
  final Rx<int> reminderHour = 20.obs; // default 8:00 PM
  final Rx<int> reminderMinute = 0.obs;

  @override
  void onInit() {
    super.onInit();
    remindersEnabled.value = _settingsBox.get(_enabledKey, defaultValue: false) as bool;
    reminderHour.value = _settingsBox.get(_hourKey, defaultValue: 20) as int;
    reminderMinute.value = _settingsBox.get(_minuteKey, defaultValue: 0) as int;
  }

  Future<void> toggleReminders(bool enabled) async {
    remindersEnabled.value = enabled;
    await _settingsBox.put(_enabledKey, enabled);

    if (enabled) {
      await _notificationService.scheduleDailyReminder(
        hour: reminderHour.value,
        minute: reminderMinute.value,
      );
    } else {
      await _notificationService.cancelDailyReminder();
    }
  }

  Future<void> updateReminderTime(int hour, int minute) async {
    reminderHour.value = hour;
    reminderMinute.value = minute;
    await _settingsBox.put(_hourKey, hour);
    await _settingsBox.put(_minuteKey, minute);

    if (remindersEnabled.value) {
      await _notificationService.scheduleDailyReminder(hour: hour, minute: minute);
    }
  }

  /// Called after adding an expense — checks if any budget crossed 90% or
  /// 100% of its limit, and fires an instant alert if so.
  Future<void> checkBudgetThresholds({
    required String categoryName,
    required double spent,
    required double limit,
  }) async {
    if (limit <= 0) return;
    final percentage = (spent / limit) * 100;

    if (percentage >= 100) {
      await _notificationService.showInstantNotification(
        id: categoryName.hashCode,
        title: 'Budget Exceeded',
        body: 'You\'ve gone over your $categoryName budget for this month.',
      );
    } else if (percentage >= 90) {
      await _notificationService.showInstantNotification(
        id: categoryName.hashCode,
        title: 'Budget Warning',
        body: 'You\'ve used ${percentage.toStringAsFixed(0)}% of your $categoryName budget.',
      );
    }
  }
}
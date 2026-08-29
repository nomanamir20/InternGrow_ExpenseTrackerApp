import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// Manages dark mode using GetX's reactive `.obs` pattern — simpler than
/// Bloc/Riverpod's boilerplate, one of GetX's main selling points.
class ThemeController extends GetxController {
  static const _boxName = 'settings';
  static const _key = 'is_dark_mode';

  final RxBool isDarkMode = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadFromHive();
  }

  void _loadFromHive() {
    final box = Hive.box(_boxName);
    isDarkMode.value = box.get(_key, defaultValue: false) as bool;
  }

  Future<void> toggleTheme(bool isDark) async {
    isDarkMode.value = isDark;
    final box = Hive.box(_boxName);
    await box.put(_key, isDark);
    Get.changeThemeMode(isDark ? ThemeMode.dark : ThemeMode.light);
  }
}
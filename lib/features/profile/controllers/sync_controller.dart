import 'package:get/get.dart';
import 'package:hive/hive.dart';

import '../../../core/constants/hive_boxes.dart';
import '../../../core/services/sync_service.dart';
import '../../../data/models/budget_model.dart';
import '../../../data/models/category_model.dart';
import '../../../data/models/transaction_model.dart';
import '../../budget/controllers/budget_controller.dart';
import '../../categories/controllers/category_controller.dart';
import '../../transactions/controllers/transaction_controller.dart';

class SyncController extends GetxController {
  final SyncService _syncService = SyncService();

  final RxBool isSyncing = false.obs;
  final Rxn<DateTime> lastSynced = Rxn<DateTime>();

  @override
  void onInit() {
    super.onInit();
    _loadLastSyncedTime();
  }

  Future<void> _loadLastSyncedTime() async {
    try {
      lastSynced.value = await _syncService.getLastSyncedTime();
    } catch (_) {
      // Not signed in yet, or no prior sync — fine, leave as null.
    }
  }

  /// Uploads all local Hive data to Firebase Realtime Database.
  Future<void> syncToCloud() async {
    isSyncing.value = true;
    try {
      final transactionsBox = Hive.box<TransactionModel>(HiveBoxes.transactions);
      final categoriesBox = Hive.box<CategoryModel>(HiveBoxes.categories);
      final budgetsBox = Hive.box<BudgetModel>(HiveBoxes.budgets);

      await _syncService.pushAllData(
        transactions: transactionsBox.values.toList(),
        categories: categoriesBox.values.toList(),
        budgets: budgetsBox.values.toList(),
      );

      lastSynced.value = DateTime.now();
      Get.snackbar('Synced', 'Your data has been backed up to the cloud.', snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      Get.snackbar('Sync Failed', 'Could not sync data. Please try again.', snackPosition: SnackPosition.BOTTOM);
    } finally {
      isSyncing.value = false;
    }
  }

  /// Downloads cloud data and restores it into local Hive boxes — useful
  /// after reinstalling the app or switching devices.
  Future<void> restoreFromCloud() async {
    isSyncing.value = true;
    try {
      final result = await _syncService.pullAllData();

      final transactionsBox = Hive.box<TransactionModel>(HiveBoxes.transactions);
      final categoriesBox = Hive.box<CategoryModel>(HiveBoxes.categories);
      final budgetsBox = Hive.box<BudgetModel>(HiveBoxes.budgets);

      await transactionsBox.clear();
      for (final t in result.transactions) {
        await transactionsBox.put(t.id, t);
      }

      await categoriesBox.clear();
      for (final c in result.categories) {
        await categoriesBox.put(c.id, c);
      }

      await budgetsBox.clear();
      for (final b in result.budgets) {
        await budgetsBox.put(b.id, b);
      }

      // Refresh the other controllers' reactive lists so the UI updates.
      Get.find<TransactionController>().refreshFromHive();
      Get.find<CategoryController>().refreshFromHive();
      Get.find<BudgetController>().refreshFromHive();

      Get.snackbar('Restored', 'Your data has been restored from the cloud.', snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      Get.snackbar('Restore Failed', 'Could not restore data. Please try again.', snackPosition: SnackPosition.BOTTOM);
    } finally {
      isSyncing.value = false;
    }
  }
}
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:collection/collection.dart';
import '../../../core/constants/hive_boxes.dart';
import '../../../data/models/budget_model.dart';
import '../../../data/models/category_model.dart';
import '../../../data/models/transaction_type.dart';
import '../../categories/controllers/category_controller.dart';
import '../../transactions/controllers/transaction_controller.dart';

class BudgetProgress {
  final BudgetModel budget;
  final CategoryModel? category;
  final double spent;

  BudgetProgress({required this.budget, required this.category, required this.spent});

  double get percentage => budget.monthlyLimit == 0 ? 0 : (spent / budget.monthlyLimit).clamp(0, 999) * 100;
  bool get isOverBudget => spent > budget.monthlyLimit;
  double get remaining => budget.monthlyLimit - spent;
}

class BudgetController extends GetxController {
  final Box<BudgetModel> _budgetsBox = Hive.box<BudgetModel>(HiveBoxes.budgets);
  final CategoryController _categoryController = Get.find<CategoryController>();
  final TransactionController _transactionController = Get.find<TransactionController>();

  final RxList<BudgetModel> budgets = <BudgetModel>[].obs;

  static String get currentMonthKey => DateFormat('yyyy-MM').format(DateTime.now());

  @override
  void onInit() {
    super.onInit();
    _loadBudgets();
  }

  void _loadBudgets() {
    budgets.assignAll(_budgetsBox.values.where((b) => b.month == currentMonthKey).toList());
  }
  void refreshFromHive() => _loadBudgets();

  Future<void> setBudget({required String categoryId, required double monthlyLimit}) async {
    // If a budget for this category+month already exists, update it instead
    // of creating a duplicate.
    final existing = _budgetsBox.values.firstWhereOrNull(
      (b) => b.categoryId == categoryId && b.month == currentMonthKey,
    );

    if (existing != null) {
      existing.monthlyLimit = monthlyLimit;
      await existing.save();
    } else {
      final budget = BudgetModel(
        id: const Uuid().v4(),
        categoryId: categoryId,
        monthlyLimit: monthlyLimit,
        month: currentMonthKey,
      );
      await _budgetsBox.put(budget.id, budget);
    }

    _loadBudgets();
  }

  Future<void> deleteBudget(String id) async {
    await _budgetsBox.delete(id);
    _loadBudgets();
  }

  double _spentForCategory(String categoryId) {
    final now = DateTime.now();
    return _transactionController.transactions
        .where((t) =>
            t.categoryId == categoryId &&
            t.type == TransactionType.expense &&
            t.date.year == now.year &&
            t.date.month == now.month)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  List<BudgetProgress> get budgetProgressList {
    return budgets.map((budget) {
      final category = _categoryController.categories.firstWhereOrNull((c) => c.id == budget.categoryId);
      final spent = _spentForCategory(budget.categoryId);
      return BudgetProgress(budget: budget, category: category, spent: spent);
    }).toList();
  }

  List<CategoryModel> get categoriesWithoutBudget {
    final budgetedCategoryIds = budgets.map((b) => b.categoryId).toSet();
    return _categoryController
        .byType(TransactionType.expense)
        .where((c) => !budgetedCategoryIds.contains(c.id))
        .toList();
  }
}
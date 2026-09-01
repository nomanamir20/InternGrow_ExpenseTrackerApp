import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../categories/controllers/category_controller.dart';
import '../../transactions/controllers/transaction_controller.dart';
import '../../../data/models/transaction_model.dart';
import '../../../data/models/transaction_type.dart';

class CategorySpending {
  final String categoryId;
  final String categoryName;
  final int colorValue;
  final double amount;
  final double percentage;

  CategorySpending({
    required this.categoryId,
    required this.categoryName,
    required this.colorValue,
    required this.amount,
    required this.percentage,
  });
}

class MonthlyTotal {
  final DateTime month;
  final double income;
  final double expense;

  MonthlyTotal({required this.month, required this.income, required this.expense});
}

class ReportsController extends GetxController {
  final TransactionController _transactionController = Get.find<TransactionController>();
  final CategoryController _categoryController = Get.find<CategoryController>();

  final Rx<DateTime> selectedMonth = DateTime(DateTime.now().year, DateTime.now().month).obs;

  List<TransactionModel> get _transactionsForSelectedMonth {
    return _transactionController.transactions.where((t) {
      return t.date.year == selectedMonth.value.year && t.date.month == selectedMonth.value.month;
    }).toList();
  }

  double get monthlyIncome => _transactionsForSelectedMonth
      .where((t) => t.type == TransactionType.income)
      .fold(0.0, (sum, t) => sum + t.amount);

  double get monthlyExpense => _transactionsForSelectedMonth
      .where((t) => t.type == TransactionType.expense)
      .fold(0.0, (sum, t) => sum + t.amount);

  double get monthlyNet => monthlyIncome - monthlyExpense;

  /// Expense breakdown by category, for the pie chart — sorted largest first.
  List<CategorySpending> get expenseByCategory {
    final expenses = _transactionsForSelectedMonth.where((t) => t.type == TransactionType.expense);
    final total = expenses.fold(0.0, (sum, t) => sum + t.amount);

    if (total == 0) return [];

    final Map<String, double> totals = {};
    for (final t in expenses) {
      totals[t.categoryId] = (totals[t.categoryId] ?? 0) + t.amount;
    }

    final result = totals.entries.map((entry) {
      final category = _categoryController.categories.firstWhereOrNull((c) => c.id == entry.key);
      return CategorySpending(
        categoryId: entry.key,
        categoryName: category?.name ?? 'Uncategorized',
        colorValue: category?.colorValue ?? 0xFF9CA3AF,
        amount: entry.value,
        percentage: (entry.value / total) * 100,
      );
    }).toList();

    result.sort((a, b) => b.amount.compareTo(a.amount));
    return result;
  }

  /// Last 6 months of income vs. expense totals, for the bar chart.
  List<MonthlyTotal> get last6MonthsTrend {
    final now = DateTime.now();
    final months = List.generate(6, (i) => DateTime(now.year, now.month - (5 - i)));

    return months.map((month) {
      final monthTransactions = _transactionController.transactions.where((t) {
        return t.date.year == month.year && t.date.month == month.month;
      });

      final income = monthTransactions
          .where((t) => t.type == TransactionType.income)
          .fold(0.0, (sum, t) => sum + t.amount);
      final expense = monthTransactions
          .where((t) => t.type == TransactionType.expense)
          .fold(0.0, (sum, t) => sum + t.amount);

      return MonthlyTotal(month: month, income: income, expense: expense);
    }).toList();
  }

  void goToPreviousMonth() {
    final current = selectedMonth.value;
    selectedMonth.value = DateTime(current.year, current.month - 1);
  }

  void goToNextMonth() {
    final current = selectedMonth.value;
    final next = DateTime(current.year, current.month + 1);
    if (next.isAfter(DateTime(DateTime.now().year, DateTime.now().month))) return;
    selectedMonth.value = next;
  }

  bool get isCurrentMonth {
    final now = DateTime.now();
    return selectedMonth.value.year == now.year && selectedMonth.value.month == now.month;
  }

  String get formattedSelectedMonth => DateFormat('MMMM yyyy').format(selectedMonth.value);
}
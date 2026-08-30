import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

import '../../../core/constants/hive_boxes.dart';
import '../../../data/models/category_model.dart';
import '../../../data/models/transaction_model.dart';
import '../../../data/models/transaction_type.dart';

class TransactionController extends GetxController {
  final Box<TransactionModel> _transactionsBox = Hive.box<TransactionModel>(HiveBoxes.transactions);
  final Box<CategoryModel> _categoriesBox = Hive.box<CategoryModel>(HiveBoxes.categories);

  /// Reactive list — any screen using Obx() around this automatically
  /// rebuilds whenever a transaction is added, edited, or removed.
  final RxList<TransactionModel> transactions = <TransactionModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadTransactions();
  }

  void _loadTransactions() {
    final all = _transactionsBox.values.toList();
    all.sort((a, b) => b.date.compareTo(a.date)); // newest first
    transactions.assignAll(all);
  }

  List<CategoryModel> categoriesForType(TransactionType type) {
    return _categoriesBox.values.where((c) => c.type == type).toList();
  }

  CategoryModel? categoryById(String id) {
    try {
      return _categoriesBox.values.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<void> addTransaction({
    required String title,
    required double amount,
    required TransactionType type,
    required String categoryId,
    required DateTime date,
    String note = '',
  }) async {
    final transaction = TransactionModel(
      id: const Uuid().v4(),
      title: title,
      amount: amount,
      type: type,
      categoryId: categoryId,
      date: date,
      note: note,
    );

    await _transactionsBox.put(transaction.id, transaction);
    _loadTransactions();
  }

  Future<void> deleteTransaction(String id) async {
    await _transactionsBox.delete(id);
    _loadTransactions();
  }

  double get totalIncome => transactions
      .where((t) => t.type == TransactionType.income)
      .fold(0.0, (sum, t) => sum + t.amount);

  double get totalExpense => transactions
      .where((t) => t.type == TransactionType.expense)
      .fold(0.0, (sum, t) => sum + t.amount);

  double get balance => totalIncome - totalExpense;
}
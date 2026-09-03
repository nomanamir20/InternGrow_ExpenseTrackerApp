import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

import '../../data/models/budget_model.dart';
import '../../data/models/category_model.dart';
import '../../data/models/transaction_model.dart';
import '../../data/models/transaction_type.dart';

/// Handles pushing local Hive data to Firebase Realtime Database, and
/// pulling it back down — keyed under the signed-in user's UID so each
/// user's data stays isolated.
class SyncService {
  final DatabaseReference _db = FirebaseDatabase.instance.ref();

  String? get _uid => FirebaseAuth.instance.currentUser?.uid;

  Future<void> pushAllData({
    required List<TransactionModel> transactions,
    required List<CategoryModel> categories,
    required List<BudgetModel> budgets,
  }) async {
    final uid = _uid;
    if (uid == null) throw Exception('Not signed in');

    final userRef = _db.child('users/$uid');

    await userRef.child('transactions').set({
      for (final t in transactions)
        t.id: {
          'id': t.id,
          'title': t.title,
          'amount': t.amount,
          'type': t.type.index,
          'categoryId': t.categoryId,
          'date': t.date.toIso8601String(),
          'note': t.note,
        },
    });

    await userRef.child('categories').set({
      for (final c in categories)
        c.id: {
          'id': c.id,
          'name': c.name,
          'iconCodePoint': c.iconCodePoint,
          'colorValue': c.colorValue,
          'type': c.type.index,
        },
    });

    await userRef.child('budgets').set({
      for (final b in budgets)
        b.id: {
          'id': b.id,
          'categoryId': b.categoryId,
          'monthlyLimit': b.monthlyLimit,
          'month': b.month,
        },
    });

    await userRef.child('lastSynced').set(DateTime.now().toIso8601String());
  }

  Future<DateTime?> getLastSyncedTime() async {
    final uid = _uid;
    if (uid == null) return null;

    final snapshot = await _db.child('users/$uid/lastSynced').get();
    if (!snapshot.exists) return null;

    return DateTime.tryParse(snapshot.value as String);
  }

  Future<({
    List<TransactionModel> transactions,
    List<CategoryModel> categories,
    List<BudgetModel> budgets,
  })> pullAllData() async {
    final uid = _uid;
    if (uid == null) throw Exception('Not signed in');

    final userRef = _db.child('users/$uid');
    final snapshot = await userRef.get();

    if (!snapshot.exists) {
      return (transactions: <TransactionModel>[], categories: <CategoryModel>[], budgets: <BudgetModel>[]);
    }

    final data = Map<String, dynamic>.from(snapshot.value as Map);

    final transactions = <TransactionModel>[];
    if (data['transactions'] != null) {
      final txMap = Map<String, dynamic>.from(data['transactions'] as Map);
      for (final entry in txMap.values) {
        final t = Map<String, dynamic>.from(entry as Map);
        transactions.add(TransactionModel(
          id: t['id'] as String,
          title: t['title'] as String,
          amount: (t['amount'] as num).toDouble(),
          type: TransactionType.values[t['type'] as int],
          categoryId: t['categoryId'] as String,
          date: DateTime.parse(t['date'] as String),
          note: t['note'] as String? ?? '',
        ));
      }
    }

    final categories = <CategoryModel>[];
    if (data['categories'] != null) {
      final catMap = Map<String, dynamic>.from(data['categories'] as Map);
      for (final entry in catMap.values) {
        final c = Map<String, dynamic>.from(entry as Map);
        categories.add(CategoryModel(
          id: c['id'] as String,
          name: c['name'] as String,
          iconCodePoint: c['iconCodePoint'] as int,
          colorValue: c['colorValue'] as int,
          type: TransactionType.values[c['type'] as int],
        ));
      }
    }

    final budgets = <BudgetModel>[];
    if (data['budgets'] != null) {
      final budgetMap = Map<String, dynamic>.from(data['budgets'] as Map);
      for (final entry in budgetMap.values) {
        final b = Map<String, dynamic>.from(entry as Map);
        budgets.add(BudgetModel(
          id: b['id'] as String,
          categoryId: b['categoryId'] as String,
          monthlyLimit: (b['monthlyLimit'] as num).toDouble(),
          month: b['month'] as String,
        ));
      }
    }

    return (transactions: transactions, categories: categories, budgets: budgets);
  }
}
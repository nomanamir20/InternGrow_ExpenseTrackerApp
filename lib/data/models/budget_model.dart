import 'package:hive/hive.dart';

part 'budget_model.g.dart';

@HiveType(typeId: 2)
class BudgetModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String categoryId;

  @HiveField(2)
  double monthlyLimit;

  /// Stored as "yyyy-MM" (e.g. "2026-08") so each category can have a
  /// different budget per month.
  @HiveField(3)
  String month;

  BudgetModel({
    required this.id,
    required this.categoryId,
    required this.monthlyLimit,
    required this.month,
  });
}
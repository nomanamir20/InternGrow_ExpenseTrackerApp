import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../../data/models/category_model.dart';
import '../../data/models/transaction_type.dart';

/// Seeded into the categories box on first app launch, so the app isn't
/// empty the moment someone signs up — a small UX touch real finance apps
/// almost always include.
List<CategoryModel> buildDefaultCategories() {
  const uuid = Uuid();

  return [
    CategoryModel(
      id: uuid.v4(),
      name: 'Salary',
      iconCodePoint: Icons.work_outline.codePoint,
      colorValue: const Color(0xFF16A34A).toARGB32(),
      type: TransactionType.income,
    ),
    CategoryModel(
      id: uuid.v4(),
      name: 'Freelance',
      iconCodePoint: Icons.laptop_mac.codePoint,
      colorValue: const Color(0xFF0891B2).toARGB32(),
      type: TransactionType.income,
    ),
    CategoryModel(
      id: uuid.v4(),
      name: 'Food & Dining',
      iconCodePoint: Icons.restaurant_outlined.codePoint,
      colorValue: const Color(0xFFDC2626).toARGB32(),
      type: TransactionType.expense,
    ),
    CategoryModel(
      id: uuid.v4(),
      name: 'Transport',
      iconCodePoint: Icons.directions_car_outlined.codePoint,
      colorValue: const Color(0xFFF59E0B).toARGB32(),
      type: TransactionType.expense,
    ),
    CategoryModel(
      id: uuid.v4(),
      name: 'Shopping',
      iconCodePoint: Icons.shopping_bag_outlined.codePoint,
      colorValue: const Color(0xFF9333EA).toARGB32(),
      type: TransactionType.expense,
    ),
    CategoryModel(
      id: uuid.v4(),
      name: 'Bills & Utilities',
      iconCodePoint: Icons.receipt_long_outlined.codePoint,
      colorValue: const Color(0xFF2563EB).toARGB32(),
      type: TransactionType.expense,
    ),
    CategoryModel(
      id: uuid.v4(),
      name: 'Entertainment',
      iconCodePoint: Icons.movie_outlined.codePoint,
      colorValue: const Color(0xFFDB2777).toARGB32(),
      type: TransactionType.expense,
    ),
    CategoryModel(
      id: uuid.v4(),
      name: 'Health',
      iconCodePoint: Icons.local_hospital_outlined.codePoint,
      colorValue: const Color(0xFF65A30D).toARGB32(),
      type: TransactionType.expense,
    ),
  ];
}
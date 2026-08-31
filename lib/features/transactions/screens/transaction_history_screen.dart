import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/models/transaction_model.dart';
import '../../../data/models/transaction_type.dart';
import '../controllers/transaction_controller.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  late final TransactionController _controller;
  TransactionType? _filter; // null = show all

  @override
  void initState() {
    super.initState();
    _controller = Get.find<TransactionController>();
  }

  Future<void> _confirmDelete(TransactionModel transaction) async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Delete Transaction'),
        content: Text('Delete "${transaction.title}"? This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Get.back(result: false), child: const Text('Cancel')),
          TextButton(onPressed: () => Get.back(result: true), child: const Text('Delete')),
        ],
      ),
    );

    if (confirmed == true) {
      _controller.deleteTransaction(transaction.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final subTextColor = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;

    return Scaffold(
      appBar: AppBar(title: const Text('Transaction History')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                _FilterChip(label: 'All', isSelected: _filter == null, onTap: () => setState(() => _filter = null)),
                const SizedBox(width: 8),
                _FilterChip(
                  label: 'Income',
                  isSelected: _filter == TransactionType.income,
                  color: AppColors.income,
                  onTap: () => setState(() => _filter = TransactionType.income),
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: 'Expense',
                  isSelected: _filter == TransactionType.expense,
                  color: AppColors.expense,
                  onTap: () => setState(() => _filter = TransactionType.expense),
                ),
              ],
            ),
          ),
          Expanded(
            child: Obx(() {
              var list = _controller.transactions.toList();
              if (_filter != null) {
                list = list.where((t) => t.type == _filter).toList();
              }

              if (list.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.receipt_long_outlined, size: 64, color: subTextColor),
                        const SizedBox(height: 16),
                        Text('No transactions yet', style: TextStyle(color: subTextColor, fontSize: 16)),
                      ],
                    ),
                  ),
                );
              }

              // Group by date for readability.
              final Map<String, List<TransactionModel>> grouped = {};
              for (final t in list) {
                final key = DateFormat('MMM d, yyyy').format(t.date);
                grouped.putIfAbsent(key, () => []).add(t);
              }

              return ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                children: [
                  for (final entry in grouped.entries) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        entry.key,
                        style: TextStyle(color: subTextColor, fontWeight: FontWeight.w600, fontSize: 13),
                      ),
                    ),
                    for (final transaction in entry.value)
                      Dismissible(
                        key: ValueKey(transaction.id),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          margin: const EdgeInsets.only(bottom: 8),
                          decoration: BoxDecoration(
                            color: AppColors.error,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.delete_outline, color: Colors.white),
                        ),
                        confirmDismiss: (_) async {
                          await _confirmDelete(transaction);
                          return false; // we handle deletion ourselves via the controller
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: _TransactionTile(transaction: transaction, controller: _controller),
                        ),
                      ),
                  ],
                ],
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _TransactionTile extends StatelessWidget {
  final TransactionModel transaction;
  final TransactionController controller;

  const _TransactionTile({required this.transaction, required this.controller});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final subTextColor = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final category = controller.categoryById(transaction.categoryId);
    final isIncome = transaction.type == TransactionType.income;
    final amountColor = isIncome ? AppColors.income : AppColors.expense;
    final categoryColor = category != null ? Color(category.colorValue) : AppColors.primary;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: borderColor),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(color: categoryColor.withValues(alpha: 0.15), shape: BoxShape.circle),
            child: Icon(
              category != null
                  ? IconData(category.iconCodePoint, fontFamily: 'MaterialIcons')
                  : Icons.category_outlined,
              color: categoryColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(transaction.title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                const SizedBox(height: 2),
                Text(category?.name ?? 'Uncategorized', style: TextStyle(color: subTextColor, fontSize: 12)),
              ],
            ),
          ),
          Text(
            '${isIncome ? '+' : '-'}\$${transaction.amount.toStringAsFixed(2)}',
            style: TextStyle(color: amountColor, fontWeight: FontWeight.w800, fontSize: 15),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final Color? color;
  final VoidCallback onTap;

  const _FilterChip({required this.label, required this.isSelected, this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final chipColor = color ?? AppColors.primary;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? chipColor : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: chipColor),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : chipColor,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}
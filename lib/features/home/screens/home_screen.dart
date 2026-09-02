import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../shared/widgets/category_icon.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/transaction_type.dart';
import '../../transactions/controllers/transaction_controller.dart';
import '../../../shared/widgets/scaffold_with_nav_bar.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<TransactionController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final subTextColor = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    return Scaffold(
      appBar: AppBar(
        title: const Text('InternGrow Finance'),
        actions: [
          IconButton(
            icon: const Icon(Icons.category_outlined),
            onPressed: () => Get.toNamed(AppRoutes.categories),
            tooltip: 'Manage Categories',
          ),
        ],
      ),
      body: Obx(() {
        final recentTransactions = controller.transactions.take(5).toList();

        return ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Balance card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryDark],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Total Balance', style: TextStyle(color: Colors.white70, fontSize: 13)),
                  const SizedBox(height: 6),
                  Text(
                    '\$${controller.balance.toStringAsFixed(2)}',
                    style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: _MiniStat(
                          icon: Icons.arrow_downward,
                          label: 'Income',
                          value: controller.totalIncome,
                        ),
                      ),
                      Container(width: 1, height: 36, color: Colors.white24),
                      Expanded(
                        child: _MiniStat(
                          icon: Icons.arrow_upward,
                          label: 'Expense',
                          value: controller.totalExpense,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Quick actions
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => Get.toNamed(AppRoutes.addTransaction, arguments: TransactionType.income),
                    icon: const Icon(Icons.add, color: AppColors.income),
                    label: const Text('Add Income', style: TextStyle(color: AppColors.income)),
                    style: OutlinedButton.styleFrom(side: const BorderSide(color: AppColors.income)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => Get.toNamed(AppRoutes.addTransaction, arguments: TransactionType.expense),
                    icon: const Icon(Icons.remove, color: AppColors.expense),
                    label: const Text('Add Expense', style: TextStyle(color: AppColors.expense)),
                    style: OutlinedButton.styleFrom(side: const BorderSide(color: AppColors.expense)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent Transactions',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                ),
                GestureDetector(
                  onTap: () => Get.find<NavShellController>().changeTab(1),
                  child: const Text('See All', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
            const SizedBox(height: 12),

            if (recentTransactions.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: Text('No transactions yet. Tap "Add Income" or "Add Expense" to get started.',
                      textAlign: TextAlign.center, style: TextStyle(color: subTextColor)),
                ),
              )
            else
              for (final transaction in recentTransactions)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _RecentTransactionTile(transaction: transaction, controller: controller),
                ),
          ],
        );
      }),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final IconData icon;
  final String label;
  final double value;

  const _MiniStat({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: Colors.white70, size: 14),
            const SizedBox(width: 4),
            Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          '\$${value.toStringAsFixed(2)}',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16),
        ),
      ],
    );
  }
}

class _RecentTransactionTile extends StatelessWidget {
  final dynamic transaction;
  final TransactionController controller;

  const _RecentTransactionTile({required this.transaction, required this.controller});

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
            width: 40,
            height: 40,
            decoration: BoxDecoration(color: categoryColor.withValues(alpha: 0.15), shape: BoxShape.circle),
            child: Icon(
              category != null
                  ? IconData(category.iconCodePoint, fontFamily: 'MaterialIcons')
                  : Icons.category_outlined,
              color: categoryColor,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(transaction.title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                Text(category?.name ?? 'Uncategorized', style: TextStyle(color: subTextColor, fontSize: 11)),
              ],
            ),
          ),
          Text(
            '${isIncome ? '+' : '-'}\$${transaction.amount.toStringAsFixed(2)}',
            style: TextStyle(color: amountColor, fontWeight: FontWeight.w700, fontSize: 14),
          ),
        ],
      ),
    );
  }
}
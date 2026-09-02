import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../shared/widgets/category_icon.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/category_model.dart';
import '../controllers/budget_controller.dart';

class BudgetScreen extends StatelessWidget {
  const BudgetScreen({super.key});

  void _showSetBudgetSheet(BuildContext context, BudgetController controller, {CategoryModel? existingCategory, double? existingAmount}) {
    final amountController = TextEditingController(text: existingAmount?.toStringAsFixed(0) ?? '');
    CategoryModel? selectedCategory = existingCategory;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final availableCategories = existingCategory != null
                ? [existingCategory]
                : controller.categoriesWithoutBudget;

            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    existingCategory != null ? 'Edit Budget' : 'Set a Budget',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 20),

                  if (existingCategory == null) ...[
                    if (availableCategories.isEmpty)
                      const Text('All your expense categories already have a budget set.')
                    else ...[
                      Text('Category', style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (final category in availableCategories)
                            ChoiceChip(
                              label: Text(category.name),
                              selected: selectedCategory?.id == category.id,
                              onSelected: (_) => setSheetState(() => selectedCategory = category),
                            ),
                        ],
                      ),
                      const SizedBox(height: 20),
                    ],
                  ] else ...[
                    Text('Category: ${existingCategory.name}', style: const TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 20),
                  ],

                  TextField(
                    controller: amountController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(labelText: 'Monthly Limit', prefixText: '\$ '),
                  ),
                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: (selectedCategory == null || availableCategories.isEmpty && existingCategory == null)
                          ? null
                          : () {
                              final amount = double.tryParse(amountController.text.trim());
                              if (amount == null || amount <= 0) {
                                Get.snackbar('Invalid Amount', 'Please enter a valid amount.',
                                    snackPosition: SnackPosition.BOTTOM);
                                return;
                              }
                              controller.setBudget(categoryId: selectedCategory!.id, monthlyLimit: amount);
                              Navigator.of(sheetContext).pop();
                            },
                      child: const Text('Save Budget'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _confirmDelete(BudgetController controller, String budgetId, String categoryName) async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Remove Budget'),
        content: Text('Remove the budget for "$categoryName"?'),
        actions: [
          TextButton(onPressed: () => Get.back(result: false), child: const Text('Cancel')),
          TextButton(onPressed: () => Get.back(result: true), child: const Text('Remove')),
        ],
      ),
    );

    if (confirmed == true) {
      controller.deleteBudget(budgetId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<BudgetController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final subTextColor = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;

    return Scaffold(
      appBar: AppBar(title: const Text('Budget Tracking')),
      body: Obx(() {
        final progressList = controller.budgetProgressList;

        if (progressList.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.account_balance_wallet_outlined, size: 64, color: subTextColor),
                  const SizedBox(height: 16),
                  Text('No budgets set yet', style: TextStyle(color: subTextColor, fontSize: 16)),
                  const SizedBox(height: 6),
                  Text(
                    'Set spending limits per category to track your budget.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: subTextColor, fontSize: 13),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => _showSetBudgetSheet(context, controller),
                    child: const Text('Set a Budget'),
                  ),
                ],
              ),
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: progressList.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final progress = progressList[index];
            final category = progress.category;
            final color = category != null ? Color(category.colorValue) : AppColors.primary;
            final progressColor = progress.isOverBudget ? AppColors.error : color;

            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: borderColor),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      if (category != null)
                        CategoryIcon(category: category, color: color, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          category?.name ?? 'Unknown Category',
                          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit_outlined, size: 18),
                        onPressed: () => _showSetBudgetSheet(
                          context,
                          controller,
                          existingCategory: category,
                          existingAmount: progress.budget.monthlyLimit,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, size: 18, color: AppColors.error),
                        onPressed: () => _confirmDelete(controller, progress.budget.id, category?.name ?? ''),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: (progress.percentage / 100).clamp(0, 1),
                      minHeight: 8,
                      backgroundColor: borderColor,
                      valueColor: AlwaysStoppedAnimation(progressColor),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '\$${progress.spent.toStringAsFixed(2)} spent',
                        style: TextStyle(color: progressColor, fontWeight: FontWeight.w600, fontSize: 12),
                      ),
                      Text(
                        'of \$${progress.budget.monthlyLimit.toStringAsFixed(2)}',
                        style: TextStyle(color: subTextColor, fontSize: 12),
                      ),
                    ],
                  ),
                  if (progress.isOverBudget) ...[
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.warning_amber_rounded, color: AppColors.error, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          'Over budget by \$${(-progress.remaining).toStringAsFixed(2)}',
                          style: const TextStyle(color: AppColors.error, fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            );
          },
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showSetBudgetSheet(context, controller),
        child: const Icon(Icons.add),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../shared/widgets/category_icon.dart';
import '../../../core/constants/category_icons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/category_model.dart';
import '../../../data/models/transaction_type.dart';
import '../controllers/category_controller.dart';
import '../../../shared/widgets/category_icon.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  late final CategoryController _controller;
  TransactionType _selectedType = TransactionType.expense;

  @override
  void initState() {
    super.initState();
    _controller = Get.find<CategoryController>();
  }

  void _showAddCategoryDialog() {
    final nameController = TextEditingController();
    IconData selectedIcon = categoryIconOptions.first;
    Color selectedColor = AppColors.categoryPalette.first;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final isDark = Theme.of(context).brightness == Brightness.dark;

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
                    'New ${_selectedType == TransactionType.income ? 'Income' : 'Expense'} Category',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 20),

                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'Category Name', hintText: 'e.g. Groceries'),
                  ),
                  const SizedBox(height: 20),

                  Text('Icon', style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      for (final icon in categoryIconOptions)
                        InkWell(
                          onTap: () => setSheetState(() => selectedIcon = icon),
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: selectedIcon == icon
                                  ? selectedColor.withValues(alpha: 0.15)
                                  : (isDark ? AppColors.darkSurface : AppColors.lightSurface),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: selectedIcon == icon ? selectedColor : AppColors.lightBorder,
                              ),
                            ),
                            child: Icon(icon, color: selectedIcon == icon ? selectedColor : null, size: 20),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  Text('Color', style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 10,
                    children: [
                      for (final color in AppColors.categoryPalette)
                        InkWell(
                          onTap: () => setSheetState(() => selectedColor = color),
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                              border: selectedColor == color
                                  ? Border.all(color: Colors.black, width: 2)
                                  : null,
                            ),
                            child: selectedColor == color
                                ? const Icon(Icons.check, color: Colors.white, size: 18)
                                : null,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        if (nameController.text.trim().isEmpty) {
                          Get.snackbar('Name Required', 'Please enter a category name.',
                              snackPosition: SnackPosition.BOTTOM);
                          return;
                        }
                        _controller.addCategory(
                          name: nameController.text.trim(),
                          iconCodePoint: selectedIcon.codePoint,
                          colorValue: selectedColor.toARGB32(),
                          type: _selectedType,
                        );
                        Navigator.of(sheetContext).pop();
                      },
                      child: const Text('Add Category'),
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

  Future<void> _confirmDelete(CategoryModel category) async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Delete Category'),
        content: Text(
          'Delete "${category.name}"? Existing transactions in this category will keep showing it, but it won\'t be selectable for new ones.',
        ),
        actions: [
          TextButton(onPressed: () => Get.back(result: false), child: const Text('Cancel')),
          TextButton(onPressed: () => Get.back(result: true), child: const Text('Delete')),
        ],
      ),
    );

    if (confirmed == true) {
      _controller.deleteCategory(category.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final subTextColor = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    return Scaffold(
      appBar: AppBar(title: const Text('Categories')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _ToggleTab(
                      label: 'Expense',
                      isSelected: _selectedType == TransactionType.expense,
                      onTap: () => setState(() => _selectedType = TransactionType.expense),
                    ),
                  ),
                  Expanded(
                    child: _ToggleTab(
                      label: 'Income',
                      isSelected: _selectedType == TransactionType.income,
                      onTap: () => setState(() => _selectedType = TransactionType.income),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Obx(() {
              final list = _controller.byType(_selectedType);

              if (list.isEmpty) {
                return Center(
                  child: Text('No categories yet. Tap + to add one.', style: TextStyle(color: subTextColor)),
                );
              }

              return ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: list.length,
                separatorBuilder: (_, _) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final category = list[index];
                  final color = Color(category.colorValue);

                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(color: color.withValues(alpha: 0.15), shape: BoxShape.circle),
                          child: CategoryIcon(category: category, color: color),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(category.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, color: AppColors.error, size: 20),
                          onPressed: () => _confirmDelete(category),
                        ),
                      ],
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddCategoryDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _ToggleTab extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _ToggleTab({required this.label, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : null,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
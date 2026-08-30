import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/models/category_model.dart';
import '../../../data/models/transaction_type.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../controllers/transaction_controller.dart';

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  late final TransactionController _controller;
  TransactionType _selectedType = TransactionType.expense;
  CategoryModel? _selectedCategory;
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _controller = Get.put(TransactionController(), permanent: true);

    // Preselect the transaction type if one was passed in (e.g. "+ Income"
    // vs "+ Expense" quick-action buttons on Home, built in a later step).
    final args = Get.arguments;
    if (args is TransactionType) {
      _selectedType = args;
    }

    _setDefaultCategory();
  }

  void _setDefaultCategory() {
    final categories = _controller.categoriesForType(_selectedType);
    _selectedCategory = categories.isNotEmpty ? categories.first : null;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  void _handleSave() {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedCategory == null) {
      Get.snackbar('Select a Category', 'Please choose a category for this transaction.',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    final amount = double.tryParse(_amountController.text.trim());
    if (amount == null || amount <= 0) {
      Get.snackbar('Invalid Amount', 'Please enter a valid amount.', snackPosition: SnackPosition.BOTTOM);
      return;
    }

    _controller.addTransaction(
      title: _titleController.text.trim(),
      amount: amount,
      type: _selectedType,
      categoryId: _selectedCategory!.id,
      date: _selectedDate,
      note: _noteController.text.trim(),
    );

    Get.back();
    Get.snackbar(
      'Transaction Added',
      '${_selectedType == TransactionType.income ? 'Income' : 'Expense'} of \$${amount.toStringAsFixed(2)} saved.',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final subTextColor = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final typeColor = _selectedType == TransactionType.income ? AppColors.income : AppColors.expense;

    return Scaffold(
      appBar: AppBar(title: const Text('Add Transaction')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Income / Expense toggle
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _TypeToggleButton(
                        label: 'Expense',
                        icon: Icons.arrow_downward,
                        color: AppColors.expense,
                        isSelected: _selectedType == TransactionType.expense,
                        onTap: () => setState(() {
                          _selectedType = TransactionType.expense;
                          _setDefaultCategory();
                        }),
                      ),
                    ),
                    Expanded(
                      child: _TypeToggleButton(
                        label: 'Income',
                        icon: Icons.arrow_upward,
                        color: AppColors.income,
                        isSelected: _selectedType == TransactionType.income,
                        onTap: () => setState(() {
                          _selectedType = TransactionType.income;
                          _setDefaultCategory();
                        }),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              AppTextField(
                controller: _titleController,
                label: 'Title',
                hintText: _selectedType == TransactionType.income ? 'e.g. Monthly Salary' : 'e.g. Grocery shopping',
                prefixIcon: const Icon(Icons.description_outlined),
                validator: (value) => (value == null || value.trim().isEmpty) ? 'Title is required' : null,
              ),
              const SizedBox(height: 20),

              Text('Amount', style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                style: TextStyle(color: typeColor, fontWeight: FontWeight.w700, fontSize: 20),
                decoration: InputDecoration(
                  prefixText: '\$ ',
                  prefixStyle: TextStyle(color: typeColor, fontWeight: FontWeight.w700, fontSize: 20),
                  hintText: '0.00',
                ),
              ),
              const SizedBox(height: 20),

              Text('Category', style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Obx(() {
                final categories = _controller.categoriesForType(_selectedType);
                return Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final category in categories)
                      _CategoryChip(
                        category: category,
                        isSelected: _selectedCategory?.id == category.id,
                        onTap: () => setState(() => _selectedCategory = category),
                      ),
                  ],
                );
              }),
              const SizedBox(height: 20),

              Text('Date', style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              InkWell(
                onTap: _pickDate,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.calendar_today_outlined, size: 18, color: subTextColor),
                      const SizedBox(width: 10),
                      Text(DateFormat('MMM d, yyyy').format(_selectedDate)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              AppTextField(
                controller: _noteController,
                label: 'Note (optional)',
                hintText: 'Add a note...',
                prefixIcon: const Icon(Icons.notes_outlined),
                textInputAction: TextInputAction.done,
              ),
              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _handleSave,
                  style: ElevatedButton.styleFrom(backgroundColor: typeColor),
                  child: Text('Save ${_selectedType == TransactionType.income ? 'Income' : 'Expense'}'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TypeToggleButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _TypeToggleButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: isSelected ? Colors.white : color),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : color,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final CategoryModel category;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryChip({required this.category, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = Color(category.colorValue);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: isSelected ? color : Colors.grey.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(IconData(category.iconCodePoint, fontFamily: 'MaterialIcons'), size: 16, color: color),
            const SizedBox(width: 6),
            Text(
              category.name,
              style: TextStyle(color: isSelected ? color : null, fontWeight: FontWeight.w600, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/routes/app_routes.dart';
import '../../data/models/transaction_type.dart';
import '../../features/home/screens/home_screen.dart';
import '../../features/transactions/screens/transactions_screen.dart';
import '../../features/reports/screens/reports_screen.dart';
import '../../features/budget/screens/budget_screen.dart';
import '../../features/profile/screens/profile_screen.dart';

class NavShellController extends GetxController {
  final RxInt currentIndex = 0.obs;

  void changeTab(int index) => currentIndex.value = index;
}

class ScaffoldWithNavBar extends StatelessWidget {
  const ScaffoldWithNavBar({super.key});

  void _showQuickAddSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              ListTile(
                leading: const Icon(Icons.arrow_downward, color: Colors.green),
                title: const Text('Add Income'),
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  Get.toNamed(AppRoutes.addTransaction, arguments: TransactionType.income);
                },
              ),
              ListTile(
                leading: const Icon(Icons.arrow_upward, color: Colors.red),
                title: const Text('Add Expense'),
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  Get.toNamed(AppRoutes.addTransaction, arguments: TransactionType.expense);
                },
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(NavShellController(), permanent: true);

    final screens = [
      const HomeScreen(),
      const TransactionsScreen(),
      const ReportsScreen(),
      const BudgetScreen(),
      const ProfileScreen(),
    ];

    return Obx(() {
      return Scaffold(
        body: IndexedStack(
          index: controller.currentIndex.value,
          children: screens,
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _showQuickAddSheet(context),
          child: const Icon(Icons.add),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        bottomNavigationBar: SizedBox(
          height: 64,
          child: BottomAppBar(
            shape: const CircularNotchedRectangle(),
            notchMargin: 8,
            padding: EdgeInsets.zero,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _NavIcon(icon: Icons.dashboard_outlined, activeIcon: Icons.dashboard, label: 'Home', index: 0, controller: controller),
                _NavIcon(icon: Icons.receipt_long_outlined, activeIcon: Icons.receipt_long, label: 'History', index: 1, controller: controller),
                const SizedBox(width: 40),
                _NavIcon(icon: Icons.pie_chart_outline, activeIcon: Icons.pie_chart, label: 'Reports', index: 2, controller: controller),
                _NavIcon(icon: Icons.person_outline, activeIcon: Icons.person, label: 'Profile', index: 4, controller: controller),
              ],
            ),
          ),
        ),
      );
    });
  }
}

class _NavIcon extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final int index;
  final NavShellController controller;

  const _NavIcon({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.index,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = controller.currentIndex.value == index;

    return InkWell(
      onTap: () => controller.changeTab(index),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? activeIcon : icon,
              size: 22,
              color: isSelected ? Theme.of(context).colorScheme.primary : null,
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: isSelected ? Theme.of(context).colorScheme.primary : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
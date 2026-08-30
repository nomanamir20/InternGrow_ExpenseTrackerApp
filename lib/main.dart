import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'core/constants/default_categories.dart';
import 'core/constants/hive_boxes.dart';
import 'core/routes/app_pages.dart';
import 'core/routes/app_routes.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_controller.dart';
import 'data/models/budget_model.dart';
import 'data/models/category_model.dart';
import 'data/models/transaction_model.dart';
import 'data/models/transaction_type.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();

  Hive.registerAdapter(TransactionTypeAdapter());
  Hive.registerAdapter(CategoryModelAdapter());
  Hive.registerAdapter(TransactionModelAdapter());
  Hive.registerAdapter(BudgetModelAdapter());

  await Hive.openBox(HiveBoxes.settings);
  await Hive.openBox<TransactionModel>(HiveBoxes.transactions);
  final categoriesBox = await Hive.openBox<CategoryModel>(HiveBoxes.categories);
  await Hive.openBox<BudgetModel>(HiveBoxes.budgets);

  // Seed default categories on first launch only.
  if (categoriesBox.isEmpty) {
    for (final category in buildDefaultCategories()) {
      await categoriesBox.put(category.id, category);
    }
  }

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final themeController = Get.put(ThemeController());

  runApp(InternGrowExpenseTrackerApp(themeController: themeController));
}

class InternGrowExpenseTrackerApp extends StatelessWidget {
  final ThemeController themeController;

  const InternGrowExpenseTrackerApp({super.key, required this.themeController});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return GetMaterialApp(
        title: 'InternGrow Finance',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: themeController.isDarkMode.value ? ThemeMode.dark : ThemeMode.light,
        initialRoute: AppRoutes.splash,
        getPages: AppPages.pages,
      );
    });
  }
}
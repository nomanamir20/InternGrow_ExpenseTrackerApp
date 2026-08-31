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
import 'features/categories/controllers/category_controller.dart';
import 'features/transactions/controllers/transaction_controller.dart';
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

  if (categoriesBox.isEmpty) {
    for (final category in buildDefaultCategories()) {
      await categoriesBox.put(category.id, category);
    }
  }

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Register all app-wide controllers ONCE here, rather than ad hoc in
  // individual screens via Get.put — this guarantees they're available
  // via Get.find() no matter which screen the user reaches first.
  Get.put(ThemeController());
  Get.put(CategoryController(), permanent: true);
  Get.put(TransactionController(), permanent: true);

  runApp(const InternGrowExpenseTrackerApp());
}

class InternGrowExpenseTrackerApp extends StatelessWidget {
  const InternGrowExpenseTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();

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
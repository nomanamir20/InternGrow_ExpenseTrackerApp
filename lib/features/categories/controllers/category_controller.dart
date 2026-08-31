import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

import '../../../core/constants/hive_boxes.dart';
import '../../../data/models/category_model.dart';
import '../../../data/models/transaction_type.dart';

class CategoryController extends GetxController {
  final Box<CategoryModel> _categoriesBox = Hive.box<CategoryModel>(HiveBoxes.categories);

  final RxList<CategoryModel> categories = <CategoryModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadCategories();
  }

  void _loadCategories() {
    categories.assignAll(_categoriesBox.values.toList());
  }

  List<CategoryModel> byType(TransactionType type) {
    return categories.where((c) => c.type == type).toList();
  }

  Future<void> addCategory({
    required String name,
    required int iconCodePoint,
    required int colorValue,
    required TransactionType type,
  }) async {
    final category = CategoryModel(
      id: const Uuid().v4(),
      name: name,
      iconCodePoint: iconCodePoint,
      colorValue: colorValue,
      type: type,
    );

    await _categoriesBox.put(category.id, category);
    _loadCategories();
  }

  Future<void> deleteCategory(String id) async {
    await _categoriesBox.delete(id);
    _loadCategories();
  }
}
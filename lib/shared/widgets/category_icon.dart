import 'package:flutter/material.dart';

import '../../data/models/category_model.dart';

/// Builds an Icon from a CategoryModel's stored icon code point.
/// Centralized here so there's only ONE place in the codebase where this
/// icon-from-runtime-data pattern exists.
class CategoryIcon extends StatelessWidget {
  final CategoryModel? category;
  final double size;
  final Color? color;

  const CategoryIcon({super.key, required this.category, this.size = 20, this.color});

  @override
  Widget build(BuildContext context) {
    final currentCategory = category;

    if (currentCategory == null) {
      return Icon(Icons.category_outlined, size: size, color: color);
    }

    final iconData = IconData(currentCategory.iconCodePoint, fontFamily: 'MaterialIcons');
    return Icon(iconData, size: size, color: color ?? Color(currentCategory.colorValue));
  }
}
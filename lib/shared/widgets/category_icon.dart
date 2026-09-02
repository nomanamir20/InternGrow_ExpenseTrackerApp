import 'package:flutter/material.dart';

import '../../data/models/category_model.dart';

/// Builds an Icon from a CategoryModel's stored icon code point.
/// Centralized here so there's only ONE place in the codebase where this
/// icon-from-runtime-data pattern exists — every screen that shows a
/// category icon uses this widget instead of repeating the pattern, which
/// is what kept causing "const" to be mistakenly re-applied to a
/// non-constant expression across multiple files.
class CategoryIcon extends StatelessWidget {
  final CategoryModel? category;
  final double size;
  final Color? color;

  const CategoryIcon({super.key, required this.category, this.size = 20, this.color});

  @override
  Widget build(BuildContext context) {
    if (category == null) {
      return Icon(Icons.category_outlined, size: size, color: color);
    }
    final iconData = IconData(category!.iconCodePoint, fontFamily: 'MaterialIcons');
    return Icon(iconData, size: size, color: color ?? Color(category!.colorValue));
  }
}
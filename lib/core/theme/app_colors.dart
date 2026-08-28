import 'package:flutter/material.dart';

/// Centralized color tokens — a single place to re-theme the whole app.
class AppColors {
  AppColors._();

  static const Color primary = Color(0xFF2563EB);   // Trustworthy blue — finance/banking association
  static const Color primaryDark = Color(0xFF1D4ED8);
  static const Color income = Color(0xFF16A34A);      // Green — money in
  static const Color expense = Color(0xFFDC2626);     // Red — money out
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFDC2626);

  static const Color lightBackground = Color(0xFFFAFAFB);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightBorder = Color(0xFFE5E7EB);

  static const Color darkBackground = Color(0xFF0F1115);
  static const Color darkSurface = Color(0xFF1A1D23);
  static const Color darkBorder = Color(0xFF2A2E37);

  static const Color textPrimaryLight = Color(0xFF1A1D23);
  static const Color textSecondaryLight = Color(0xFF6B7280);
  static const Color textPrimaryDark = Color(0xFFF5F5F7);
  static const Color textSecondaryDark = Color(0xFF9CA3AF);

  // A palette for category chips/charts — enough distinct colors for
  // typical expense categories (food, transport, bills, etc.)
  static const List<Color> categoryPalette = [
    Color(0xFF2563EB),
    Color(0xFF16A34A),
    Color(0xFFF59E0B),
    Color(0xFFDC2626),
    Color(0xFF9333EA),
    Color(0xFF0891B2),
    Color(0xFFDB2777),
    Color(0xFF65A30D),
  ];
}
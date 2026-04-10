import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors
  static const Color primary = Color(0xFF6C63FF);
  static const Color primaryDark = Color(0xFF5548C8);
  static const Color accent = Color(0xFFFF6584);

  // Income & Expense (Fintech Standard)
  static const Color income = Color(0xFF4ADE80);
  static const Color expense = Color(0xFFFF6B6B);
  static const Color savings = Color(0xFF60A5FA);

  // Category Colors
  static const Color foodDining = Color(0xFFFF9800);
  static const Color shopping = Color(0xFF9C27B0);
  static const Color transportation = Color(0xFF2196F3);
  static const Color entertainment = Color(0xFFE91E63);
  static const Color bills = Color(0xFF607D8B);
  static const Color healthcare = Color(0xFFF44336);
  static const Color education = Color(0xFF3F51B5);
  static const Color other = Color(0xFF795548);

  // Income Categories
  static const Color salary = Color(0xFF4CAF50);
  static const Color freelance = Color(0xFF009688);
  static const Color investment = Color(0xFF00BCD4);
  static const Color gift = Color(0xFFE91E63);
  static const Color otherIncome = Color(0xFF8BC34A);

  // UI Colors
  static const Color background = Color(0xFFFFFFFF);
  static const Color lightBackground = Color(0xFFFFFFFF);
  static const Color surface = Colors.white;
  static const Color error = Color(0xFFFF6B6B);
  static const Color success = Color(0xFF4ADE80);
  static const Color warning = Color(0xFFFACC15);

  // Dark Mode Colors (Premium Dark)
  static const Color darkBackground = Color(0xFF0F1113);
  static const Color darkSurface = Color(0xFF1A1D1F);
  static const Color darkCard = Color(0xFF272B30);
  static const Color darkField = Color(0xFF1E2123);

  // Text Colors
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF9CA3AF);
  static const Color textLight = Color(0xFFFFFFFF);

  // Gradients
  static const List<Color> primaryGradient = [
    Color(0xFF6C63FF),
    Color(0xFF5548C8),
  ];

  // New gradient matching the screenshot theme (pink to purple to blue)
  static const List<Color> balanceCardGradient = [
    Color(0xFFFFB3C6), // Soft pink (top left)
    Color(0xFFD77BFF), // Purple magenta (middle)
    Color(0xFF8B9CFF), // Soft blue purple (bottom right)
  ];

  static const List<Color> incomeGradient = [
    Color(0xFF4CAF50),
    Color(0xFF45A049),
  ];

  static const List<Color> expenseGradient = [
    Color(0xFFFF5252),
    Color(0xFFE53935),
  ];

  // Chart colors matching the screenshot
  static const Color chartGreen = Color(0xFF4ADE80);
  static const Color chartLightGreen = Color(0xFF86EFAC);
  static const Color chartPurple = Color(0xFFA78BFA);
  static const Color chartBlue = Color(0xFF60A5FA);
  static const Color chartPink = Color(0xFFF9A8D4);

  // Text colors for better consistency
  static const Color darkText = Color(0xFF1A1D1F);
  static const Color secondaryText = Color(0xFF6F7787);
  static const Color greyText = Color(0xFF9CA3AF);
  static const Color dividerColor = Color(0xFFE5E7EB);
  static const Color fieldBackground = Color(0xFFF5F5F5);

  // Theme-aware methods
  static bool isDarkMode(BuildContext context) => Theme.of(context).brightness == Brightness.dark;

  static Color adaptiveBackground(BuildContext context) => 
      isDarkMode(context) ? darkBackground : lightBackground;

  static Color adaptiveSurface(BuildContext context) => 
      isDarkMode(context) ? darkSurface : surface;

  static Color adaptiveCard(BuildContext context) => 
      isDarkMode(context) ? darkCard : surface;

  static Color adaptiveText(BuildContext context) => 
      isDarkMode(context) ? textLight : darkText;

  static Color adaptiveSecondaryText(BuildContext context) => 
      isDarkMode(context) ? Colors.white.withValues(alpha: 0.7) : secondaryText;

  static Color adaptiveFieldBackground(BuildContext context) => 
      isDarkMode(context) ? darkSurface : fieldBackground;

  static Color adaptiveDivider(BuildContext context) => 
      isDarkMode(context) ? Colors.white.withValues(alpha: 0.1) : dividerColor;
}

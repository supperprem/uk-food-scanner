import 'package:flutter/material.dart';

class AppTheme {
  // Colors (Apple Health + Yuka premium style)
  static const Color primaryGreen = Color(0xFF2E7D32);
  static const Color secondaryGreen = Color(0xFF43A047);
  static const Color lightBackground = Color(0xFFF8FAF8);
  static const Color cardColor = Colors.white;
  static const Color textDark = Colors.black87;
  static const Color textGrey = Colors.grey;
  static const Color accentOrange = Color(0xFFF57C00);
  static const Color accentRed = Color(0xFFD32F2F);

  // Spacing Constants
  static const double spacingXs = 4.0;
  static const double spacingSm = 8.0;
  static const double spacingMd = 16.0;
  static const double spacingLg = 24.0;
  static const double spacingXl = 32.0;

  // Radius Constants
  static const double radiusSm = 12.0;
  static const double radiusMd = 16.0;
  static const double radiusLg = 20.0;
  static const double radiusXl = 24.0;

  // Card Styles
  static BoxDecoration cardDecoration = BoxDecoration(
    color: cardColor,
    borderRadius: BorderRadius.circular(radiusLg),
    boxShadow: [
      BoxShadow(
        color: Colors.grey.withValues(alpha: 0.06),
        blurRadius: 12,
        offset: const Offset(0, 4),
      ),
    ],
    border: Border.all(color: Colors.grey.shade200),
  );

  static BoxDecoration gradientCardDecoration = BoxDecoration(
    gradient: const LinearGradient(
      colors: [primaryGreen, secondaryGreen],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    borderRadius: BorderRadius.circular(radiusXl),
    boxShadow: [
      BoxShadow(
        color: primaryGreen.withValues(alpha: 0.3),
        blurRadius: 16,
        offset: const Offset(0, 8),
      ),
    ],
  );

  // Text Styles
  static const TextStyle heading1 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: textDark,
    height: 1.2,
  );

  static const TextStyle heading2 = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: textDark,
    height: 1.3,
  );

  static const TextStyle bodyText = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: textDark,
    height: 1.4,
  );

  static const TextStyle captionText = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: textGrey,
    height: 1.3,
  );

  static const double paddingDefault = 20.0;
  static const double radiusDefault = 20.0;
}

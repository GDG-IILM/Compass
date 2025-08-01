// utils/colors.dart
import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors
  static const Color primaryBlue = Color(0xFF1E3A8A);
  static const Color primaryLightBlue = Color(0xFF3B82F6);
  static const Color primaryDarkBlue = Color(0xFF1E40AF);

  // Secondary Colors
  static const Color secondaryGreen = Color(0xFF10B981);
  static const Color secondaryLightGreen = Color(0xFF34D399);
  static const Color secondaryOrange = Color(0xFFF59E0B);
  static const Color secondaryPurple = Color(0xFF8B5CF6);

  // Neutral Colors
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color darkGray = Color(0xFF374151);
  static const Color mediumGray = Color(0xFF6B7280);
  static const Color lightGray = Color(0xFF9CA3AF);
  static const Color veryLightGray = Color(0xFFF3F4F6);
  static const Color offWhite = Color(0xFFFAFAFA);

  // Background Colors (These were missing the commonly used names)
  static const Color backgroundColor = Color(0xFFF8FAFC);
  static const Color background = Color(0xFFF8FAFC); // Added this alias
  static const Color surfaceColor = Color(0xFFFFFFFF);
  static const Color surface = Color(0xFFFFFFFF); // Added this alias
  static const Color cardColor = Color(0xFFFFFFFF);

  // Primary/Accent Colors (Added missing accent)
  static const Color primary = primaryBlue; // Alias for primary
  static const Color accent = primaryLightBlue; // Added accent color

  // Status Colors
  static const Color successGreen = Color(0xFF059669);
  static const Color success = Color(0xFF059669); // Added this alias
  static const Color warningYellow = Color(0xFFF59E0B);
  static const Color warning = warningYellow; // Alias
  static const Color errorRed = Color(0xFFDC2626);
  static const Color error = errorRed; // Alias
  static const Color infoBlue = Color(0xFF2563EB);
  static const Color info = infoBlue; // Alias

  // Text Colors
  static const Color textPrimary = Color(0xFF111827);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textTertiary = Color(0xFF9CA3AF);
  static const Color textLight = Color(0xFFFFFFFF);

  // Border Colors
  static const Color borderLight = Color(0xFFE5E7EB);
  static const Color borderMedium = Color(0xFFD1D5DB);
  static const Color borderDark = Color(0xFF9CA3AF);

  // Gradient Colors
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryBlue, primaryLightBlue],
  );

  static const LinearGradient secondaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [secondaryGreen, secondaryLightGreen],
  );

  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFFFFF), Color(0xFFF8FAFC)],
  );

  // Shadow Colors
  static const Color shadowLight = Color(0x0D000000);
  static const Color shadowMedium = Color(0x1A000000);
  static const Color shadowDark = Color(0x26000000);

  // Academic Theme Colors
  static const Color academicBlue = Color(0xFF1E40AF);
  static const Color academicGold = Color(0xFFD97706);
  static const Color academicNavy = Color(0xFF1E3A8A);
  static const Color academicCream = Color(0xFFFEF7ED);

  // Category Colors for different sections
  static const Color resourcesColor = Color(0xFF10B981);
  static const Color eventsColor = Color(0xFF8B5CF6);
  static const Color wallColor = Color(0xFFF59E0B);
  static const Color profileColor = Color(0xFF3B82F6);

  // Opacity variants
  static Color primaryBlueWithOpacity(double opacity) =>
      primaryBlue.withOpacity(opacity);

  static Color blackWithOpacity(double opacity) =>
      black.withOpacity(opacity);

  static Color whiteWithOpacity(double opacity) =>
      white.withOpacity(opacity);

  // Additional commonly used opacity variants
  static Color primaryWithOpacity(double opacity) =>
      primary.withOpacity(opacity);

  static Color accentWithOpacity(double opacity) =>
      accent.withOpacity(opacity);

  static Color successWithOpacity(double opacity) =>
      success.withOpacity(opacity);
}
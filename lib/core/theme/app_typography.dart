import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Vişi Editorial Typography System
/// 
/// Minimal, elegant, lifestyle inspired sans-serif hierarchy:
/// - Large editorial headings
/// - Medium section titles
/// - Small uppercase metadata labels
/// - Comfortable body text
/// - Distinct weighted price values
class AppTypography {
  AppTypography._();

  static const String fontFamily = 'System'; // Clean system sans-serif

  static TextTheme lightTextTheme = const TextTheme(
    displayLarge: TextStyle(
      fontSize: 32,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.8,
      color: AppColors.lightTextPrimary,
      height: 1.2,
    ),
    displayMedium: TextStyle(
      fontSize: 26,
      fontWeight: FontWeight.w600,
      letterSpacing: -0.5,
      color: AppColors.lightTextPrimary,
      height: 1.25,
    ),
    titleLarge: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      letterSpacing: -0.3,
      color: AppColors.lightTextPrimary,
      height: 1.3,
    ),
    titleMedium: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      letterSpacing: -0.2,
      color: AppColors.lightTextPrimary,
      height: 1.35,
    ),
    bodyLarge: TextStyle(
      fontSize: 15,
      fontWeight: FontWeight.w400,
      letterSpacing: -0.1,
      color: AppColors.lightTextPrimary,
      height: 1.45,
    ),
    bodyMedium: TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.w400,
      letterSpacing: 0,
      color: AppColors.lightTextSecondary,
      height: 1.4,
    ),
    labelSmall: TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.w600,
      letterSpacing: 1.2,
      color: AppColors.lightTextMuted,
      height: 1.2,
    ),
  );

  static TextTheme darkTextTheme = const TextTheme(
    displayLarge: TextStyle(
      fontSize: 32,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.8,
      color: AppColors.darkTextPrimary,
      height: 1.2,
    ),
    displayMedium: TextStyle(
      fontSize: 26,
      fontWeight: FontWeight.w600,
      letterSpacing: -0.5,
      color: AppColors.darkTextPrimary,
      height: 1.25,
    ),
    titleLarge: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      letterSpacing: -0.3,
      color: AppColors.darkTextPrimary,
      height: 1.3,
    ),
    titleMedium: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      letterSpacing: -0.2,
      color: AppColors.darkTextPrimary,
      height: 1.35,
    ),
    bodyLarge: TextStyle(
      fontSize: 15,
      fontWeight: FontWeight.w400,
      letterSpacing: -0.1,
      color: AppColors.darkTextPrimary,
      height: 1.45,
    ),
    bodyMedium: TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.w400,
      letterSpacing: 0,
      color: AppColors.darkTextSecondary,
      height: 1.4,
    ),
    labelSmall: TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.w600,
      letterSpacing: 1.2,
      color: AppColors.darkTextMuted,
      height: 1.2,
    ),
  );
}

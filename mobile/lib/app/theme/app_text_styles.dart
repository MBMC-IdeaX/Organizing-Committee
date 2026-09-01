import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Centralized Typography Hierarchy for IdeaX Judging System using Inter.
class AppTextStyles {
  AppTextStyles._();

  static TextStyle _interStyle({
    required double fontSize,
    required FontWeight fontWeight,
    Color? color,
    double? letterSpacing,
    double? height,
  }) {
    final effectiveColor = color ?? AppColors.textPrimary;
    return TextStyle(
      fontFamily: 'Inter',
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: effectiveColor,
      letterSpacing: letterSpacing,
      height: height,
    );
  }

  // Large Dashboard Numbers / Prominent Metric Displays
  static TextStyle displayLarge = _interStyle(
    fontSize: 32,
    fontWeight: FontWeight.w800,
    color: AppColors.primaryNavy,
    letterSpacing: -0.5,
  );

  static TextStyle displayMedium = _interStyle(
    fontSize: 26,
    fontWeight: FontWeight.w700,
    color: AppColors.primaryNavy,
    letterSpacing: -0.3,
  );

  // Screen & Section Headings
  static TextStyle headingLarge = _interStyle(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  static TextStyle headingMedium = _interStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static TextStyle headingSmall = _interStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  // Body Text
  static TextStyle bodyLarge = _interStyle(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
    height: 1.4,
  );

  static TextStyle bodyMedium = _interStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    height: 1.4,
  );

  static TextStyle bodySmall = _interStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );

  // Buttons & Interactive Labels
  static TextStyle button = _interStyle(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    color: AppColors.textOnPrimary,
    letterSpacing: 0.2,
  );

  static TextStyle buttonSecondary = _interStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.primaryBlue,
    letterSpacing: 0.2,
  );

  // Labels & Badges
  static TextStyle label = _interStyle(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
  );

  static TextStyle badge = _interStyle(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.4,
  );

  // Rubric Scores (Visually Prominent)
  static TextStyle scoreDisplay = _interStyle(
    fontSize: 24,
    fontWeight: FontWeight.w800,
    color: AppColors.primaryBlue,
  );

  static TextStyle titleMedium = _interStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static TextStyle labelLarge = _interStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static TextStyle caption = _interStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
  );
}

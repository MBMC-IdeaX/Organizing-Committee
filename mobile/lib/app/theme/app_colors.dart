import 'package:flutter/material.dart';

/// Centralized Design System Colors for IdeaX Judging System
/// Adheres strictly to the finalized Light Glassmorphism UI direction.
class AppColors {
  AppColors._();

  // Primary Palette
  static const Color primaryNavy = Color(0xFF0B1F4B);
  static const Color primaryBlue = Color(0xFF2563EB);
  static const Color secondaryBlue = Color(0xFF3B82F6);
  static const Color softBlue = Color(0xFFDBEAFE);
  static const Color accentCyan = Color(0xFF06B6D4);

  // Background & Surfaces
  static const Color background = Color(0xFFF5F9FF);
  static const Color surface = Color(0xFFFFFFFF);
  
  // Glassmorphism Values (60-80% opacity white with soft borders)
  static const Color glassSurface = Color(0xCCFFFFFF); // ~80% opacity
  static const Color glassSurfaceLight = Color(0x99FFFFFF); // ~60% opacity
  static const Color border = Color(0xFFDCE6F5);
  static const Color borderLight = Color(0x80DCE6F5);

  // Typography
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textMuted = Color(0xFF94A3B8);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // Status & Feedback
  static const Color success = Color(0xFF16A34A);
  static const Color successBackground = Color(0xFFDCFCE7);
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningBackground = Color(0xFFFEF3C7);
  static const Color error = Color(0xFFDC2626);
  static const Color errorBackground = Color(0xFFFEE2E2);
  static const Color info = Color(0xFF0284C7);
  static const Color infoBackground = Color(0xFFE0F2FE);

  // Gradients (Subtle & soft)
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryNavy, primaryBlue],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient backgroundMeshGradient = LinearGradient(
    colors: [Color(0xFFF0F6FF), Color(0xFFF8FAFC), Color(0xFFEFF6FF)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient glassCardGradient = LinearGradient(
    colors: [
      Color(0xE6FFFFFF),
      Color(0xB3FFFFFF),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient heroCardGradient = LinearGradient(
    colors: [primaryNavy, Color(0xFF1E3A8A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient successCardGradient = LinearGradient(
    colors: [Color(0xFF065F46), Color(0xFF059669)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

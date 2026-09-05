import 'package:flutter/material.dart';

/// Centralized Spacing, Radii, and Sizing Tokens for IdeaX Glassmorphism Design System.
class AppDimensions {
  AppDimensions._();

  // Spacing & Padding
  static const double space2 = 2.0;
  static const double space4 = 4.0;
  static const double space6 = 6.0;
  static const double space8 = 8.0;
  static const double space10 = 10.0;
  static const double space12 = 12.0;
  static const double space14 = 14.0;
  static const double space16 = 16.0;
  static const double space18 = 18.0;
  static const double space20 = 20.0;
  static const double space24 = 24.0;
  static const double space28 = 28.0;
  static const double space32 = 32.0;
  static const double space40 = 40.0;
  static const double space48 = 48.0;

  // Screen Padding
  static const EdgeInsets screenPadding = EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0);
  static const EdgeInsets cardPadding = EdgeInsets.all(18.0);
  static const EdgeInsets compactCardPadding = EdgeInsets.all(14.0);
  static const EdgeInsets inputPadding = EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0);

  // Corner Radii
  static const double radiusSmall = 8.0;
  static const double radiusMedium = 14.0;
  static const double radiusLarge = 20.0;
  static const double radiusExtraLarge = 28.0;

  static const BorderRadius borderRadiusSmall = BorderRadius.all(Radius.circular(radiusSmall));
  static const BorderRadius borderRadiusMedium = BorderRadius.all(Radius.circular(radiusMedium));
  static const BorderRadius borderRadiusLarge = BorderRadius.all(Radius.circular(radiusLarge));
  static const BorderRadius borderRadiusExtraLarge = BorderRadius.all(Radius.circular(radiusExtraLarge));

  // Button & Input Heights (Compact, proportional)
  static const double buttonHeight = 48.0;
  static const double compactButtonHeight = 42.0;
  static const double smallButtonHeight = 36.0;
  static const double inputHeight = 48.0;
  static const double appBarHeight = 56.0;
  static const double logoHeight = 44.0;
  static const double splashLogoHeight = 72.0;

  // Glassmorphism Blur Strength (Subtle, crisp)
  static const double glassBlur = 10.0;
  static const double glassBorderWidth = 1.2;

  // Soft Glass Shadows
  static const List<BoxShadow> glassShadow = [
    BoxShadow(
      color: Color(0x0A0B1F4B), // Very subtle navy drop shadow
      blurRadius: 16,
      offset: Offset(0, 4),
    ),
  ];

  static const List<BoxShadow> glassElevatedShadow = [
    BoxShadow(
      color: Color(0x120B1F4B),
      blurRadius: 20,
      offset: Offset(0, 6),
    ),
  ];
}

/// Design system aliases
typedef GlassDimensions = AppDimensions;
typedef GlassSpacing = AppDimensions;
typedef GlassRadius = AppDimensions;
typedef GlassShadows = AppDimensions;

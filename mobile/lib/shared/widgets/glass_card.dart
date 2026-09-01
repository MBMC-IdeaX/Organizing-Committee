import 'dart:ui';
import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_dimensions.dart';

/// Reusable Light Glassmorphism Container Card.
/// Implements subtle backdrop filter, translucent white surface, and refined borders.
class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final Color? surfaceColor;
  final Color? borderColor;
  final Gradient? gradient;
  final double blur;
  final VoidCallback? onTap;

  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.borderRadius,
    this.surfaceColor,
    this.borderColor,
    this.gradient,
    this.blur = AppDimensions.glassBlur,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveRadius = borderRadius ?? AppDimensions.borderRadiusLarge;

    Widget cardContent = Container(
      width: width,
      height: height,
      padding: padding ?? AppDimensions.cardPadding,
      decoration: BoxDecoration(
        color: gradient == null ? (surfaceColor ?? AppColors.glassSurface) : null,
        gradient: gradient,
        borderRadius: effectiveRadius,
        border: Border.all(
          color: borderColor ?? AppColors.border,
          width: AppDimensions.glassBorderWidth,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A0B1F4B), // Very subtle navy drop shadow
            blurRadius: 16,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );

    Widget frostedCard = ClipRRect(
      borderRadius: effectiveRadius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: cardContent,
      ),
    );

    if (margin != null) {
      frostedCard = Padding(padding: margin!, child: frostedCard);
    }

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: frostedCard,
      );
    }

    return frostedCard;
  }
}

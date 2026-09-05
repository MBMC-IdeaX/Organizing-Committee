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
  final List<BoxShadow>? boxShadow;
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
    this.boxShadow,
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
          color: borderColor ?? AppColors.borderLight,
          width: AppDimensions.glassBorderWidth,
        ),
        boxShadow: boxShadow ?? AppDimensions.glassShadow,
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

    if (onTap != null) {
      frostedCard = Material(
        color: Colors.transparent,
        borderRadius: effectiveRadius,
        child: InkWell(
          borderRadius: effectiveRadius,
          onTap: onTap,
          splashColor: AppColors.primaryBlue.withValues(alpha: 0.08),
          highlightColor: AppColors.primaryBlue.withValues(alpha: 0.04),
          child: frostedCard,
        ),
      );
    }

    if (margin != null) {
      frostedCard = Padding(padding: margin!, child: frostedCard);
    }

    return frostedCard;
  }
}

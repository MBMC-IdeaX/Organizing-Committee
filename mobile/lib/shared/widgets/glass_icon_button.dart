import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_dimensions.dart';

/// Compact, accessible glass icon button.
class GlassIconButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;
  final Color? color;
  final Color? backgroundColor;
  final double size;
  final double iconSize;

  const GlassIconButton({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.color,
    this.backgroundColor,
    this.size = 38.0,
    this.iconSize = 18.0,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? AppColors.primaryNavy;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.glassSurface,
        borderRadius: AppDimensions.borderRadiusSmall,
        border: Border.all(color: AppColors.borderLight),
      ),
      child: IconButton(
        icon: Icon(icon, size: iconSize),
        color: effectiveColor,
        tooltip: tooltip,
        padding: EdgeInsets.zero,
        constraints: BoxConstraints(minWidth: size, minHeight: size),
        onPressed: onPressed,
      ),
    );
  }
}

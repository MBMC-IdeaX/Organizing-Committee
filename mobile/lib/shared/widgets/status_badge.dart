import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_dimensions.dart';
import '../../app/theme/app_text_styles.dart';

enum BadgeType {
  success,
  warning,
  error,
  info,
  neutral,
}

class StatusBadge extends StatelessWidget {
  final String label;
  final BadgeType type;

  const StatusBadge({
    super.key,
    required this.label,
    this.type = BadgeType.neutral,
  });

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    Color textColor;

    switch (type) {
      case BadgeType.success:
        backgroundColor = AppColors.successBackground;
        textColor = AppColors.success;
        break;
      case BadgeType.warning:
        backgroundColor = AppColors.warningBackground;
        textColor = AppColors.warning;
        break;
      case BadgeType.error:
        backgroundColor = AppColors.errorBackground;
        textColor = AppColors.error;
        break;
      case BadgeType.info:
        backgroundColor = AppColors.infoBackground;
        textColor = AppColors.info;
        break;
      case BadgeType.neutral:
        backgroundColor = AppColors.softBlue;
        textColor = AppColors.primaryNavy;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: AppDimensions.borderRadiusSmall,
      ),
      child: Text(
        label,
        style: AppTextStyles.badge.copyWith(color: textColor),
      ),
    );
  }
}

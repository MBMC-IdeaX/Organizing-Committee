import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_dimensions.dart';
import '../../app/theme/app_text_styles.dart';
import 'glass_card.dart';

/// Reusable Foundation for Criterion Score Card.
/// Designed for high readability, touch accessibility, and prominent score display.
class ScoreCardFoundation extends StatelessWidget {
  final String criteriaName;
  final String? description;
  final int maxScore;
  final int? currentScore;
  final Widget? scoringWidget;

  const ScoreCardFoundation({
    super.key,
    required this.criteriaName,
    this.description,
    required this.maxScore,
    this.currentScore,
    this.scoringWidget,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      margin: const EdgeInsets.only(bottom: AppDimensions.space16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      criteriaName,
                      style: AppTextStyles.headingSmall.copyWith(
                        color: AppColors.primaryNavy,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (description != null && description!.isNotEmpty) ...[
                      const SizedBox(height: AppDimensions.space4),
                      Text(
                        description!,
                        style: AppTextStyles.bodySmall,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: AppDimensions.space12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.softBlue,
                  borderRadius: AppDimensions.borderRadiusSmall,
                ),
                child: Text(
                  'Max: $maxScore',
                  style: AppTextStyles.badge.copyWith(
                    color: AppColors.primaryBlue,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          if (scoringWidget != null) ...[
            const SizedBox(height: AppDimensions.space16),
            const Divider(),
            const SizedBox(height: AppDimensions.space8),
            scoringWidget!,
          ],
        ],
      ),
    );
  }
}

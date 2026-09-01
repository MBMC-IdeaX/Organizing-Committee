import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../app/theme/app_text_styles.dart';

class AuthHeader extends StatelessWidget {
  final double logoHeight;
  final bool showTagline;

  const AuthHeader({
    super.key,
    this.logoHeight = 56.0,
    this.showTagline = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // IdeaX Brand Logo Container
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: AppDimensions.borderRadiusLarge,
            border: Border.all(color: AppColors.border, width: 1.0),
            boxShadow: const [
              BoxShadow(
                color: Color(0x080B1F4B),
                blurRadius: 12,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Image.asset(
            'assets/images/ideax_logo.png',
            height: logoHeight,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: AppColors.primaryNavy,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.bolt, color: AppColors.accentCyan, size: 24),
                ),
                const SizedBox(width: 10),
                Text(
                  'IdeaX',
                  style: AppTextStyles.displayMedium.copyWith(
                    color: AppColors.primaryNavy,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppDimensions.space20),
        Text(
          'IdeaX Judging System',
          style: AppTextStyles.headingLarge.copyWith(
            color: AppColors.primaryNavy,
            fontWeight: FontWeight.w800,
          ),
          textAlign: TextAlign.center,
        ),
        if (showTagline) ...[
          const SizedBox(height: AppDimensions.space8),
          Text(
            'Live Hackathon Evaluation Platform',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }
}

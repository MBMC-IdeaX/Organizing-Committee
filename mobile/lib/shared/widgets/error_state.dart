import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_dimensions.dart';
import '../../app/theme/app_text_styles.dart';
import 'primary_button.dart';

class ErrorState extends StatelessWidget {
  final String title;
  final String message;
  final String? retryText;
  final VoidCallback? onRetry;

  const ErrorState({
    super.key,
    this.title = 'Something went wrong',
    required this.message,
    this.retryText = 'Try Again',
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: AppDimensions.screenPadding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(AppDimensions.space20),
              decoration: const BoxDecoration(
                color: AppColors.errorBackground,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.error_outline_rounded, size: 48, color: AppColors.error),
            ),
            const SizedBox(height: AppDimensions.space20),
            Text(
              title,
              style: AppTextStyles.headingMedium.copyWith(color: AppColors.primaryNavy),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppDimensions.space8),
            Text(
              message,
              style: AppTextStyles.bodyMedium,
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: AppDimensions.space24),
              PrimaryButton(
                text: retryText!,
                onPressed: onRetry!,
                width: 160,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

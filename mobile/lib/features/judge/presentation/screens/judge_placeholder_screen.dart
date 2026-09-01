import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../app/routes/route_names.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_app_bar.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../../../shared/widgets/secondary_button.dart';
import '../../../../shared/widgets/status_badge.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';

class JudgePlaceholderScreen extends StatelessWidget {
  const JudgePlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is Unauthenticated) {
          Navigator.pushNamedAndRemoveUntil(context, RouteNames.login, (route) => false);
        }
      },
      child: Scaffold(
        appBar: AppAppBar(
          showLogo: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.logout_rounded, color: AppColors.error),
              tooltip: 'Logout',
              onPressed: () => context.read<AuthCubit>().logout(),
            ),
          ],
        ),
        body: Container(
          decoration: const BoxDecoration(
            gradient: AppColors.backgroundMeshGradient,
          ),
          child: ListView(
            padding: AppDimensions.screenPadding,
            children: [
              // Header Card
              GlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Judge Panel',
                          style: AppTextStyles.headingMedium.copyWith(
                            color: AppColors.primaryNavy,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const StatusBadge(
                          label: 'JUDGE ROLE',
                          type: BadgeType.info,
                        ),
                      ],
                    ),
                    const SizedBox(height: AppDimensions.space8),
                    Text(
                      'Welcome to the IdeaX Hackathon Live Evaluation Panel. Your session is active.',
                      style: AppTextStyles.bodyMedium,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppDimensions.space20),

              // Foundation Status Card
              GlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Judge Foundation Status',
                      style: AppTextStyles.headingSmall.copyWith(color: AppColors.primaryNavy),
                    ),
                    const SizedBox(height: AppDimensions.space12),
                    _buildStatusRow('Backend API & Security', 'CONNECTED', BadgeType.success),
                    const SizedBox(height: AppDimensions.space8),
                    _buildStatusRow('JWT Authentication', 'ACTIVE', BadgeType.success),
                    const SizedBox(height: AppDimensions.space8),
                    _buildStatusRow('Evaluation Workflow', 'PHASE 3 (Upcoming)', BadgeType.neutral),
                  ],
                ),
              ),
              const SizedBox(height: AppDimensions.space24),

              SecondaryButton(
                text: 'Sign Out of Judge Panel',
                icon: Icons.logout_rounded,
                onPressed: () => context.read<AuthCubit>().logout(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusRow(String title, String status, BadgeType badgeType) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary)),
        StatusBadge(label: status, type: badgeType),
      ],
    );
  }
}

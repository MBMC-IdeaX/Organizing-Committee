import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../app/routes/route_names.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../../../shared/widgets/secondary_button.dart';
import '../../domain/entities/judging_session_entity.dart';
import '../cubit/judge_dashboard_cubit.dart';
import '../cubit/judge_dashboard_state.dart';

class JudgeCompletionScreen extends StatelessWidget {
  final JudgingSessionEntity session;

  const JudgeCompletionScreen({super.key, required this.session});

  @override
  Widget build(BuildContext context) {
    // Trigger dashboard refresh in background
    context.read<JudgeDashboardCubit>().loadDashboard();

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            RouteNames.judgeDashboard,
            (route) => false,
          );
        }
      },
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: AppColors.backgroundMeshGradient,
          ),
          child: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: AppDimensions.screenPadding,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight - (AppDimensions.screenPadding.vertical),
                    ),
                    child: IntrinsicHeight(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Spacer(),

                          // Success Icon with Glow Pill
                          Container(
                            width: 76,
                            height: 76,
                            decoration: BoxDecoration(
                              color: AppColors.success.withValues(alpha: 0.15),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.check_circle_rounded,
                              color: AppColors.success,
                              size: 50,
                            ),
                          ),
                          const SizedBox(height: AppDimensions.space20),

                          Text(
                            'Evaluation Completed!',
                            style: AppTextStyles.headingMedium.copyWith(
                              color: AppColors.primaryNavy,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: AppDimensions.space6),
                          Text(
                            'You have successfully submitted your scores for this project.',
                            textAlign: TextAlign.center,
                            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                          ),
                          const SizedBox(height: AppDimensions.space24),

                          // Summary Glass Card
                          GlassCard(
                            gradient: AppColors.successCardGradient,
                            child: Column(
                              children: [
                                Text(
                                  session.teamName,
                                  style: AppTextStyles.titleMedium.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: AppDimensions.space4),
                                Text(
                                  session.projectName,
                                  style: AppTextStyles.bodySmall.copyWith(color: Colors.white70),
                                ),
                                const SizedBox(height: AppDimensions.space16),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    'Final Score: ${session.totalScore} / ${session.totalMaxScore} Points',
                                    style: AppTextStyles.labelLarge.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const Spacer(),
                          const SizedBox(height: AppDimensions.space24),

                          // Next Project Action
                          BlocBuilder<JudgeDashboardCubit, JudgeDashboardState>(
                            builder: (context, state) {
                              if (state is JudgeDashboardLoaded && state.dashboard.nextTeam != null) {
                                final nextTeam = state.dashboard.nextTeam!;
                                return Column(
                                  children: [
                                    PrimaryButton(
                                      text: 'Next Project (${nextTeam.teamName})',
                                      icon: Icons.arrow_forward_rounded,
                                      height: 44,
                                      onPressed: () {
                                        Navigator.pushNamedAndRemoveUntil(
                                          context,
                                          RouteNames.judgeDashboard,
                                          (route) => false,
                                        );
                                        Navigator.pushNamed(
                                          context,
                                          RouteNames.judgeProjectDetails,
                                          arguments: nextTeam.id,
                                        );
                                      },
                                    ),
                                    const SizedBox(height: AppDimensions.space12),
                                    SecondaryButton(
                                      text: 'View My Dashboard',
                                      height: 42,
                                      onPressed: () {
                                        Navigator.pushNamedAndRemoveUntil(
                                          context,
                                          RouteNames.judgeDashboard,
                                          (route) => false,
                                        );
                                      },
                                    ),
                                  ],
                                );
                              }

                              return PrimaryButton(
                                text: 'Return to Dashboard',
                                icon: Icons.dashboard_rounded,
                                height: 44,
                                onPressed: () {
                                  Navigator.pushNamedAndRemoveUntil(
                                    context,
                                    RouteNames.judgeDashboard,
                                    (route) => false,
                                  );
                                },
                              );
                            },
                          ),
                          const SizedBox(height: AppDimensions.space16),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../app/routes/route_names.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_app_bar.dart';
import '../../../../shared/widgets/error_state.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../../../shared/widgets/loading_indicator.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../../../shared/widgets/status_badge.dart';
import '../cubit/judging_cubit.dart';
import '../cubit/judging_state.dart';

class JudgeProjectDetailsScreen extends StatefulWidget {
  final int teamId;

  const JudgeProjectDetailsScreen({super.key, required this.teamId});

  @override
  State<JudgeProjectDetailsScreen> createState() => _JudgeProjectDetailsScreenState();
}

class _JudgeProjectDetailsScreenState extends State<JudgeProjectDetailsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<JudgingCubit>().loadSession(widget.teamId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppAppBar(
        title: 'Project Overview',
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.backgroundMeshGradient,
        ),
        child: BlocBuilder<JudgingCubit, JudgingState>(
          builder: (context, state) {
            if (state is JudgingLoading) {
              return const LoadingIndicator(message: 'Loading project details...');
            } else if (state is JudgingError) {
              return ErrorState(
                message: state.message,
                onRetry: () => context.read<JudgingCubit>().loadSession(widget.teamId),
              );
            } else if (state is JudgingSessionLoaded) {
              final session = state.session;

              BadgeType badgeType;
              String badgeLabel;
              if (session.isCompleted) {
                badgeType = BadgeType.success;
                badgeLabel = 'COMPLETED';
              } else if (session.isInProgress) {
                badgeType = BadgeType.warning;
                badgeLabel = 'IN PROGRESS';
              } else {
                badgeType = BadgeType.neutral;
                badgeLabel = 'NOT STARTED';
              }

              return ListView(
                padding: AppDimensions.screenPadding,
                children: [
                  // Team Header Card
                  GlassCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            StatusBadge(
                              label: 'QUEUE #${session.displayOrder.toString().padLeft(2, '0')}',
                              type: BadgeType.info,
                            ),
                            StatusBadge(label: badgeLabel, type: badgeType),
                          ],
                        ),
                        const SizedBox(height: AppDimensions.space16),
                        Text(
                          session.teamName,
                          style: AppTextStyles.headingMedium.copyWith(
                            color: AppColors.primaryNavy,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: AppDimensions.space4),
                        Text(
                          session.projectName,
                          style: AppTextStyles.headingSmall.copyWith(
                            color: AppColors.primaryBlue,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppDimensions.space16),

                  // Idea / Pitch Card
                  GlassCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.lightbulb_outline_rounded, color: AppColors.primaryBlue, size: 20),
                            const SizedBox(width: AppDimensions.space8),
                            Text(
                              'Project Idea & Description',
                              style: AppTextStyles.titleMedium.copyWith(
                                color: AppColors.primaryNavy,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppDimensions.space12),
                        Text(
                          session.idea != null && session.idea!.isNotEmpty
                              ? session.idea!
                              : 'No detailed pitch description provided for this team.',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textPrimary,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppDimensions.space16),

                  // Evaluation Summary Card (if completed)
                  if (session.isCompleted) ...[
                    GlassCard(
                      gradient: AppColors.heroCardGradient,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Evaluated Score',
                                style: AppTextStyles.labelLarge.copyWith(color: Colors.white70),
                              ),
                              const SizedBox(height: AppDimensions.space4),
                              Text(
                                '${session.totalScore} / ${session.totalMaxScore} Points',
                                style: AppTextStyles.headingSmall.copyWith(color: Colors.white),
                              ),
                            ],
                          ),
                          const Icon(Icons.check_circle_rounded, color: AppColors.accentCyan, size: 36),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppDimensions.space16),
                  ],

                  // Action Button
                  PrimaryButton(
                    text: session.isCompleted
                        ? 'View Evaluation'
                        : (session.isInProgress ? 'Continue Scoring' : 'Start Scoring'),
                    icon: session.isCompleted ? Icons.visibility_rounded : Icons.edit_note_rounded,
                    onPressed: () {
                      final cubit = context.read<JudgingCubit>();
                      Navigator.pushNamed(
                        context,
                        RouteNames.judgeScoring,
                        arguments: widget.teamId,
                      ).then((_) {
                        cubit.loadSession(widget.teamId);
                      });
                    },
                  ),
                  const SizedBox(height: AppDimensions.space32),
                ],
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}

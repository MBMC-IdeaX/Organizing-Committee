import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_app_bar.dart';
import '../../../../shared/widgets/error_state.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../../../shared/widgets/loading_indicator.dart';
import '../../domain/entities/team_result_entity.dart';
import '../cubit/team_result_cubit.dart';
import '../cubit/team_result_state.dart';

class TeamResultDetailsScreen extends StatefulWidget {
  final int teamId;

  const TeamResultDetailsScreen({
    super.key,
    required this.teamId,
  });

  @override
  State<TeamResultDetailsScreen> createState() => _TeamResultDetailsScreenState();
}

class _TeamResultDetailsScreenState extends State<TeamResultDetailsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<TeamResultCubit>().loadTeamResult(widget.teamId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const AppAppBar(
        title: 'Team Evaluation Details',
      ),
      body: BlocBuilder<TeamResultCubit, TeamResultState>(
        builder: (context, state) {
          if (state is TeamResultLoading) {
            return const LoadingIndicator(message: 'Loading evaluation details...');
          }

          if (state is TeamResultError) {
            return ErrorState(
              message: state.message,
              onRetry: () => context.read<TeamResultCubit>().loadTeamResult(widget.teamId),
            );
          }

          if (state is TeamResultLoaded) {
            return _buildContent(state.teamResult);
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildContent(TeamResultEntity result) {
    return SingleChildScrollView(
      padding: AppDimensions.screenPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Project Overview Header Card
          GlassCard(
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
                            result.teamName,
                            style: AppTextStyles.headingLarge.copyWith(color: AppColors.primaryNavy),
                          ),
                          const SizedBox(height: AppDimensions.space4),
                          Text(
                            'Project: ${result.projectName}',
                            style: AppTextStyles.bodyLarge.copyWith(
                              color: AppColors.primaryBlue,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppDimensions.space12),

                    // Rank Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.softBlue,
                        borderRadius: AppDimensions.borderRadiusMedium,
                        border: Border.all(color: AppColors.primaryBlue.withValues(alpha: 0.3), width: 1),
                      ),
                      child: Column(
                        children: [
                          Text(
                            'RANK',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.primaryBlue,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.0,
                            ),
                          ),
                          const SizedBox(height: 2.0),
                          Text(
                            '#${result.rank}',
                            style: AppTextStyles.headingMedium.copyWith(
                              color: AppColors.primaryNavy,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (result.idea != null && result.idea!.isNotEmpty) ...[
                  const SizedBox(height: AppDimensions.space16),
                  const Divider(color: AppColors.border),
                  const SizedBox(height: AppDimensions.space12),
                  Text(
                    'Idea description',
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryNavy,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.space4),
                  Text(
                    result.idea!,
                    style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: AppDimensions.space24),

          // Standing Metrics Overview
          Text('Aggregate Metrics', style: AppTextStyles.headingSmall.copyWith(color: AppColors.primaryNavy)),
          const SizedBox(height: AppDimensions.space12),
          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  title: 'Final Percentage',
                  value: '${result.percentage.toStringAsFixed(2)}%',
                  color: AppColors.primaryBlue,
                  icon: Icons.percent_rounded,
                ),
              ),
              const SizedBox(width: AppDimensions.space12),
              Expanded(
                child: _buildMetricCard(
                  title: 'Raw Score Total',
                  value: '${result.aggregateTotal} / ${result.aggregateMaxScore}',
                  color: AppColors.accentCyan,
                  icon: Icons.score_rounded,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.space24),

          // Criteria breakdown with horizontal progress bars
          Text('Criterion Standings (Average)', style: AppTextStyles.headingSmall.copyWith(color: AppColors.primaryNavy)),
          const SizedBox(height: AppDimensions.space12),
          GlassCard(
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: result.criterionBreakdowns.length,
              separatorBuilder: (context, index) => const SizedBox(height: AppDimensions.space16),
              itemBuilder: (context, index) {
                final crit = result.criterionBreakdowns[index];
                final progressVal = crit.maxScore > 0 ? (crit.averageScore / crit.maxScore) : 0.0;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            crit.criteriaName,
                            style: AppTextStyles.bodyLarge.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppColors.primaryNavy,
                            ),
                          ),
                        ),
                        Text(
                          '${crit.averageScore.toStringAsFixed(2)} / ${crit.maxScore}',
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontFamily: 'monospace',
                            fontWeight: FontWeight.w700,
                            color: AppColors.primaryBlue,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppDimensions.space8),
                    ClipRRect(
                      borderRadius: AppDimensions.borderRadiusSmall,
                      child: LinearProgressIndicator(
                        value: progressVal,
                        minHeight: 8,
                        backgroundColor: AppColors.softBlue,
                        valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryBlue),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: AppDimensions.space24),

          // Audited individual Judge Scorecards
          Text('Evaluator Ballots', style: AppTextStyles.headingSmall.copyWith(color: AppColors.primaryNavy)),
          const SizedBox(height: AppDimensions.space12),
          if (result.judgeBreakdowns.isEmpty)
            GlassCard(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Text(
                    'No completed evaluations recorded yet.',
                    style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                  ),
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: result.judgeBreakdowns.length,
              separatorBuilder: (context, index) => const SizedBox(height: AppDimensions.space16),
              itemBuilder: (context, index) {
                final breakdown = result.judgeBreakdowns[index];
                return GlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Judge Username and Total Score
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.gavel_rounded, color: AppColors.primaryNavy, size: 20),
                              const SizedBox(width: AppDimensions.space8),
                              Text(
                                breakdown.judgeUsername,
                                style: AppTextStyles.bodyLarge.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primaryNavy,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.softBlue,
                              borderRadius: AppDimensions.borderRadiusSmall,
                            ),
                            child: Text(
                              'Score: ${breakdown.totalScore} / ${breakdown.maxScore}',
                              style: AppTextStyles.bodyMedium.copyWith(
                                fontWeight: FontWeight.w700,
                                color: AppColors.primaryBlue,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppDimensions.space16),
                      const Divider(color: AppColors.border),
                      const SizedBox(height: AppDimensions.space12),

                      // Criterion Scores Breakdown
                      Text(
                        'Scores per Criterion',
                        style: AppTextStyles.bodySmall.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: AppDimensions.space8),
                      ...breakdown.criterionScores.entries.map((entry) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                entry.key,
                                style: AppTextStyles.bodyMedium,
                              ),
                              Text(
                                entry.value.toString(),
                                style: AppTextStyles.bodyMedium.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.primaryNavy,
                                ),
                              ),
                            ],
                          ),
                        );
                      }),

                      // Optional comments
                      if (breakdown.comment != null && breakdown.comment!.trim().isNotEmpty) ...[
                        const SizedBox(height: AppDimensions.space12),
                        const Divider(color: AppColors.border),
                        const SizedBox(height: AppDimensions.space12),
                        Text(
                          'Evaluator comment',
                          style: AppTextStyles.bodySmall.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: AppDimensions.space4),
                        Text(
                          breakdown.comment!,
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontStyle: FontStyle.italic,
                            color: AppColors.primaryNavy,
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
          const SizedBox(height: AppDimensions.space24),
        ],
      ),
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required Color color,
    required IconData icon,
  }) {
    return GlassCard(
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: AppDimensions.borderRadiusSmall,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: AppDimensions.space12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: AppTextStyles.headingSmall.copyWith(
                    color: AppColors.primaryNavy,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2.0),
                Text(
                  title,
                  style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

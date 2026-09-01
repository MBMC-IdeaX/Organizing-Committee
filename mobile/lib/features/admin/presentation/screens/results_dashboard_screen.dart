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
import '../../domain/entities/ranking_result_entity.dart';
import '../../domain/entities/results_summary_entity.dart';
import '../cubit/results_dashboard_cubit.dart';
import '../cubit/results_dashboard_state.dart';

class ResultsDashboardScreen extends StatefulWidget {
  const ResultsDashboardScreen({super.key});

  @override
  State<ResultsDashboardScreen> createState() => _ResultsDashboardScreenState();
}

class _ResultsDashboardScreenState extends State<ResultsDashboardScreen> {
  @override
  void initState() {
    super.initState();
    context.read<ResultsDashboardCubit>().loadResultsDashboard();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const AppAppBar(
        title: 'Results & Rankings',
      ),
      body: BlocBuilder<ResultsDashboardCubit, ResultsDashboardState>(
        builder: (context, state) {
          if (state is ResultsDashboardLoading) {
            return const LoadingIndicator(message: 'Calculating scores and standings...');
          }

          if (state is ResultsDashboardError) {
            return ErrorState(
              message: state.message,
              onRetry: () => context.read<ResultsDashboardCubit>().loadResultsDashboard(),
            );
          }

          if (state is ResultsDashboardNotReady) {
            return _buildIncompleteState(state.summary);
          }

          if (state is ResultsDashboardLoaded) {
            return _buildCompleteState(state.summary, state.ranking);
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildIncompleteState(ResultsSummaryEntity summary) {
    final remaining = summary.remainingEvaluations;
    final progress = summary.totalRequiredEvaluations > 0
        ? summary.completedEvaluations / summary.totalRequiredEvaluations
        : 0.0;

    return RefreshIndicator(
      onRefresh: () => context.read<ResultsDashboardCubit>().loadResultsDashboard(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: AppDimensions.screenPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Header Card
            GlassCard(
              gradient: const LinearGradient(
                colors: [Color(0xFFFFFBEB), Color(0xFFFEF3C7)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.pending_actions_rounded, color: AppColors.warning, size: 28),
                      const SizedBox(width: AppDimensions.space12),
                      Expanded(
                        child: Text(
                          'Results are not ready yet',
                          style: AppTextStyles.headingSmall.copyWith(
                            color: const Color(0xFF78350F),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppDimensions.space16),
                  Text(
                    'All judge evaluations must be completed before final rankings can be generated.',
                    style: AppTextStyles.bodyMedium.copyWith(color: const Color(0xFF92400E)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppDimensions.space24),

            // Progress Indicators
            Text('Evaluation Progress', style: AppTextStyles.headingSmall.copyWith(color: AppColors.primaryNavy)),
            const SizedBox(height: AppDimensions.space12),
            GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Completed Status',
                        style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w600),
                      ),
                      Text(
                        '${summary.completedEvaluations} / ${summary.totalRequiredEvaluations} (${summary.judgingCompletionPercentage.toStringAsFixed(1)}%)',
                        style: AppTextStyles.bodyLarge.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryBlue,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppDimensions.space16),
                  ClipRRect(
                    borderRadius: AppDimensions.borderRadiusSmall,
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 12,
                      backgroundColor: AppColors.softBlue,
                      valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryBlue),
                    ),
                  ),
                  const SizedBox(height: AppDimensions.space16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildSimpleStat(
                          title: 'Active Teams',
                          value: summary.activeTeams.toString(),
                        ),
                      ),
                      Container(width: 1, height: 40, color: AppColors.border),
                      Expanded(
                        child: _buildSimpleStat(
                          title: 'Active Judges',
                          value: summary.activeJudges.toString(),
                        ),
                      ),
                      Container(width: 1, height: 40, color: AppColors.border),
                      Expanded(
                        child: _buildSimpleStat(
                          title: 'Missing Ballots',
                          value: remaining.toString(),
                          valueColor: AppColors.error,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppDimensions.space24),

            // Pull to refresh call-to-action
            Center(
              child: Column(
                children: [
                  const Icon(Icons.sync_rounded, color: AppColors.textSecondary, size: 24),
                  const SizedBox(height: AppDimensions.space8),
                  Text(
                    'Pull down to refresh standing sheets',
                    style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: AppDimensions.space16),
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      side: const BorderSide(color: AppColors.primaryBlue),
                      shape: RoundedRectangleBorder(borderRadius: AppDimensions.borderRadiusSmall),
                    ),
                    onPressed: () => context.read<ResultsDashboardCubit>().loadResultsDashboard(),
                    icon: const Icon(Icons.refresh_rounded, color: AppColors.primaryBlue),
                    label: Text(
                      'Refresh Now',
                      style: AppTextStyles.buttonSecondary.copyWith(color: AppColors.primaryBlue),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSimpleStat({required String title, required String value, Color? valueColor}) {
    return Column(
      children: [
        Text(
          value,
          style: AppTextStyles.headingMedium.copyWith(
            color: valueColor ?? AppColors.primaryNavy,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: AppDimensions.space4),
        Text(
          title,
          style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
        ),
      ],
    );
  }

  Widget _buildCompleteState(ResultsSummaryEntity summary, List<RankingResultEntity> ranking) {
    // Extract podium details safely
    RankingResultEntity? gold = ranking.isNotEmpty ? ranking.firstWhere((r) => r.rank == 1, orElse: () => ranking[0]) : null;
    RankingResultEntity? silver = ranking.length > 1 ? ranking.firstWhere((r) => r.rank == 2, orElse: () => ranking[1]) : null;
    RankingResultEntity? bronze = ranking.length > 2 ? ranking.firstWhere((r) => r.rank == 3, orElse: () => ranking[2]) : null;

    // Handle exact ties on podium or edge-cases
    if (gold != null && silver != null && gold.teamId == silver.teamId) {
      // In case first and second have rank 1 due to tie, we re-evaluate
      final sortedRanks = List<RankingResultEntity>.from(ranking);
      gold = sortedRanks[0];
      silver = sortedRanks.length > 1 ? sortedRanks[1] : null;
      bronze = sortedRanks.length > 2 ? sortedRanks[2] : null;
    }

    return RefreshIndicator(
      onRefresh: () => context.read<ResultsDashboardCubit>().loadResultsDashboard(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: AppDimensions.screenPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Complete Header
            GlassCard(
              gradient: const LinearGradient(
                colors: [Color(0xFFECFDF5), Color(0xFFD1FAE5)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 28),
                  const SizedBox(width: AppDimensions.space12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'JUDGING COMPLETE',
                          style: AppTextStyles.headingSmall.copyWith(
                            color: const Color(0xFF065F46),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2.0),
                        Text(
                          'Final aggregate rankings computed across all active judges.',
                          style: AppTextStyles.bodySmall.copyWith(color: const Color(0xFF047857)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppDimensions.space24),

            // Podium Standing Visualizer
            if (ranking.isNotEmpty) ...[
              Text('Podium Standings', style: AppTextStyles.headingSmall.copyWith(color: AppColors.primaryNavy)),
              const SizedBox(height: AppDimensions.space16),
              _buildPodium(gold: gold, silver: silver, bronze: bronze),
              const SizedBox(height: 28.0),
            ],

            // Overall Leaderboard Standings List
            Text('Overall Standings', style: AppTextStyles.headingSmall.copyWith(color: AppColors.primaryNavy)),
            const SizedBox(height: AppDimensions.space12),
            GlassCard(
              padding: EdgeInsets.zero,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Table Header
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: const BoxDecoration(
                      color: Color(0x08000000),
                      border: Border(bottom: BorderSide(color: AppColors.border)),
                    ),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 44,
                          child: Text('Rank', style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.w700)),
                        ),
                        Expanded(
                          child: Text('Team / Project', style: AppTextStyles.bodySmall),
                        ),
                        SizedBox(
                          width: 60,
                          child: Text('Score', style: AppTextStyles.bodySmall, textAlign: TextAlign.right),
                        ),
                        SizedBox(
                          width: 70,
                          child: Text('Percent', style: AppTextStyles.bodySmall, textAlign: TextAlign.right),
                        ),
                      ],
                    ),
                  ),

                  // Table Rows
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: ranking.length,
                    separatorBuilder: (context, index) => const Divider(height: 1, color: AppColors.border),
                    itemBuilder: (context, index) {
                      final row = ranking[index];
                      return InkWell(
                        onTap: () => Navigator.pushNamed(
                          context,
                          RouteNames.adminResultsTeamDetails,
                          arguments: row.teamId,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 44,
                                child: Text(
                                  row.rank.toString(),
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    fontWeight: FontWeight.w800,
                                    color: _getRankColor(row.rank),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      row.teamName,
                                      style: AppTextStyles.bodyMedium.copyWith(
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.primaryNavy,
                                      ),
                                    ),
                                    const SizedBox(height: 2.0),
                                    Text(
                                      row.projectName,
                                      style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                width: 60,
                                child: Text(
                                  '${row.aggregateTotal}/${row.aggregateMaxScore}',
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    fontFamily: 'monospace',
                                    color: AppColors.primaryNavy,
                                  ),
                                  textAlign: TextAlign.right,
                                ),
                              ),
                              SizedBox(
                                width: 70,
                                child: Text(
                                  '${row.percentage.toStringAsFixed(2)}%',
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.primaryBlue,
                                  ),
                                  textAlign: TextAlign.right,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppDimensions.space24),
          ],
        ),
      ),
    );
  }

  Color _getRankColor(int rank) {
    switch (rank) {
      case 1:
        return const Color(0xFFD97706); // Gold
      case 2:
        return const Color(0xFF4B5563); // Silver
      case 3:
        return const Color(0xFF92400E); // Bronze
      default:
        return AppColors.textSecondary;
    }
  }

  Widget _buildPodium({
    RankingResultEntity? gold,
    RankingResultEntity? silver,
    RankingResultEntity? bronze,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final podiumWidth = constraints.maxWidth;
        final colWidth = (podiumWidth - 32) / 3;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 2nd Place: Silver
            if (silver != null) ...[
              _buildPodiumColumn(
                entity: silver,
                medal: '🥈',
                label: '2nd Place',
                height: 140,
                width: colWidth,
                color: const Color(0xFFF3F4F6),
                borderColor: const Color(0xFFD1D5DB),
              ),
              const SizedBox(width: 12),
            ] else
              SizedBox(width: colWidth),

            // 1st Place: Gold
            if (gold != null) ...[
              _buildPodiumColumn(
                entity: gold,
                medal: '🥇',
                label: 'Champion',
                height: 180,
                width: colWidth,
                color: const Color(0xFFFEF3C7),
                borderColor: const Color(0xFFFBBF24),
                isChampion: true,
              ),
              const SizedBox(width: 12),
            ] else
              SizedBox(width: colWidth),

            // 3rd Place: Bronze
            if (bronze != null) ...[
              _buildPodiumColumn(
                entity: bronze,
                medal: '🥉',
                label: '3rd Place',
                height: 110,
                width: colWidth,
                color: const Color(0xFFFFF7ED),
                borderColor: const Color(0xFFFDBA74),
              ),
            ] else
              SizedBox(width: colWidth),
          ],
        );
      },
    );
  }

  Widget _buildPodiumColumn({
    required RankingResultEntity entity,
    required String medal,
    required String label,
    required double height,
    required double width,
    required Color color,
    required Color borderColor,
    bool isChampion = false,
  }) {
    return SizedBox(
      width: width,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Medal Badge
          Text(
            medal,
            style: TextStyle(fontSize: isChampion ? 38 : 30),
          ),
          const SizedBox(height: 2.0),
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4.0),

          // Podium pedestal
          GestureDetector(
            onTap: () => Navigator.pushNamed(
              context,
              RouteNames.adminResultsTeamDetails,
              arguments: entity.teamId,
            ),
            child: Container(
              height: height,
              width: width,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.85),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(AppDimensions.radiusMedium),
                  topRight: Radius.circular(AppDimensions.radiusMedium),
                ),
                border: Border.all(color: borderColor, width: 2),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x0D000000),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  )
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    entity.teamName,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AppColors.primaryNavy,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppDimensions.space4),
                  Text(
                    entity.projectName,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.7),
                      borderRadius: AppDimensions.borderRadiusSmall,
                    ),
                    child: Text(
                      '${entity.percentage.toStringAsFixed(1)}%',
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w800,
                        color: AppColors.primaryBlue,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

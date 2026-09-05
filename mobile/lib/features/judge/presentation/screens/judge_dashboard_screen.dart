import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../app/routes/route_names.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_app_bar.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/error_state.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../../../shared/widgets/glass_search_field.dart';
import '../../../../shared/widgets/loading_indicator.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../../../shared/widgets/status_badge.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';
import '../../domain/entities/judge_team_entity.dart';
import '../cubit/judge_dashboard_cubit.dart';
import '../cubit/judge_dashboard_state.dart';

enum JudgeQueueFilter { all, notStarted, inProgress, completed }

class JudgeDashboardScreen extends StatefulWidget {
  const JudgeDashboardScreen({super.key});

  @override
  State<JudgeDashboardScreen> createState() => _JudgeDashboardScreenState();
}

class _JudgeDashboardScreenState extends State<JudgeDashboardScreen> {
  String _searchQuery = '';
  JudgeQueueFilter _selectedFilter = JudgeQueueFilter.all;

  @override
  void initState() {
    super.initState();
    context.read<JudgeDashboardCubit>().loadDashboard();
  }

  void _confirmLogout() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: AppDimensions.borderRadiusLarge),
        backgroundColor: AppColors.surface,
        title: Text(
          'Sign Out?',
          style: AppTextStyles.headingLarge.copyWith(color: AppColors.primaryNavy),
        ),
        content: Text(
          'Are you sure you want to log out of the Judge Console?',
          style: AppTextStyles.bodyMedium,
        ),
        actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 18),
        actions: [
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: AppColors.textSecondary,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            ),
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              elevation: 0,
              minimumSize: const Size(0, 38),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: AppDimensions.borderRadiusSmall,
              ),
            ),
            onPressed: () {
              Navigator.of(ctx).pop();
              context.read<AuthCubit>().logout();
            },
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }

  List<JudgeTeamEntity> _filterTeams(List<JudgeTeamEntity> teams) {
    return teams.where((team) {
      if (_selectedFilter == JudgeQueueFilter.notStarted && (team.isInProgress || team.isCompleted)) return false;
      if (_selectedFilter == JudgeQueueFilter.inProgress && !team.isInProgress) return false;
      if (_selectedFilter == JudgeQueueFilter.completed && !team.isCompleted) return false;

      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        final matchName = team.teamName.toLowerCase().contains(q);
        final matchProject = team.projectName.toLowerCase().contains(q);
        final matchIdea = team.idea?.toLowerCase().contains(q) ?? false;
        return matchName || matchProject || matchIdea;
      }
      return true;
    }).toList();
  }

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
              icon: const Icon(Icons.refresh_rounded, color: AppColors.primaryNavy),
              tooltip: 'Refresh',
              onPressed: () => context.read<JudgeDashboardCubit>().loadDashboard(),
            ),
            IconButton(
              icon: const Icon(Icons.logout_rounded, color: AppColors.error),
              tooltip: 'Logout',
              onPressed: _confirmLogout,
            ),
          ],
        ),
        body: Container(
          decoration: const BoxDecoration(
            gradient: AppColors.backgroundMeshGradient,
          ),
          child: BlocBuilder<JudgeDashboardCubit, JudgeDashboardState>(
            builder: (context, state) {
              if (state is JudgeDashboardLoading) {
                return const LoadingIndicator(message: 'Loading your judging dashboard...');
              } else if (state is JudgeDashboardError) {
                return ErrorState(
                  message: state.message,
                  onRetry: () => context.read<JudgeDashboardCubit>().loadDashboard(),
                );
              } else if (state is JudgeDashboardLoaded) {
                final dashboard = state.dashboard;
                final allTeams = state.teams;
                final filteredTeams = _filterTeams(allTeams);

                if (allTeams.isEmpty) {
                  return EmptyState(
                    title: 'No Active Projects',
                    message: 'There are currently no active teams configured for judging.',
                    actionText: 'Refresh',
                    onAction: () => context.read<JudgeDashboardCubit>().loadDashboard(),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () => context.read<JudgeDashboardCubit>().loadDashboard(),
                  color: AppColors.primaryBlue,
                  child: ListView(
                    padding: AppDimensions.screenPadding,
                    children: [
                      // Header Card
                      _buildHeaderCard(),
                      const SizedBox(height: AppDimensions.space16),

                      // Progress Card
                      _buildProgressCard(dashboard.completedTeams, dashboard.totalTeams, dashboard.progressPercentage),
                      const SizedBox(height: AppDimensions.space16),

                      // Next Recommended Project Card
                      if (dashboard.nextTeam != null)
                        _buildNextProjectCard(dashboard.nextTeam!, dashboard.totalTeams)
                      else
                        _buildAllCompletedCard(),
                      const SizedBox(height: AppDimensions.space20),

                      // Section Title: Projects Queue
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Evaluation Queue',
                            style: AppTextStyles.headingSmall.copyWith(color: AppColors.primaryNavy),
                          ),
                          Text(
                            '${allTeams.length} Projects',
                            style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppDimensions.space12),

                      // 200+ Team Scalability: Search & Filter
                      GlassSearchField(
                        hintText: 'Search projects or teams...',
                        onChanged: (val) {
                          setState(() {
                            _searchQuery = val.trim();
                          });
                        },
                      ),
                      const SizedBox(height: AppDimensions.space10),

                      // Filter chips
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _buildFilterChip('All (${allTeams.length})', JudgeQueueFilter.all),
                            const SizedBox(width: AppDimensions.space8),
                            _buildFilterChip('Not Started (${allTeams.where((t) => !t.isInProgress && !t.isCompleted).length})', JudgeQueueFilter.notStarted),
                            const SizedBox(width: AppDimensions.space8),
                            _buildFilterChip('In Progress (${allTeams.where((t) => t.isInProgress).length})', JudgeQueueFilter.inProgress),
                            const SizedBox(width: AppDimensions.space8),
                            _buildFilterChip('Completed (${allTeams.where((t) => t.isCompleted).length})', JudgeQueueFilter.completed),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppDimensions.space14),

                      // Teams List
                      if (filteredTeams.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 24.0),
                          child: Center(
                            child: Text(
                              'No projects match "$_searchQuery"',
                              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                            ),
                          ),
                        )
                      else
                        ...filteredTeams.map((team) => _buildTeamCard(team)),
                      const SizedBox(height: AppDimensions.space32),
                    ],
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, JudgeQueueFilter filter) {
    final isSelected = _selectedFilter == filter;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) {
        setState(() {
          _selectedFilter = filter;
        });
      },
      selectedColor: AppColors.primaryBlue,
      backgroundColor: AppColors.glassSurface,
      labelStyle: AppTextStyles.bodySmall.copyWith(
        color: isSelected ? Colors.white : AppColors.primaryNavy,
        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
      ),
      side: BorderSide(
        color: isSelected ? AppColors.primaryBlue : AppColors.borderLight,
      ),
      shape: RoundedRectangleBorder(borderRadius: AppDimensions.borderRadiusSmall),
    );
  }

  Widget _buildHeaderCard() {
    return GlassCard(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'IdeaX Live Evaluation',
                  style: AppTextStyles.headingMedium.copyWith(
                    color: AppColors.primaryNavy,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppDimensions.space2),
                Text(
                  'Judge Evaluation Console',
                  style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppDimensions.space8),
          const StatusBadge(
            label: 'JUDGE',
            type: BadgeType.info,
          ),
        ],
      ),
    );
  }

  Widget _buildProgressCard(int completed, int total, double percentage) {
    return GlassCard(
      gradient: AppColors.heroCardGradient,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Your Progress',
                style: AppTextStyles.labelLarge.copyWith(color: Colors.white70),
              ),
              Text(
                '${percentage.toStringAsFixed(0)}%',
                style: AppTextStyles.headingMedium.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.space6),
          Text(
            '$completed / $total Projects Completed',
            style: AppTextStyles.headingSmall.copyWith(color: Colors.white),
          ),
          const SizedBox(height: AppDimensions.space10),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: total > 0 ? completed / total : 0,
              backgroundColor: Colors.white.withValues(alpha: 0.2),
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.accentCyan),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNextProjectCard(JudgeTeamEntity nextTeam, int totalTeams) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.play_circle_fill_rounded, color: AppColors.primaryBlue, size: 20),
                  const SizedBox(width: AppDimensions.space6),
                  Text(
                    'Next Project',
                    style: AppTextStyles.labelLarge.copyWith(color: AppColors.primaryBlue, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
              StatusBadge(
                label: 'Order #${nextTeam.displayOrder.toString().padLeft(2, '0')}',
                type: BadgeType.info,
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.space10),
          Text(
            nextTeam.teamName,
            style: AppTextStyles.headingSmall.copyWith(color: AppColors.primaryNavy),
          ),
          const SizedBox(height: AppDimensions.space2),
          Text(
            nextTeam.projectName,
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.primaryBlue, fontWeight: FontWeight.w600),
          ),
          if (nextTeam.idea != null && nextTeam.idea!.isNotEmpty) ...[
            const SizedBox(height: AppDimensions.space6),
            Text(
              nextTeam.idea!,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
            ),
          ],
          const SizedBox(height: AppDimensions.space14),
          PrimaryButton(
            text: nextTeam.isInProgress ? 'Continue Scoring' : 'Start Next Project',
            icon: Icons.arrow_forward_rounded,
            height: 42,
            onPressed: () => _openProjectDetails(nextTeam.id),
          ),
        ],
      ),
    );
  }

  Widget _buildAllCompletedCard() {
    return GlassCard(
      child: Column(
        children: [
          const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 44),
          const SizedBox(height: AppDimensions.space10),
          Text(
            'All Projects Completed!',
            style: AppTextStyles.headingSmall.copyWith(color: AppColors.success),
          ),
          const SizedBox(height: AppDimensions.space6),
          Text(
            'You have evaluated all active teams. Thank you for your contributions!',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildTeamCard(JudgeTeamEntity team) {
    BadgeType badgeType;
    String badgeLabel;

    if (team.isCompleted) {
      badgeType = BadgeType.success;
      badgeLabel = 'Completed ✓';
    } else if (team.isInProgress) {
      badgeType = BadgeType.warning;
      badgeLabel = 'In Progress';
    } else {
      badgeType = BadgeType.neutral;
      badgeLabel = 'Not Started';
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.space10),
      child: GlassCard(
        onTap: () => _openProjectDetails(team.id),
        padding: const EdgeInsets.all(AppDimensions.space14),
        child: Row(
          children: [
            // Order Bubble
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: team.isCompleted ? AppColors.success.withValues(alpha: 0.15) : AppColors.softBlue,
                borderRadius: BorderRadius.circular(10),
              ),
              alignment: Alignment.center,
              child: Text(
                team.displayOrder.toString().padLeft(2, '0'),
                style: AppTextStyles.labelLarge.copyWith(
                  color: team.isCompleted ? AppColors.success : AppColors.primaryNavy,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: AppDimensions.space12),

            // Team & Project Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    team.teamName,
                    style: AppTextStyles.titleMedium.copyWith(
                      color: AppColors.primaryNavy,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    team.projectName,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.primaryBlue,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            // Status Badge & Score
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                StatusBadge(label: badgeLabel, type: badgeType),
                if (team.isCompleted) ...[
                  const SizedBox(height: AppDimensions.space4),
                  Text(
                    '${team.totalScore} / ${team.totalMaxScore} pts',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _openProjectDetails(int teamId) {
    Navigator.pushNamed(
      context,
      RouteNames.judgeProjectDetails,
      arguments: teamId,
    ).then((_) {
      if (mounted) {
        context.read<JudgeDashboardCubit>().loadDashboard();
      }
    });
  }
}

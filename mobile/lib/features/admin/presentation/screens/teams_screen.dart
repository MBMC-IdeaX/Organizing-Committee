import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../shared/widgets/app_app_bar.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/error_state.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../../../shared/widgets/loading_indicator.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../../../shared/widgets/status_badge.dart';
import '../../domain/entities/team_entity.dart';
import '../cubit/admin_dashboard_cubit.dart';
import '../cubit/teams_cubit.dart';
import '../cubit/teams_state.dart';
import '../widgets/add_edit_team_dialog.dart';

class TeamsScreen extends StatefulWidget {
  const TeamsScreen({super.key});

  @override
  State<TeamsScreen> createState() => _TeamsScreenState();
}

class _TeamsScreenState extends State<TeamsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<TeamsCubit>().loadTeams();
  }

  void _openAddTeamDialog() {
    showDialog(
      context: context,
      builder: (_) => AddEditTeamDialog(
        onSave: ({required teamName, required projectName, idea, required displayOrder}) {
          return context.read<TeamsCubit>().createTeam(
                teamName: teamName,
                projectName: projectName,
                idea: idea,
                displayOrder: displayOrder,
              );
        },
      ),
    );
  }

  void _openEditTeamDialog(TeamEntity team) {
    showDialog(
      context: context,
      builder: (_) => AddEditTeamDialog(
        team: team,
        onSave: ({required teamName, required projectName, idea, required displayOrder}) {
          return context.read<TeamsCubit>().updateTeam(
                id: team.id,
                teamName: teamName,
                projectName: projectName,
                idea: idea,
                displayOrder: displayOrder,
              );
        },
      ),
    );
  }

  void _confirmToggleStatus(TeamEntity team) {
    final newStatus = !team.active;
    if (!newStatus) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: AppDimensions.borderRadiusLarge),
          title: Text(
            'Deactivate Team?',
            style: AppTextStyles.headingLarge.copyWith(color: AppColors.primaryNavy),
          ),
          content: Text(
            'Deactivating "${team.teamName}" will exclude them from the active judging session. Historical evaluations are preserved.',
            style: AppTextStyles.bodyMedium,
          ),
          actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
          actions: [
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: AppColors.textSecondary,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.warning,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: AppDimensions.borderRadiusSmall,
                ),
              ),
              onPressed: () {
                Navigator.of(ctx).pop();
                context.read<TeamsCubit>().toggleTeamStatus(team.id, false);
              },
              child: const Text('Deactivate'),
            ),
          ],
        ),
      );
    } else {
      context.read<TeamsCubit>().toggleTeamStatus(team.id, true);
    }
  }

  void _confirmDeleteTeam(TeamEntity team) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: AppDimensions.borderRadiusLarge),
        title: Text(
          'Delete Team?',
          style: AppTextStyles.headingLarge.copyWith(color: AppColors.primaryNavy),
        ),
        content: Text(
          'Are you sure you want to permanently delete ${team.teamName}?\n\nThis action cannot be undone.',
          style: AppTextStyles.bodyMedium,
        ),
        actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
        actions: [
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: AppColors.textSecondary,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: AppDimensions.borderRadiusSmall,
              ),
            ),
            onPressed: () async {
              Navigator.of(ctx).pop();
              try {
                final success = await context.read<TeamsCubit>().deleteTeam(team.id);
                if (success && mounted) {
                  context.read<AdminDashboardCubit>().loadDashboardSummary();
                }
              } on ConflictException catch (_) {
                if (!mounted) return;
                _showCannotDeleteDialog(team);
              } catch (e) {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(e.toString().replaceAll('Exception: ', '')),
                    backgroundColor: AppColors.error,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showCannotDeleteDialog(TeamEntity team) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: AppDimensions.borderRadiusLarge),
        title: Text(
          'Cannot Delete Team',
          style: AppTextStyles.headingLarge.copyWith(color: AppColors.primaryNavy),
        ),
        content: Text(
          'Judging records already exist for "${team.teamName}". You can deactivate the team to preserve evaluation history, or force delete to erase all its judging sessions.',
          style: AppTextStyles.bodyMedium,
        ),
        actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
        actions: [
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: AppColors.textSecondary,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            ),
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          if (team.active)
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.warning,
                side: const BorderSide(color: AppColors.warning),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: AppDimensions.borderRadiusSmall),
              ),
              onPressed: () {
                Navigator.of(ctx).pop();
                context.read<TeamsCubit>().toggleTeamStatus(team.id, false);
              },
              child: const Text('Deactivate'),
            ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: AppDimensions.borderRadiusSmall,
              ),
            ),
            onPressed: () async {
              Navigator.of(ctx).pop();
              try {
                final success = await context.read<TeamsCubit>().deleteTeam(team.id, force: true);
                if (success && mounted) {
                  context.read<AdminDashboardCubit>().loadDashboardSummary();
                }
              } catch (e) {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(e.toString().replaceAll('Exception: ', '')),
                    backgroundColor: AppColors.error,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            child: const Text('Force Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const AppAppBar(
        title: 'Manage Teams',
      ),
      body: BlocConsumer<TeamsCubit, TeamsState>(
        listener: (context, state) {
          if (state is TeamsLoaded && state.actionSuccessMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.actionSuccessMessage!),
                backgroundColor: AppColors.success,
                behavior: SnackBarBehavior.floating,
              ),
            );
          } else if (state is TeamsError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is TeamsLoading) {
            return const LoadingIndicator(message: 'Loading teams...');
          }

          if (state is TeamsError && state.message.isNotEmpty) {
            return ErrorState(
              message: state.message,
              onRetry: () => context.read<TeamsCubit>().loadTeams(),
            );
          }

          if (state is TeamsLoaded) {
            final teams = state.teams;

            return RefreshIndicator(
              onRefresh: () => context.read<TeamsCubit>().loadTeams(),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: AppDimensions.screenPadding,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Participating Teams',
                                style: AppTextStyles.headingSmall.copyWith(color: AppColors.primaryNavy),
                              ),
                              const SizedBox(height: AppDimensions.space4),
                              Text(
                                '${teams.length} total (${teams.where((t) => t.active).length} active)',
                                style: AppTextStyles.bodySmall,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: AppDimensions.space12),
                        PrimaryButton(
                          text: 'Add Team',
                          icon: Icons.add,
                          width: 160,
                          height: 42,
                          onPressed: _openAddTeamDialog,
                        ),
                      ],
                    ),
                    const SizedBox(height: AppDimensions.space16),

                    if (teams.isEmpty)
                      EmptyState(
                        title: 'No teams added yet',
                        message: 'Add hackathon teams to establish the judging queue.',
                        icon: Icons.groups_outlined,
                        actionText: 'Add First Team',
                        onAction: _openAddTeamDialog,
                      )
                    else
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: teams.length,
                        separatorBuilder: (_, __) => const SizedBox(height: AppDimensions.space12),
                        itemBuilder: (context, index) {
                          final team = teams[index];
                          final orderDisplay = (index + 1).toString().padLeft(2, '0');

                          return GlassCard(
                            padding: const EdgeInsets.all(AppDimensions.space16),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Order Badge Bubble
                                Container(
                                  width: 36,
                                  height: 36,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: team.active ? AppColors.softBlue : AppColors.border,
                                    borderRadius: AppDimensions.borderRadiusSmall,
                                  ),
                                  child: Text(
                                    orderDisplay,
                                    style: AppTextStyles.bodyMedium.copyWith(
                                      color: team.active ? AppColors.primaryBlue : AppColors.textMuted,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: AppDimensions.space12),

                                // Team Information
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              team.teamName,
                                              style: AppTextStyles.bodyLarge.copyWith(
                                                color: team.active ? AppColors.primaryNavy : AppColors.textMuted,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                          ),
                                          StatusBadge(
                                            label: team.active ? 'ACTIVE' : 'INACTIVE',
                                            type: team.active ? BadgeType.success : BadgeType.neutral,
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: AppDimensions.space4),
                                      Text(
                                        team.projectName,
                                        style: AppTextStyles.bodyMedium.copyWith(
                                          color: AppColors.primaryBlue,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      if (team.idea != null && team.idea!.isNotEmpty) ...[
                                        const SizedBox(height: AppDimensions.space4),
                                        Text(
                                          team.idea!,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                                        ),
                                      ],
                                      const SizedBox(height: AppDimensions.space12),

                                      // Actions Row: Move Up/Down, Edit, Status
                                      Row(
                                        children: [
                                          // Reorder Controls
                                          IconButton(
                                            icon: const Icon(Icons.arrow_upward_rounded, size: 18),
                                            color: index > 0 ? AppColors.primaryNavy : AppColors.border,
                                            tooltip: 'Move Up',
                                            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                                            padding: EdgeInsets.zero,
                                            onPressed: index > 0 ? () => context.read<TeamsCubit>().moveTeamUp(index) : null,
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.arrow_downward_rounded, size: 18),
                                            color: index < teams.length - 1 ? AppColors.primaryNavy : AppColors.border,
                                            tooltip: 'Move Down',
                                            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                                            padding: EdgeInsets.zero,
                                            onPressed: index < teams.length - 1 ? () => context.read<TeamsCubit>().moveTeamDown(index) : null,
                                          ),
                                          const Spacer(),

                                          // Edit
                                          TextButton.icon(
                                            icon: const Icon(Icons.edit_outlined, size: 16),
                                            label: const Text('Edit'),
                                            style: TextButton.styleFrom(
                                              foregroundColor: AppColors.primaryNavy,
                                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                            ),
                                            onPressed: () => _openEditTeamDialog(team),
                                          ),

                                          // Toggle Status
                                          TextButton(
                                            style: TextButton.styleFrom(
                                              foregroundColor: team.active ? AppColors.warning : AppColors.success,
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                            ),
                                            onPressed: () => _confirmToggleStatus(team),
                                            child: Text(team.active ? 'Deactivate' : 'Activate'),
                                          ),

                                          // Delete
                                          TextButton.icon(
                                            icon: const Icon(Icons.delete_outline_rounded, size: 16),
                                            label: const Text('Delete'),
                                            style: TextButton.styleFrom(
                                              foregroundColor: AppColors.error,
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                            ),
                                            onPressed: () => _confirmDeleteTeam(team),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                  ],
                ),
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}

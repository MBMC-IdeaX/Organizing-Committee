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
import '../../domain/entities/judge_entity.dart';
import '../cubit/admin_dashboard_cubit.dart';
import '../cubit/judges_cubit.dart';
import '../cubit/judges_state.dart';
import '../widgets/create_judge_dialog.dart';

class JudgesScreen extends StatefulWidget {
  const JudgesScreen({super.key});

  @override
  State<JudgesScreen> createState() => _JudgesScreenState();
}

class _JudgesScreenState extends State<JudgesScreen> {
  @override
  void initState() {
    super.initState();
    context.read<JudgesCubit>().loadJudges();
  }

  void _openCreateJudgeDialog() {
    showDialog(
      context: context,
      builder: (_) => CreateJudgeDialog(
        onSave: ({required username, required password}) {
          return context.read<JudgesCubit>().createJudge(
                username: username,
                password: password,
              );
        },
      ),
    );
  }

  void _openEditJudgeDialog(JudgeEntity judge) {
    showDialog(
      context: context,
      builder: (_) => CreateJudgeDialog(
        judge: judge,
        onSave: ({required username, required password}) {
          return context.read<JudgesCubit>().updateJudge(
                id: judge.id,
                username: username,
                password: password.isEmpty ? null : password,
              );
        },
      ),
    );
  }

  void _confirmToggleStatus(JudgeEntity judge) {
    final newStatus = !judge.active;
    if (!newStatus) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: AppDimensions.borderRadiusLarge),
          backgroundColor: AppColors.surface,
          title: Text(
            'Deactivate Judge?',
            style: AppTextStyles.headingLarge.copyWith(color: AppColors.primaryNavy),
          ),
          content: Text(
            'Deactivating "${judge.username}" will immediately revoke their access and prevent them from logging in.',
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
                backgroundColor: AppColors.warning,
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
                context.read<JudgesCubit>().toggleJudgeStatus(judge.id, false);
              },
              child: const Text('Deactivate'),
            ),
          ],
        ),
      );
    } else {
      context.read<JudgesCubit>().toggleJudgeStatus(judge.id, true);
    }
  }

  void _confirmDeleteJudge(JudgeEntity judge) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: AppDimensions.borderRadiusLarge),
        backgroundColor: AppColors.surface,
        title: Text(
          'Delete Judge?',
          style: AppTextStyles.headingLarge.copyWith(color: AppColors.primaryNavy),
        ),
        content: Text(
          'Are you sure you want to permanently delete ${judge.username}?\n\nThis action cannot be undone.',
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
            onPressed: () async {
              Navigator.of(ctx).pop();
              try {
                final success = await context.read<JudgesCubit>().deleteJudge(judge.id);
                if (success && mounted) {
                  context.read<AdminDashboardCubit>().loadDashboardSummary();
                }
              } on ConflictException catch (_) {
                if (!mounted) return;
                _showCannotDeleteDialog(judge);
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

  void _showCannotDeleteDialog(JudgeEntity judge) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: AppDimensions.borderRadiusLarge),
        backgroundColor: AppColors.surface,
        title: Text(
          'Cannot Delete Judge',
          style: AppTextStyles.headingLarge.copyWith(color: AppColors.primaryNavy),
        ),
        content: Text(
          'This judge (${judge.username}) has evaluation history. You can deactivate the account to revoke access, or force delete to erase all submitted evaluations.',
          style: AppTextStyles.bodyMedium,
        ),
        actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 18),
        actions: [
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: AppColors.textSecondary,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            ),
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          if (judge.active)
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.warning,
                side: const BorderSide(color: AppColors.warning),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                shape: RoundedRectangleBorder(borderRadius: AppDimensions.borderRadiusSmall),
              ),
              onPressed: () {
                Navigator.of(ctx).pop();
                context.read<JudgesCubit>().toggleJudgeStatus(judge.id, false);
              },
              child: const Text('Deactivate'),
            ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              elevation: 0,
              minimumSize: const Size(0, 38),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: AppDimensions.borderRadiusSmall,
              ),
            ),
            onPressed: () async {
              Navigator.of(ctx).pop();
              try {
                final success = await context.read<JudgesCubit>().deleteJudge(judge.id, force: true);
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
        title: 'Manage Judges',
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.backgroundMeshGradient,
        ),
        child: BlocConsumer<JudgesCubit, JudgesState>(
          listener: (context, state) {
            if (state is JudgesLoaded && state.actionSuccessMessage != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.actionSuccessMessage!),
                  backgroundColor: AppColors.success,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            } else if (state is JudgesError) {
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
            if (state is JudgesLoading) {
              return const LoadingIndicator(message: 'Loading judge accounts...');
            }

            if (state is JudgesError && state.message.isNotEmpty) {
              return ErrorState(
                message: state.message,
                onRetry: () => context.read<JudgesCubit>().loadJudges(),
              );
            }

            if (state is JudgesLoaded) {
              final judges = state.judges;

              return RefreshIndicator(
                onRefresh: () => context.read<JudgesCubit>().loadJudges(),
                color: AppColors.primaryBlue,
                child: ListView(
                  padding: AppDimensions.screenPadding,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Judge Accounts',
                                style: AppTextStyles.headingSmall.copyWith(color: AppColors.primaryNavy),
                              ),
                              const SizedBox(height: AppDimensions.space2),
                              Text(
                                '${judges.length} total (${judges.where((j) => j.active).length} active)',
                                style: AppTextStyles.bodySmall,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: AppDimensions.space12),
                        PrimaryButton(
                          text: 'Create Judge',
                          icon: Icons.person_add_outlined,
                          width: 145,
                          height: 40,
                          onPressed: _openCreateJudgeDialog,
                        ),
                      ],
                    ),
                    const SizedBox(height: AppDimensions.space16),

                    if (judges.isEmpty)
                      EmptyState(
                        title: 'No judges created yet',
                        message: 'Create judge accounts with credentials for evaluator logins.',
                        icon: Icons.person_outline_rounded,
                        actionText: 'Create First Judge',
                        onAction: _openCreateJudgeDialog,
                      )
                    else
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: judges.length,
                        separatorBuilder: (_, __) => const SizedBox(height: AppDimensions.space12),
                        itemBuilder: (context, index) {
                          final judge = judges[index];

                          return GlassCard(
                            padding: const EdgeInsets.all(AppDimensions.space14),
                            child: Row(
                              children: [
                                // Judge Avatar
                                CircleAvatar(
                                  radius: 20,
                                  backgroundColor: judge.active ? AppColors.softBlue : AppColors.borderLight,
                                  child: Icon(
                                    Icons.gavel_rounded,
                                    color: judge.active ? AppColors.primaryBlue : AppColors.textMuted,
                                    size: 18,
                                  ),
                                ),
                                const SizedBox(width: AppDimensions.space14),

                                // Details
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              judge.username,
                                              style: AppTextStyles.bodyLarge.copyWith(
                                                color: judge.active ? AppColors.primaryNavy : AppColors.textMuted,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                          ),
                                          StatusBadge(
                                            label: judge.active ? 'ACTIVE' : 'INACTIVE',
                                            type: judge.active ? BadgeType.success : BadgeType.neutral,
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: AppDimensions.space2),
                                      Text(
                                        'Evaluator (JUDGE)',
                                        style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                                      ),
                                    ],
                                  ),
                                ),

                                // Actions
                                Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit_outlined, size: 18),
                                      color: AppColors.primaryNavy,
                                      tooltip: 'Edit / Reset Password',
                                      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                                      padding: const EdgeInsets.all(6),
                                      onPressed: () => _openEditJudgeDialog(judge),
                                    ),
                                    IconButton(
                                      icon: Icon(
                                        judge.active ? Icons.toggle_on_rounded : Icons.toggle_off_rounded,
                                        size: 26,
                                        color: judge.active ? AppColors.success : AppColors.textMuted,
                                      ),
                                      tooltip: judge.active ? 'Deactivate Judge' : 'Activate Judge',
                                      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                                      padding: const EdgeInsets.all(6),
                                      onPressed: () => _confirmToggleStatus(judge),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline_rounded, size: 18),
                                      color: AppColors.error,
                                      tooltip: 'Delete Judge',
                                      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                                      padding: const EdgeInsets.all(6),
                                      onPressed: () => _confirmDeleteJudge(judge),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    const SizedBox(height: AppDimensions.space32),
                  ],
                ),
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}

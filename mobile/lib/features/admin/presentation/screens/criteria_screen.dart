import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_app_bar.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/error_state.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../../../shared/widgets/loading_indicator.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../../../shared/widgets/status_badge.dart';
import '../../domain/entities/criteria_entity.dart';
import '../cubit/criteria_cubit.dart';
import '../cubit/criteria_state.dart';
import '../widgets/add_edit_criteria_dialog.dart';

class CriteriaScreen extends StatefulWidget {
  const CriteriaScreen({super.key});

  @override
  State<CriteriaScreen> createState() => _CriteriaScreenState();
}

class _CriteriaScreenState extends State<CriteriaScreen> {
  @override
  void initState() {
    super.initState();
    context.read<CriteriaCubit>().loadCriteria();
  }

  void _openAddCriteriaDialog() {
    showDialog(
      context: context,
      builder: (_) => AddEditCriteriaDialog(
        onSave: ({required name, description, required maxScore, required displayOrder}) {
          return context.read<CriteriaCubit>().createCriteria(
                name: name,
                description: description,
                maxScore: maxScore,
                displayOrder: displayOrder,
              );
        },
      ),
    );
  }

  void _openEditCriteriaDialog(CriteriaEntity criteria) {
    showDialog(
      context: context,
      builder: (_) => AddEditCriteriaDialog(
        criteria: criteria,
        onSave: ({required name, description, required maxScore, required displayOrder}) {
          return context.read<CriteriaCubit>().updateCriteria(
                id: criteria.id,
                name: name,
                description: description,
                maxScore: maxScore,
                displayOrder: displayOrder,
              );
        },
      ),
    );
  }

  void _confirmToggleStatus(CriteriaEntity criteria) {
    final newStatus = !criteria.active;
    if (!newStatus) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: AppDimensions.borderRadiusLarge),
          backgroundColor: AppColors.surface,
          title: Text(
            'Deactivate Criterion?',
            style: AppTextStyles.headingLarge.copyWith(color: AppColors.primaryNavy),
          ),
          content: Text(
            'Deactivating "${criteria.name}" will exclude its points from the active judging rubric.',
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
                context.read<CriteriaCubit>().toggleCriteriaStatus(criteria.id, false);
              },
              child: const Text('Deactivate'),
            ),
          ],
        ),
      );
    } else {
      context.read<CriteriaCubit>().toggleCriteriaStatus(criteria.id, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const AppAppBar(
        title: 'Judging Criteria',
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.backgroundMeshGradient,
        ),
        child: BlocConsumer<CriteriaCubit, CriteriaState>(
          listener: (context, state) {
            if (state is CriteriaLoaded && state.actionSuccessMessage != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.actionSuccessMessage!),
                  backgroundColor: AppColors.success,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            } else if (state is CriteriaError) {
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
            if (state is CriteriaLoading) {
              return const LoadingIndicator(message: 'Loading criteria rubrics...');
            }

            if (state is CriteriaError && state.message.isNotEmpty) {
              return ErrorState(
                message: state.message,
                onRetry: () => context.read<CriteriaCubit>().loadCriteria(),
              );
            }

            if (state is CriteriaLoaded) {
              final criteriaList = state.criteria;
              final totalScore = state.totalMaxScore;
              final activeCount = criteriaList.where((c) => c.active).length;

              return RefreshIndicator(
                onRefresh: () => context.read<CriteriaCubit>().loadCriteria(),
                color: AppColors.primaryBlue,
                child: ListView(
                  padding: AppDimensions.screenPadding,
                  children: [
                    // Total Max Score Preview Glass Banner
                    GlassCard(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF0B1F4B), Color(0xFF1E3A8A)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(AppDimensions.space10),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.15),
                              borderRadius: AppDimensions.borderRadiusMedium,
                            ),
                            child: const Icon(Icons.analytics_outlined, color: Colors.white, size: 26),
                          ),
                          const SizedBox(width: AppDimensions.space14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Total Maximum Score',
                                  style: AppTextStyles.bodySmall.copyWith(color: Colors.white70),
                                ),
                                const SizedBox(height: AppDimensions.space2),
                                Text(
                                  '$totalScore Points',
                                  style: AppTextStyles.headingMedium.copyWith(color: Colors.white, fontWeight: FontWeight.w700),
                                ),
                                const SizedBox(height: AppDimensions.space2),
                                Row(
                                  children: [
                                    const Icon(Icons.check_circle_outline_rounded, color: AppColors.accentCyan, size: 14),
                                    const SizedBox(width: 4),
                                    Text(
                                      '$activeCount active criteria • Configuration valid',
                                      style: AppTextStyles.caption.copyWith(color: Colors.white70),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppDimensions.space20),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            'Evaluation Rubrics',
                            style: AppTextStyles.headingSmall.copyWith(color: AppColors.primaryNavy),
                          ),
                        ),
                        const SizedBox(width: AppDimensions.space12),
                        PrimaryButton(
                          text: 'Add Criterion',
                          icon: Icons.add,
                          width: 150,
                          height: 40,
                          onPressed: _openAddCriteriaDialog,
                        ),
                      ],
                    ),
                    const SizedBox(height: AppDimensions.space16),

                    if (criteriaList.isEmpty)
                      EmptyState(
                        title: 'No criteria configured yet',
                        message: 'Create rubrics with point caps for judges to evaluate.',
                        icon: Icons.rule_folder_outlined,
                        actionText: 'Add First Criterion',
                        onAction: _openAddCriteriaDialog,
                      )
                    else
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: criteriaList.length,
                        separatorBuilder: (_, __) => const SizedBox(height: AppDimensions.space12),
                        itemBuilder: (context, index) {
                          final crit = criteriaList[index];
                          final orderDisplay = (index + 1).toString().padLeft(2, '0');

                          return GlassCard(
                            padding: const EdgeInsets.all(AppDimensions.space14),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Order Bubble
                                Container(
                                  width: 36,
                                  height: 36,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: crit.active ? AppColors.softBlue : AppColors.borderLight,
                                    borderRadius: AppDimensions.borderRadiusSmall,
                                  ),
                                  child: Text(
                                    orderDisplay,
                                    style: AppTextStyles.bodyMedium.copyWith(
                                      color: crit.active ? AppColors.primaryBlue : AppColors.textMuted,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: AppDimensions.space12),

                                // Details
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              crit.name,
                                              style: AppTextStyles.bodyLarge.copyWith(
                                                color: crit.active ? AppColors.primaryNavy : AppColors.textMuted,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                            decoration: BoxDecoration(
                                              color: crit.active ? AppColors.softBlue : AppColors.borderLight,
                                              borderRadius: AppDimensions.borderRadiusSmall,
                                            ),
                                            child: Text(
                                              '${crit.maxScore} pts',
                                              style: AppTextStyles.bodySmall.copyWith(
                                                color: crit.active ? AppColors.primaryBlue : AppColors.textMuted,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      if (crit.description != null && crit.description!.isNotEmpty) ...[
                                        const SizedBox(height: AppDimensions.space4),
                                        Text(
                                          crit.description!,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                                        ),
                                      ],
                                      const SizedBox(height: AppDimensions.space10),

                                      // Actions Row: Move Up/Down, Edit, Status
                                      Row(
                                        children: [
                                          StatusBadge(
                                            label: crit.active ? 'ACTIVE' : 'INACTIVE',
                                            type: crit.active ? BadgeType.success : BadgeType.neutral,
                                          ),
                                          const SizedBox(width: AppDimensions.space8),

                                          // Move Up/Down
                                          IconButton(
                                            icon: const Icon(Icons.arrow_upward_rounded, size: 18),
                                            color: index > 0 ? AppColors.primaryNavy : AppColors.border,
                                            tooltip: 'Move Up',
                                            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                                            padding: EdgeInsets.zero,
                                            onPressed: index > 0 ? () => context.read<CriteriaCubit>().moveCriteriaUp(index) : null,
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.arrow_downward_rounded, size: 18),
                                            color: index < criteriaList.length - 1 ? AppColors.primaryNavy : AppColors.border,
                                            tooltip: 'Move Down',
                                            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                                            padding: EdgeInsets.zero,
                                            onPressed: index < criteriaList.length - 1 ? () => context.read<CriteriaCubit>().moveCriteriaDown(index) : null,
                                          ),
                                          const Spacer(),

                                          TextButton.icon(
                                            icon: const Icon(Icons.edit_outlined, size: 15),
                                            label: const Text('Edit'),
                                            style: TextButton.styleFrom(
                                              foregroundColor: AppColors.primaryNavy,
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                              textStyle: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.w600),
                                            ),
                                            onPressed: () => _openEditCriteriaDialog(crit),
                                          ),

                                          TextButton(
                                            style: TextButton.styleFrom(
                                              foregroundColor: crit.active ? AppColors.warning : AppColors.success,
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                              textStyle: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.w600),
                                            ),
                                            onPressed: () => _confirmToggleStatus(crit),
                                            child: Text(crit.active ? 'Deactivate' : 'Activate'),
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

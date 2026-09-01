import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../app/routes/route_names.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_app_bar.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/error_state.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../../../shared/widgets/loading_indicator.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../../../shared/widgets/secondary_button.dart';
import '../../../../shared/widgets/status_badge.dart';
import '../../domain/entities/judging_criteria_score_entity.dart';
import '../cubit/judging_cubit.dart';
import '../cubit/judging_state.dart';
import '../widgets/criterion_score_control.dart';

class ScoringScreen extends StatefulWidget {
  final int teamId;

  const ScoringScreen({super.key, required this.teamId});

  @override
  State<ScoringScreen> createState() => _ScoringScreenState();
}

class _ScoringScreenState extends State<ScoringScreen> {
  final TextEditingController _commentController = TextEditingController();
  bool _commentInitialized = false;

  @override
  void initState() {
    super.initState();
    context.read<JudgingCubit>().loadSession(widget.teamId);
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<JudgingCubit, JudgingState>(
      listener: (context, state) {
        if (state is JudgingSessionLoaded) {
          if (!_commentInitialized) {
            _commentController.text = state.localComment ?? '';
            _commentInitialized = true;
          }

          if (state.actionSuccessMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.actionSuccessMessage!),
                backgroundColor: AppColors.success,
              ),
            );
          }

          if (state.actionErrorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.actionErrorMessage!),
                backgroundColor: AppColors.error,
              ),
            );
          }
        } else if (state is JudgingCompletedSuccess) {
          Navigator.pushReplacementNamed(
            context,
            RouteNames.judgeCompleted,
            arguments: state.session,
          );
        }
      },
      builder: (context, state) {
        final hasUnsaved = state is JudgingSessionLoaded && state.hasUnsavedChanges;

        return PopScope(
          canPop: !hasUnsaved,
          onPopInvokedWithResult: (didPop, result) async {
            if (didPop) return;
            final navigator = Navigator.of(context);
            final shouldLeave = await _showUnsavedChangesDialog(context);
            if (shouldLeave == true) {
              navigator.pop();
            }
          },
          child: Scaffold(
            appBar: AppAppBar(
              title: state is JudgingSessionLoaded
                  ? state.session.projectName
                  : 'Live Scoring',
            ),
            body: Container(
              decoration: const BoxDecoration(
                gradient: AppColors.backgroundMeshGradient,
              ),
              child: _buildBody(context, state),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, JudgingState state) {
    if (state is JudgingLoading) {
      return const LoadingIndicator(message: 'Loading scoring rubric...');
    } else if (state is JudgingError) {
      return ErrorState(
        message: state.message,
        onRetry: () => context.read<JudgingCubit>().loadSession(widget.teamId),
      );
    } else if (state is JudgingSessionLoaded) {
      final session = state.session;
      final isReadOnly = session.isCompleted;

      return ListView(
        padding: AppDimensions.screenPadding,
        children: [
          // Total Score Running Banner
          _buildTotalScoreBanner(state.currentTotalScore, session.totalMaxScore, isReadOnly),
          const SizedBox(height: AppDimensions.space16),

          // Team Info Subtitle
          Text(
            session.teamName,
            style: AppTextStyles.headingSmall.copyWith(color: AppColors.primaryNavy),
          ),
          const SizedBox(height: AppDimensions.space4),
          Text(
            'Rubric Evaluation (Order #${session.displayOrder.toString().padLeft(2, '0')})',
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppDimensions.space16),

          // Criteria List Cards
          ...session.criteriaScores.map(
            (criterion) => _buildCriteriaCard(context, criterion, state, isReadOnly),
          ),
          const SizedBox(height: AppDimensions.space16),

          // Optional Comment Card
          _buildCommentCard(context, isReadOnly, state),
          const SizedBox(height: AppDimensions.space24),

          // Actions (Save Draft & Mark Complete)
          if (!isReadOnly) ...[
            Row(
              children: [
                Expanded(
                  child: SecondaryButton(
                    text: 'Save Draft',
                    icon: Icons.save_outlined,
                    isLoading: state.isSaving,
                    onPressed: state.isSaving || state.isCompleting
                        ? null
                        : () => context.read<JudgingCubit>().saveDraftScores(),
                  ),
                ),
                const SizedBox(width: AppDimensions.space12),
                Expanded(
                  child: PrimaryButton(
                    text: 'Mark Complete',
                    icon: Icons.check_circle_outline,
                    isLoading: state.isCompleting,
                    onPressed: state.isSaving || state.isCompleting
                        ? null
                        : () => _confirmAndComplete(context),
                  ),
                ),
              ],
            ),
          ] else ...[
            GlassCard(
              child: Row(
                children: [
                  const Icon(Icons.lock_outline_rounded, color: AppColors.textSecondary, size: 20),
                  const SizedBox(width: AppDimensions.space8),
                  Expanded(
                    child: Text(
                      'This evaluation is finalized and marked as completed.',
                      style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: AppDimensions.space32),
        ],
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildTotalScoreBanner(int totalScore, int maxScore, bool isReadOnly) {
    return GlassCard(
      gradient: isReadOnly ? AppColors.successCardGradient : AppColors.heroCardGradient,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isReadOnly ? 'Final Total Score' : 'Running Total Score',
                style: AppTextStyles.labelLarge.copyWith(color: Colors.white70),
              ),
              const SizedBox(height: AppDimensions.space4),
              Text(
                '$totalScore / $maxScore Points',
                style: AppTextStyles.headingMedium.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          StatusBadge(
            label: isReadOnly ? 'FINALIZED' : 'IN PROGRESS',
            type: isReadOnly ? BadgeType.success : BadgeType.info,
          ),
        ],
      ),
    );
  }

  Widget _buildCriteriaCard(
    BuildContext context,
    JudgingCriteriaScoreEntity criterion,
    JudgingSessionLoaded state,
    bool isReadOnly,
  ) {
    final int score = state.localScores[criterion.criteriaId] ?? 0;
    final bool isScored = state.localScores.containsKey(criterion.criteriaId);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.space12),
      child: GlassCard(
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
                        '${criterion.displayOrder.toString().padLeft(2, '0')}  ${criterion.criteriaName}',
                        style: AppTextStyles.titleMedium.copyWith(
                          color: AppColors.primaryNavy,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (criterion.description != null && criterion.description!.isNotEmpty) ...[
                        const SizedBox(height: AppDimensions.space4),
                        Text(
                          criterion.description!,
                          style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                        ),
                      ],
                    ],
                  ),
                ),
                StatusBadge(
                  label: 'Max ${criterion.maxScore} pts',
                  type: BadgeType.neutral,
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.space16),

            // Score Row with Direct Input + Steppers
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (!isReadOnly)
                  Expanded(
                    child: Text(
                      isScored ? 'Entered Score:' : 'Set Score (0 - ${criterion.maxScore}):',
                      style: AppTextStyles.labelLarge.copyWith(
                        color: isScored ? AppColors.primaryBlue : AppColors.textSecondary,
                      ),
                    ),
                  )
                else
                  Expanded(
                    child: Text('Awarded Score:', style: AppTextStyles.bodyMedium),
                  ),
                const SizedBox(width: AppDimensions.space8),
                CriterionScoreControl(
                  criteriaId: criterion.criteriaId,
                  criteriaName: criterion.criteriaName,
                  maxScore: criterion.maxScore,
                  score: score,
                  isReadOnly: isReadOnly,
                  onScoreChanged: (newScore) {
                    context.read<JudgingCubit>().setScore(
                          criterion.criteriaId,
                          newScore,
                          criterion.maxScore,
                        );
                  },
                  onIncrement: () {
                    context.read<JudgingCubit>().incrementScore(
                          criterion.criteriaId,
                          criterion.maxScore,
                        );
                  },
                  onDecrement: () {
                    context.read<JudgingCubit>().decrementScore(criterion.criteriaId);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommentCard(BuildContext context, bool isReadOnly, JudgingSessionLoaded state) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.chat_bubble_outline_rounded, color: AppColors.primaryBlue, size: 20),
              const SizedBox(width: AppDimensions.space8),
              Text(
                'Judge Comments (Optional)',
                style: AppTextStyles.titleMedium.copyWith(
                  color: AppColors.primaryNavy,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.space12),
          if (!isReadOnly)
            AppTextField(
              controller: _commentController,
              label: 'Evaluation Notes',
              hintText: 'Add feedback or qualitative notes for this team...',
              maxLines: 3,
              onChanged: (val) => context.read<JudgingCubit>().setComment(val),
            )
          else
            Text(
              state.localComment != null && state.localComment!.isNotEmpty
                  ? state.localComment!
                  : 'No comments entered for this evaluation.',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textPrimary,
                fontStyle: state.localComment != null && state.localComment!.isNotEmpty
                    ? FontStyle.normal
                    : FontStyle.italic,
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _confirmAndComplete(BuildContext context) async {
    final cubit = context.read<JudgingCubit>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: AppDimensions.borderRadiusLarge),
        title: Text(
          'Complete Evaluation?',
          style: AppTextStyles.headingLarge.copyWith(color: AppColors.primaryNavy),
        ),
        content: Text(
          'Once submitted as complete, these scores and comments become immutable and cannot be changed.',
          style: AppTextStyles.bodyMedium,
        ),
        actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
        actions: [
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: AppColors.textSecondary,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            onPressed: () => Navigator.pop(dialogCtx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: AppDimensions.borderRadiusSmall,
              ),
            ),
            onPressed: () => Navigator.pop(dialogCtx, true),
            child: const Text('Mark as Complete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      cubit.completeEvaluation();
    }
  }

  Future<bool?> _showUnsavedChangesDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: AppDimensions.borderRadiusLarge),
        title: Text(
          'Unsaved Changes',
          style: AppTextStyles.headingLarge.copyWith(color: AppColors.primaryNavy),
        ),
        content: Text(
          'You have unsaved score changes. Are you sure you want to leave without saving?',
          style: AppTextStyles.bodyMedium,
        ),
        actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
        actions: [
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: AppColors.textSecondary,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            onPressed: () => Navigator.pop(dialogCtx, false),
            child: const Text('Stay'),
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
            onPressed: () => Navigator.pop(dialogCtx, true),
            child: const Text('Leave'),
          ),
        ],
      ),
    );
  }
}

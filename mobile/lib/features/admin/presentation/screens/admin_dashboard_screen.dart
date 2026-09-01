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
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';
import '../cubit/admin_dashboard_cubit.dart';
import '../cubit/admin_dashboard_state.dart';
import '../widgets/reset_system_dialog.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  @override
  void initState() {
    super.initState();
    context.read<AdminDashboardCubit>().loadDashboardSummary();
  }

  void _confirmLogout() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: AppDimensions.borderRadiusLarge),
        title: Text(
          'Sign Out?',
          style: AppTextStyles.headingLarge.copyWith(color: AppColors.primaryNavy),
        ),
        content: Text(
          'Are you sure you want to log out of the Admin Console?',
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

  void _openResetSystemDialog() {
    showDialog<bool>(
      context: context,
      builder: (_) => ResetSystemDialog(
        onConfirm: ({
          required adminPassword,
          required clearJudgings,
          required clearJudges,
          required clearTeams,
        }) async {
          return await context.read<AdminDashboardCubit>().resetSystemData(
            adminPassword: adminPassword,
            clearJudgings: clearJudgings,
            clearJudges: clearJudges,
            clearTeams: clearTeams,
          );
        },
      ),
    ).then((result) {
      if (result == true && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Competition data reset successfully.'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    });
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
        backgroundColor: AppColors.background,
        appBar: AppAppBar(
          title: 'IdeaX Admin Console',
          actions: [
            IconButton(
              icon: const Icon(Icons.logout_rounded, color: AppColors.primaryNavy),
              tooltip: 'Logout',
              onPressed: _confirmLogout,
            ),
          ],
        ),
      body: BlocBuilder<AdminDashboardCubit, AdminDashboardState>(
        builder: (context, state) {
          if (state is AdminDashboardLoading) {
            return const LoadingIndicator(message: 'Loading event configuration...');
          }

          if (state is AdminDashboardError) {
            return ErrorState(
              message: state.message,
              onRetry: () => context.read<AdminDashboardCubit>().loadDashboardSummary(),
            );
          }

          if (state is AdminDashboardLoaded) {
            final summary = state.summary;

            return RefreshIndicator(
              onRefresh: () => context.read<AdminDashboardCubit>().loadDashboardSummary(),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: AppDimensions.screenPadding,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Welcome Banner
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Event Configuration',
                                style: AppTextStyles.headingMedium.copyWith(color: AppColors.primaryNavy),
                              ),
                              const SizedBox(height: AppDimensions.space4),
                              Text(
                                'Prepare teams, rubrics, and judge accounts',
                                style: AppTextStyles.bodyMedium,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: AppDimensions.space8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.softBlue,
                            borderRadius: AppDimensions.borderRadiusSmall,
                          ),
                          child: Text(
                            'ADMIN ROLE',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.primaryBlue,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppDimensions.space20),

                    // Configuration Readiness Glass Card
                    GlassCard(
                      gradient: summary.readyForJudging
                          ? const LinearGradient(
                              colors: [Color(0xFFF0FDF4), Color(0xFFDCFCE7)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            )
                          : const LinearGradient(
                              colors: [Color(0xFFFFFBEB), Color(0xFFFEF3C7)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                summary.readyForJudging ? Icons.check_circle_rounded : Icons.pending_actions_rounded,
                                color: summary.readyForJudging ? AppColors.success : AppColors.warning,
                                size: 24,
                              ),
                              const SizedBox(width: AppDimensions.space8),
                              Text(
                                summary.readyForJudging ? 'Judging Setup: Ready' : 'Judging Setup: In Progress',
                                style: AppTextStyles.headingSmall.copyWith(
                                  color: summary.readyForJudging ? const Color(0xFF14532D) : const Color(0xFF78350F),
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppDimensions.space12),

                          // Readiness Checklist
                          _buildChecklistItem(
                            isDone: summary.activeTeams > 0,
                            title: '${summary.activeTeams} Active Teams configured',
                          ),
                          const SizedBox(height: AppDimensions.space8),
                          _buildChecklistItem(
                            isDone: summary.activeCriteria > 0,
                            title: '${summary.activeCriteria} Active Criteria (Total Max Score: ${summary.totalMaxScore} pts)',
                          ),
                          const SizedBox(height: AppDimensions.space8),
                          _buildChecklistItem(
                            isDone: summary.activeJudges > 0,
                            title: '${summary.activeJudges} Active Judges provisioned',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppDimensions.space24),

                    // Key Metric Stat Cards Grid
                    Text(
                      'Overview Metrics',
                      style: AppTextStyles.headingSmall.copyWith(color: AppColors.primaryNavy),
                    ),
                    const SizedBox(height: AppDimensions.space12),

                    Row(
                      children: [
                        Expanded(
                          child: _buildMetricCard(
                            title: 'Teams',
                            count: summary.totalTeams.toString(),
                            subtitle: '${summary.activeTeams} Active',
                            icon: Icons.groups_rounded,
                            color: AppColors.primaryBlue,
                          ),
                        ),
                        const SizedBox(width: AppDimensions.space12),
                        Expanded(
                          child: _buildMetricCard(
                            title: 'Criteria',
                            count: summary.totalCriteria.toString(),
                            subtitle: '${summary.totalMaxScore} Pts Max',
                            icon: Icons.rule_folder_rounded,
                            color: AppColors.accentCyan,
                          ),
                        ),
                        const SizedBox(width: AppDimensions.space12),
                        Expanded(
                          child: _buildMetricCard(
                            title: 'Judges',
                            count: summary.totalJudges.toString(),
                            subtitle: '${summary.activeJudges} Active',
                            icon: Icons.gavel_rounded,
                            color: AppColors.secondaryBlue,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppDimensions.space24),

                    // Management Navigation Cards
                    Text(
                      'Event Modules',
                      style: AppTextStyles.headingSmall.copyWith(color: AppColors.primaryNavy),
                    ),
                    const SizedBox(height: AppDimensions.space12),

                    _buildNavigationCard(
                      title: 'Manage Teams',
                      description: 'Register hackathon teams, update projects, and arrange evaluation order.',
                      icon: Icons.groups_outlined,
                      badgeText: '${summary.totalTeams} Teams',
                      onTap: () {
                        final cubit = context.read<AdminDashboardCubit>();
                        Navigator.pushNamed(context, RouteNames.adminTeams).then((_) {
                          cubit.loadDashboardSummary();
                        });
                      },
                    ),
                    const SizedBox(height: AppDimensions.space12),

                    _buildNavigationCard(
                      title: 'Manage Criteria Rubrics',
                      description: 'Configure judging criteria, adjust point caps, and verify total maximum score.',
                      icon: Icons.rule_outlined,
                      badgeText: '${summary.totalCriteria} Rubrics',
                      onTap: () {
                        final cubit = context.read<AdminDashboardCubit>();
                        Navigator.pushNamed(context, RouteNames.adminCriteria).then((_) {
                          cubit.loadDashboardSummary();
                        });
                      },
                    ),
                    const SizedBox(height: AppDimensions.space12),

                    _buildNavigationCard(
                      title: 'Manage Judges',
                      description: 'Provision judge user accounts and toggle evaluator login access.',
                      icon: Icons.person_search_outlined,
                      badgeText: '${summary.totalJudges} Judges',
                      onTap: () {
                        final cubit = context.read<AdminDashboardCubit>();
                        Navigator.pushNamed(context, RouteNames.adminJudges).then((_) {
                          cubit.loadDashboardSummary();
                        });
                      },
                    ),
                    const SizedBox(height: AppDimensions.space12),

                    _buildNavigationCard(
                      title: 'Results & Rankings',
                      description: 'View real-time standings, deterministic podium sheets, and detailed judge score audit trails.',
                      icon: Icons.analytics_outlined,
                      badgeText: 'Standings',
                      onTap: () {
                        Navigator.pushNamed(context, RouteNames.adminResults);
                      },
                    ),
                    const SizedBox(height: AppDimensions.space24),

                    // Danger Zone / Reset
                    Text(
                      'Danger Zone',
                      style: AppTextStyles.headingSmall.copyWith(
                        color: AppColors.error,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.space12),

                    GlassCard(
                      padding: const EdgeInsets.all(AppDimensions.space16),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(AppDimensions.space12),
                            decoration: BoxDecoration(
                              color: AppColors.error.withValues(alpha: 0.1),
                              borderRadius: AppDimensions.borderRadiusMedium,
                            ),
                            child: const Icon(Icons.restart_alt_rounded, color: AppColors.error, size: 24),
                          ),
                          const SizedBox(width: AppDimensions.space16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Reset Competition Data',
                                  style: AppTextStyles.bodyLarge.copyWith(
                                    color: AppColors.primaryNavy,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: AppDimensions.space4),
                                Text(
                                  'Clear evaluation scores, test accounts, or reset entire competition.',
                                  style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: AppDimensions.space8),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.error,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              minimumSize: const Size(0, 36),
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                              shape: RoundedRectangleBorder(borderRadius: AppDimensions.borderRadiusSmall),
                            ),
                            onPressed: _openResetSystemDialog,
                            child: const Text('Reset Data'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    ),
  );
}

  Widget _buildChecklistItem({required bool isDone, required String title}) {
    return Row(
      children: [
        Icon(
          isDone ? Icons.check_circle_outline_rounded : Icons.radio_button_unchecked_rounded,
          size: 18,
          color: isDone ? AppColors.success : AppColors.warning,
        ),
        const SizedBox(width: AppDimensions.space8),
        Expanded(
          child: Text(
            title,
            style: AppTextStyles.bodyMedium.copyWith(
              color: isDone ? AppColors.textPrimary : AppColors.textSecondary,
              fontWeight: isDone ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String count,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return GlassCard(
      padding: const EdgeInsets.all(AppDimensions.space12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: AppDimensions.space8),
          Text(
            count,
            style: AppTextStyles.headingMedium.copyWith(
              color: AppColors.primaryNavy,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppDimensions.space4),
          Text(title, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
          Text(subtitle, style: AppTextStyles.bodySmall.copyWith(color: AppColors.textMuted)),
        ],
      ),
    );
  }

  Widget _buildNavigationCard({
    required String title,
    required String description,
    required IconData icon,
    required String badgeText,
    required VoidCallback onTap,
  }) {
    return GlassCard(
      onTap: onTap,
      padding: const EdgeInsets.all(AppDimensions.space16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppDimensions.space12),
            decoration: BoxDecoration(
              color: AppColors.softBlue,
              borderRadius: AppDimensions.borderRadiusMedium,
            ),
            child: Icon(icon, color: AppColors.primaryBlue, size: 24),
          ),
          const SizedBox(width: AppDimensions.space16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: AppTextStyles.bodyLarge.copyWith(
                          color: AppColors.primaryNavy,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: AppDimensions.borderRadiusSmall,
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Text(
                        badgeText,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.primaryNavy,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppDimensions.space4),
                Text(
                  description,
                  style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppDimensions.space8),
          const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
        ],
      ),
    );
  }
}

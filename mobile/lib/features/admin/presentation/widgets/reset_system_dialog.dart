import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/errors/app_exception.dart';

class ResetSystemDialog extends StatefulWidget {
  final Future<bool> Function({
    required String adminPassword,
    required bool clearJudgings,
    required bool clearJudges,
    required bool clearTeams,
  }) onConfirm;

  const ResetSystemDialog({
    super.key,
    required this.onConfirm,
  });

  @override
  State<ResetSystemDialog> createState() => _ResetSystemDialogState();
}

class _ResetSystemDialogState extends State<ResetSystemDialog> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _clearJudgings = true;
  bool _clearJudges = false;
  bool _clearTeams = false;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  String _mapErrorMessage(dynamic error) {
    if (error is UnauthorizedException) {
      return 'Administrator verification failed. Please check your password.';
    }
    if (error is ForbiddenException) {
      return 'Only active administrators are authorized to reset competition data.';
    }
    if (error is NetworkException) {
      return 'Unable to connect to the server. Please check your connection.';
    }
    if (error is ValidationException) {
      return error.message.isNotEmpty
          ? error.message
          : 'Please enter your administrator password.';
    }

    final str = error.toString().toLowerCase();
    if (str.contains('unauthorized') || str.contains('password') || str.contains('401') || str.contains('reset_invalid_password')) {
      return 'Administrator verification failed. Please check your password.';
    }
    if (str.contains('network') || str.contains('socket') || str.contains('connection') || str.contains('timeout')) {
      return 'Unable to connect to the server. Please check your connection.';
    }
    if (str.contains('validation') || str.contains('400')) {
      return 'Please enter your administrator password.';
    }

    return 'Reset could not be completed. No changes were applied.';
  }

  Future<void> _handleAuthorizeClick() async {
    if (_isLoading) return;
    if (!(_formKey.currentState?.validate() ?? false)) return;

    if (!_clearJudgings && !_clearJudges && !_clearTeams) {
      setState(() {
        _errorMessage = 'Please select at least one item to reset/clear.';
      });
      return;
    }

    setState(() {
      _errorMessage = null;
    });

    // Show secondary confirmation for dangerous actions
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: AppDimensions.borderRadiusLarge),
        backgroundColor: AppColors.surface,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                borderRadius: AppDimensions.borderRadiusSmall,
              ),
              child: const Icon(Icons.error_outline_rounded, color: AppColors.error, size: 22),
            ),
            const SizedBox(width: AppDimensions.space12),
            Expanded(
              child: Text(
                'Are you absolutely sure?',
                style: AppTextStyles.headingMedium.copyWith(color: AppColors.primaryNavy),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'This action permanently removes selected competition data and cannot be undone.',
              style: AppTextStyles.bodyMedium,
            ),
            const SizedBox(height: AppDimensions.space12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: AppDimensions.borderRadiusSmall,
                border: Border.all(color: AppColors.borderLight),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Operations to execute:', style: AppTextStyles.labelLarge),
                  const SizedBox(height: 6),
                  if (_clearJudgings)
                    _buildSelectionBullet('Clear all evaluation scores & ballots'),
                  if (_clearJudges)
                    _buildSelectionBullet('Delete all judge accounts'),
                  if (_clearTeams)
                    _buildSelectionBullet('Delete all participating teams'),
                ],
              ),
            ),
          ],
        ),
        actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 18),
        actions: [
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: AppColors.textSecondary,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            ),
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              elevation: 0,
              minimumSize: const Size(0, 38),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              shape: RoundedRectangleBorder(borderRadius: AppDimensions.borderRadiusSmall),
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Reset Competition'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final success = await widget.onConfirm(
        adminPassword: _passwordController.text.trim(),
        clearJudgings: _clearJudgings,
        clearJudges: _clearJudges,
        clearTeams: _clearTeams,
      );

      if (success && mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = _mapErrorMessage(e);
          _isLoading = false;
        });
      }
    }
  }

  Widget _buildSelectionBullet(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          const Icon(Icons.check_circle_rounded, color: AppColors.error, size: 14),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              style: AppTextStyles.bodySmall.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.primaryNavy,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: AppDimensions.borderRadiusLarge),
      backgroundColor: AppColors.surface,
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.1),
              borderRadius: AppDimensions.borderRadiusSmall,
            ),
            child: const Icon(Icons.warning_amber_rounded, color: AppColors.error, size: 24),
          ),
          const SizedBox(width: AppDimensions.space12),
          Expanded(
            child: Text(
              'Reset Competition Data',
              style: AppTextStyles.headingMedium.copyWith(color: AppColors.primaryNavy),
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF2F2),
                  borderRadius: AppDimensions.borderRadiusSmall,
                  border: Border.all(color: const Color(0xFFFCA5A5)),
                ),
                child: Text(
                  'Warning: This action permanently removes selected competition data.',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: const Color(0xFF991B1B),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: AppDimensions.space16),

              Text(
                'Select Operations to Execute:',
                style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: AppDimensions.space8),

              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
                dense: true,
                value: _clearJudgings,
                title: const Text('Clear all evaluation scores & ballots'),
                subtitle: const Text('Erases scorecards; resets rankings to 0'),
                onChanged: _isLoading ? null : (v) => setState(() => _clearJudgings = v ?? false),
              ),
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
                dense: true,
                value: _clearJudges,
                title: const Text('Delete all judge accounts'),
                subtitle: const Text('Admin account is strictly preserved'),
                onChanged: _isLoading ? null : (v) => setState(() => _clearJudges = v ?? false),
              ),
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
                dense: true,
                value: _clearTeams,
                title: const Text('Delete all participating teams'),
                subtitle: const Text('Removes all team profiles from event'),
                onChanged: _isLoading ? null : (v) => setState(() => _clearTeams = v ?? false),
              ),

              const SizedBox(height: AppDimensions.space12),

              // Selected Summary Box
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: AppDimensions.borderRadiusSmall,
                  border: Border.all(color: AppColors.borderLight),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('You selected:', style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
                    const SizedBox(height: 4),
                    if (!_clearJudgings && !_clearJudges && !_clearTeams)
                      Text('No operations selected', style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary))
                    else ...[
                      if (_clearJudgings) _buildSelectionBullet('Clear evaluation scores & ballots'),
                      if (_clearJudges) _buildSelectionBullet('Delete judge accounts'),
                      if (_clearTeams) _buildSelectionBullet('Delete participating teams'),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: AppDimensions.space16),
              Text(
                'Administrator Password:',
                style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: AppDimensions.space8),

              TextFormField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                enabled: !_isLoading,
                decoration: InputDecoration(
                  labelText: 'Admin Password',
                  hintText: 'Enter your admin password',
                  prefixIcon: const Icon(Icons.lock_outline_rounded, size: 20),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                      size: 20,
                    ),
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  ),
                  filled: true,
                  fillColor: AppColors.surface,
                  border: OutlineInputBorder(
                    borderRadius: AppDimensions.borderRadiusSmall,
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Please enter your administrator password.';
                  }
                  return null;
                },
              ),

              if (_errorMessage != null) ...[
                const SizedBox(height: AppDimensions.space12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.1),
                    borderRadius: AppDimensions.borderRadiusSmall,
                    border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline_rounded, color: AppColors.error, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.error,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
      actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 18),
      actions: [
        TextButton(
          style: TextButton.styleFrom(
            foregroundColor: AppColors.textSecondary,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          ),
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.error,
            foregroundColor: Colors.white,
            elevation: 0,
            minimumSize: const Size(0, 38),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            shape: RoundedRectangleBorder(
              borderRadius: AppDimensions.borderRadiusSmall,
            ),
          ),
          onPressed: _isLoading ? null : _handleAuthorizeClick,
          child: _isLoading
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : const Text('Authorize Reset'),
        ),
      ],
    );
  }
}

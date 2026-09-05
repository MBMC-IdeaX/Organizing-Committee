import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../../../shared/widgets/secondary_button.dart';
import '../../domain/entities/judge_entity.dart';

class CreateJudgeDialog extends StatefulWidget {
  final JudgeEntity? judge;
  final Future<bool> Function({
    required String username,
    required String password,
  }) onSave;

  const CreateJudgeDialog({
    super.key,
    this.judge,
    required this.onSave,
  });

  @override
  State<CreateJudgeDialog> createState() => _CreateJudgeDialogState();
}

class _CreateJudgeDialogState extends State<CreateJudgeDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _usernameController;
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController(text: widget.judge?.username ?? '');
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isLoading = true);
      final success = await widget.onSave(
        username: _usernameController.text.trim(),
        password: _passwordController.text,
      );
      if (mounted) {
        setState(() => _isLoading = false);
        if (success) {
          Navigator.of(context).pop();
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.judge != null;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: AppDimensions.borderRadiusLarge),
      backgroundColor: AppColors.surface,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimensions.space24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isEditing ? 'Edit Judge' : 'Create Judge Account',
                      style: AppTextStyles.headingSmall.copyWith(color: AppColors.primaryNavy),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: AppColors.textSecondary, size: 20),
                      onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: AppDimensions.space16),

                AppTextField(
                  controller: _usernameController,
                  label: 'Judge Username',
                  hintText: 'e.g. judge_sarah',
                  prefixIcon: Icons.badge_outlined,
                  readOnly: _isLoading,
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) return 'Username is required';
                    if (val.trim().length < 3) return 'Username must be at least 3 characters';
                    return null;
                  },
                ),
                const SizedBox(height: AppDimensions.space16),

                AppTextField(
                  controller: _passwordController,
                  label: isEditing ? 'New Password (Optional)' : 'Password',
                  hintText: isEditing ? 'Leave blank to keep unchanged' : 'Enter password',
                  isPassword: true,
                  prefixIcon: Icons.lock_outline,
                  readOnly: _isLoading,
                  validator: (val) {
                    if (!isEditing && (val == null || val.isEmpty)) {
                      return 'Password is required';
                    }
                    if (val != null && val.isNotEmpty && val.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppDimensions.space16),

                AppTextField(
                  controller: _confirmPasswordController,
                  label: 'Confirm Password',
                  hintText: 'Re-enter password',
                  isPassword: true,
                  prefixIcon: Icons.lock_outline,
                  readOnly: _isLoading,
                  validator: (val) {
                    if (!isEditing && (val == null || val.isEmpty)) {
                      return 'Please confirm password';
                    }
                    if (_passwordController.text.isNotEmpty && val != _passwordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppDimensions.space24),

                Row(
                  children: [
                    Expanded(
                      child: SecondaryButton(
                        text: 'Cancel',
                        height: 40,
                        onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
                      ),
                    ),
                    const SizedBox(width: AppDimensions.space12),
                    Expanded(
                      child: PrimaryButton(
                        text: isEditing ? 'Save Changes' : 'Create Judge',
                        height: 40,
                        isLoading: _isLoading,
                        onPressed: _handleSubmit,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../../../shared/widgets/secondary_button.dart';
import '../../domain/entities/team_entity.dart';

class AddEditTeamDialog extends StatefulWidget {
  final TeamEntity? team;
  final Future<bool> Function({
    required String teamName,
    required String projectName,
    String? idea,
    required int displayOrder,
  }) onSave;

  const AddEditTeamDialog({
    super.key,
    this.team,
    required this.onSave,
  });

  @override
  State<AddEditTeamDialog> createState() => _AddEditTeamDialogState();
}

class _AddEditTeamDialogState extends State<AddEditTeamDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _teamNameController;
  late final TextEditingController _projectNameController;
  late final TextEditingController _ideaController;
  late final TextEditingController _orderController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _teamNameController = TextEditingController(text: widget.team?.teamName ?? '');
    _projectNameController = TextEditingController(text: widget.team?.projectName ?? '');
    _ideaController = TextEditingController(text: widget.team?.idea ?? '');
    _orderController = TextEditingController(text: (widget.team?.displayOrder ?? 0).toString());
  }

  @override
  void dispose() {
    _teamNameController.dispose();
    _projectNameController.dispose();
    _ideaController.dispose();
    _orderController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isLoading = true);
      final success = await widget.onSave(
        teamName: _teamNameController.text.trim(),
        projectName: _projectNameController.text.trim(),
        idea: _ideaController.text.trim().isEmpty ? null : _ideaController.text.trim(),
        displayOrder: int.tryParse(_orderController.text.trim()) ?? 0,
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
    final isEditing = widget.team != null;

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
                      isEditing ? 'Edit Team' : 'Add Team',
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
                  controller: _teamNameController,
                  label: 'Team Name',
                  hintText: 'e.g. Team Nova',
                  prefixIcon: Icons.group_outlined,
                  readOnly: _isLoading,
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) return 'Team name is required';
                    if (val.trim().length < 2) return 'Team name must be at least 2 characters';
                    return null;
                  },
                ),
                const SizedBox(height: AppDimensions.space16),

                AppTextField(
                  controller: _projectNameController,
                  label: 'Project Name',
                  hintText: 'e.g. Smart AgriSense',
                  prefixIcon: Icons.lightbulb_outline,
                  readOnly: _isLoading,
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) return 'Project name is required';
                    if (val.trim().length < 2) return 'Project name must be at least 2 characters';
                    return null;
                  },
                ),
                const SizedBox(height: AppDimensions.space16),

                AppTextField(
                  controller: _ideaController,
                  label: 'Project Idea / Summary (Optional)',
                  hintText: 'Brief summary of the innovation...',
                  prefixIcon: Icons.description_outlined,
                  maxLines: 3,
                  readOnly: _isLoading,
                ),
                const SizedBox(height: AppDimensions.space16),

                AppTextField(
                  controller: _orderController,
                  label: 'Display Order',
                  hintText: '0',
                  prefixIcon: Icons.sort,
                  keyboardType: TextInputType.number,
                  readOnly: _isLoading,
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) return 'Order is required';
                    if (int.tryParse(val.trim()) == null) return 'Must be a valid integer';
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
                        text: isEditing ? 'Save Changes' : 'Create Team',
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

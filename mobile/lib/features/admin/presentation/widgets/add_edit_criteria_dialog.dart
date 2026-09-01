import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../../../shared/widgets/secondary_button.dart';
import '../../domain/entities/criteria_entity.dart';

class AddEditCriteriaDialog extends StatefulWidget {
  final CriteriaEntity? criteria;
  final Future<bool> Function({
    required String name,
    String? description,
    required int maxScore,
    required int displayOrder,
  }) onSave;

  const AddEditCriteriaDialog({
    super.key,
    this.criteria,
    required this.onSave,
  });

  @override
  State<AddEditCriteriaDialog> createState() => _AddEditCriteriaDialogState();
}

class _AddEditCriteriaDialogState extends State<AddEditCriteriaDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _maxScoreController;
  late final TextEditingController _orderController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.criteria?.name ?? '');
    _descriptionController = TextEditingController(text: widget.criteria?.description ?? '');
    _maxScoreController = TextEditingController(text: (widget.criteria?.maxScore ?? 20).toString());
    _orderController = TextEditingController(text: (widget.criteria?.displayOrder ?? 0).toString());
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _maxScoreController.dispose();
    _orderController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isLoading = true);
      final success = await widget.onSave(
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim().isEmpty ? null : _descriptionController.text.trim(),
        maxScore: int.parse(_maxScoreController.text.trim()),
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
    final isEditing = widget.criteria != null;

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
                      isEditing ? 'Edit Criterion' : 'Add Criterion',
                      style: AppTextStyles.headingSmall.copyWith(color: AppColors.primaryNavy),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: AppColors.textSecondary),
                      onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: AppDimensions.space16),

                AppTextField(
                  controller: _nameController,
                  label: 'Criterion Name',
                  hintText: 'e.g. Technical Implementation',
                  prefixIcon: Icons.rule_folder_outlined,
                  readOnly: _isLoading,
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) return 'Criterion name is required';
                    if (val.trim().length < 2) return 'Name must be at least 2 characters';
                    return null;
                  },
                ),
                const SizedBox(height: AppDimensions.space16),

                AppTextField(
                  controller: _descriptionController,
                  label: 'Description / Rubric Guide (Optional)',
                  hintText: 'Evaluation guidelines for judges...',
                  prefixIcon: Icons.description_outlined,
                  maxLines: 3,
                  readOnly: _isLoading,
                ),
                const SizedBox(height: AppDimensions.space16),

                AppTextField(
                  controller: _maxScoreController,
                  label: 'Maximum Score (Points)',
                  hintText: '20',
                  prefixIcon: Icons.star_outline_rounded,
                  keyboardType: TextInputType.number,
                  readOnly: _isLoading,
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) return 'Max score is required';
                    final parsed = int.tryParse(val.trim());
                    if (parsed == null || parsed <= 0) return 'Must be a positive integer';
                    return null;
                  },
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
                        onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
                      ),
                    ),
                    const SizedBox(width: AppDimensions.space12),
                    Expanded(
                      child: PrimaryButton(
                        text: isEditing ? 'Save Changes' : 'Create Criterion',
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

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';

class CriterionScoreControl extends StatefulWidget {
  final int criteriaId;
  final String criteriaName;
  final int maxScore;
  final int score;
  final bool isReadOnly;
  final ValueChanged<int> onScoreChanged;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  const CriterionScoreControl({
    super.key,
    required this.criteriaId,
    required this.criteriaName,
    required this.maxScore,
    required this.score,
    required this.isReadOnly,
    required this.onScoreChanged,
    required this.onIncrement,
    required this.onDecrement,
  });

  @override
  State<CriterionScoreControl> createState() => _CriterionScoreControlState();
}

class _CriterionScoreControlState extends State<CriterionScoreControl> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.score.toString());
    _focusNode = FocusNode();

    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        // Auto-select text on focus so typing directly replaces the number
        _controller.selection = TextSelection(
          baseOffset: 0,
          extentOffset: _controller.text.length,
        );
      } else {
        // When focus is lost, normalize empty or invalid value to valid score
        if (_controller.text.isEmpty) {
          _controller.text = widget.score.toString();
        } else {
          final val = int.tryParse(_controller.text) ?? widget.score;
          final clamped = val.clamp(0, widget.maxScore);
          _controller.text = clamped.toString();
          if (clamped != widget.score) {
            widget.onScoreChanged(clamped);
          }
        }
        // Force visual update to remove focus highlight on outer box
        if (mounted) setState(() {});
      }
    });
  }

  @override
  void didUpdateWidget(covariant CriterionScoreControl oldWidget) {
    super.didUpdateWidget(oldWidget);
    // If score changed from outside (+/- stepper or reset) and user isn't actively typing
    if (oldWidget.score != widget.score && !_focusNode.hasFocus) {
      _controller.text = widget.score.toString();
    }
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _handleTextChanged(String val) {
    if (val.isEmpty) return; // Allow temporary empty state while typing

    final parsed = int.tryParse(val);
    if (parsed == null) return;

    if (parsed > widget.maxScore) {
      // Exceeds maxScore: clamp to maxScore and notify
      _controller.text = widget.maxScore.toString();
      _controller.selection = TextSelection.fromPosition(
        TextPosition(offset: _controller.text.length),
      );
      widget.onScoreChanged(widget.maxScore);
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Maximum score for ${widget.criteriaName} is ${widget.maxScore}'),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      final clamped = parsed.clamp(0, widget.maxScore);
      widget.onScoreChanged(clamped);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isReadOnly) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.softBlue.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Text(
          '${widget.score} / ${widget.maxScore} pts',
          style: AppTextStyles.titleMedium.copyWith(
            color: AppColors.primaryNavy,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }

    final bool canDecrement = widget.score > 0;
    final bool canIncrement = widget.score < widget.maxScore;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.softBlue.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _focusNode.hasFocus ? AppColors.primaryBlue : AppColors.borderLight,
          width: _focusNode.hasFocus ? 1.8 : 1.0,
        ),
        boxShadow: _focusNode.hasFocus
            ? [
                BoxShadow(
                  color: AppColors.primaryBlue.withValues(alpha: 0.08),
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                ),
              ]
            : null,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Decrement (-) Button
          IconButton(
            icon: const Icon(Icons.remove_rounded),
            iconSize: 22,
            tooltip: 'Decrease score',
            color: canDecrement ? AppColors.primaryNavy : AppColors.textSecondary.withValues(alpha: 0.35),
            constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
            padding: EdgeInsets.zero,
            onPressed: canDecrement
                ? () {
                    widget.onDecrement();
                    _controller.text = (widget.score - 1).clamp(0, widget.maxScore).toString();
                  }
                : null,
          ),

          // Direct Numeric Score Input (no inner box)
          SizedBox(
            width: 48,
            height: 44,
            child: Semantics(
              label: 'Score for ${widget.criteriaName}, maximum ${widget.maxScore}',
              child: TextField(
                controller: _controller,
                focusNode: _focusNode,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                style: AppTextStyles.titleMedium.copyWith(
                  color: AppColors.primaryNavy,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(4),
                ],
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 12),
                  isDense: true,
                ),
                onChanged: (val) {
                  _handleTextChanged(val);
                },
                onTap: () {
                  // Request visual state update to draw focused outer border
                  setState(() {});
                },
                onSubmitted: (val) {
                  _focusNode.unfocus();
                },
              ),
            ),
          ),

          // Increment (+) Button
          IconButton(
            icon: const Icon(Icons.add_rounded),
            iconSize: 22,
            tooltip: 'Increase score',
            color: canIncrement ? AppColors.primaryNavy : AppColors.textSecondary.withValues(alpha: 0.35),
            constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
            padding: EdgeInsets.zero,
            onPressed: canIncrement
                ? () {
                    widget.onIncrement();
                    _controller.text = (widget.score + 1).clamp(0, widget.maxScore).toString();
                  }
                : null,
          ),
        ],
      ),
    );
  }
}

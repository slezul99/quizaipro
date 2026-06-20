import 'package:flutter/material.dart';

import 'package:quizaipro_mobile/core/theme/aurora_tokens.dart';
import 'package:quizaipro_mobile/features/tests/domain/entities/test_option.dart';

enum AnswerOptionState { idle, selected, correct, incorrect }

class AnswerOptionWidget extends StatelessWidget {
  const AnswerOptionWidget({
    super.key,
    required this.option,
    required this.optionState,
    this.onTap,
  });

  final TestOption option;
  final AnswerOptionState optionState;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final aurora = context.aurora;
    final theme = Theme.of(context);

    final (bg, border, labelColor) = switch (optionState) {
      AnswerOptionState.idle => (
          aurora.backgroundSurface,
          aurora.borderDefault,
          aurora.textPrimary,
        ),
      AnswerOptionState.selected => (
          aurora.backgroundSurfaceElevated,
          aurora.brandGradientStart,
          aurora.brandGradientStart,
        ),
      AnswerOptionState.correct => (
          aurora.stateSuccessSurface,
          aurora.stateSuccess,
          aurora.stateSuccess,
        ),
      AnswerOptionState.incorrect => (
          aurora.stateErrorSurface,
          aurora.stateError,
          aurora.stateError,
        ),
    };

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        padding: EdgeInsets.symmetric(
          horizontal: aurora.space16,
          vertical: aurora.space12,
        ),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(aurora.radiusMd),
          border: Border.all(color: border, width: 1.5),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                option.text,
                style: theme.textTheme.bodyMedium?.copyWith(color: labelColor),
              ),
            ),
            if (optionState == AnswerOptionState.correct) ...[
              SizedBox(width: aurora.space8),
              Icon(Icons.check_circle_rounded, color: aurora.stateSuccess, size: 20),
            ] else if (optionState == AnswerOptionState.incorrect) ...[
              SizedBox(width: aurora.space8),
              Icon(Icons.cancel_rounded, color: aurora.stateError, size: 20),
            ],
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import 'package:quizaipro_mobile/core/theme/aurora_tokens.dart';
import 'package:quizaipro_mobile/features/tests/domain/entities/test_question.dart';

class QuestionCard extends StatelessWidget {
  const QuestionCard({
    super.key,
    required this.question,
    required this.questionNumber,
    required this.totalQuestions,
  });

  final TestQuestion question;
  final int questionNumber;
  final int totalQuestions;

  @override
  Widget build(BuildContext context) {
    final aurora = context.aurora;
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(aurora.space20),
      decoration: BoxDecoration(
        color: aurora.backgroundSurface,
        borderRadius: BorderRadius.circular(aurora.radiusLg),
        border: Border.all(color: aurora.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (question.topic != null) ...[
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: aurora.space8,
                vertical: aurora.space4,
              ),
              decoration: BoxDecoration(
                color: aurora.backgroundSurfaceElevated,
                borderRadius: BorderRadius.circular(aurora.radiusSm),
              ),
              child: Text(
                question.topic!,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: aurora.textTertiary,
                ),
              ),
            ),
            SizedBox(height: aurora.space12),
          ],
          Text(
            question.question,
            style: theme.textTheme.titleMedium?.copyWith(
              color: aurora.textPrimary,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

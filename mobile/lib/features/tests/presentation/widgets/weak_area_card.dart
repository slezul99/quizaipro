import 'package:flutter/material.dart';

import 'package:quizaipro_mobile/core/theme/aurora_tokens.dart';
import 'package:quizaipro_mobile/features/tests/domain/entities/weak_area.dart';
import 'package:quizaipro_mobile/l10n/app_localizations.dart';

class WeakAreaCard extends StatelessWidget {
  const WeakAreaCard({super.key, required this.weakArea});

  final WeakArea weakArea;

  @override
  Widget build(BuildContext context) {
    final aurora = context.aurora;
    final theme = Theme.of(context);
    final pct = weakArea.accuracyPct;

    return Container(
      padding: EdgeInsets.all(aurora.space16),
      decoration: BoxDecoration(
        color: aurora.stateWarningSurface,
        borderRadius: BorderRadius.circular(aurora.radiusMd),
        border: Border.all(color: aurora.stateWarning.withOpacity(0.4)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.warning_amber_rounded,
            color: aurora.stateWarning,
            size: 20,
          ),
          SizedBox(width: aurora.space12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  weakArea.topic,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: aurora.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: aurora.space4),
                Text(
                  AppLocalizations.of(context)!.testsScoreFraction(
                    weakArea.correctAnswers,
                    weakArea.totalQuestions,
                  ),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: aurora.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: aurora.space8,
              vertical: aurora.space4,
            ),
            decoration: BoxDecoration(
              color: aurora.stateWarning.withOpacity(0.15),
              borderRadius: BorderRadius.circular(aurora.radiusSm),
            ),
            child: Text(
              '$pct%',
              style: theme.textTheme.labelMedium?.copyWith(
                color: aurora.stateWarning,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

import 'package:quizaipro_mobile/core/theme/aurora_tokens.dart';
import 'package:quizaipro_mobile/features/ai_generation/domain/entities/quality_mode.dart';
import 'package:quizaipro_mobile/l10n/app_localizations.dart';

class QualityModeSelector extends StatelessWidget {
  const QualityModeSelector({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  final QualityMode selected;
  final ValueChanged<QualityMode> onChanged;

  @override
  Widget build(BuildContext context) {
    final aurora = context.aurora;
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context).aiStudioQualityLabel,
          style:
              theme.textTheme.labelMedium?.copyWith(color: aurora.textSecondary),
        ),
        SizedBox(height: aurora.space8),
        Row(
          children: QualityMode.values.map((mode) {
            final isSelected = mode == selected;
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  right: mode != QualityMode.premium ? aurora.space8 : 0,
                ),
                child: GestureDetector(
                  onTap: () => onChanged(mode),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: EdgeInsets.symmetric(
                      vertical: aurora.space12,
                      horizontal: aurora.space8,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? aurora.brandGradientStart.withOpacity(0.12)
                          : aurora.backgroundSurface,
                      border: Border.all(
                        color: isSelected
                            ? aurora.brandGradientStart
                            : aurora.borderDefault,
                        width: isSelected ? 1.5 : 1,
                      ),
                      borderRadius: BorderRadius.circular(aurora.radiusMd),
                    ),
                    child: Column(
                      children: [
                        Text(
                          switch (mode) {
                            QualityMode.fast => AppLocalizations.of(context).aiStudioQualityFast,
                            QualityMode.balanced => AppLocalizations.of(context).aiStudioQualityBalanced,
                            QualityMode.premium => AppLocalizations.of(context).aiStudioQualityPremium,
                          },
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: isSelected
                                ? aurora.brandGradientStart
                                : aurora.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: aurora.space2),
                        Text(
                          switch (mode) {
                            QualityMode.fast => AppLocalizations.of(context).aiStudioQualityFastDescription,
                            QualityMode.balanced => AppLocalizations.of(context).aiStudioQualityBalancedDescription,
                            QualityMode.premium => AppLocalizations.of(context).aiStudioQualityPremiumDescription,
                          },
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: aurora.textSecondary,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

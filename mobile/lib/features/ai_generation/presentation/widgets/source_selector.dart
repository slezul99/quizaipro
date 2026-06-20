import 'package:flutter/material.dart';

import 'package:quizaipro_mobile/core/theme/aurora_tokens.dart';
import 'package:quizaipro_mobile/features/ai_generation/domain/entities/generation_source.dart';
import 'package:quizaipro_mobile/l10n/app_localizations.dart';

class SourceSelector extends StatelessWidget {
  const SourceSelector({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  final GenerationSource selected;
  final ValueChanged<GenerationSource> onChanged;

  @override
  Widget build(BuildContext context) {
    final aurora = context.aurora;
    final theme = Theme.of(context);

    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: aurora.backgroundSurface,
        borderRadius: BorderRadius.circular(aurora.radiusMd),
      ),
      child: Row(
        children: GenerationSource.values.map((source) {
          final isSelected = source == selected;
          return Expanded(
            child: GestureDetector(
              onTap: () => onChanged(source),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: EdgeInsets.all(aurora.space4),
                decoration: BoxDecoration(
                  color: isSelected
                      ? aurora.backgroundSurfaceElevated
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(aurora.radiusSm),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 4,
                            offset: const Offset(0, 1),
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      source.icon,
                      size: 16,
                      color: isSelected
                          ? aurora.brandGradientStart
                          : aurora.textSecondary,
                    ),
                    SizedBox(width: aurora.space4),
                    Text(
                      switch (source) {
                        GenerationSource.topic => AppLocalizations.of(context).aiStudioSourceTopic,
                        GenerationSource.text => AppLocalizations.of(context).aiStudioSourceText,
                        GenerationSource.pdf => AppLocalizations.of(context).aiStudioSourcePdf,
                      },
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: isSelected
                            ? aurora.brandGradientStart
                            : aurora.textSecondary,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

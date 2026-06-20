import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:quizaipro_mobile/core/theme/aurora_tokens.dart';
import 'package:quizaipro_mobile/features/ai_generation/domain/entities/generation_job.dart';
import 'package:quizaipro_mobile/features/ai_generation/domain/entities/generation_source.dart';
import 'package:quizaipro_mobile/features/ai_generation/domain/entities/generation_status.dart';
import 'package:quizaipro_mobile/features/ai_generation/domain/entities/quality_mode.dart';
import 'package:quizaipro_mobile/l10n/app_localizations.dart';

class GenerationHistoryTile extends StatelessWidget {
  const GenerationHistoryTile({
    super.key,
    required this.job,
    required this.onTap,
  });

  final GenerationJob job;
  final VoidCallback? onTap;

  IconData get _sourceIcon => switch (job.source) {
        GenerationSource.topic => Icons.lightbulb_outline_rounded,
        GenerationSource.text => Icons.text_fields_rounded,
        GenerationSource.pdf => Icons.picture_as_pdf_rounded,
      };

  Color _statusColor(AuroraTokens aurora) => switch (job.status) {
        GenerationStatus.completed => aurora.stateSuccess,
        GenerationStatus.failed => aurora.stateError,
        GenerationStatus.cancelled => aurora.textSecondary,
        _ => aurora.stateInfo,
      };

  String _statusLabel(BuildContext context) => switch (job.status) {
        GenerationStatus.completed => AppLocalizations.of(context).aiStudioCardsCount(job.cards.length),
        GenerationStatus.failed => AppLocalizations.of(context).aiStudioStatusFailed,
        GenerationStatus.cancelled => AppLocalizations.of(context).aiStudioStatusCancelled,
        GenerationStatus.pending => AppLocalizations.of(context).aiStudioStatusPending,
        GenerationStatus.processing => AppLocalizations.of(context).aiStudioStatusProcessing,
      };

  @override
  Widget build(BuildContext context) {
    final aurora = context.aurora;
    final theme = Theme.of(context);
    final dateStr = DateFormat('MMM d, HH:mm').format(job.createdAt.toLocal());

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: aurora.space12),
        padding: EdgeInsets.all(aurora.space16),
        decoration: BoxDecoration(
          color: aurora.backgroundSurface,
          borderRadius: BorderRadius.circular(aurora.radiusMd),
          border: Border.all(color: aurora.borderDefault),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: aurora.brandGradientStart.withOpacity(0.1),
                borderRadius: BorderRadius.circular(aurora.radiusSm),
              ),
              child: Icon(_sourceIcon,
                  color: aurora.brandGradientStart, size: 20),
            ),
            SizedBox(width: aurora.space12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    switch (job.source) {
                      GenerationSource.topic => AppLocalizations.of(context).aiStudioSourceTopic,
                      GenerationSource.text => AppLocalizations.of(context).aiStudioSourceText,
                      GenerationSource.pdf => AppLocalizations.of(context).aiStudioSourcePdf,
                    },
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: aurora.textPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: aurora.space2),
                  Text(
                    '${switch (job.qualityMode) {
                      QualityMode.fast => AppLocalizations.of(context).aiStudioQualityFast,
                      QualityMode.balanced => AppLocalizations.of(context).aiStudioQualityBalanced,
                      QualityMode.premium => AppLocalizations.of(context).aiStudioQualityPremium,
                    }} · $dateStr',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: aurora.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: aurora.space8),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: aurora.space8,
                vertical: aurora.space4,
              ),
              decoration: BoxDecoration(
                color: _statusColor(aurora).withOpacity(0.12),
                borderRadius: BorderRadius.circular(aurora.radiusFull),
              ),
              child: Text(
                _statusLabel(context),
                style: theme.textTheme.labelSmall?.copyWith(
                  color: _statusColor(aurora),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

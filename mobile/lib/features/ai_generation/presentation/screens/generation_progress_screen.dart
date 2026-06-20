import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:quizaipro_mobile/core/router/app_routes.dart';
import 'package:quizaipro_mobile/core/theme/aurora_tokens.dart';
import 'package:quizaipro_mobile/l10n/app_localizations.dart';
import 'package:quizaipro_mobile/features/ai_generation/domain/entities/generation_source.dart';
import 'package:quizaipro_mobile/features/ai_generation/domain/entities/generation_status.dart';
import 'package:quizaipro_mobile/features/ai_generation/domain/entities/quality_mode.dart';
import 'package:quizaipro_mobile/features/ai_generation/presentation/providers/generation_job_notifier.dart';
import 'package:quizaipro_mobile/features/ai_generation/presentation/widgets/generation_progress_widget.dart';

class GenerationProgressScreen extends ConsumerWidget {
  const GenerationProgressScreen({super.key, required this.jobId});

  final String jobId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final aurora = context.aurora;
    final theme = Theme.of(context);

    ref.listen(
      generationJobNotifierProvider(jobId: jobId),
      (_, next) {
        next.whenData((job) {
          if (job.isCompleted) {
            context.pushReplacementNamed(
              AppRoutes.aiGenerationResultsName,
              queryParameters: {'jobId': jobId},
            );
          }
        });
      },
    );

    final jobAsync = ref.watch(generationJobNotifierProvider(jobId: jobId));

    return Scaffold(
      backgroundColor: aurora.backgroundCanvas,
      appBar: AppBar(
        backgroundColor: aurora.backgroundCanvas,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          AppLocalizations.of(context).aiProgressTitle,
          style: theme.textTheme.titleMedium
              ?.copyWith(color: aurora.textPrimary),
        ),
      ),
      body: jobAsync.when(
        loading: () => Center(
          child: GenerationProgressWidget(
            status: GenerationStatus.pending,
            progress: 0,
          ),
        ),
        error: (error, _) => Center(
          child: Padding(
            padding: EdgeInsets.all(aurora.space32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.error_outline_rounded,
                    color: aurora.stateError, size: 48),
                SizedBox(height: aurora.space16),
                Text(
                  error.toString(),
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(color: aurora.textSecondary),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: aurora.space24),
                TextButton(
                  onPressed: () => context.pop(),
                  child: Text(
                    AppLocalizations.of(context).aiProgressGoBack,
                    style: theme.textTheme.titleSmall?.copyWith(
                        color: aurora.brandGradientStart),
                  ),
                ),
              ],
            ),
          ),
        ),
        data: (job) => Center(
          child: Padding(
            padding: EdgeInsets.all(aurora.space32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GenerationProgressWidget(
                  status: job.status,
                  progress: job.progress,
                ),
                SizedBox(height: aurora.space32),
                Text(
                  AppLocalizations.of(context).aiProgressFrom(
                    switch (job.source) {
                      GenerationSource.topic => AppLocalizations.of(context).aiStudioSourceTopic,
                      GenerationSource.text => AppLocalizations.of(context).aiStudioSourceText,
                      GenerationSource.pdf => AppLocalizations.of(context).aiStudioSourcePdf,
                    }
                  ),
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: aurora.textPrimary,
                  ),
                ),
                SizedBox(height: aurora.space8),
                Text(
                  AppLocalizations.of(context).aiProgressQuality(
                    job.requestedCardCount,
                    switch (job.qualityMode) {
                      QualityMode.fast => AppLocalizations.of(context).aiStudioQualityFast,
                      QualityMode.balanced => AppLocalizations.of(context).aiStudioQualityBalanced,
                      QualityMode.premium => AppLocalizations.of(context).aiStudioQualityPremium,
                    }
                  ),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: aurora.textTertiary,
                  ),
                ),
                if (job.status == GenerationStatus.failed) ...[
                  SizedBox(height: aurora.space32),
                  Container(
                    padding: EdgeInsets.all(aurora.space16),
                    decoration: BoxDecoration(
                      color: aurora.stateErrorSurface,
                      borderRadius: BorderRadius.circular(aurora.radiusMd),
                    ),
                    child: Text(
                      job.errorMessage ?? AppLocalizations.of(context).aiProgressFailed,
                      style: theme.textTheme.bodySmall
                          ?.copyWith(color: aurora.stateError),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(height: aurora.space16),
                  OutlinedButton(
                    onPressed: () => context.pop(),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: aurora.borderDefault),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(aurora.radiusMd),
                      ),
                    ),
                    child: Text(
                      AppLocalizations.of(context).aiProgressGoBack,
                      style: theme.textTheme.bodyMedium
                          ?.copyWith(color: aurora.textPrimary),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:quizaipro_mobile/core/router/app_routes.dart';
import 'package:quizaipro_mobile/core/theme/aurora_tokens.dart';
import 'package:quizaipro_mobile/l10n/app_localizations.dart';
import 'package:quizaipro_mobile/features/ai_generation/domain/entities/generation_status.dart';
import 'package:quizaipro_mobile/features/ai_generation/presentation/providers/generation_history_notifier.dart';
import 'package:quizaipro_mobile/features/ai_generation/presentation/widgets/generation_history_tile.dart';

class GenerationHistoryScreen extends ConsumerWidget {
  const GenerationHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final aurora = context.aurora;
    final theme = Theme.of(context);
    final historyAsync = ref.watch(generationHistoryProvider);

    return Scaffold(
      backgroundColor: aurora.backgroundCanvas,
      appBar: AppBar(
        backgroundColor: aurora.backgroundCanvas,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded,
              color: aurora.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: Text(
          AppLocalizations.of(context).aiHistoryTitle,
          style: theme.textTheme.titleMedium
              ?.copyWith(color: aurora.textPrimary),
        ),
      ),
      body: historyAsync.when(
        loading: () => Center(
          child: CircularProgressIndicator(color: aurora.brandGradientStart),
        ),
        error: (e, _) => Center(
          child: Padding(
            padding: EdgeInsets.all(aurora.space32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.error_outline_rounded,
                    color: aurora.stateError, size: 48),
                SizedBox(height: aurora.space16),
                Text(
                  e.toString(),
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(color: aurora.textSecondary),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: aurora.space20),
                TextButton(
                  onPressed: () =>
                      ref.invalidate(generationHistoryProvider),
                  child: Text(AppLocalizations.of(context).retry,
                      style: theme.textTheme.bodyMedium
                          ?.copyWith(color: aurora.brandGradientStart)),
                ),
              ],
            ),
          ),
        ),
        data: (jobs) {
          if (jobs.isEmpty) {
            return Center(
              child: Padding(
                padding: EdgeInsets.all(aurora.space32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: aurora.backgroundSurface,
                      ),
                      child: Icon(Icons.history_rounded,
                          size: 32, color: aurora.textSecondary),
                    ),
                    SizedBox(height: aurora.space20),
                    Text(
                      AppLocalizations.of(context).aiHistoryEmpty,
                      style: theme.textTheme.titleMedium
                          ?.copyWith(color: aurora.textPrimary),
                    ),
                    SizedBox(height: aurora.space8),
                    Text(
                      AppLocalizations.of(context).aiHistoryEmptySubtitle,
                      style: theme.textTheme.bodySmall
                          ?.copyWith(color: aurora.textSecondary),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }

          return RefreshIndicator(
            color: aurora.brandGradientStart,
            onRefresh: () async =>
                ref.invalidate(generationHistoryProvider),
            child: ListView.builder(
              padding: EdgeInsets.all(aurora.space16),
              itemCount: jobs.length,
              itemBuilder: (_, i) {
                final job = jobs[i];
                return GenerationHistoryTile(
                  job: job,
                  onTap: job.status == GenerationStatus.completed
                      ? () => context.pushNamed(
                            AppRoutes.aiGenerationResultsName,
                            queryParameters: {'jobId': job.id},
                          )
                      : null,
                );
              },
            ),
          );
        },
      ),
    );
  }
}

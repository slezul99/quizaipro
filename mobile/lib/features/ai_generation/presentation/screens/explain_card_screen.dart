import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:quizaipro_mobile/core/theme/aurora_tokens.dart';
import 'package:quizaipro_mobile/l10n/app_localizations.dart';
import 'package:quizaipro_mobile/features/ai_generation/presentation/providers/explain_card_notifier.dart';

class ExplainCardScreen extends ConsumerStatefulWidget {
  const ExplainCardScreen({
    super.key,
    required this.question,
    required this.answer,
    this.deckId,
  });

  final String question;
  final String answer;
  final String? deckId;

  @override
  ConsumerState<ExplainCardScreen> createState() => _ExplainCardScreenState();
}

class _ExplainCardScreenState extends ConsumerState<ExplainCardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(explainCardNotifierProvider(
            question: widget.question,
            answer: widget.answer,
            deckId: widget.deckId,
          ).notifier)
          .explain();
    });
  }

  @override
  Widget build(BuildContext context) {
    final aurora = context.aurora;
    final theme = Theme.of(context);

    final provider = explainCardNotifierProvider(
      question: widget.question,
      answer: widget.answer,
      deckId: widget.deckId,
    );

    final explanationAsync = ref.watch(provider);

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
          AppLocalizations.of(context).aiExplainTitle,
          style: theme.textTheme.titleMedium
              ?.copyWith(color: aurora.textPrimary),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(aurora.space20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Card content
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(aurora.space16),
              decoration: BoxDecoration(
                color: aurora.backgroundSurface,
                borderRadius: BorderRadius.circular(aurora.radiusMd),
                border: Border.all(color: aurora.borderDefault),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(context).aiExplainQuestion,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: aurora.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: aurora.space8),
                  Text(
                    widget.question,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: aurora.textPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: aurora.space12),
                  Container(height: 1, color: aurora.borderSubtle),
                  SizedBox(height: aurora.space12),
                  Text(
                    AppLocalizations.of(context).aiExplainAnswer,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: aurora.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: aurora.space8),
                  Text(
                    widget.answer,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: aurora.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: aurora.space24),

            // AI Explanation
            Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(colors: [
                      aurora.brandGradientStart,
                      aurora.brandGradientEnd,
                    ]),
                  ),
                  child: const Icon(Icons.auto_awesome_rounded,
                      color: Colors.white, size: 14),
                ),
                SizedBox(width: aurora.space8),
                Text(
                  AppLocalizations.of(context).aiExplainExplanation,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: aurora.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            SizedBox(height: aurora.space16),

            explanationAsync.when(
              loading: () => Column(
                children: [
                  Center(
                    child: CircularProgressIndicator(
                        color: aurora.brandGradientStart),
                  ),
                  SizedBox(height: aurora.space16),
                  Text(
                    AppLocalizations.of(context).aiExplainLoading,
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(color: aurora.textSecondary),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
              error: (error, _) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.all(aurora.space16),
                    decoration: BoxDecoration(
                      color: aurora.stateErrorSurface,
                      borderRadius: BorderRadius.circular(aurora.radiusMd),
                    ),
                    child: Text(
                      error.toString(),
                      style: theme.textTheme.bodySmall
                          ?.copyWith(color: aurora.stateError),
                    ),
                  ),
                  SizedBox(height: aurora.space16),
                  TextButton.icon(
                    onPressed: () => ref
                        .read(provider.notifier)
                        .explain(),
                    icon: Icon(Icons.refresh_rounded,
                        color: aurora.brandGradientStart, size: 16),
                    label: Text(
                      AppLocalizations.of(context).aiExplainRetry,
                      style: theme.textTheme.bodyMedium
                          ?.copyWith(color: aurora.brandGradientStart),
                    ),
                  ),
                ],
              ),
              data: (explanation) => Container(
                width: double.infinity,
                padding: EdgeInsets.all(aurora.space20),
                decoration: BoxDecoration(
                  color: aurora.backgroundSurface,
                  borderRadius: BorderRadius.circular(aurora.radiusMd),
                  border: Border.all(color: aurora.borderDefault),
                ),
                child: Text(
                  explanation,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: aurora.textPrimary,
                    height: 1.7,
                  ),
                ),
              ),
            ),
            SizedBox(height: aurora.space32),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:quizaipro_mobile/core/theme/aurora_tokens.dart';
import 'package:quizaipro_mobile/features/tests/domain/entities/test_history_item.dart';
import 'package:quizaipro_mobile/features/tests/presentation/providers/test_history_notifier.dart';
import 'package:quizaipro_mobile/features/tests/presentation/widgets/test_shimmer.dart';
import 'package:quizaipro_mobile/l10n/app_localizations.dart';

class TestHistoryScreen extends ConsumerWidget {
  const TestHistoryScreen({
    super.key,
    required this.deckId,
    required this.deckTitle,
  });

  final String deckId;
  final String deckTitle;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(testHistoryProvider(deckId: deckId));
    final aurora = context.aurora;
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: aurora.backgroundCanvas,
      appBar: AppBar(
        backgroundColor: aurora.backgroundCanvas,
        elevation: 0,
        title: Text(
          l10n.testsHistoryTitle,
          style: theme.textTheme.titleMedium?.copyWith(color: aurora.textPrimary),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: aurora.textPrimary),
          onPressed: () => context.pop(),
        ),
      ),
      body: historyAsync.when(
        loading: () => const TestShimmer(),
        error: (err, _) => Center(
          child: Padding(
            padding: EdgeInsets.all(aurora.space20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.error_outline, size: 48, color: aurora.stateError),
                SizedBox(height: aurora.space16),
                Text(
                  l10n.testsHistoryLoadError,
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(color: aurora.textPrimary),
                ),
                SizedBox(height: aurora.space8),
                TextButton(
                  onPressed: () =>
                      ref.invalidate(testHistoryProvider(deckId: deckId)),
                  child: Text(l10n.testsRetry),
                ),
              ],
            ),
          ),
        ),
        data: (items) => items.isEmpty
            ? Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.history_rounded,
                      size: 64,
                      color: aurora.textTertiary,
                    ),
                    SizedBox(height: aurora.space16),
                    Text(
                      l10n.testsHistoryEmpty,
                      style: theme.textTheme.bodyLarge
                          ?.copyWith(color: aurora.textSecondary),
                    ),
                    SizedBox(height: aurora.space8),
                    Text(
                      l10n.testsHistoryEmptySubtitle,
                      style: theme.textTheme.bodySmall
                          ?.copyWith(color: aurora.textTertiary),
                    ),
                  ],
                ),
              )
            : ListView.separated(
                padding: EdgeInsets.all(aurora.space20),
                itemCount: items.length,
                separatorBuilder: (_, __) => SizedBox(height: aurora.space12),
                itemBuilder: (ctx, i) =>
                    _HistoryItemCard(item: items[i]),
              ),
      ),
    );
  }
}

class _HistoryItemCard extends StatelessWidget {
  const _HistoryItemCard({required this.item});
  final TestHistoryItem item;

  Color _scoreColor(AuroraTokens aurora) {
    if (item.scorePct >= 80) return aurora.stateSuccess;
    if (item.scorePct >= 60) return aurora.stateWarning;
    return aurora.stateError;
  }

  @override
  Widget build(BuildContext context) {
    final aurora = context.aurora;
    final theme = Theme.of(context);
    final scoreColor = _scoreColor(aurora);
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: EdgeInsets.all(aurora.space16),
      decoration: BoxDecoration(
        color: aurora.backgroundSurface,
        borderRadius: BorderRadius.circular(aurora.radiusMd),
        border: Border.all(color: aurora.borderSubtle),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: scoreColor.withOpacity(0.12),
              border: Border.all(color: scoreColor, width: 2),
            ),
            alignment: Alignment.center,
            child: Text(
              '${item.scorePct}%',
              style: theme.textTheme.labelLarge?.copyWith(
                color: scoreColor,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          SizedBox(width: aurora.space16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.testsScoreFraction(item.correctCount, item.totalQuestions),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: aurora.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: aurora.space4),
                Text(
                  _formatDate(item.completedAt),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: aurora.textTertiary,
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
              color: aurora.backgroundSurfaceElevated,
              borderRadius: BorderRadius.circular(aurora.radiusSm),
            ),
            child: Text(
              _formatDuration(l10n, item.durationSeconds),
              style: theme.textTheme.labelSmall?.copyWith(
                color: aurora.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.day.toString().padLeft(2, '0')}.'
        '${dt.month.toString().padLeft(2, '0')}.'
        '${dt.year}';
  }

  String _formatDuration(AppLocalizations l10n, int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return m == 0
        ? l10n.testsSecondsShort(s)
        : l10n.testsMinutesSecondsShort(m, s);
  }
}

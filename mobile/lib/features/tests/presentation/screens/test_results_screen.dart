import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:quizaipro_mobile/core/router/app_routes.dart';
import 'package:quizaipro_mobile/core/theme/aurora_tokens.dart';
import 'package:quizaipro_mobile/features/tests/domain/entities/test_result.dart';
import 'package:quizaipro_mobile/features/tests/presentation/providers/test_session_notifier.dart';
import 'package:quizaipro_mobile/features/tests/presentation/providers/test_session_state.dart';
import 'package:quizaipro_mobile/features/tests/presentation/widgets/weak_area_card.dart';
import 'package:quizaipro_mobile/l10n/app_localizations.dart';

class TestResultsScreen extends ConsumerWidget {
  const TestResultsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(testSessionNotifierProvider);
    final notifier = ref.read(testSessionNotifierProvider.notifier);

    if (state is! TestSessionStateCompleted) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final result = state.result;
    final aurora = context.aurora;
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: aurora.backgroundCanvas,
      appBar: AppBar(
        backgroundColor: aurora.backgroundCanvas,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          l10n.testsResultsTitle,
          style: theme.textTheme.titleMedium?.copyWith(color: aurora.textPrimary),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.close_rounded, color: aurora.textPrimary),
            onPressed: () {
              notifier.reset();
              context.go(AppRoutes.library);
            },
          ),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.all(aurora.space20),
        children: [
          _ScoreCard(result: result),
          SizedBox(height: aurora.space24),
          _StatsRow(result: result),
          SizedBox(height: aurora.space24),
          if (result.weakAreas.isNotEmpty) ...[
            Text(
              l10n.testsWeakAreas,
              style: theme.textTheme.titleSmall?.copyWith(
                color: aurora.textPrimary,
              ),
            ),
            SizedBox(height: aurora.space12),
            ...result.weakAreas.map(
              (w) => Padding(
                padding: EdgeInsets.only(bottom: aurora.space8),
                child: WeakAreaCard(weakArea: w),
              ),
            ),
            SizedBox(height: aurora.space24),
          ],
          _ActionButtons(
            result: result,
            onReview: () => context.pushNamed(AppRoutes.testReviewName),
            onTryAgain: () async {
              notifier.reset();
              await ref.read(testSessionNotifierProvider.notifier).startTest(
                    deckId: result.deckId,
                    deckTitle: result.deckTitle,
                    config: result.config,
                    emptyMessage: l10n.testsNoQuestions,
                  );
              if (context.mounted) {
                context.pushReplacementNamed(AppRoutes.testSessionName);
              }
            },
            onHistory: () => context.pushNamed(
              AppRoutes.testHistoryName,
              queryParameters: {
                'deckId': result.deckId,
                'deckTitle': result.deckTitle,
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ScoreCard extends StatelessWidget {
  const _ScoreCard({required this.result});
  final TestResult result;

  Color _scoreColor(AuroraTokens aurora) {
    if (result.scorePct >= 80) return aurora.stateSuccess;
    if (result.scorePct >= 60) return aurora.stateWarning;
    return aurora.stateError;
  }

  @override
  Widget build(BuildContext context) {
    final aurora = context.aurora;
    final theme = Theme.of(context);
    final scoreColor = _scoreColor(aurora);
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: EdgeInsets.all(aurora.space24),
      decoration: BoxDecoration(
        color: aurora.backgroundSurface,
        borderRadius: BorderRadius.circular(aurora.radiusXl),
        border: Border.all(color: aurora.borderSubtle),
      ),
      child: Column(
        children: [
          Text(
            result.deckTitle,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: aurora.textSecondary,
            ),
          ),
          SizedBox(height: aurora.space16),
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: scoreColor.withOpacity(0.12),
              border: Border.all(color: scoreColor, width: 3),
            ),
            alignment: Alignment.center,
            child: Text(
              '${result.scorePct}%',
              style: theme.textTheme.headlineMedium?.copyWith(
                color: scoreColor,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          SizedBox(height: aurora.space16),
          Text(
            _scoreLabel(l10n, result.scorePct),
            style: theme.textTheme.titleMedium?.copyWith(
              color: aurora.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: aurora.space4),
          Text(
            l10n.testsCorrectOfTotal(result.correctCount, result.totalQuestions),
            style: theme.textTheme.bodySmall?.copyWith(
              color: aurora.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  String _scoreLabel(AppLocalizations l10n, int pct) {
    if (pct >= 90) return l10n.testsScoreExcellent;
    if (pct >= 80) return l10n.testsScoreGreat;
    if (pct >= 60) return l10n.testsScoreGood;
    if (pct >= 40) return l10n.testsScorePractice;
    return l10n.testsScoreStudy;
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow({required this.result});
  final TestResult result;

  @override
  Widget build(BuildContext context) {
    final aurora = context.aurora;
    final l10n = AppLocalizations.of(context)!;
    return Row(
      children: [
        _StatCell(
          label: l10n.testsCorrect,
          value: '${result.correctCount}',
          color: aurora.stateSuccess,
        ),
        SizedBox(width: aurora.space12),
        _StatCell(
          label: l10n.testsWrong,
          value: '${result.wrongCount}',
          color: aurora.stateError,
        ),
        SizedBox(width: aurora.space12),
        _StatCell(
          label: l10n.testsDuration,
          value: _formatDuration(l10n, result.durationSeconds),
          color: aurora.brandGradientStart,
        ),
      ],
    );
  }

  String _formatDuration(AppLocalizations l10n, int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return m == 0
        ? l10n.testsSecondsShort(s)
        : l10n.testsMinutesSecondsShort(m, s);
  }
}

class _StatCell extends StatelessWidget {
  const _StatCell({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final aurora = context.aurora;
    final theme = Theme.of(context);
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: aurora.space16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(aurora.radiusMd),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: theme.textTheme.titleLarge?.copyWith(
                color: color,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: aurora.space4),
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: aurora.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionButtons extends StatelessWidget {
  const _ActionButtons({
    required this.result,
    required this.onReview,
    required this.onTryAgain,
    required this.onHistory,
  });

  final TestResult result;
  final VoidCallback onReview;
  final VoidCallback onTryAgain;
  final VoidCallback onHistory;

  @override
  Widget build(BuildContext context) {
    final aurora = context.aurora;
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Column(
      children: [
        GestureDetector(
          onTap: onReview,
          child: Container(
            height: 52,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [aurora.brandGradientStart, aurora.brandGradientEnd],
              ),
              borderRadius: BorderRadius.circular(aurora.radiusMd),
            ),
            alignment: Alignment.center,
            child: Text(
              l10n.testsReviewAnswers,
              style: theme.textTheme.titleSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        SizedBox(height: aurora.space12),
        OutlinedButton(
          onPressed: onTryAgain,
          style: OutlinedButton.styleFrom(
            minimumSize: const Size.fromHeight(52),
            side: BorderSide(color: aurora.brandGradientStart),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(aurora.radiusMd),
            ),
          ),
          child: Text(
            l10n.testsTryAgain,
            style: theme.textTheme.titleSmall?.copyWith(
              color: aurora.brandGradientStart,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        SizedBox(height: aurora.space12),
        TextButton(
          onPressed: onHistory,
          child: Text(
            l10n.testsViewHistory,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: aurora.textSecondary,
            ),
          ),
        ),
      ],
    );
  }
}

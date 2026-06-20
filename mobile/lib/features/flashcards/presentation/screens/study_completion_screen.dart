import 'package:flutter/material.dart';
import 'package:quizaipro_mobile/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:quizaipro_mobile/core/theme/aurora_tokens.dart';
import 'package:quizaipro_mobile/features/flashcards/domain/entities/session_stats.dart';
import 'package:quizaipro_mobile/features/dashboard/presentation/providers/dashboard_notifier.dart';

class StudyCompletionScreen extends ConsumerWidget {
  const StudyCompletionScreen({
    super.key,
    required this.stats,
    required this.deckTitle,
    required this.onStudyAgain,
  });

  final SessionStats stats;
  final String deckTitle;
  final VoidCallback onStudyAgain;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final tokens = context.aurora;
    final tt = Theme.of(context).textTheme;

    final retentionPct = (stats.retentionRate * 100).round();
    final elapsed = _formatDuration(stats.elapsed);

    return Scaffold(
      backgroundColor: tokens.backgroundCanvas,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: tokens.space24,
            vertical: tokens.space32,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Trophy icon
              Center(
                child: Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    gradient: tokens.brandGradient,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.emoji_events_rounded,
                    color: Colors.white,
                    size: 48,
                  ),
                ),
              ),
              SizedBox(height: tokens.space24),

              // Title
              Text(
                l10n.flashcardsSessionComplete,
                style: tt.headlineSmall?.copyWith(
                  color: tokens.textPrimary,
                  fontWeight: FontWeight.w800,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: tokens.space4),
              Text(
                deckTitle,
                style: tt.bodyLarge
                    ?.copyWith(color: tokens.textSecondary),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: tokens.space32),

              // Stats card
              Container(
                padding: EdgeInsets.all(tokens.space20),
                decoration: BoxDecoration(
                  color: tokens.backgroundSurface,
                  borderRadius: BorderRadius.circular(tokens.radiusXl),
                  border: Border.all(color: tokens.borderDefault),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.flashcardsSessionStats,
                      style: tt.titleSmall?.copyWith(
                        color: tokens.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: tokens.space16),
                    _StatRow(
                      icon: Icons.layers_rounded,
                      label: l10n.flashcardsCardsStudied,
                      value: '${stats.reviewed}',
                      color: tokens.brandGradientStart,
                    ),
                    _StatRow(
                      icon: Icons.star_outline_rounded,
                      label: l10n.flashcardsNewCards,
                      value: '${stats.newCount}',
                      color: tokens.stateInfo,
                    ),
                    _StatRow(
                      icon: Icons.replay_rounded,
                      label: l10n.flashcardsReviewCards,
                      value: '${stats.reviewCount}',
                      color: tokens.stateWarning,
                    ),
                    _StatRow(
                      icon: Icons.shield_outlined,
                      label: l10n.flashcardsRetention,
                      value: '$retentionPct%',
                      color: tokens.stateSuccess,
                    ),
                    _StatRow(
                      icon: Icons.timer_outlined,
                      label: l10n.flashcardsTimeSpent,
                      value: elapsed,
                      color: tokens.textSecondary,
                    ),
                  ],
                ),
              ),
              SizedBox(height: tokens.space20),

              // Grade breakdown
              Container(
                padding: EdgeInsets.all(tokens.space20),
                decoration: BoxDecoration(
                  color: tokens.backgroundSurface,
                  borderRadius: BorderRadius.circular(tokens.radiusXl),
                  border: Border.all(color: tokens.borderDefault),
                ),
                child: Row(
                  children: [
                    _GradeChip(
                      label: l10n.flashcardsAgain,
                      count: stats.againCount,
                      color: tokens.stateError,
                      bg: tokens.stateErrorSurface,
                    ),
                    _GradeChip(
                      label: l10n.flashcardsHard,
                      count: stats.hardCount,
                      color: tokens.stateWarning,
                      bg: tokens.stateWarningSurface,
                    ),
                    _GradeChip(
                      label: l10n.flashcardsGood,
                      count: stats.goodCount,
                      color: tokens.stateSuccess,
                      bg: tokens.stateSuccessSurface,
                    ),
                    _GradeChip(
                      label: l10n.flashcardsEasy,
                      count: stats.easyCount,
                      color: tokens.brandGradientStart,
                      bg: tokens.stateInfoSurface,
                    ),
                  ],
                ),
              ),
              SizedBox(height: tokens.space32),

              FilledButton(
                onPressed: () {
                  ref.invalidate(dashboardNotifierProvider);
                  onStudyAgain();
                },
                style: FilledButton.styleFrom(
                  padding:
                      EdgeInsets.symmetric(vertical: tokens.space16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(tokens.radiusMd),
                  ),
                ),
                child: Text(l10n.flashcardsStudyAgain),
              ),
              SizedBox(height: tokens.space12),
              OutlinedButton(
                onPressed: () {
                  ref.invalidate(dashboardNotifierProvider);
                  context.pop();
                },
                style: OutlinedButton.styleFrom(
                  padding:
                      EdgeInsets.symmetric(vertical: tokens.space16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(tokens.radiusMd),
                  ),
                ),
                child: Text(l10n.flashcardsBackToLibrary),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDuration(Duration d) {
    final m = d.inMinutes;
    final s = d.inSeconds % 60;
    if (m == 0) return '${s}s';
    return '${m}m ${s}s';
  }
}

class _StatRow extends StatelessWidget {
  const _StatRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final tokens = context.aurora;
    final tt = Theme.of(context).textTheme;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: tokens.space8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          SizedBox(width: tokens.space12),
          Expanded(
            child: Text(
              label,
              style: tt.bodyMedium?.copyWith(color: tokens.textSecondary),
            ),
          ),
          Text(
            value,
            style: tt.bodyMedium?.copyWith(
              color: tokens.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _GradeChip extends StatelessWidget {
  const _GradeChip({
    required this.label,
    required this.count,
    required this.color,
    required this.bg,
  });

  final String label;
  final int count;
  final Color color;
  final Color bg;

  @override
  Widget build(BuildContext context) {
    final tokens = context.aurora;
    final tt = Theme.of(context).textTheme;
    return Expanded(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: tokens.space4),
        padding: EdgeInsets.symmetric(vertical: tokens.space12),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(tokens.radiusMd),
        ),
        child: Column(
          children: [
            Text(
              '$count',
              style: tt.titleMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.w800,
              ),
            ),
            SizedBox(height: tokens.space2),
            Text(
              label,
              style: tt.labelSmall?.copyWith(color: color),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:quizaipro_mobile/core/router/app_routes.dart';
import 'package:quizaipro_mobile/core/theme/aurora_tokens.dart';
import 'package:quizaipro_mobile/features/dashboard/domain/entities/activity_item.dart';
import 'package:quizaipro_mobile/l10n/app_localizations.dart';

/// Compact, tappable summary row for one recent-activity entry. Tapping opens
/// the full [ActivityDetailScreen] (a dedicated page) instead of expanding the
/// Q&A inline — keeps the home feed tidy and gives the review room to breathe.
class ActivityItemTile extends StatelessWidget {
  const ActivityItemTile({
    super.key,
    required this.item,
    required this.tokens,
  });

  final ActivityItem item;
  final AuroraTokens tokens;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isTest = item.maybeMap(test: (_) => true, orElse: () => false);
    final accent = isTest ? tokens.stateInfo : tokens.brandGradientStart;
    final icon = isTest ? Icons.fact_check_rounded : Icons.style_rounded;

    return Material(
      color: tokens.backgroundSurface,
      borderRadius: BorderRadius.circular(tokens.radiusL),
      child: InkWell(
        borderRadius: BorderRadius.circular(tokens.radiusL),
        onTap: () => context.pushNamed(
          AppRoutes.activityDetailName,
          extra: item,
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(tokens.radiusL),
            border: Border.all(color: tokens.borderSubtle),
          ),
          padding: EdgeInsets.all(tokens.space12),
          child: Row(
            children: [
              // Type avatar — distinguishes a study session from a test at a glance.
              Container(
                width: 42,
                height: 42,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: accent.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(tokens.radiusM),
                ),
                child: Icon(icon, color: accent, size: 22),
              ),
              SizedBox(width: tokens.space12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: tokens.titleSmall.copyWith(
                        fontWeight: FontWeight.w700,
                        color: tokens.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 2),
                    Text(
                      '${_timeAgo(l10n, item.timestamp)}  ·  ${_summaryLabel(l10n)}',
                      style: tokens.bodySmall.copyWith(color: tokens.textTertiary),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              SizedBox(width: tokens.space8),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: tokens.space8,
                  vertical: tokens.space4,
                ),
                decoration: BoxDecoration(
                  color: tokens.brandPrimary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(tokens.radiusFull),
                ),
                child: Text(
                  '+${item.xpEarned} XP',
                  style: tokens.labelSmall.copyWith(
                    color: tokens.brandPrimary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _summaryLabel(AppLocalizations l10n) {
    return item.map(
      study: (s) => l10n.dashboardActivitySummary(s.cardsReviewed, '').trim(),
      test: (t) {
        final pct = t.totalQuestions > 0
            ? (t.correctCount * 100 ~/ t.totalQuestions)
            : 0;
        return '$pct% (${t.correctCount}/${t.totalQuestions})';
      },
    );
  }

  String _timeAgo(AppLocalizations l10n, DateTime ts) {
    final diff = DateTime.now().difference(ts);
    if (diff.inMinutes < 60) return l10n.dashboardTimeAgoMinutes(diff.inMinutes);
    if (diff.inHours < 24) return l10n.dashboardTimeAgoHours(diff.inHours);
    return l10n.dashboardTimeAgoDays(diff.inDays);
  }
}

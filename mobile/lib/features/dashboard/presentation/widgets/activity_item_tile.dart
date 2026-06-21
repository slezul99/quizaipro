import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:quizaipro_mobile/core/router/app_routes.dart';
import 'package:quizaipro_mobile/core/theme/aurora_tokens.dart';
import 'package:quizaipro_mobile/features/dashboard/domain/entities/activity_item.dart';
import 'package:quizaipro_mobile/l10n/app_localizations.dart';

/// Self-contained, tappable card for one recent-activity entry. Tapping opens
/// the full [ActivityDetailScreen]. The card carries its own type identity
/// (accent rail + icon), so the parent section no longer needs a separate
/// timeline node — keeping the feed clean and free of duplicate icons.
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
        child: ClipRRect(
          borderRadius: BorderRadius.circular(tokens.radiusL),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: tokens.borderSubtle),
              borderRadius: BorderRadius.circular(tokens.radiusL),
            ),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Accent rail — instantly tells study vs. test apart.
                  Container(width: 4, color: accent),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.all(tokens.space12),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: accent.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(tokens.radiusM),
                            ),
                            child: Icon(icon, color: accent, size: 20),
                          ),
                          SizedBox(width: tokens.space12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
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
                                SizedBox(height: tokens.space4),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.schedule_rounded,
                                      size: 13,
                                      color: tokens.textTertiary,
                                    ),
                                    SizedBox(width: tokens.space4),
                                    Flexible(
                                      child: Text(
                                        _timeAgo(l10n, item.timestamp),
                                        style: tokens.bodySmall.copyWith(
                                          color: tokens.textTertiary,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: tokens.space8),
                          // Trailing: the headline metric on top, +XP below.
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _metricBadge(),
                              SizedBox(height: tokens.space4),
                              Text(
                                '+${item.xpEarned} XP',
                                style: tokens.labelSmall.copyWith(
                                  color: tokens.brandPrimary,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// The defining number for the entry: a coloured score chip for tests,
  /// a card-count chip for study sessions.
  Widget _metricBadge() {
    return item.map(
      study: (s) => _Chip(
        label: '${s.cardsReviewed} 🃏',
        color: tokens.brandGradientStart,
        tokens: tokens,
      ),
      test: (t) {
        final pct = t.totalQuestions > 0
            ? (t.correctCount * 100 ~/ t.totalQuestions)
            : 0;
        final color = pct >= 80
            ? tokens.stateSuccess
            : pct >= 50
                ? tokens.stateWarning
                : tokens.stateError;
        return _Chip(label: '$pct%', color: color, tokens: tokens);
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

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.color,
    required this.tokens,
  });

  final String label;
  final Color color;
  final AuroraTokens tokens;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: tokens.space8,
        vertical: tokens.space4,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(tokens.radiusFull),
      ),
      child: Text(
        label,
        style: tokens.labelSmall.copyWith(
          color: color,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:quizaipro_mobile/l10n/app_localizations.dart';

import 'package:quizaipro_mobile/core/theme/aurora_tokens.dart';
import 'package:quizaipro_mobile/features/dashboard/domain/entities/daily_goal_progress.dart';

/// Daily-goal card. Bolder layout than a plain surface: a gradient target badge,
/// a big completed/target fraction, and a gradient progress bar that turns green
/// on completion.
class DailyGoalCard extends StatelessWidget {
  const DailyGoalCard({
    super.key,
    required this.goal,
    required this.tokens,
    required this.label,
    required this.completedLabel,
  });

  final DailyGoalProgress goal;
  final AuroraTokens tokens;
  final String label;
  final String completedLabel;

  static const _successGradient = LinearGradient(
    colors: [Color(0xFF22c55e), Color(0xFF16a34a)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final done = goal.isCompleted;
    final accent = done ? _successGradient : tokens.brandGradient;
    final accentColor = done ? const Color(0xFF22c55e) : tokens.brandPrimary;

    return Container(
      decoration: BoxDecoration(
        color: tokens.surfaceCard,
        borderRadius: BorderRadius.circular(tokens.radiusL),
        boxShadow: tokens.shadowCard,
        border: Border.all(color: accentColor.withOpacity(0.18)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(tokens.radiusL),
        child: Stack(
          children: [
            // Soft decorative glow
            Positioned(
              top: -36,
              right: -28,
              child: Container(
                width: 130,
                height: 130,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      accentColor.withOpacity(0.12),
                      accentColor.withOpacity(0.0),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(tokens.space20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      // Gradient target badge
                      Container(
                        width: 44,
                        height: 44,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          gradient: accent,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: accentColor.withOpacity(0.35),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Icon(
                          done
                              ? Icons.check_rounded
                              : Icons.flag_rounded,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                      SizedBox(width: tokens.space12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              label,
                              style: tokens.titleSmall
                                  .copyWith(fontWeight: FontWeight.w700),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: tokens.space2),
                            Text(
                              done
                                  ? completedLabel
                                  : l10n.dashboardCardsLeft(goal.remainingCards),
                              style: tokens.bodySmall.copyWith(
                                color: done ? accentColor : tokens.textSecondary,
                                fontWeight:
                                    done ? FontWeight.w600 : FontWeight.w400,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: tokens.space8),
                      // Big fraction
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: '${goal.completedCards}',
                              style: tokens.headlineSmall.copyWith(
                                fontWeight: FontWeight.w900,
                                color: accentColor,
                              ),
                            ),
                            TextSpan(
                              text: '/${goal.targetCards}',
                              style: tokens.bodyMedium.copyWith(
                                color: tokens.textTertiary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: tokens.space16),
                  // Gradient progress bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: Stack(
                      children: [
                        Container(
                          height: 10,
                          color: tokens.surfaceSubtle,
                        ),
                        FractionallySizedBox(
                          widthFactor: goal.progress.clamp(0.0, 1.0),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 500),
                            curve: Curves.easeOut,
                            height: 10,
                            decoration: BoxDecoration(gradient: accent),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

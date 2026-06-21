import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:quizaipro_mobile/core/router/app_routes.dart';
import 'package:quizaipro_mobile/core/theme/aurora_tokens.dart';
import 'package:quizaipro_mobile/features/dashboard/domain/entities/evolution_stage.dart';
import 'package:quizaipro_mobile/features/dashboard/domain/entities/streak_summary.dart';
import 'package:quizaipro_mobile/features/dashboard/presentation/widgets/evolution_tree_animation.dart';
import 'package:quizaipro_mobile/l10n/app_localizations.dart';

class EvolutionTreeCard extends StatelessWidget {
  const EvolutionTreeCard({
    super.key,
    required this.streak,
    required this.tokens,
  });

  final StreakSummary streak;
  final AuroraTokens tokens;

  String _getLastReward(int currentStreak, AppLocalizations l10n) {
    if (currentStreak >= 100) {
      return l10n.streakLastReward('+1000 XP');
    } else if (currentStreak >= 30) {
      return l10n.streakLastReward('+300 XP');
    } else if (currentStreak >= 7) {
      return l10n.streakLastReward('+70 XP');
    } else if (currentStreak >= 3) {
      return l10n.streakLastReward('+30 XP');
    } else {
      return l10n.streakNoLastReward;
    }
  }

  String _getNextReward(int currentStreak, AppLocalizations l10n) {
    if (currentStreak < 3) {
      return l10n.streakNextReward('+30 XP');
    } else if (currentStreak < 7) {
      return l10n.streakNextReward('+70 XP');
    } else if (currentStreak < 30) {
      return l10n.streakNextReward('+300 XP');
    } else if (currentStreak < 100) {
      return l10n.streakNextReward('+1000 XP');
    } else {
      return l10n.streakMaxReward;
    }
  }

  // Helper to get stage-specific atmospheric background gradient (Alternative 3 elements)
  LinearGradient _getAtmosphericGradient(EvolutionStage stage) {
    switch (stage) {
      case EvolutionStage.seed:
        return const LinearGradient(
          colors: [Color(0xFF1E1714), Color(0xFF130E0C)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case EvolutionStage.sprout:
        return const LinearGradient(
          colors: [Color(0xFF0E2215), Color(0xFF08140D)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case EvolutionStage.youngTree:
        return const LinearGradient(
          colors: [Color(0xFF0C222E), Color(0xFF06131C)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case EvolutionStage.bloomingTree:
        return const LinearGradient(
          colors: [Color(0xFF28131E), Color(0xFF180A12)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case EvolutionStage.ancientTree:
        return const LinearGradient(
          colors: [Color(0xFF2D1D0D), Color(0xFF1C1108)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case EvolutionStage.legendaryTree:
        return const LinearGradient(
          colors: [Color(0xFF200F33), Color(0xFF12081E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case EvolutionStage.eternalTree:
        return const LinearGradient(
          colors: [Color(0xFF0B1220), Color(0xFF05080D)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final currentStreak = streak.currentStreak;
    final stageKey = streak.currentStage?.key ?? 'seed';
    final stage = EvolutionStage.fromKey(stageKey);
    final palette = stage.palette;

    final progress = streak.progressRatio ?? 1.0;
    final daysRemaining = streak.daysRemaining ?? 0;
    final nextStageKey = streak.nextStage?.key;

    final String currentStageName = stage.getLocalizedName(l10n);

    final String? nextStageName;
    if (nextStageKey != null) {
      nextStageName = EvolutionStage.fromKey(nextStageKey).getLocalizedName(l10n);
    } else {
      nextStageName = null;
    }

    final targetDays = streak.nextStage?.startDays ?? streak.currentStage?.nextStageDays ?? currentStreak;
    final pct = (progress * 100).toInt();

    return Container(
      decoration: BoxDecoration(
        gradient: _getAtmosphericGradient(stage),
        border: Border.all(
          color: palette.primary.withValues(alpha: 0.35),
          width: 1.5,
        ),
        borderRadius: BorderRadius.circular(tokens.radiusL),
        boxShadow: [
          BoxShadow(
            color: palette.primary.withValues(alpha: 0.12),
            blurRadius: 20,
            spreadRadius: 2,
          ),
          ...tokens.shadowCard,
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(tokens.radiusL),
        onTap: () => context.push(AppRoutes.streakJourney),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: tokens.space20,
            vertical: tokens.space24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 1. TOP: Circular Growth Shrine containing the Tree (160x160 size)
              Hero(
                tag: 'evolution_tree_hero',
                child: Container(
                  width: 180,
                  height: 180,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        palette.primary.withValues(alpha: 0.15),
                        palette.secondary.withValues(alpha: 0.04),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    border: Border.all(
                      color: palette.primary.withValues(alpha: 0.4),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: palette.primary.withValues(alpha: 0.1),
                        blurRadius: 16,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: EvolutionTreeAnimation(
                    stage: stage,
                    size: 160,
                    animate: true,
                  ),
                ),
              ),
              SizedBox(height: tokens.space20),

              // 2. MIDDLE: Current streak & Stage name badge
              Text(
                l10n.streakDayCount(currentStreak),
                textAlign: TextAlign.center,
                style: tokens.headlineSmall.copyWith(
                  fontWeight: FontWeight.w900,
                  color: tokens.textPrimary,
                  fontSize: 26,
                  letterSpacing: -0.5,
                ),
              ),
              SizedBox(height: tokens.space8),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: tokens.space4,
                ),
                decoration: BoxDecoration(
                  color: palette.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(tokens.radiusS),
                  border: Border.all(
                    color: palette.primary.withValues(alpha: 0.35),
                    width: 1.2,
                  ),
                ),
                child: Text(
                  currentStageName.toUpperCase(),
                  style: tokens.labelMedium.copyWith(
                    color: palette.primary,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
              SizedBox(height: tokens.space24),

              // 3. PROGRESS SECTION: Progress bar, current/target, percentage
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        l10n.streakProgressDays(
                          currentStreak.toString(),
                          '$pct',
                          targetDays.toString(),
                        ),
                        style: tokens.bodySmall.copyWith(
                          color: tokens.textSecondary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: tokens.space8),
                  // Glowing neon segmented-style progress bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(tokens.radiusS),
                    child: Container(
                      height: 10,
                      color: tokens.surfaceSubtle.withValues(alpha: 0.5),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          return Align(
                            alignment: Alignment.centerLeft,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 600),
                              curve: Curves.easeOutCubic,
                              width: constraints.maxWidth * progress,
                              height: 10,
                              decoration: BoxDecoration(
                                gradient: palette.gradient,
                                borderRadius: BorderRadius.circular(tokens.radiusS),
                                boxShadow: [
                                  BoxShadow(
                                    color: palette.primary.withValues(alpha: 0.4),
                                    blurRadius: 4,
                                    spreadRadius: 1,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: tokens.space24),

              // Divider
              Container(
                height: 1,
                color: tokens.borderDefault.withValues(alpha: 0.15),
              ),
              SizedBox(height: tokens.space20),

              // 4. REWARDS SECTION: Last unlocked, next reward, days remaining
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.check_circle_rounded,
                        color: currentStreak >= 3
                            ? Colors.greenAccent
                            : tokens.textSecondary.withValues(alpha: 0.4),
                        size: 20,
                      ),
                      SizedBox(width: tokens.space10),
                      Expanded(
                        child: Text(
                          _getLastReward(currentStreak, l10n),
                          style: tokens.bodyMedium.copyWith(
                            color: currentStreak >= 3
                                ? tokens.textPrimary
                                : tokens.textSecondary,
                            fontWeight: currentStreak >= 3
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: tokens.space12),
                  Row(
                    children: [
                      Icon(
                        currentStreak >= 100
                            ? Icons.star_rounded
                            : Icons.lock_clock,
                        color: currentStreak >= 100
                            ? Colors.amberAccent
                            : palette.primary,
                        size: 20,
                      ),
                      SizedBox(width: tokens.space10),
                      Expanded(
                        child: Text(
                          _getNextReward(currentStreak, l10n),
                          style: tokens.bodyMedium.copyWith(
                            color: tokens.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (nextStageName != null) ...[
                    SizedBox(height: tokens.space16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.hourglass_top_rounded,
                          color: palette.primary.withValues(alpha: 0.85),
                          size: 16,
                        ),
                        SizedBox(width: tokens.space6),
                        Text(
                          l10n.streakDaysRemaining(daysRemaining, nextStageName),
                          style: tokens.bodySmall.copyWith(
                            color: tokens.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ] else ...[
                    SizedBox(height: tokens.space16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.workspace_premium_rounded,
                          color: Colors.amberAccent,
                          size: 18,
                        ),
                        SizedBox(width: tokens.space6),
                        Text(
                          l10n.streakMaximized,
                          style: tokens.bodySmall.copyWith(
                            color: Colors.amberAccent,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

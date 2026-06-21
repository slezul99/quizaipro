import 'package:flutter/material.dart';

import 'package:quizaipro_mobile/core/theme/aurora_tokens.dart';
import 'package:quizaipro_mobile/core/widgets/radial_progress_ring.dart';
import 'package:quizaipro_mobile/core/widgets/streak_flame.dart';
import 'package:quizaipro_mobile/features/dashboard/domain/entities/streak_summary.dart';
import 'package:quizaipro_mobile/features/dashboard/domain/entities/xp_summary.dart';
import 'package:go_router/go_router.dart';
import 'package:quizaipro_mobile/core/router/app_routes.dart';


/// Compact chess.com-style stat chips (streak + level) shown in the dashboard
/// header. Replaces the old full-width XP/streak cards: tapping either chip
/// opens a detail bottom sheet, so no information is lost despite the smaller
/// footprint. The level chip is a [RadialProgressRing] whose ring fills with
/// the user's progress toward the next level.
class DashboardHeaderStats extends StatelessWidget {
  const DashboardHeaderStats({
    super.key,
    required this.streak,
    required this.xp,
    required this.tokens,
  });

  final StreakSummary streak;
  final XpSummary xp;
  final AuroraTokens tokens;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _StreakChip(streak: streak, tokens: tokens),
        SizedBox(width: tokens.space8),
        _LevelChip(xp: xp, tokens: tokens),
      ],
    );
  }
}

/// Circular gradient badge holding the level number. Used both as the small
/// glyph nested inside the [RadialProgressRing] header chip and, scaled up,
/// as the headline icon in the level detail sheet.
class _LevelBadge extends StatelessWidget {
  const _LevelBadge({
    required this.level,
    required this.size,
    required this.tokens,
  });

  final int level;
  final double size;
  final AuroraTokens tokens;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: tokens.brandGradient,
      ),
      child: Text(
        '$level',
        style: TextStyle(
          fontSize: size * 0.42,
          fontWeight: FontWeight.w800,
          color: Colors.white,
          height: 1,
        ),
      ),
    );
  }
}

class _StreakChip extends StatelessWidget {
  const _StreakChip({
    required this.streak,
    required this.tokens,
  });

  final StreakSummary streak;
  final AuroraTokens tokens;

  @override
  Widget build(BuildContext context) {
    final active = streak.isActive;
    final count = streak.currentStreak;

    return GestureDetector(
      onTap: () => context.pushNamed(AppRoutes.streakJourneyName),
      child: Container(
        height: 34,
        padding: EdgeInsets.symmetric(horizontal: tokens.space12),
        decoration: BoxDecoration(
          color: tokens.surfaceCard,
          borderRadius: BorderRadius.circular(tokens.radiusM),
          boxShadow: tokens.shadowCard,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            StreakFlame(
                streak: count,
                size: 18,
                active: active,
                inactiveColor: tokens.textTertiary),
            const SizedBox(width: 5),
            Text(
              '$count',
              style: tokens.titleSmall.copyWith(
                fontWeight: FontWeight.w800,
                color: active ? streakFlameColor(count) : tokens.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LevelChip extends StatelessWidget {
  const _LevelChip({required this.xp, required this.tokens});

  final XpSummary xp;
  final AuroraTokens tokens;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.pushNamed(AppRoutes.levelJourneyName),
      child: RadialProgressRing(
        progress: xp.levelProgress,
        size: 34,
        strokeWidth: 3,
        backgroundColor: tokens.surfaceSubtle,
        progressGradient: tokens.brandGradient,
        child: _LevelBadge(level: xp.level, size: 22, tokens: tokens),
      ),
    );
  }
}

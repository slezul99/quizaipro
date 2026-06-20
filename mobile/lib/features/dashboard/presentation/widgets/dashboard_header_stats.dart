import 'package:flutter/material.dart';

import 'package:quizaipro_mobile/core/theme/aurora_tokens.dart';
import 'package:quizaipro_mobile/core/widgets/radial_progress_ring.dart';
import 'package:quizaipro_mobile/features/dashboard/domain/entities/streak_summary.dart';
import 'package:quizaipro_mobile/features/dashboard/domain/entities/xp_summary.dart';
import 'package:go_router/go_router.dart';
import 'package:quizaipro_mobile/core/router/app_routes.dart';


/// Tier palette shared with the level page. The streak glyph borrows it so its
/// colour visibly evolves as the learner climbs tiers — a small "your progress
/// changes the world" touch fitting the study theme.
({Color solid, List<Color> gradient}) _tierPalette(int level) {
  if (level <= 5) {
    return (solid: const Color(0xFFCD7F32), gradient: const [Color(0xFFF0B27A), Color(0xFFCD7F32)]);
  }
  if (level <= 15) {
    return (solid: const Color(0xFF9CA3AF), gradient: const [Color(0xFFE5E7EB), Color(0xFF9CA3AF)]);
  }
  if (level <= 30) {
    return (solid: const Color(0xFFF59E0B), gradient: const [Color(0xFFFFE259), Color(0xFFFFA751)]);
  }
  if (level <= 50) {
    return (solid: const Color(0xFF14B8A6), gradient: const [Color(0xFF2DD4BF), Color(0xFF0D9488)]);
  }
  if (level <= 100) {
    return (solid: const Color(0xFF10B981), gradient: const [Color(0xFF34D399), Color(0xFF059669)]);
  }
  return (solid: const Color(0xFF8B5CF6), gradient: const [Color(0xFFA78BFA), Color(0xFF7C3AED)]);
}

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
        _StreakChip(streak: streak, level: xp.level, tokens: tokens),
        SizedBox(width: tokens.space8),
        _LevelChip(xp: xp, tokens: tokens),
      ],
    );
  }
}

/// Streak glyph — a "bolt of momentum" instead of the generic 🔥. It's drawn
/// via a [ShaderMask] with the current tier gradient, so the streak mark shifts
/// colour (bronze → silver → gold → teal → emerald → violet) as the learner
/// levels up. A muted outline is shown once the streak has lapsed.
class _StreakIcon extends StatelessWidget {
  const _StreakIcon({
    required this.active,
    required this.size,
    required this.level,
    required this.tokens,
  });

  final bool active;
  final double size;
  final int level;
  final AuroraTokens tokens;

  @override
  Widget build(BuildContext context) {
    if (!active) {
      return Icon(
        Icons.bolt_outlined,
        size: size,
        color: tokens.textTertiary,
      );
    }
    final gradient = _tierPalette(level).gradient;
    return ShaderMask(
      shaderCallback: (rect) => LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: gradient,
      ).createShader(rect),
      blendMode: BlendMode.srcIn,
      child: Icon(
        Icons.bolt_rounded,
        size: size,
        color: Colors.white,
      ),
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
    required this.level,
    required this.tokens,
  });

  final StreakSummary streak;
  final int level;
  final AuroraTokens tokens;

  @override
  Widget build(BuildContext context) {
    final active = streak.isActive;
    final tierColor = _tierPalette(level).solid;

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
            _StreakIcon(active: active, size: 18, level: level, tokens: tokens),
            const SizedBox(width: 5),
            Text(
              '${streak.currentStreak}',
              style: tokens.titleSmall.copyWith(
                fontWeight: FontWeight.w800,
                color: active ? tierColor : tokens.textSecondary,
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

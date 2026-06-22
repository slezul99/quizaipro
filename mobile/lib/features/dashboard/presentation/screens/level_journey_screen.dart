import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quizaipro_mobile/core/theme/aurora_tokens.dart';
import 'package:quizaipro_mobile/features/dashboard/domain/entities/level_journey.dart';
import 'package:quizaipro_mobile/features/dashboard/domain/usecases/get_level_journey_use_case.dart';
import 'package:quizaipro_mobile/features/dashboard/presentation/providers/dashboard_providers.dart';
import 'package:quizaipro_mobile/core/usecase/usecase.dart';
import 'package:quizaipro_mobile/l10n/app_localizations.dart';

final levelJourneyProvider = FutureProvider.autoDispose<LevelJourney>((ref) async {
  final useCase = ref.watch(getLevelJourneyUseCaseProvider);
  final res = await useCase(const NoParams());
  return res.fold((fail) => throw fail, (data) => data);
});

class LevelJourneyScreen extends ConsumerWidget {
  const LevelJourneyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.aurora;
    final l = AppLocalizations.of(context)!;
    final detailsAsync = ref.watch(levelJourneyProvider);

    return Scaffold(
      backgroundColor: tokens.backgroundCanvas,
      body: detailsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(
          child: Text(
            l.levelJourneyLoadError,
            style: TextStyle(color: tokens.textSecondary),
          ),
        ),
        data: (details) => _LevelJourneyContent(details: details, tokens: tokens),
      ),
    );
  }
}

class _LevelJourneyContent extends StatelessWidget {
  const _LevelJourneyContent({required this.details, required this.tokens});

  final LevelJourney details;
  final AuroraTokens tokens;

  Color _getTierColor(int level) {
    if (level <= 5) return const Color(0xFFCD7F32); // Bronze
    if (level <= 15) return const Color(0xFFC0C0C0); // Silver
    if (level <= 30) return const Color(0xFFFFD700); // Gold
    if (level <= 50) return const Color(0xFF14B8A6); // Teal (Sage)
    if (level <= 100) return const Color(0xFF10B981); // Emerald (Grandmaster)
    return const Color(0xFF8B5CF6); // Purple (Legend)
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final currentTierColor = _getTierColor(details.level);
    final remainingXp =
        (details.xpForNextLevel - details.xpInCurrentLevel).clamp(0, 1 << 30);

    return CustomScrollView(
      slivers: [
        // ── Gradient hero (folds in the old home level card) ────────────────
        SliverToBoxAdapter(
          child: _LevelHero(
            tokens: tokens,
            tierColor: currentTierColor,
            level: details.level,
            tierName: details.tier.name,
            totalXp: details.totalXp,
            progress: details.progressRatio,
            xpInLevel: details.xpInCurrentLevel,
            xpForNext: details.xpForNextLevel,
            remainingXp: remainingXp,
          ),
        ),
        SliverPadding(
          padding: EdgeInsets.fromLTRB(
            tokens.space20,
            tokens.space24,
            tokens.space20,
            0,
          ),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              // ── Next goal: the next locked reward, to aim for ──────────────
              _NextGoalCard(
                tokens: tokens,
                level: details.level,
                milestones: details.milestones,
              ),
              const SizedBox(height: 28),

              // ── Tier ladder: all ranks, current highlighted, rest as goals ─
              Text(
                l.levelJourneyTiers,
                style: tokens.titleMedium.copyWith(
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                l.levelJourneyTiersSubtitle,
                style: tokens.bodySmall.copyWith(color: tokens.textSecondary),
              ),
              const SizedBox(height: 14),
              _TierLadder(tokens: tokens, level: details.level),
              const SizedBox(height: 28),

              // Roadmap title
              Text(
                l.levelJourneyRewardsRoad,
                style: tokens.titleMedium.copyWith(
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 16),

              // Milestones vertical roadmap
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: details.milestones.length,
                itemBuilder: (context, index) {
                  final milestone = details.milestones[index];
                  final isLast = index == details.milestones.length - 1;
                  final milestoneColor = _getTierColor(milestone.level);

                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Connector & dot column
                      Column(
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: milestone.unlocked ? milestoneColor : tokens.surfaceSubtle,
                              border: Border.all(
                                color: milestone.unlocked ? Colors.white : tokens.borderSubtle,
                                width: 2,
                              ),
                              boxShadow: milestone.unlocked
                                  ? [BoxShadow(color: milestoneColor.withOpacity(0.3), blurRadius: 6)]
                                  : null,
                            ),
                            alignment: Alignment.center,
                            child: milestone.unlocked
                                ? const Icon(Icons.check, color: Colors.white, size: 16)
                                : Text(
                                    '${milestone.level}',
                                    style: TextStyle(
                                      color: tokens.textTertiary,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                          ),
                          if (!isLast)
                            Container(
                              width: 3,
                              height: 48,
                              color: milestone.unlocked
                                  ? milestoneColor.withOpacity(0.5)
                                  : tokens.borderSubtle,
                            ),
                        ],
                      ),
                      const SizedBox(width: 16),

                      // Reward description
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l.levelJourneyMilestone(milestone.level),
                              style: tokens.titleSmall.copyWith(
                                fontWeight: FontWeight.bold,
                                color: milestone.unlocked ? tokens.textPrimary : tokens.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              milestone.rewardDesc,
                              style: tokens.bodySmall.copyWith(
                                color: tokens.textTertiary,
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),

              const SizedBox(height: 24),

              // XP History Section
              Text(
                l.levelJourneyXpHistory,
                style: tokens.titleMedium.copyWith(
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 12),

              if (details.recentXpEvents.isEmpty)
                Container(
                  padding: EdgeInsets.all(tokens.space16),
                  decoration: BoxDecoration(
                    color: tokens.surfaceCard,
                    borderRadius: BorderRadius.circular(tokens.radiusM),
                    boxShadow: tokens.shadowCard,
                  ),
                  child: Center(
                    child: Text(
                      l.levelJourneyXpHistoryEmpty,
                      style: tokens.bodyMedium.copyWith(color: tokens.textSecondary),
                    ),
                  ),
                )
              else
                Container(
                  decoration: BoxDecoration(
                    color: tokens.surfaceCard,
                    borderRadius: BorderRadius.circular(tokens.radiusM),
                    boxShadow: tokens.shadowCard,
                  ),
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: details.recentXpEvents.length,
                    separatorBuilder: (context, index) => Divider(
                      color: tokens.borderSubtle,
                      height: 1,
                    ),
                    itemBuilder: (context, index) {
                      final event = details.recentXpEvents[index];
                      IconData icon;
                      Color iconColor;

                      if (event.eventType == 'flashcard_review') {
                        icon = Icons.rate_review_rounded;
                        iconColor = tokens.brandPrimary;
                      } else if (event.eventType == 'test_attempt') {
                        icon = Icons.assignment_rounded;
                        iconColor = Colors.green;
                      } else {
                        icon = Icons.emoji_events_rounded;
                        iconColor = Colors.orange;
                      }

                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: iconColor.withOpacity(0.1),
                          child: Icon(icon, color: iconColor, size: 20),
                        ),
                        title: Text(
                          event.description,
                          style: tokens.bodyMedium.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        subtitle: Text(
                          event.timestamp.length >= 10
                              ? event.timestamp.substring(0, 10)
                              : event.timestamp,
                          style: tokens.bodySmall.copyWith(
                            color: tokens.textTertiary,
                          ),
                        ),
                        trailing: Text(
                          '+${event.xpGained} XP',
                          style: const TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.w900,
                            fontSize: 14,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              const SizedBox(height: 32),
            ]),
          ),
        ),
      ],
    );
  }
}

/// Gradient banner at the top of the level page. Carries the tier badge, name,
/// progress toward the next level and total XP — the content that used to live
/// in the duplicate home "level card".
class _LevelHero extends StatelessWidget {
  const _LevelHero({
    required this.tokens,
    required this.tierColor,
    required this.level,
    required this.tierName,
    required this.totalXp,
    required this.progress,
    required this.xpInLevel,
    required this.xpForNext,
    required this.remainingXp,
  });

  final AuroraTokens tokens;
  final Color tierColor;
  final int level;
  final String tierName;
  final int totalXp;
  final double progress;
  final int xpInLevel;
  final int xpForNext;
  final int remainingXp;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final topPad = MediaQuery.of(context).padding.top;
    return Container(
      padding: EdgeInsets.fromLTRB(20, topPad + 8, 20, 28),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [tierColor, Color.lerp(tierColor, Colors.black, 0.28)!],
        ),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            color: tierColor.withOpacity(0.35),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Back + total XP pill
          Row(
            children: [
              _CircleIconButton(
                icon: Icons.arrow_back_ios_new_rounded,
                onTap: () => Navigator.pop(context),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.stars_rounded, color: Colors.white, size: 16),
                    const SizedBox(width: 6),
                    Text(
                      '$totalXp XP',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              // Badge with double ring glow
              Hero(
                tag: 'level_badge_hero',
                child: Container(
                  width: 84,
                  height: 84,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.16),
                    border: Border.all(color: Colors.white.withOpacity(0.5), width: 2),
                  ),
                  child: Container(
                    width: 64,
                    height: 64,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 8),
                      ],
                    ),
                    child: Text(
                      '$level',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w900,
                        color: tierColor,
                        height: 1,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tierName.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 20,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      l.levelJourneyLevel(level),
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.85),
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: Stack(
              children: [
                Container(height: 10, color: Colors.white.withOpacity(0.25)),
                FractionallySizedBox(
                  widthFactor: progress.clamp(0.0, 1.0),
                  child: Container(height: 10, color: Colors.white),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$xpInLevel / $xpForNext XP',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
              Text(
                l.levelJourneyXpRemaining(remainingXp),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.18),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 18),
      ),
    );
  }
}

// ── Tier ladder data ─────────────────────────────────────────────────────────

class _TierInfo {
  const _TierInfo(this.key, this.minLevel, this.color, this.icon);
  final String key;
  final int minLevel;
  final Color color;
  final IconData icon;
}

const List<_TierInfo> _kTiers = [
  _TierInfo('bronze', 1, Color(0xFFCD7F32), Icons.shield_rounded),
  _TierInfo('silver', 6, Color(0xFFB6C0CC), Icons.shield_moon_rounded),
  _TierInfo('gold', 16, Color(0xFFF5B700), Icons.workspace_premium_rounded),
  _TierInfo('platinum', 31, Color(0xFF14B8A6), Icons.diamond_rounded),
  _TierInfo('master', 51, Color(0xFF10B981), Icons.military_tech_rounded),
  _TierInfo('legend', 101, Color(0xFF8B5CF6), Icons.auto_awesome_rounded),
];

String _tierName(AppLocalizations l, String key) {
  switch (key) {
    case 'bronze':
      return l.levelTierBronze;
    case 'silver':
      return l.levelTierSilver;
    case 'gold':
      return l.levelTierGold;
    case 'platinum':
      return l.levelTierPlatinum;
    case 'master':
      return l.levelTierMaster;
    default:
      return l.levelTierLegend;
  }
}

/// Goal card pointing at the next locked milestone reward — gives a concrete
/// thing to climb toward.
class _NextGoalCard extends StatelessWidget {
  const _NextGoalCard({
    required this.tokens,
    required this.level,
    required this.milestones,
  });

  final AuroraTokens tokens;
  final int level;
  final List<LevelJourneyMilestone> milestones;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    LevelJourneyMilestone? next;
    for (final m in milestones) {
      if (!m.unlocked) {
        next = m;
        break;
      }
    }

    if (next == null) {
      return Container(
        padding: EdgeInsets.all(tokens.space16),
        decoration: BoxDecoration(
          color: tokens.surfaceCard,
          borderRadius: BorderRadius.circular(tokens.radiusM),
          boxShadow: tokens.shadowCard,
        ),
        child: Row(
          children: [
            const Text('👑', style: TextStyle(fontSize: 22)),
            SizedBox(width: tokens.space12),
            Expanded(
              child: Text(l.levelJourneyAllRewards,
                  style: tokens.titleSmall.copyWith(fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      );
    }

    final levelsToGo = (next.level - level).clamp(0, 1 << 30);
    return Container(
      padding: EdgeInsets.all(tokens.space16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            tokens.brandGradientStart.withOpacity(0.16),
            tokens.brandGradientStart.withOpacity(0.04),
          ],
        ),
        borderRadius: BorderRadius.circular(tokens.radiusM),
        border: Border.all(color: tokens.brandGradientStart.withOpacity(0.30)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.flag_rounded,
                  size: 16, color: tokens.brandGradientStart),
              SizedBox(width: tokens.space4),
              Text(
                l.levelJourneyNextGoal,
                style: tokens.labelMedium.copyWith(
                  color: tokens.brandGradientStart,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.0,
                ),
              ),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: tokens.brandGradientStart,
                  borderRadius: BorderRadius.circular(tokens.radiusFull),
                ),
                child: Text(
                  '+$levelsToGo',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: tokens.space8),
          Text(
            l.levelJourneyToLevel(next.level),
            style: tokens.titleMedium.copyWith(fontWeight: FontWeight.w900),
          ),
          SizedBox(height: tokens.space4),
          Text(
            next.rewardDesc,
            style: tokens.bodyMedium.copyWith(color: tokens.textSecondary),
          ),
        ],
      ),
    );
  }
}

/// Horizontal ladder of all tiers: passed tiers get a check, the current tier
/// glows with a "you're here" marker, future tiers are dimmed goals.
class _TierLadder extends StatelessWidget {
  const _TierLadder({required this.tokens, required this.level});

  final AuroraTokens tokens;
  final int level;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    int currentIndex = 0;
    for (var i = 0; i < _kTiers.length; i++) {
      if (level >= _kTiers[i].minLevel) currentIndex = i;
    }

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 3,
      mainAxisSpacing: tokens.space12,
      crossAxisSpacing: tokens.space12,
      childAspectRatio: 0.70,
      children: [
        for (var i = 0; i < _kTiers.length; i++)
          _TierMedallion(
            tokens: tokens,
            name: _tierName(l, _kTiers[i].key),
            fromLabel: l.levelJourneyFromLevel(_kTiers[i].minLevel),
            youHereLabel: l.levelJourneyYouAreHere,
            color: _kTiers[i].color,
            icon: _kTiers[i].icon,
            state: i < currentIndex
                ? _TierState.passed
                : (i == currentIndex ? _TierState.current : _TierState.locked),
          ),
      ],
    );
  }
}

enum _TierState { passed, current, locked }

class _TierMedallion extends StatelessWidget {
  const _TierMedallion({
    required this.tokens,
    required this.name,
    required this.fromLabel,
    required this.youHereLabel,
    required this.color,
    required this.icon,
    required this.state,
  });

  final AuroraTokens tokens;
  final String name;
  final String fromLabel;
  final String youHereLabel;
  final Color color;
  final IconData icon;
  final _TierState state;

  @override
  Widget build(BuildContext context) {
    final isCurrent = state == _TierState.current;
    final isLocked = state == _TierState.locked;
    final tint = isLocked ? tokens.textTertiary : color;

    return Container(
      padding: EdgeInsets.symmetric(
          vertical: tokens.space12, horizontal: tokens.space4),
      decoration: BoxDecoration(
        color: isCurrent ? null : tokens.surfaceCard,
        gradient: isCurrent
            ? LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  color.withValues(alpha: 0.18),
                  color.withValues(alpha: 0.03),
                ],
              )
            : null,
        borderRadius: BorderRadius.circular(tokens.radiusM),
        border: Border.all(
          color: isCurrent ? color : tokens.borderSubtle,
          width: isCurrent ? 1.6 : 1,
        ),
        boxShadow: isCurrent
            ? [
                BoxShadow(
                  color: color.withValues(alpha: 0.30),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                )
              ]
            : null,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Medallion ────────────────────────────────────────────────
          SizedBox(
            width: 56,
            height: 56,
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                if (!isLocked)
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: color
                              .withValues(alpha: isCurrent ? 0.50 : 0.28),
                          blurRadius: isCurrent ? 16 : 10,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  ),
                Container(
                  width: 50,
                  height: 50,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isLocked ? tint.withValues(alpha: 0.12) : null,
                    gradient: isLocked
                        ? null
                        : LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Color.lerp(color, Colors.white, 0.30)!,
                              color,
                              Color.lerp(color, Colors.black, 0.20)!,
                            ],
                          ),
                    border: Border.all(
                      color: isLocked
                          ? tint.withValues(alpha: 0.25)
                          : Colors.white.withValues(alpha: 0.45),
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    isLocked ? Icons.lock_rounded : icon,
                    color: isLocked ? tint : Colors.white,
                    size: 24,
                  ),
                ),
                if (state == _TierState.passed)
                  Positioned(
                    right: 1,
                    bottom: 1,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: tokens.stateSuccess,
                        shape: BoxShape.circle,
                        border:
                            Border.all(color: tokens.surfaceCard, width: 1.5),
                      ),
                      child: const Icon(Icons.check,
                          color: Colors.white, size: 9),
                    ),
                  ),
              ],
            ),
          ),
          SizedBox(height: tokens.space8),
          Text(
            name,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: tokens.labelMedium.copyWith(
              fontWeight: FontWeight.w800,
              color: isLocked ? tokens.textSecondary : tokens.textPrimary,
            ),
          ),
          const SizedBox(height: 3),
          if (isCurrent)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(tokens.radiusFull),
              ),
              child: Text(
                youHereLabel,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 8.5,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.4,
                ),
              ),
            )
          else
            Text(
              fromLabel,
              style: tokens.labelSmall.copyWith(color: tokens.textTertiary),
            ),
        ],
      ),
    );
  }
}

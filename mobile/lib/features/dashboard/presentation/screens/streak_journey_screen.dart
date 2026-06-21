import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quizaipro_mobile/core/theme/aurora_tokens.dart';
import 'package:quizaipro_mobile/core/widgets/streak_flame.dart';
import 'package:quizaipro_mobile/features/dashboard/domain/entities/evolution_stage.dart';
import 'package:quizaipro_mobile/features/dashboard/domain/entities/streak_journey.dart';
import 'package:quizaipro_mobile/features/dashboard/domain/usecases/get_streak_journey_use_case.dart';
import 'package:quizaipro_mobile/features/dashboard/presentation/providers/dashboard_providers.dart';
import 'package:quizaipro_mobile/features/dashboard/presentation/widgets/evolution_tree_animation.dart';
import 'package:quizaipro_mobile/l10n/app_localizations.dart';
import 'package:quizaipro_mobile/core/usecase/usecase.dart';

final streakJourneyProvider = FutureProvider.autoDispose<StreakJourney>((ref) async {
  final useCase = ref.watch(getStreakJourneyUseCaseProvider);
  final res = await useCase(const NoParams());
  return res.fold((fail) => throw fail, (data) => data);
});

/// TESTER ONLY — lets us tap a locked tree to preview its art. Set to `false`
/// before shipping to production so the trees stay a locked surprise (the day
/// flame stays visible to everyone as a stimulus).
const bool kTesterUnlockStages = true;

class StreakJourneyScreen extends ConsumerWidget {
  const StreakJourneyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.aurora;
    final detailsAsync = ref.watch(streakJourneyProvider);

    return Scaffold(
      backgroundColor: tokens.backgroundCanvas,
      body: detailsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(
          child: Text(
            'Failed to load progression journey.',
            style: TextStyle(color: tokens.textSecondary),
          ),
        ),
        data: (details) => _StreakJourneyContent(details: details, tokens: tokens),
      ),
    );
  }
}

class _StreakJourneyContent extends StatefulWidget {
  const _StreakJourneyContent({required this.details, required this.tokens});

  final StreakJourney details;
  final AuroraTokens tokens;

  @override
  State<_StreakJourneyContent> createState() => _StreakJourneyContentState();
}

class _StreakJourneyContentState extends State<_StreakJourneyContent> {
  /// Tester-only preview of a not-yet-unlocked stage's tree.
  EvolutionStage? _previewStage;
  StreakJourney get details => widget.details;
  AuroraTokens get tokens => widget.tokens;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final stageKey = details.streak.currentStage?.key ?? 'seed';
    final currentStage = EvolutionStage.fromKey(stageKey);
    final displayStage = _previewStage ?? currentStage;

    final currentStageName = displayStage.getLocalizedName(l10n);

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          pinned: true,
          expandedHeight: 220,
          backgroundColor: tokens.backgroundCanvas,
          surfaceTintColor: Colors.transparent,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new_rounded, color: tokens.textPrimary),
            onPressed: () => Navigator.pop(context),
          ),
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              alignment: Alignment.bottomCenter,
              padding: EdgeInsets.only(bottom: tokens.space24),
              child: Hero(
                tag: 'evolution_tree_hero',
                child: SizedBox(
                  width: 140,
                  height: 140,
                  child: EvolutionTreeAnimation(stage: displayStage, size: 140),
                ),
              ),
            ),
          ),
        ),
        SliverPadding(
          padding: EdgeInsets.symmetric(horizontal: tokens.space20),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              Center(
                child: Column(
                  children: [
                    Text(
                      l10n.streakGrowthStage(currentStageName),
                      style: tokens.headlineSmall.copyWith(
                        fontWeight: FontWeight.w800,
                        color: displayStage.palette.primary,
                      ),
                    ),
                    SizedBox(height: tokens.space4),
                    Text(
                      l10n.streakCurrentDays(details.streak.currentStreak),
                      style: tokens.bodyMedium.copyWith(
                        color: tokens.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: tokens.space24),

              // DEMO: flame colour changes with the streak length (temporary —
              // shows the user what the icon becomes at each milestone).
              _buildSectionTitle('🔥 Цвет огонька по дням / Flame by days'),
              _buildFlameLegend(),
              SizedBox(height: tokens.space24),

              _buildSectionTitle(l10n.streakEvolutionRoadmap),
              _buildRoadmap(l10n),
              SizedBox(height: tokens.space24),

              _buildSectionTitle(l10n.streakMilestoneAchievements),
              _buildMilestones(l10n),
              SizedBox(height: tokens.space24),

              _buildSectionTitle(l10n.streakConsistencyHistory),
              _buildActivityGrid(),
              SizedBox(height: tokens.space24),

              _buildSectionTitle(l10n.streakClaimedRewardsHistory),
              _buildRewardsHistory(l10n),
              SizedBox(height: tokens.space40),
            ]),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.only(bottom: tokens.space12),
      child: Text(title, style: tokens.titleMedium.copyWith(fontWeight: FontWeight.w800)),
    );
  }

  /// Temporary demo: the flame icon's colour at each streak length.
  Widget _buildFlameLegend() {
    return Padding(
      padding: EdgeInsets.only(bottom: tokens.space12),
      child: Wrap(
        spacing: tokens.space16,
        runSpacing: tokens.space12,
        children: streakFlameTiers.map((d) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              StreakFlame(streak: d, size: 32),
              SizedBox(height: tokens.space4),
              Text('$d+',
                  style: tokens.labelSmall.copyWith(
                      color: streakFlameColor(d), fontWeight: FontWeight.w800)),
            ],
          );
        }).toList(),
      ),
    );
  }

  /// TESTER ONLY — confirm, then show the chosen stage's tree art at the top
  /// without actually having reached that streak.
  Future<void> _previewStageDialog(EvolutionStage stage) async {
    final l10n = AppLocalizations.of(context)!;
    final isUnlocked = details.streak.currentStreak >= stage.startDays;
    final isCurrentPreview = _previewStage == stage;
    final name = stage.getLocalizedName(l10n);

    if (isCurrentPreview) {
      setState(() => _previewStage = null);
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('🔓 $name'),
        content: Text(
          isUnlocked
              ? 'Показать дерево «$name» вверху?'
              : 'Тест-режим: открыть дерево «$name» (${stage.dayRangeText}) для предпросмотра? '
                  'На проде эта стадия откроется только по достижении стрика.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Показать'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      setState(() => _previewStage = stage);
    }
  }

  Widget _buildRoadmap(AppLocalizations l10n) {
    final stages = EvolutionStage.values;
    final stageKey = details.streak.currentStage?.key ?? 'seed';
    final currentStage = EvolutionStage.fromKey(stageKey);
    
    return Container(
      padding: EdgeInsets.all(tokens.space16),
      decoration: BoxDecoration(
        color: tokens.surfaceCard,
        borderRadius: BorderRadius.circular(tokens.radiusL),
        boxShadow: tokens.shadowCard,
      ),
      child: Column(
        children: List.generate(stages.length, (index) {
          final s = stages[index];
          final isUnlocked = details.streak.currentStreak >= s.startDays;
          final isActive = currentStage == s;
          final palette = s.palette;

          final displayName = s.getLocalizedName(l10n);
          final isPreviewing = _previewStage == s;

          final row = SizedBox(
            height: 64, // Fixed height - O(N) layout complexity
            child: Stack(
              children: [
                if (index != stages.length - 1)
                  Positioned(
                    left: 13,
                    top: 14,
                    bottom: 0,
                    width: 2.5,
                    child: Container(
                      color: isUnlocked ? palette.primary : tokens.borderSubtle,
                    ),
                  ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      margin: const EdgeInsets.only(top: 2),
                      decoration: BoxDecoration(
                        color: isUnlocked ? palette.primary : tokens.surfaceSubtle,
                        shape: BoxShape.circle,
                        boxShadow: isActive
                            ? [BoxShadow(color: palette.primary.withOpacity(0.6), blurRadius: 10, spreadRadius: 2)]
                            : null,
                      ),
                      child: Icon(
                        isUnlocked ? Icons.check_rounded : Icons.lock_outline_rounded,
                        color: isUnlocked ? Colors.white : tokens.textTertiary,
                        size: 14,
                      ),
                    ),
                    SizedBox(width: tokens.space16),
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                displayName,
                                style: tokens.titleSmall.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: isUnlocked ? tokens.textPrimary : tokens.textTertiary,
                                ),
                              ),
                              Text(s.dayRangeText, style: tokens.bodySmall.copyWith(color: tokens.textSecondary)),
                            ],
                          ),
                          if (isActive)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                gradient: palette.gradient,
                                borderRadius: BorderRadius.circular(tokens.radiusXs),
                              ),
                              child: Text(
                                l10n.streakActiveBadge,
                                style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w800),
                              ),
                            )
                          else if (isPreviewing)
                            Icon(Icons.visibility_rounded, size: 16, color: palette.primary)
                          else if (kTesterUnlockStages && !isUnlocked)
                            Icon(Icons.visibility_outlined, size: 16, color: tokens.textTertiary),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );

          if (!kTesterUnlockStages) return row;
          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => _previewStageDialog(s),
            child: row,
          );
        }),
      ),
    );
  }

  Widget _buildMilestones(AppLocalizations l10n) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: details.milestones.length,
      itemBuilder: (context, index) {
        final m = details.milestones[index];
        return Container(
          margin: EdgeInsets.only(bottom: tokens.space10),
          padding: EdgeInsets.all(tokens.space12),
          decoration: BoxDecoration(
            color: tokens.surfaceCard,
            borderRadius: BorderRadius.circular(tokens.radiusM),
            border: Border.all(
              color: m.unlocked ? tokens.brandPrimary.withOpacity(0.3) : tokens.borderSubtle,
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                m.unlocked ? Icons.stars_rounded : Icons.stars_outlined,
                color: m.unlocked ? tokens.brandPrimary : tokens.textTertiary,
                size: 28,
              ),
              SizedBox(width: tokens.space12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      m.name,
                      style: tokens.titleSmall.copyWith(
                        fontWeight: FontWeight.bold,
                        color: m.unlocked ? tokens.textPrimary : tokens.textSecondary,
                      ),
                    ),
                    Text(m.desc, style: tokens.bodySmall.copyWith(color: tokens.textSecondary)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: m.unlocked ? tokens.brandPrimary.withOpacity(0.1) : tokens.surfaceSubtle,
                  borderRadius: BorderRadius.circular(tokens.radiusXs),
                ),
                child: Text(
                  '+${m.xp} XP',
                  style: tokens.labelSmall.copyWith(
                    color: m.unlocked ? tokens.brandPrimary : tokens.textTertiary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildActivityGrid() {
    final start = DateTime.parse(details.calendar.startDate);
    final dates = List.generate(30, (i) => start.add(Duration(days: i)));
    final activeSet = Set<String>.from(details.calendar.activeDates);

    return Container(
      padding: EdgeInsets.all(tokens.space16),
      decoration: BoxDecoration(
        color: tokens.surfaceCard,
        borderRadius: BorderRadius.circular(tokens.radiusL),
        boxShadow: tokens.shadowCard,
      ),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 30,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 7,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        itemBuilder: (context, index) {
          final day = dates[index];
          final dateStr = '${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}';
          final isActive = activeSet.contains(dateStr);

          return Tooltip(
            message: '$dateStr: ${isActive ? "Active" : "Inactive"}',
            child: Container(
              decoration: BoxDecoration(
                color: isActive ? tokens.brandPrimary : tokens.surfaceSubtle,
                borderRadius: BorderRadius.circular(tokens.radiusXs),
              ),
              child: Center(
                child: Text(
                  '${day.day}',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: isActive ? Colors.white : tokens.textSecondary,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildRewardsHistory(AppLocalizations l10n) {
    if (details.rewardsHistory.isEmpty) {
      return Container(
        padding: EdgeInsets.all(tokens.space16),
        alignment: Alignment.center,
        child: Text(
          l10n.streakNoRewards,
          style: tokens.bodyMedium.copyWith(color: tokens.textTertiary),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: tokens.surfaceCard,
        borderRadius: BorderRadius.circular(tokens.radiusL),
        boxShadow: tokens.shadowCard,
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: details.rewardsHistory.length,
        separatorBuilder: (_, __) => Divider(color: tokens.borderSubtle, height: 1),
        itemBuilder: (context, index) {
          final r = details.rewardsHistory[index];
          return ListTile(
            leading: const Icon(Icons.workspace_premium_rounded, color: Color(0xFFF59E0B)),
            title: Text(r.name, style: tokens.titleSmall.copyWith(fontWeight: FontWeight.bold)),
            subtitle: Text('Claimed on ${r.unlockedAt.substring(0, 10)}', style: tokens.bodySmall),
            trailing: Text(
              '+${r.xp} XP',
              style: tokens.labelMedium.copyWith(color: tokens.brandPrimary, fontWeight: FontWeight.bold),
            ),
          );
        },
      ),
    );
  }
}

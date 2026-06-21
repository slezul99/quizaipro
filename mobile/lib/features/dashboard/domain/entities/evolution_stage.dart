import 'package:flutter/material.dart';
import 'package:quizaipro_mobile/l10n/app_localizations.dart';

enum EvolutionStage {
  seed,
  sprout,
  youngTree,
  bloomingTree,
  ancientTree,
  legendaryTree,
  eternalTree;

  static EvolutionStage fromKey(String key) {
    switch (key) {
      case 'sprout': return EvolutionStage.sprout;
      case 'young_tree': return EvolutionStage.youngTree;
      case 'blooming_tree': return EvolutionStage.bloomingTree;
      case 'ancient_tree': return EvolutionStage.ancientTree;
      case 'legendary_tree': return EvolutionStage.legendaryTree;
      case 'eternal_tree': return EvolutionStage.eternalTree;
      default: return EvolutionStage.seed;
    }
  }

  String getLocalizedName(AppLocalizations l10n) {
    switch (this) {
      case EvolutionStage.seed: return l10n.streakStageSeed;
      case EvolutionStage.sprout: return l10n.streakStageSprout;
      case EvolutionStage.youngTree: return l10n.streakStageYoungTree;
      case EvolutionStage.bloomingTree: return l10n.streakStageBloomingTree;
      case EvolutionStage.ancientTree: return l10n.streakStageAncientTree;
      case EvolutionStage.legendaryTree: return l10n.streakStageLegendaryTree;
      case EvolutionStage.eternalTree: return l10n.streakStageEternalTree;
    }
  }

  String get dayRangeText {
    switch (this) {
      case EvolutionStage.seed: return '1-2 days';
      case EvolutionStage.sprout: return '3-6 days';
      case EvolutionStage.youngTree: return '7-13 days';
      case EvolutionStage.bloomingTree: return '14-29 days';
      case EvolutionStage.ancientTree: return '30-59 days';
      case EvolutionStage.legendaryTree: return '60-364 days';
      case EvolutionStage.eternalTree: return '365+ days';
    }
  }

  EvolutionStage? get next {
    switch (this) {
      case EvolutionStage.seed: return EvolutionStage.sprout;
      case EvolutionStage.sprout: return EvolutionStage.youngTree;
      case EvolutionStage.youngTree: return EvolutionStage.bloomingTree;
      case EvolutionStage.bloomingTree: return EvolutionStage.ancientTree;
      case EvolutionStage.ancientTree: return EvolutionStage.legendaryTree;
      case EvolutionStage.legendaryTree: return EvolutionStage.eternalTree;
      case EvolutionStage.eternalTree: return null;
    }
  }

  int get startDays {
    switch (this) {
      case EvolutionStage.seed: return 0;
      case EvolutionStage.sprout: return 3;
      case EvolutionStage.youngTree: return 7;
      case EvolutionStage.bloomingTree: return 14;
      case EvolutionStage.ancientTree: return 30;
      case EvolutionStage.legendaryTree: return 60;
      case EvolutionStage.eternalTree: return 365;
    }
  }

  EvolutionPalette get palette {
    switch (this) {
      case EvolutionStage.seed:
        return const EvolutionPalette(
          primary: Color(0xFFb58d63),
          secondary: Color(0xFF7c5d3f),
          accent: Color(0xFF966F46),
          gradient: LinearGradient(
            colors: [Color(0xFF5a3c22), Color(0xFF966f46)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        );
      case EvolutionStage.sprout:
        return const EvolutionPalette(
          primary: Color(0xFF4ade80),
          secondary: Color(0xFF22c55e),
          accent: Color(0xFF10b981),
          gradient: LinearGradient(
            colors: [Color(0xFF166534), Color(0xFF22c55e)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        );
      case EvolutionStage.youngTree:
        return const EvolutionPalette(
          primary: Color(0xFF0ea5e9),
          secondary: Color(0xFF0369a1),
          accent: Color(0xFF0284c7),
          gradient: LinearGradient(
            colors: [Color(0xFF075985), Color(0xFF0ea5e9)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        );
      case EvolutionStage.bloomingTree:
        return const EvolutionPalette(
          primary: Color(0xFFec4899),
          secondary: Color(0xFFdb2777),
          accent: Color(0xFFf472b6),
          gradient: LinearGradient(
            colors: [Color(0xFF9d174d), Color(0xFFec4899)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        );
      case EvolutionStage.ancientTree:
        return const EvolutionPalette(
          primary: Color(0xFFf59e0b),
          secondary: Color(0xFFd97706),
          accent: Color(0xFFb45309),
          gradient: LinearGradient(
            colors: [Color(0xFF78350f), Color(0xFFf59e0b)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        );
      case EvolutionStage.legendaryTree:
        return const EvolutionPalette(
          primary: Color(0xFFa855f7),
          secondary: Color(0xFFec4899),
          accent: Color(0xFF6366f1),
          gradient: LinearGradient(
            colors: [Color(0xFF4c1d95), Color(0xFFa855f7), Color(0xFFdb2777)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        );
      case EvolutionStage.eternalTree:
        return const EvolutionPalette(
          primary: Color(0xFFFCD34D),
          secondary: Color(0xFFB45309),
          accent: Color(0xFF111827),
          gradient: LinearGradient(
            colors: [Color(0xFF0B1220), Color(0xFFB45309), Color(0xFFFCD34D)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        );
    }
  }
}

class EvolutionPalette {
  final Color primary;
  final Color secondary;
  final Color accent;
  final LinearGradient gradient;

  const EvolutionPalette({
    required this.primary,
    required this.secondary,
    required this.accent,
    required this.gradient,
  });
}

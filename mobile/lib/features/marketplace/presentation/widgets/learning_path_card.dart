import 'package:flutter/material.dart';
import 'package:quizaipro_mobile/l10n/app_localizations.dart';

import 'package:quizaipro_mobile/core/theme/aurora_tokens.dart';
import 'package:quizaipro_mobile/features/marketplace/domain/entities/learning_path.dart';

class LearningPathCard extends StatelessWidget {
  const LearningPathCard({
    super.key,
    required this.path,
    required this.onTap,
    required this.tokens,
    required this.enrollLabel,
  });

  final LearningPath path;
  final VoidCallback onTap;
  final AuroraTokens tokens;
  final String enrollLabel;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;
    final coverColor = _hexToColor(path.coverColorHex);
    final (diffLabel, diffColor) = _difficultyInfo(l10n, path.difficulty);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: tokens.backgroundSurface,
          borderRadius: BorderRadius.circular(tokens.radiusLg),
          border: Border.all(color: tokens.borderSubtle),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header strip
            Container(
              height: 96,
              decoration: BoxDecoration(
                color: coverColor,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(tokens.radiusLg),
                ),
              ),
              padding: EdgeInsets.all(tokens.space16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.route_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                  const Spacer(),
                  _DifficultyBadge(
                    label: diffLabel,
                    color: diffColor,
                    tokens: tokens,
                  ),
                ],
              ),
            ),
            // Info
            Padding(
              padding: EdgeInsets.all(tokens.space16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    path.title,
                    style: tt.titleMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: tokens.space4),
                  Text(
                    path.description,
                    style: tt.bodySmall,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: tokens.space12),
                  Row(
                    children: [
                      _StatChip(
                        icon: Icons.style_outlined,
                        label: l10n.marketplaceDeckCount(path.deckCount),
                        tokens: tokens,
                      ),
                      SizedBox(width: tokens.space8),
                      _StatChip(
                        icon: Icons.access_time_rounded,
                        label: l10n.marketplaceHours(path.estimatedHours),
                        tokens: tokens,
                      ),
                      SizedBox(width: tokens.space8),
                      _StatChip(
                        icon: Icons.people_outline_rounded,
                        label: _formatCount(path.enrolledCount),
                        tokens: tokens,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  (String, Color) _difficultyInfo(AppLocalizations l10n, PathDifficulty difficulty) => switch (difficulty) {
        PathDifficulty.beginner => (l10n.libraryFilterDifficultyBeginner, const Color(0xFF10B981)),
        PathDifficulty.intermediate => (l10n.libraryFilterDifficultyIntermediate, const Color(0xFFF59E0B)),
        PathDifficulty.advanced => (l10n.libraryFilterDifficultyAdvanced, const Color(0xFFEF4444)),
      };

  String _formatCount(int count) {
    if (count >= 1000) return '${(count / 1000).toStringAsFixed(1)}k';
    return '$count';
  }

  Color _hexToColor(String hex) {
    final clean = hex.replaceAll('#', '');
    try {
      return Color(int.parse('FF$clean', radix: 16));
    } catch (_) {
      return const Color(0xFF6366F1);
    }
  }
}

class _DifficultyBadge extends StatelessWidget {
  const _DifficultyBadge({
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
        color: Colors.black.withOpacity(0.2),
        borderRadius: BorderRadius.circular(tokens.radiusFull),
        border: Border.all(color: color.withOpacity(0.6)),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.icon,
    required this.label,
    required this.tokens,
  });

  final IconData icon;
  final String label;
  final AuroraTokens tokens;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: tokens.textTertiary),
        SizedBox(width: tokens.space4),
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall,
        ),
      ],
    );
  }
}

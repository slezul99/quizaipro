import 'package:flutter/material.dart';

import 'package:quizaipro_mobile/core/theme/aurora_tokens.dart';
import 'package:quizaipro_mobile/features/library/domain/entities/library_deck.dart';
import 'package:quizaipro_mobile/l10n/app_localizations.dart';

/// Library deck card — emblem-led layout. Instead of a flat colour banner the
/// deck colour now lives in a rounded gradient emblem carrying the deck's
/// initial, over a clean surface card. Content type (cards / test) and the due
/// count read as pills below the title.
class LibraryDeckCard extends StatelessWidget {
  const LibraryDeckCard({
    super.key,
    required this.deck,
    required this.tokens,
    required this.onTap,
    required this.onActionsTap,
  });

  final LibraryDeck deck;
  final AuroraTokens tokens;
  final VoidCallback onTap;
  final VoidCallback onActionsTap;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final l = AppLocalizations.of(context)!;
    final cover = _hexToColor(deck.coverColorHex);
    final initial =
        deck.title.trim().isNotEmpty ? deck.title.trim()[0].toUpperCase() : '?';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(tokens.space12),
        decoration: BoxDecoration(
          color: tokens.backgroundSurface,
          borderRadius: BorderRadius.circular(tokens.radiusLg),
          border: Border.all(color: tokens.borderSubtle),
          boxShadow: [
            BoxShadow(
              color: cover.withValues(alpha: 0.10),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Emblem with deck initial
                Container(
                  width: 46,
                  height: 46,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [cover, Color.lerp(cover, Colors.black, 0.22)!],
                    ),
                    borderRadius: BorderRadius.circular(tokens.radiusMd),
                    boxShadow: [
                      BoxShadow(
                        color: cover.withValues(alpha: 0.35),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Text(
                    initial,
                    style: tt.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                const Spacer(),
                if (deck.isFavorite)
                  Padding(
                    padding: EdgeInsets.only(right: tokens.space4),
                    child: Icon(Icons.favorite_rounded,
                        size: 15, color: tokens.stateError),
                  ),
                GestureDetector(
                  onTap: onActionsTap,
                  child: Icon(Icons.more_vert_rounded,
                      size: 20, color: tokens.textTertiary),
                ),
              ],
            ),
            SizedBox(height: tokens.space12),
            Text(
              deck.title,
              style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w700),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: tokens.space8),
            // Count + due
            Row(
              children: [
                Icon(Icons.style_rounded, size: 13, color: tokens.textTertiary),
                SizedBox(width: tokens.space4),
                Text(
                  '${deck.cardCount}',
                  style: tt.labelSmall?.copyWith(color: tokens.textTertiary),
                ),
                if (deck.dueCount > 0) ...[
                  SizedBox(width: tokens.space8),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: tokens.space8,
                      vertical: 1,
                    ),
                    decoration: BoxDecoration(
                      color: tokens.stateError.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(tokens.radiusFull),
                    ),
                    child: Text(
                      '${deck.dueCount}',
                      style: tt.labelSmall?.copyWith(
                        color: tokens.stateError,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
                if (deck.isArchived) ...[
                  SizedBox(width: tokens.space8),
                  Icon(Icons.archive_outlined,
                      size: 13, color: tokens.textTertiary),
                ],
              ],
            ),
            SizedBox(height: tokens.space10),
            // Content-type badges
            Wrap(
              spacing: tokens.space4,
              runSpacing: tokens.space4,
              children: [
                if (deck.hasFlashcards)
                  _TypeBadge(
                    icon: Icons.style_rounded,
                    label: l.marketplaceCards,
                    color: tokens.brandGradientStart,
                    tokens: tokens,
                  ),
                if (deck.hasTests)
                  _TypeBadge(
                    icon: Icons.fact_check_rounded,
                    label: l.cardTileQuizChip,
                    color: tokens.stateInfo,
                    tokens: tokens,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
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

/// Small pill showing a deck's content type (flashcards / tests).
class _TypeBadge extends StatelessWidget {
  const _TypeBadge({
    required this.icon,
    required this.label,
    required this.color,
    required this.tokens,
  });

  final IconData icon;
  final String label;
  final Color color;
  final AuroraTokens tokens;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: tokens.space8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(tokens.radiusFull),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: color),
          SizedBox(width: tokens.space4),
          Text(
            label,
            style: tt.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}

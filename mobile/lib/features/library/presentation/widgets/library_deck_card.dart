import 'package:flutter/material.dart';

import 'package:quizaipro_mobile/core/theme/aurora_tokens.dart';
import 'package:quizaipro_mobile/features/library/domain/entities/library_deck.dart';
import 'package:quizaipro_mobile/l10n/app_localizations.dart';

/// Library deck card — illustration-forward grid tile.
///
///  • a tinted "artwork" zone filling the top of the card: the deck's emoji
///    on a soft cover-coloured gradient with a stacked-card motif + glow,
///  • a small avatar badge (deck initial) and a `…` menu floating over it,
///  • a footer with the title, card/ due counts and a progress bar that ends
///    with the mastered percentage.
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
    final l = AppLocalizations.of(context);
    final cover = _hexToColor(deck.coverColorHex);
    final initial =
        deck.title.trim().isNotEmpty ? deck.title.trim()[0].toUpperCase() : '?';

    // "Mastered" share = cards that aren't currently due. New decks → 0%.
    final mastered = deck.cardCount > 0
        ? ((deck.cardCount - deck.dueCount).clamp(0, deck.cardCount)) /
            deck.cardCount
        : 0.0;
    final pct = (mastered * 100).round();

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        decoration: BoxDecoration(
          color: tokens.backgroundSurface,
          borderRadius: BorderRadius.circular(tokens.radiusLg),
          border: Border.all(color: cover.withValues(alpha: 0.12)),
          boxShadow: [
            BoxShadow(
              color: cover.withValues(alpha: 0.16),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(tokens.radiusLg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Artwork zone (emoji + decoration + floating controls) ──
              Expanded(
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    _DeckArtwork(cover: cover, icon: deck.icon),
                    Positioned(
                      top: 10,
                      left: 10,
                      child: _AvatarBadge(
                        initial: initial,
                        cover: cover,
                        surface: tokens.backgroundSurface,
                      ),
                    ),
                    Positioned(
                      top: 10,
                      right: 8,
                      child: Row(
                        children: [
                          if (deck.isFavorite)
                            Padding(
                              padding: const EdgeInsets.only(right: 4),
                              child: Icon(Icons.favorite_rounded,
                                  size: 15, color: tokens.stateError),
                            ),
                          GestureDetector(
                            onTap: onActionsTap,
                            behavior: HitTestBehavior.opaque,
                            child: Container(
                              width: 28,
                              height: 28,
                              alignment: Alignment.center,
                              child: Icon(Icons.more_horiz_rounded,
                                  size: 20, color: tokens.textTertiary),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // ── Footer (title, counts, progress + %) ──────────────────
              Padding(
                padding: EdgeInsets.fromLTRB(
                    tokens.space12, tokens.space10, tokens.space12, tokens.space12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      deck.title,
                      style: tt.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        height: 1.18,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: tokens.space4),
                    Row(
                      children: [
                        Text(
                          l.marketplaceCardCount(deck.cardCount),
                          style: tt.labelSmall?.copyWith(
                            color: tokens.textTertiary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (deck.dueCount > 0) ...[
                          SizedBox(width: tokens.space8),
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: tokens.stateError,
                              shape: BoxShape.circle,
                            ),
                          ),
                          SizedBox(width: tokens.space4),
                          Text(
                            '${deck.dueCount}',
                            style: tt.labelSmall?.copyWith(
                              color: tokens.stateError,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                        if (deck.isArchived) ...[
                          SizedBox(width: tokens.space8),
                          Icon(Icons.archive_rounded,
                              size: 12, color: tokens.textTertiary),
                        ],
                      ],
                    ),
                    SizedBox(height: tokens.space10),
                    Row(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius:
                                BorderRadius.circular(tokens.radiusFull),
                            child: Stack(
                              children: [
                                Container(
                                    height: 6, color: tokens.surfaceSubtle),
                                FractionallySizedBox(
                                  widthFactor: mastered.clamp(0.03, 1.0),
                                  child: Container(
                                    height: 6,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          cover,
                                          Color.lerp(cover, Colors.white, 0.30)!,
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(width: tokens.space8),
                        Text(
                          '$pct%',
                          style: tt.labelSmall?.copyWith(
                            color: tokens.textSecondary,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
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

/// The tinted illustration area: the deck emoji on a soft cover-coloured
/// gradient, with a stacked-card motif and a glow behind the glyph.
class _DeckArtwork extends StatelessWidget {
  const _DeckArtwork({required this.cover, required this.icon});

  final Color cover;
  final String icon;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            cover.withValues(alpha: 0.16),
            cover.withValues(alpha: 0.05),
          ],
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Stacked-card motif behind the emoji.
          Transform.translate(
            offset: const Offset(10, 6),
            child: Transform.rotate(
              angle: 0.18,
              child: _MotifCard(color: cover.withValues(alpha: 0.16)),
            ),
          ),
          Transform.translate(
            offset: const Offset(-8, 2),
            child: Transform.rotate(
              angle: -0.12,
              child: _MotifCard(color: cover.withValues(alpha: 0.26)),
            ),
          ),
          // Soft glow.
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: cover.withValues(alpha: 0.35),
                  blurRadius: 26,
                  spreadRadius: 2,
                ),
              ],
            ),
          ),
          // Emoji.
          Text(icon, style: const TextStyle(fontSize: 44, height: 1)),
        ],
      ),
    );
  }
}

class _MotifCard extends StatelessWidget {
  const _MotifCard({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56,
      height: 70,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}

/// Small circular badge with the deck initial, sits over the artwork.
class _AvatarBadge extends StatelessWidget {
  const _AvatarBadge({
    required this.initial,
    required this.cover,
    required this.surface,
  });

  final String initial;
  final Color cover;
  final Color surface;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: surface,
        shape: BoxShape.circle,
        border: Border.all(color: cover.withValues(alpha: 0.35), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: cover.withValues(alpha: 0.18),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        initial,
        style: TextStyle(
          color: cover,
          fontWeight: FontWeight.w900,
          fontSize: 15,
        ),
      ),
    );
  }
}

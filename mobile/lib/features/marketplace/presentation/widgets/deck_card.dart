import 'package:flutter/material.dart';
import 'package:quizaipro_mobile/l10n/app_localizations.dart';

import 'package:quizaipro_mobile/core/theme/aurora_tokens.dart';
import 'package:quizaipro_mobile/features/marketplace/domain/entities/deck_summary.dart';

/// Marketplace deck card — mirrors the library's illustration-forward grid
/// tile: a tinted "artwork" zone (deck initial on a cover-coloured gradient
/// with a stacked-card motif + glow) above a footer with the title, author and
/// rating / clone-count social proof.
class DeckCard extends StatelessWidget {
  const DeckCard({
    super.key,
    required this.deck,
    required this.onTap,
    required this.tokens,
  });

  final DeckSummary deck;
  final VoidCallback onTap;
  final AuroraTokens tokens;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final l = AppLocalizations.of(context)!;
    final cover = _hexToColor(deck.coverColorHex);
    final initial =
        deck.title.trim().isNotEmpty ? deck.title.trim()[0].toUpperCase() : '?';

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
              // ── Artwork zone (initial glyph + motif + PRO badge) ──────────
              Expanded(
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    _DeckArtwork(cover: cover, glyph: initial),
                    if (deck.isPro)
                      Positioned(
                        top: tokens.space8,
                        right: tokens.space8,
                        child: _ProBadge(tokens: tokens),
                      ),
                    Positioned(
                      bottom: tokens.space8,
                      left: tokens.space12,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: tokens.space8,
                          vertical: tokens.space4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.28),
                          borderRadius:
                              BorderRadius.circular(tokens.radiusFull),
                        ),
                        child: Text(
                          l.marketplaceCardCount(deck.cardCount),
                          style: tt.labelSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // ── Footer (title, author, rating + clones) ───────────────────
              Padding(
                padding: EdgeInsets.fromLTRB(tokens.space12, tokens.space10,
                    tokens.space12, tokens.space12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      deck.title,
                      style: tt.titleSmall
                          ?.copyWith(fontWeight: FontWeight.w800, height: 1.18),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: tokens.space4),
                    Text(
                      deck.authorName,
                      style: tt.bodySmall?.copyWith(color: tokens.textTertiary),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: tokens.space10),
                    Row(
                      children: [
                        const Icon(Icons.star_rounded,
                            size: 14, color: Color(0xFFF59E0B)),
                        SizedBox(width: tokens.space4),
                        Text(
                          deck.rating.toStringAsFixed(1),
                          style: tt.labelSmall?.copyWith(
                            color: tokens.textSecondary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const Spacer(),
                        Icon(Icons.file_copy_outlined,
                            size: 13, color: tokens.textTertiary),
                        SizedBox(width: tokens.space4),
                        Text(
                          '${deck.cloneCount}',
                          style: tt.labelSmall
                              ?.copyWith(color: tokens.textTertiary),
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

/// Tinted illustration area: the deck initial on a soft cover-coloured
/// gradient, with a stacked-card motif and a glow behind the glyph.
class _DeckArtwork extends StatelessWidget {
  const _DeckArtwork({required this.cover, required this.glyph});

  final Color cover;
  final String glyph;

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
          Container(
            width: 60,
            height: 60,
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
          Text(
            glyph,
            style: TextStyle(
              fontSize: 40,
              height: 1,
              fontWeight: FontWeight.w900,
              color: cover,
            ),
          ),
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

class _ProBadge extends StatelessWidget {
  const _ProBadge({required this.tokens});

  final AuroraTokens tokens;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: tokens.space8,
        vertical: tokens.space4,
      ),
      decoration: BoxDecoration(
        gradient: tokens.brandGradient,
        borderRadius: BorderRadius.circular(tokens.radiusFull),
      ),
      child: Text(
        AppLocalizations.of(context)!.marketplaceProBadge,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
      ),
    );
  }
}

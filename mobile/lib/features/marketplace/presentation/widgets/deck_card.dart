import 'package:flutter/material.dart';
import 'package:quizaipro_mobile/l10n/app_localizations.dart';

import 'package:quizaipro_mobile/core/theme/aurora_tokens.dart';
import 'package:quizaipro_mobile/features/marketplace/domain/entities/deck_summary.dart';

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
    final coverColor = _hexToColor(deck.coverColorHex);

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
            // Cover strip
            Container(
              height: 80,
              decoration: BoxDecoration(
                color: coverColor,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(tokens.radiusLg),
                ),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    coverColor,
                    coverColor.withOpacity(0.7),
                  ],
                ),
              ),
              child: Stack(
                children: [
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
                        color: Colors.black.withOpacity(0.25),
                        borderRadius: BorderRadius.circular(tokens.radiusFull),
                      ),
                      child: Text(
                        AppLocalizations.of(context)!.marketplaceCardCount(deck.cardCount),
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
            // Info
            Padding(
              padding: EdgeInsets.all(tokens.space12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    deck.title,
                    style: tt.titleSmall,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: tokens.space4),
                  Text(
                    deck.authorName,
                    style: tt.bodySmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: tokens.space8),
                  Row(
                    children: [
                      Icon(
                        Icons.star_rounded,
                        size: 14,
                        color: const Color(0xFFF59E0B),
                      ),
                      SizedBox(width: tokens.space4),
                      Text(
                        deck.rating.toStringAsFixed(1),
                        style: tt.labelSmall?.copyWith(
                          color: tokens.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      Icon(
                        Icons.file_copy_outlined,
                        size: 13,
                        color: tokens.textTertiary,
                      ),
                      SizedBox(width: tokens.space4),
                      Text(
                        '${deck.cloneCount}',
                        style: tt.labelSmall?.copyWith(
                          color: tokens.textTertiary,
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

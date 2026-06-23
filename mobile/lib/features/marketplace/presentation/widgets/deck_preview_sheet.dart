import 'package:flutter/material.dart';

import 'package:quizaipro_mobile/core/theme/aurora_tokens.dart';
import 'package:quizaipro_mobile/features/marketplace/domain/entities/deck_card_preview.dart';

/// Marketplace deck preview — a scrollable list of the deck's sample cards with
/// both the question (front) and answer (back) visible, so a user can scan the
/// content and decide whether the deck is worth cloning.
class DeckPreviewSheet extends StatelessWidget {
  const DeckPreviewSheet({
    super.key,
    required this.cards,
    required this.deckTitle,
    required this.tokens,
    required this.previewLabel,
    required this.frontLabel,
    required this.backLabel,
  });

  final List<DeckCardPreview> cards;
  final String deckTitle;
  final AuroraTokens tokens;
  final String previewLabel;
  final String frontLabel;
  final String backLabel;

  @override
  Widget build(BuildContext context) {
    final t = tokens;
    final tt = Theme.of(context).textTheme;

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.7,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      builder: (_, controller) => Column(
        children: [
          SizedBox(height: t.space8),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: t.borderDefault,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          SizedBox(height: t.space12),
          Text(previewLabel, style: tt.titleMedium),
          SizedBox(height: t.space4),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: t.space20),
            child: Text(
              deckTitle,
              style: tt.bodySmall?.copyWith(color: t.textTertiary),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: t.space16),
          Expanded(
            child: ListView.separated(
              controller: controller,
              padding: EdgeInsets.fromLTRB(
                  t.space20, 0, t.space20, t.space32),
              itemCount: cards.length,
              separatorBuilder: (_, __) => SizedBox(height: t.space12),
              itemBuilder: (_, i) => _PreviewCardTile(
                index: i + 1,
                card: cards[i],
                tokens: t,
                frontLabel: frontLabel,
                backLabel: backLabel,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PreviewCardTile extends StatelessWidget {
  const _PreviewCardTile({
    required this.index,
    required this.card,
    required this.tokens,
    required this.frontLabel,
    required this.backLabel,
  });

  final int index;
  final DeckCardPreview card;
  final AuroraTokens tokens;
  final String frontLabel;
  final String backLabel;

  @override
  Widget build(BuildContext context) {
    final t = tokens;
    final tt = Theme.of(context).textTheme;
    return Container(
      padding: EdgeInsets.all(t.space16),
      decoration: BoxDecoration(
        color: t.backgroundSurfaceElevated,
        borderRadius: BorderRadius.circular(t.radiusLg),
        border: Border.all(color: t.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 24,
                height: 24,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  gradient: t.brandGradient,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '$index',
                  style: tt.labelSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              SizedBox(width: t.space12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      frontLabel.toUpperCase(),
                      style: tt.labelSmall?.copyWith(
                        color: t.textTertiary,
                        letterSpacing: 0.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: t.space4),
                    Text(
                      card.front,
                      style:
                          tt.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Padding(
            padding: EdgeInsets.only(top: t.space12, bottom: t.space12),
            child: Divider(height: 1, color: t.borderSubtle),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.subdirectory_arrow_right_rounded,
                  size: 18, color: t.textTertiary),
              SizedBox(width: t.space8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      backLabel.toUpperCase(),
                      style: tt.labelSmall?.copyWith(
                        color: t.textTertiary,
                        letterSpacing: 0.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: t.space4),
                    Text(
                      card.back,
                      style: tt.bodyMedium
                          ?.copyWith(color: t.textSecondary),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

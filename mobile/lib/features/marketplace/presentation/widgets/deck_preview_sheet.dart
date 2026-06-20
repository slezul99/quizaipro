import 'package:flutter/material.dart';

import 'package:quizaipro_mobile/core/theme/aurora_tokens.dart';
import 'package:quizaipro_mobile/features/marketplace/domain/entities/deck_card_preview.dart';

class DeckPreviewSheet extends StatefulWidget {
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
  State<DeckPreviewSheet> createState() => _DeckPreviewSheetState();
}

class _DeckPreviewSheetState extends State<DeckPreviewSheet> {
  int _current = 0;
  bool _showBack = false;

  @override
  Widget build(BuildContext context) {
    final t = widget.tokens;
    final tt = Theme.of(context).textTheme;
    final card = widget.cards[_current];

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.65,
      builder: (_, controller) => Padding(
        padding: EdgeInsets.fromLTRB(t.space20, t.space8, t.space20, t.space32),
        child: Column(
          children: [
            Text(widget.previewLabel, style: tt.titleMedium),
            SizedBox(height: t.space4),
            Text(
              widget.deckTitle,
              style: tt.bodySmall,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: t.space20),

            // Card flip
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _showBack = !_showBack),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder: (child, anim) => FadeTransition(
                    opacity: anim,
                    child: child,
                  ),
                  child: _CardFace(
                    key: ValueKey(_showBack),
                    text: _showBack ? card.back : card.front,
                    label: _showBack ? widget.backLabel : widget.frontLabel,
                    tokens: t,
                    isBack: _showBack,
                  ),
                ),
              ),
            ),
            SizedBox(height: t.space16),

            // Navigation dots
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: _current > 0
                      ? () => setState(() {
                            _current--;
                            _showBack = false;
                          })
                      : null,
                  icon: const Icon(Icons.chevron_left_rounded),
                ),
                ...List.generate(
                  widget.cards.length,
                  (i) => Container(
                    width: 8,
                    height: 8,
                    margin: EdgeInsets.symmetric(horizontal: t.space4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: i == _current
                          ? t.brandGradientStart
                          : t.borderDefault,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: _current < widget.cards.length - 1
                      ? () => setState(() {
                            _current++;
                            _showBack = false;
                          })
                      : null,
                  icon: const Icon(Icons.chevron_right_rounded),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CardFace extends StatelessWidget {
  const _CardFace({
    super.key,
    required this.text,
    required this.label,
    required this.tokens,
    required this.isBack,
  });

  final String text;
  final String label;
  final AuroraTokens tokens;
  final bool isBack;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(tokens.space24),
      decoration: BoxDecoration(
        color: isBack
            ? tokens.backgroundSurfaceElevated
            : tokens.backgroundSurface,
        borderRadius: BorderRadius.circular(tokens.radiusXl),
        border: Border.all(
          color: isBack
              ? tokens.brandGradientStart.withOpacity(0.3)
              : tokens.borderDefault,
          width: isBack ? 2 : 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: tokens.space12,
              vertical: tokens.space4,
            ),
            decoration: BoxDecoration(
              color: isBack
                  ? tokens.brandGradientStart.withOpacity(0.1)
                  : tokens.backgroundSurfaceElevated,
              borderRadius: BorderRadius.circular(tokens.radiusFull),
            ),
            child: Text(
              label,
              style: tt.labelSmall?.copyWith(
                color: isBack ? tokens.brandGradientStart : tokens.textTertiary,
              ),
            ),
          ),
          SizedBox(height: tokens.space20),
          Text(
            text,
            style: tt.bodyLarge?.copyWith(fontWeight: FontWeight.w500),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

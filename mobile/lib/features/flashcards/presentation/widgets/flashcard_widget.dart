import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:quizaipro_mobile/core/theme/aurora_tokens.dart';
import 'package:quizaipro_mobile/core/utils/mcq_text.dart';
import 'package:quizaipro_mobile/features/flashcards/domain/entities/study_card.dart';
import 'package:quizaipro_mobile/l10n/app_localizations.dart';

class FlashcardWidget extends StatefulWidget {
  const FlashcardWidget({
    super.key,
    required this.card,
    required this.isFlipped,
    required this.onTap,
    required this.tapLabel,
  });

  final StudyCard card;
  final bool isFlipped;
  final VoidCallback onTap;
  final String tapLabel;

  @override
  State<FlashcardWidget> createState() => _FlashcardWidgetState();
}

class _FlashcardWidgetState extends State<FlashcardWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  String? _prevCardId;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 380),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    _prevCardId = widget.card.id;
  }

  @override
  void didUpdateWidget(FlashcardWidget old) {
    super.didUpdateWidget(old);
    if (widget.card.id != _prevCardId) {
      _prevCardId = widget.card.id;
      _controller.reset();
    } else if (widget.isFlipped != old.isFlipped) {
      if (widget.isFlipped) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, _) {
          final angle = _animation.value * math.pi;
          final showFront = angle < math.pi / 2;
          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateY(angle),
            child: showFront
                ? _CardFace(
                    card: widget.card,
                    isFront: true,
                    tapLabel: widget.tapLabel,
                  )
                : Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()..rotateY(math.pi),
                    child: _CardFace(
                      card: widget.card,
                      isFront: false,
                      tapLabel: widget.tapLabel,
                    ),
                  ),
          );
        },
      ),
    );
  }
}

class _CardFace extends StatelessWidget {
  const _CardFace({
    required this.card,
    required this.isFront,
    required this.tapLabel,
  });

  final StudyCard card;
  final bool isFront;
  final String tapLabel;

  @override
  Widget build(BuildContext context) {
    final tokens = context.aurora;
    final tt = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;

    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 280),
      decoration: BoxDecoration(
        color: tokens.backgroundSurface,
        borderRadius: BorderRadius.circular(tokens.radiusXl),
        border: Border.all(color: tokens.borderDefault),
        boxShadow: [
          BoxShadow(
            color: tokens.borderDefault.withOpacity(0.4),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(tokens.space32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: tokens.space12,
                    vertical: tokens.space4,
                  ),
                  decoration: BoxDecoration(
                    color: isFront
                        ? tokens.stateInfoSurface
                        : tokens.stateSuccessSurface,
                    borderRadius:
                        BorderRadius.circular(tokens.radiusFull),
                  ),
                  child: Text(
                    isFront ? l10n.flashcardsCardFront : l10n.flashcardsCardBack,
                    style: tt.labelSmall?.copyWith(
                      color: isFront
                          ? tokens.stateInfo
                          : tokens.stateSuccess,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (card.isFavorite)
                  Icon(Icons.favorite,
                      size: 18, color: tokens.stateError),
              ],
            ),
            SizedBox(height: tokens.space32),
            Text(
              isFront ? mcqStem(card.front) : card.back,
              style: tt.headlineSmall?.copyWith(
                color: tokens.textPrimary,
                fontWeight: FontWeight.w600,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            if (!isFront && card.hint != null) ...[
              SizedBox(height: tokens.space16),
              Container(
                padding: EdgeInsets.all(tokens.space12),
                decoration: BoxDecoration(
                  color: tokens.backgroundSurfaceElevated,
                  borderRadius:
                      BorderRadius.circular(tokens.radiusMd),
                ),
                child: Text(
                  card.hint!,
                  style: tt.bodyMedium?.copyWith(
                    color: tokens.textSecondary,
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
            SizedBox(height: tokens.space32),
            if (isFront)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.touch_app_outlined,
                      size: 16, color: tokens.textTertiary),
                  SizedBox(width: tokens.space4),
                  Text(
                    tapLabel,
                    style: tt.bodySmall
                        ?.copyWith(color: tokens.textTertiary),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

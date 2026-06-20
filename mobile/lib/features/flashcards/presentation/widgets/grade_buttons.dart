import 'package:flutter/material.dart';

import 'package:quizaipro_mobile/core/theme/aurora_tokens.dart';
import 'package:quizaipro_mobile/features/flashcards/domain/entities/card_grade.dart';

class GradeButtons extends StatelessWidget {
  const GradeButtons({
    super.key,
    required this.onGrade,
    required this.visible,
    required this.labels,
  });

  final void Function(CardGrade) onGrade;
  final bool visible;

  /// [again, hard, good, easy]
  final List<String> labels;

  @override
  Widget build(BuildContext context) {
    return AnimatedSlide(
      offset: visible ? Offset.zero : const Offset(0, 1.2),
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
      child: AnimatedOpacity(
        opacity: visible ? 1 : 0,
        duration: const Duration(milliseconds: 200),
        child: Row(
          children: [
            _GradeButton(
              grade: CardGrade.again,
              label: labels[0],
              onTap: () => onGrade(CardGrade.again),
            ),
            _GradeButton(
              grade: CardGrade.hard,
              label: labels[1],
              onTap: () => onGrade(CardGrade.hard),
            ),
            _GradeButton(
              grade: CardGrade.good,
              label: labels[2],
              onTap: () => onGrade(CardGrade.good),
            ),
            _GradeButton(
              grade: CardGrade.easy,
              label: labels[3],
              onTap: () => onGrade(CardGrade.easy),
            ),
          ],
        ),
      ),
    );
  }
}

class _GradeButton extends StatelessWidget {
  const _GradeButton({
    required this.grade,
    required this.label,
    required this.onTap,
  });

  final CardGrade grade;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = context.aurora;
    final tt = Theme.of(context).textTheme;

    final (bg, fg) = switch (grade) {
      CardGrade.again => (tokens.stateErrorSurface, tokens.stateError),
      CardGrade.hard =>
        (tokens.stateWarningSurface, tokens.stateWarning),
      CardGrade.good =>
        (tokens.stateSuccessSurface, tokens.stateSuccess),
      CardGrade.easy =>
        (tokens.stateInfoSurface, tokens.brandGradientStart),
    };

    return Expanded(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: tokens.space4),
        child: Material(
          color: bg,
          borderRadius: BorderRadius.circular(tokens.radiusMd),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(tokens.radiusMd),
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: tokens.space16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(_iconFor(grade), color: fg, size: 20),
                  SizedBox(height: tokens.space4),
                  Text(
                    label,
                    style: tt.labelSmall?.copyWith(
                      color: fg,
                      fontWeight: FontWeight.w700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  IconData _iconFor(CardGrade g) => switch (g) {
        CardGrade.again => Icons.replay_rounded,
        CardGrade.hard => Icons.sentiment_dissatisfied_rounded,
        CardGrade.good => Icons.check_rounded,
        CardGrade.easy => Icons.bolt_rounded,
      };
}

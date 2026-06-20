import 'package:flutter/material.dart';

import 'package:quizaipro_mobile/core/theme/aurora_tokens.dart';
import 'package:quizaipro_mobile/features/ai_generation/domain/entities/generated_card.dart';

class GeneratedCardPreview extends StatelessWidget {
  const GeneratedCardPreview({
    super.key,
    required this.card,
    required this.index,
    required this.isSelected,
    required this.onToggle,
  });

  final GeneratedCard card;
  final int index;
  final bool isSelected;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final aurora = context.aurora;
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onToggle,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: EdgeInsets.only(bottom: aurora.space12),
        decoration: BoxDecoration(
          color: aurora.backgroundSurface,
          border: Border.all(
            color:
                isSelected ? aurora.brandGradientStart : aurora.borderDefault,
            width: isSelected ? 1.5 : 1,
          ),
          borderRadius: BorderRadius.circular(aurora.radiusMd),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Checkbox area
            Container(
              width: 48,
              padding: EdgeInsets.all(aurora.space12),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: isSelected
                      ? aurora.brandGradientStart
                      : Colors.transparent,
                  border: Border.all(
                    color: isSelected
                        ? aurora.brandGradientStart
                        : aurora.borderDefault,
                    width: 1.5,
                  ),
                  borderRadius: BorderRadius.circular(aurora.radiusXs),
                ),
                child: isSelected
                    ? const Icon(Icons.check_rounded,
                        size: 14, color: Colors.white)
                    : null,
              ),
            ),
            // Content
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  top: aurora.space12,
                  right: aurora.space12,
                  bottom: aurora.space12,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (card.topic.isNotEmpty)
                      Container(
                        margin: EdgeInsets.only(bottom: aurora.space8),
                        padding: EdgeInsets.symmetric(
                          horizontal: aurora.space8,
                          vertical: aurora.space2,
                        ),
                        decoration: BoxDecoration(
                          color: aurora.brandGradientStart.withOpacity(0.1),
                          borderRadius:
                              BorderRadius.circular(aurora.radiusFull),
                        ),
                        child: Text(
                          card.topic,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: aurora.brandGradientStart,
                          ),
                        ),
                      ),
                    Text(
                      card.question,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: aurora.textPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: aurora.space8),
                    Container(
                      width: double.infinity,
                      height: 1,
                      color: aurora.borderSubtle,
                    ),
                    SizedBox(height: aurora.space8),
                    Text(
                      card.answer,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: aurora.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

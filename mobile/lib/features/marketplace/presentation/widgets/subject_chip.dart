import 'package:flutter/material.dart';

import 'package:quizaipro_mobile/core/theme/aurora_tokens.dart';
import 'package:quizaipro_mobile/features/marketplace/domain/entities/subject.dart';

class SubjectChip extends StatelessWidget {
  const SubjectChip({
    super.key,
    required this.subject,
    required this.selected,
    required this.onTap,
    required this.tokens,
  });

  final Subject subject;
  final bool selected;
  final VoidCallback onTap;
  final AuroraTokens tokens;

  @override
  Widget build(BuildContext context) {
    final color = _hexToColor(subject.colorHex);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
          horizontal: tokens.space16,
          vertical: tokens.space8,
        ),
        decoration: BoxDecoration(
          color: selected ? color : tokens.backgroundSurface,
          borderRadius: BorderRadius.circular(tokens.radiusFull),
          border: Border.all(
            color: selected ? color : tokens.borderDefault,
            width: selected ? 0 : 1,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: color.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  )
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              String.fromCharCode(
                int.tryParse(subject.iconCode, radix: 16) ?? 0x1F4DA,
              ),
              style: const TextStyle(fontSize: 16),
            ),
            SizedBox(width: tokens.space8),
            Text(
              subject.name,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: selected ? Colors.white : tokens.textPrimary,
                    fontWeight:
                        selected ? FontWeight.w700 : FontWeight.w500,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Color _hexToColor(String hex) {
    final clean = hex.replaceAll('#', '');
    return Color(int.parse('FF$clean', radix: 16));
  }
}

import 'package:flutter/material.dart';

import 'package:quizaipro_mobile/core/theme/aurora_tokens.dart';

class SessionProgressBar extends StatelessWidget {
  const SessionProgressBar({
    super.key,
    required this.progress,
    required this.currentIndex,
    required this.total,
  });

  final double progress;
  final int currentIndex;
  final int total;

  @override
  Widget build(BuildContext context) {
    final tokens = context.aurora;
    final tt = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${(progress * 100).round()}%',
              style: tt.labelMedium?.copyWith(
                color: tokens.brandGradientStart,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              '$currentIndex / $total',
              style: tt.labelMedium?.copyWith(
                color: tokens.textSecondary,
              ),
            ),
          ],
        ),
        SizedBox(height: tokens.space8),
        ClipRRect(
          borderRadius: BorderRadius.circular(tokens.radiusFull),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 6,
            backgroundColor: tokens.borderSubtle,
            valueColor: AlwaysStoppedAnimation<Color>(
              tokens.brandGradientStart,
            ),
          ),
        ),
      ],
    );
  }
}

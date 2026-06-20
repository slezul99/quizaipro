import 'package:flutter/material.dart';

import 'package:quizaipro_mobile/core/theme/aurora_tokens.dart';

class TestProgressBar extends StatelessWidget {
  const TestProgressBar({
    super.key,
    required this.current,
    required this.total,
  });

  final int current;
  final int total;

  @override
  Widget build(BuildContext context) {
    final aurora = context.aurora;
    final progress = total == 0 ? 0.0 : current / total;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '$current / $total',
              style: Theme.of(context)
                  .textTheme
                  .labelMedium
                  ?.copyWith(color: aurora.textSecondary),
            ),
            Text(
              '${(progress * 100).round()}%',
              style: Theme.of(context)
                  .textTheme
                  .labelMedium
                  ?.copyWith(color: aurora.textSecondary),
            ),
          ],
        ),
        SizedBox(height: aurora.space4),
        ClipRRect(
          borderRadius: BorderRadius.circular(aurora.radiusFull),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 6,
            backgroundColor: aurora.borderSubtle,
            valueColor: AlwaysStoppedAnimation<Color>(aurora.brandGradientStart),
          ),
        ),
      ],
    );
  }
}

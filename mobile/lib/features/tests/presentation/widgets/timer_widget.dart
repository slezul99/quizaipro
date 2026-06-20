import 'package:flutter/material.dart';

import 'package:quizaipro_mobile/core/theme/aurora_tokens.dart';

class TimerWidget extends StatelessWidget {
  const TimerWidget({super.key, required this.remainingSeconds});

  final int remainingSeconds;

  String get _formatted {
    final m = remainingSeconds ~/ 60;
    final s = remainingSeconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final aurora = context.aurora;
    final isLow = remainingSeconds <= 30;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: aurora.space12,
        vertical: aurora.space4,
      ),
      decoration: BoxDecoration(
        color: isLow ? aurora.stateErrorSurface : aurora.backgroundSurfaceElevated,
        borderRadius: BorderRadius.circular(aurora.radiusSm),
        border: Border.all(
          color: isLow ? aurora.stateError : aurora.borderDefault,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.timer_outlined,
            size: 16,
            color: isLow ? aurora.stateError : aurora.textSecondary,
          ),
          SizedBox(width: aurora.space4),
          Text(
            _formatted,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: isLow ? aurora.stateError : aurora.textPrimary,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
          ),
        ],
      ),
    );
  }
}

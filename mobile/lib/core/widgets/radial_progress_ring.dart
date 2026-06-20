import 'dart:math';

import 'package:flutter/material.dart';

/// A static circular progress indicator drawn as a ring with a gradient
/// stroke. Used for compact stat displays (level badge, daily goal) where
/// a calm, non-animated visual is preferred over a linear bar.
class RadialProgressRing extends StatelessWidget {
  const RadialProgressRing({
    super.key,
    required this.progress,
    required this.size,
    required this.strokeWidth,
    required this.backgroundColor,
    required this.progressGradient,
    this.child,
  });

  /// 0.0 - 1.0, clamped before drawing.
  final double progress;
  final double size;
  final double strokeWidth;
  final Color backgroundColor;
  final Gradient progressGradient;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size(size, size),
            painter: _RingPainter(
              progress: progress.clamp(0.0, 1.0),
              strokeWidth: strokeWidth,
              backgroundColor: backgroundColor,
              progressGradient: progressGradient,
            ),
          ),
          if (child != null) child!,
        ],
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({
    required this.progress,
    required this.strokeWidth,
    required this.backgroundColor,
    required this.progressGradient,
  });

  final double progress;
  final double strokeWidth;
  final Color backgroundColor;
  final Gradient progressGradient;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = (size.shortestSide - strokeWidth) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    final backgroundPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, backgroundPaint);

    if (progress <= 0) return;

    final progressPaint = Paint()
      ..shader = progressGradient.createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(rect, -pi / 2, 2 * pi * progress, false, progressPaint);
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.backgroundColor != backgroundColor ||
        oldDelegate.progressGradient != progressGradient;
  }
}

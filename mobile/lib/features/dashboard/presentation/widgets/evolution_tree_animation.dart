import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:quizaipro_mobile/features/dashboard/domain/entities/evolution_stage.dart';

class EvolutionTreeAnimation extends StatefulWidget {
  const EvolutionTreeAnimation({
    super.key,
    required this.stage,
    required this.size,
    this.animate = true,
  });

  final EvolutionStage stage;
  final double size;
  final bool animate;

  @override
  State<EvolutionTreeAnimation> createState() => _EvolutionTreeAnimationState();
}

class _EvolutionTreeAnimationState extends State<EvolutionTreeAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );
    if (widget.animate) {
      _controller.repeat();
    } else {
      _controller.value = 0.5;
    }
  }

  @override
  void didUpdateWidget(covariant EvolutionTreeAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.animate != oldWidget.animate) {
      if (widget.animate) {
        _controller.repeat();
      } else {
        _controller.stop();
        _controller.value = 0.5;
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
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          size: Size(widget.size, widget.size),
          painter: TreePainter(
            stage: widget.stage,
            animValue: _controller.value,
          ),
        );
      },
    );
  }
}

class TreePainter extends CustomPainter {
  final EvolutionStage stage;
  final double animValue;

  TreePainter({required this.stage, required this.animValue});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height;
    final scale = size.width / 100;

    // 1. Paint background environment particles
    _paintParticles(canvas, cx, cy, scale, false);

    final soilPaint = Paint()
      ..color = const Color(0xFF3b2314)
      ..style = PaintingStyle.fill;
    final soilPath = Path()
      ..moveTo(cx - 25 * scale, cy)
      ..quadraticBezierTo(cx, cy - 8 * scale, cx + 25 * scale, cy)
      ..close();
    canvas.drawPath(soilPath, soilPaint);

    final sway = math.sin(animValue * 2 * math.pi) * 0.05;

    switch (stage) {
      case EvolutionStage.seed:
        _paintSeed(canvas, cx, cy, scale, sway);
        break;
      case EvolutionStage.sprout:
        _paintSprout(canvas, cx, cy, scale, sway);
        break;
      case EvolutionStage.youngTree:
        _paintYoungTree(canvas, cx, cy, scale, sway);
        break;
      case EvolutionStage.bloomingTree:
        _paintBloomingTree(canvas, cx, cy, scale, sway);
        break;
      case EvolutionStage.ancientTree:
        _paintAncientTree(canvas, cx, cy, scale, sway);
        break;
      case EvolutionStage.legendaryTree:
        _paintLegendaryTree(canvas, cx, cy, scale, sway);
        break;
    }

    // 2. Paint foreground environment particles
    _paintParticles(canvas, cx, cy, scale, true);
  }

  void _paintParticles(Canvas canvas, double cx, double cy, double scale, bool foreground) {
    const count = 12;
    for (int i = 0; i < count; i++) {
      // Background / Foreground splitting
      if (foreground && i % 2 == 0) continue;
      if (!foreground && i % 2 != 0) continue;

      final math.Random random = math.Random(i * 100);
      final offsetFraction = i / count;
      final progress = (animValue + offsetFraction) % 1.0;
      final opacity = math.sin(progress * math.pi);
      if (opacity <= 0.01) continue;

      switch (stage) {
        case EvolutionStage.seed:
          // Dark soil particles drifting downwards
          final px = cx + (random.nextDouble() - 0.5) * 80 * scale;
          final py = cy - 80 * scale + progress * 75 * scale;
          final radius = (1.5 + random.nextDouble() * 2.0) * scale;
          canvas.drawCircle(
            Offset(px, py),
            radius,
            Paint()..color = const Color(0xFF5a3c22).withOpacity(opacity * 0.75),
          );
          break;
        case EvolutionStage.sprout:
          // Glowing green spores rising upwards
          final px = cx + (random.nextDouble() - 0.5) * 70 * scale + math.sin(progress * math.pi * 2) * 4 * scale;
          final py = cy - progress * 90 * scale;
          final radius = (1.0 + random.nextDouble() * 2.5) * scale;
          canvas.drawCircle(
            Offset(px, py),
            radius,
            Paint()..color = const Color(0xFF86efac).withOpacity(opacity * 0.9),
          );
          break;
        case EvolutionStage.youngTree:
          // Forest wind streaks drifting left to right
          final px = (cx - 75 * scale) + progress * 150 * scale;
          final py = cy - 95 * scale + random.nextDouble() * 65 * scale;
          final length = (6.0 + random.nextDouble() * 10.0) * scale;
          canvas.drawLine(
            Offset(px, py),
            Offset(px + length, py),
            Paint()
              ..color = const Color(0xFF7dd3fc).withOpacity(opacity * 0.6)
              ..strokeWidth = 1.2 * scale
              ..strokeCap = StrokeCap.round,
          );
          break;
        case EvolutionStage.bloomingTree:
          // Falling pink blossom petals fluttering downwards
          final px = cx + (random.nextDouble() - 0.5) * 90 * scale + math.sin(progress * math.pi * 3) * 6 * scale;
          final py = cy - 95 * scale + progress * 90 * scale;
          final rot = progress * math.pi * 2 + i;
          canvas.save();
          canvas.translate(px, py);
          canvas.rotate(rot);
          canvas.drawOval(
            Rect.fromLTWH(-3 * scale, -1.5 * scale, 6 * scale, 3 * scale),
            Paint()..color = const Color(0xFFf472b6).withOpacity(opacity * 0.85),
          );
          canvas.restore();
          break;
        case EvolutionStage.ancientTree:
          // Golden fireflies floating and pulsing
          final px = cx + (random.nextDouble() - 0.5) * 85 * scale + math.cos(progress * math.pi * 2) * 5 * scale;
          final py = cy - 100 * scale + progress * 90 * scale;
          final pulse = opacity * (0.6 + 0.4 * math.sin(progress * math.pi * 12));
          canvas.drawCircle(
            Offset(px, py),
            (2.0 + random.nextDouble() * 2.0) * scale,
            Paint()..color = const Color(0xFFfbbf24).withOpacity(pulse * 0.95),
          );
          break;
        case EvolutionStage.legendaryTree:
          // Twinkling white/purple celestial stars swirling upwards
          final px = cx + (random.nextDouble() - 0.5) * 95 * scale + math.sin(progress * math.pi * 4) * 8 * scale;
          final py = cy - 110 * scale + progress * 100 * scale;
          final starSize = (1.5 + random.nextDouble() * 2.0) * scale;
          final pulse = opacity * (0.5 + 0.5 * math.sin(progress * math.pi * 16));
          final starPaint = Paint()..color = Colors.white.withOpacity(pulse)..strokeWidth = 0.8 * scale;
          canvas.drawLine(Offset(px - starSize, py), Offset(px + starSize, py), starPaint);
          canvas.drawLine(Offset(px, py - starSize), Offset(px, py + starSize), starPaint);
          break;
      }
    }
  }

  void _paintSeed(Canvas canvas, double cx, double cy, double scale, double sway) {
    canvas.save();
    canvas.translate(cx, cy - 4 * scale);
    canvas.rotate(sway * 0.5);

    final seedPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF8B5A2B), Color(0xFFD2B48C)],
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
      ).createShader(Rect.fromLTWH(-6 * scale, -12 * scale, 12 * scale, 12 * scale))
      ..style = PaintingStyle.fill;

    canvas.drawOval(Rect.fromLTWH(-6 * scale, -12 * scale, 12 * scale, 12 * scale), seedPaint);

    final shootPaint = Paint()..color = const Color(0xFF4ADE80)..style = PaintingStyle.fill;
    final shootPath = Path()
      ..moveTo(-1 * scale, -12 * scale)
      ..quadraticBezierTo(2 * scale, -17 * scale, 5 * scale, -15 * scale)
      ..quadraticBezierTo(2 * scale, -13 * scale, -1 * scale, -12 * scale);
    canvas.drawPath(shootPath, shootPaint);
    canvas.restore();
  }

  void _paintSprout(Canvas canvas, double cx, double cy, double scale, double sway) {
    final stemPaint = Paint()
      ..color = const Color(0xFF4ADE80)
      ..strokeWidth = 3 * scale
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final leafPaint = Paint()..color = const Color(0xFF22C55E)..style = PaintingStyle.fill;

    canvas.save();
    canvas.translate(cx, cy - 2 * scale);
    final stemPath = Path()
      ..moveTo(0, 0)
      ..quadraticBezierTo(sway * 30 * scale, -20 * scale, sway * 10 * scale, -40 * scale);
    canvas.drawPath(stemPath, stemPaint);

    canvas.translate(sway * 10 * scale, -40 * scale);
    canvas.rotate(sway * 1.5);

    canvas.save();
    canvas.rotate(-math.pi / 4);
    canvas.drawOval(Rect.fromLTWH(-8 * scale, -3 * scale, 10 * scale, 6 * scale), leafPaint);
    canvas.restore();

    canvas.save();
    canvas.rotate(math.pi / 4);
    canvas.drawOval(Rect.fromLTWH(-2 * scale, -3 * scale, 10 * scale, 6 * scale), leafPaint);
    canvas.restore();
    canvas.restore();
  }

  void _paintYoungTree(Canvas canvas, double cx, double cy, double scale, double sway) {
    canvas.save();
    canvas.translate(cx, cy - 2 * scale);

    final trunkPaint = Paint()
      ..color = const Color(0xFF7c5d3f)
      ..strokeWidth = 5 * scale
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final trunkPath = Path()
      ..moveTo(0, 0)
      ..quadraticBezierTo(sway * 20 * scale, -25 * scale, sway * 8 * scale, -50 * scale);
    canvas.drawPath(trunkPath, trunkPaint);

    canvas.translate(sway * 8 * scale, -50 * scale);

    canvas.save();
    canvas.rotate(-0.5 + sway);
    final leftPath = Path()..moveTo(0, 0)..quadraticBezierTo(-10 * scale, -10 * scale, -15 * scale, -20 * scale);
    canvas.drawPath(leftPath, trunkPaint);
    canvas.drawCircle(Offset(-15 * scale, -20 * scale), 12 * scale, Paint()..color = const Color(0xFF0ea5e9));
    canvas.restore();

    canvas.save();
    canvas.rotate(0.5 + sway);
    final rightPath = Path()..moveTo(0, 0)..quadraticBezierTo(10 * scale, -10 * scale, 15 * scale, -20 * scale);
    canvas.drawPath(rightPath, trunkPaint);
    canvas.drawCircle(Offset(15 * scale, -20 * scale), 10 * scale, Paint()..color = const Color(0xFF0284c7));
    canvas.restore();

    canvas.drawCircle(Offset(0, -15 * scale), 14 * scale, Paint()..color = const Color(0xFF38bdf8));
    canvas.restore();
  }

  void _paintBloomingTree(Canvas canvas, double cx, double cy, double scale, double sway) {
    canvas.save();
    canvas.translate(cx, cy - 2 * scale);

    final trunkPaint = Paint()
      ..color = const Color(0xFF5c3a21)
      ..strokeWidth = 7 * scale
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final trunkPath = Path()
      ..moveTo(0, 0)
      ..quadraticBezierTo(sway * 15 * scale, -30 * scale, sway * 5 * scale, -55 * scale);
    canvas.drawPath(trunkPath, trunkPaint);

    canvas.translate(sway * 5 * scale, -55 * scale);

    final leafPaint = Paint()..color = const Color(0xFF059669);
    canvas.drawCircle(Offset(-15 * scale, -15 * scale), 16 * scale, leafPaint);
    canvas.drawCircle(Offset(15 * scale, -12 * scale), 14 * scale, leafPaint);
    canvas.drawCircle(Offset(0, -28 * scale), 18 * scale, leafPaint);

    final blossomPaint = Paint()..color = const Color(0xFFf472b6);
    canvas.drawCircle(Offset(-10 * scale, -25 * scale), 6 * scale, blossomPaint);
    canvas.drawCircle(Offset(12 * scale, -20 * scale), 5 * scale, blossomPaint);
    canvas.drawCircle(Offset(-18 * scale, -5 * scale), 5 * scale, blossomPaint);
    canvas.drawCircle(Offset(2 * scale, -38 * scale), 6 * scale, blossomPaint);
    canvas.drawCircle(Offset(18 * scale, -3 * scale), 4 * scale, blossomPaint);
    canvas.restore();
  }

  void _paintAncientTree(Canvas canvas, double cx, double cy, double scale, double sway) {
    canvas.save();
    canvas.translate(cx, cy - 2 * scale);

    final trunkPaint = Paint()
      ..color = const Color(0xFF4c2f13)
      ..strokeWidth = 9 * scale
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final trunkPath = Path()
      ..moveTo(0, 0)
      ..quadraticBezierTo(sway * 10 * scale, -30 * scale, sway * 3 * scale, -60 * scale);
    canvas.drawPath(trunkPath, trunkPaint);

    canvas.translate(sway * 3 * scale, -60 * scale);

    final f1 = Paint()..color = const Color(0xFFb45309);
    final f2 = Paint()..color = const Color(0xFFd97706);
    final f3 = Paint()..color = const Color(0xFFf59e0b);

    canvas.drawCircle(Offset(-22 * scale, -10 * scale), 20 * scale, f1);
    canvas.drawCircle(Offset(22 * scale, -8 * scale), 18 * scale, f1);
    canvas.drawCircle(Offset(-12 * scale, -28 * scale), 22 * scale, f2);
    canvas.drawCircle(Offset(12 * scale, -24 * scale), 20 * scale, f2);
    canvas.drawCircle(Offset(0, -42 * scale), 24 * scale, f3);
    canvas.restore();
  }

  void _paintLegendaryTree(Canvas canvas, double cx, double cy, double scale, double sway) {
    canvas.save();
    canvas.translate(cx, cy - 2 * scale);

    final trunkPaint = Paint()
      ..color = const Color(0xFF311042)
      ..strokeWidth = 10 * scale
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final trunkPath = Path()
      ..moveTo(0, 0)
      ..quadraticBezierTo(sway * 8 * scale, -30 * scale, sway * 2 * scale, -60 * scale);
    canvas.drawPath(trunkPath, trunkPaint);

    canvas.translate(sway * 2 * scale, -60 * scale);

    final l1 = Paint()..color = const Color(0xFF4c1d95).withOpacity(0.9);
    final l2 = Paint()..color = const Color(0xFF7c3aed).withOpacity(0.9);
    final l3 = Paint()..color = const Color(0xFFec4899).withOpacity(0.85);

    canvas.drawCircle(Offset(-25 * scale, -10 * scale), 22 * scale, l1);
    canvas.drawCircle(Offset(25 * scale, -8 * scale), 20 * scale, l1);
    canvas.drawCircle(Offset(-15 * scale, -32 * scale), 24 * scale, l2);
    canvas.drawCircle(Offset(15 * scale, -28 * scale), 22 * scale, l2);
    canvas.drawCircle(Offset(0, -46 * scale), 26 * scale, l3);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant TreePainter oldDelegate) {
    return oldDelegate.animValue != animValue || oldDelegate.stage != stage;
  }
}

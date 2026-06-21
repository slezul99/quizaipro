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
      case EvolutionStage.eternalTree:
        _paintEternalTree(canvas, cx, cy, scale, sway);
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
        case EvolutionStage.eternalTree:
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

  // ─── Shared tree-art helpers ────────────────────────────────────────────
  // Origin is assumed translated to the base centre (0,0); up is negative y.

  /// Soft ground shadow ellipse so the tree sits on the soil instead of
  /// floating.
  void _groundShadow(Canvas canvas, double scale, double halfWidth) {
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(0, -1.5 * scale),
        width: halfWidth * 2,
        height: 8 * scale,
      ),
      Paint()
        ..color = Colors.black.withOpacity(0.12)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, 3 * scale),
    );
  }

  /// A smoothly tapering trunk filled with a cylindrical (centre-lit) gradient
  /// so it reads as a rounded volume rather than a flat stick.
  void _trunk(
    Canvas canvas,
    double scale, {
    required double topY,
    required double topX,
    required double baseHalf,
    required double topHalf,
    required Color light,
    required Color dark,
  }) {
    final rect = Rect.fromLTRB(-baseHalf, topY, baseHalf, 0);
    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [dark, light, dark],
        stops: const [0.0, 0.45, 1.0],
      ).createShader(rect);
    final path = Path()
      ..moveTo(-baseHalf, 0)
      ..quadraticBezierTo(-baseHalf * 0.7, topY * 0.5, topX - topHalf, topY)
      ..lineTo(topX + topHalf, topY)
      ..quadraticBezierTo(baseHalf * 0.7, topY * 0.5, baseHalf, 0)
      ..close();
    canvas.drawPath(path, paint);
  }

  /// A volumetric foliage blob: radial gradient with a top-left highlight and a
  /// bottom-right shadow, giving each clump a 3-D sense of mass.
  void _blob(Canvas canvas, Offset c, double r, Color color, {Color? highlight}) {
    final rect = Rect.fromCircle(center: c, radius: r);
    final hi = highlight ?? Color.lerp(color, Colors.white, 0.40)!;
    final lo = Color.lerp(color, Colors.black, 0.24)!;
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.4, -0.5),
          radius: 1.05,
          colors: [hi, color, lo],
          stops: const [0.0, 0.5, 1.0],
        ).createShader(rect),
    );
  }

  /// A soft circular glow behind a canopy — used for the magical late stages.
  void _glow(Canvas canvas, Offset c, double r, Color color) {
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..color = color
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, r * 0.5),
    );
  }

  /// A five-petal blossom with a warm centre — replaces flat pink dots.
  void _blossom(Canvas canvas, Offset c, double r, Color color) {
    final petal = Paint()..color = color;
    for (var i = 0; i < 5; i++) {
      final a = i * math.pi * 2 / 5 - math.pi / 2;
      canvas.drawCircle(
        c + Offset(math.cos(a), math.sin(a)) * r * 0.62,
        r * 0.5,
        petal,
      );
    }
    canvas.drawCircle(c, r * 0.42, Paint()..color = const Color(0xFFFFE6A0));
  }

  void _paintYoungTree(Canvas canvas, double cx, double cy, double scale, double sway) {
    canvas.save();
    canvas.translate(cx, cy - 2 * scale);
    _groundShadow(canvas, scale, 20 * scale);

    final lean = sway * 6 * scale;
    _trunk(canvas, scale,
        topY: -42 * scale,
        topX: lean,
        baseHalf: 4 * scale,
        topHalf: 2.4 * scale,
        light: const Color(0xFF8a6a47),
        dark: const Color(0xFF5a3f28));

    canvas.translate(lean, -42 * scale);
    _blob(canvas, Offset(-13 * scale, -6 * scale), 13 * scale, const Color(0xFF0ea5e9));
    _blob(canvas, Offset(14 * scale, -4 * scale), 11 * scale, const Color(0xFF0284c7));
    _blob(canvas, Offset(0, -16 * scale), 16 * scale, const Color(0xFF38bdf8));
    canvas.restore();
  }

  void _paintBloomingTree(Canvas canvas, double cx, double cy, double scale, double sway) {
    canvas.save();
    canvas.translate(cx, cy - 2 * scale);
    _groundShadow(canvas, scale, 24 * scale);

    final lean = sway * 5 * scale;
    _trunk(canvas, scale,
        topY: -50 * scale,
        topX: lean,
        baseHalf: 5.5 * scale,
        topHalf: 3 * scale,
        light: const Color(0xFF7a5435),
        dark: const Color(0xFF4f3018));

    canvas.translate(lean, -50 * scale);
    _blob(canvas, Offset(-15 * scale, -12 * scale), 17 * scale, const Color(0xFF16a34a));
    _blob(canvas, Offset(16 * scale, -10 * scale), 15 * scale, const Color(0xFF22c55e));
    _blob(canvas, Offset(0, -28 * scale), 19 * scale, const Color(0xFF34d399));

    _blossom(canvas, Offset(-12 * scale, -24 * scale), 7 * scale, const Color(0xFFf472b6));
    _blossom(canvas, Offset(11 * scale, -18 * scale), 6 * scale, const Color(0xFFf9a8d4));
    _blossom(canvas, Offset(-18 * scale, -6 * scale), 5.5 * scale, const Color(0xFFf472b6));
    _blossom(canvas, Offset(3 * scale, -38 * scale), 6.5 * scale, const Color(0xFFf9a8d4));
    _blossom(canvas, Offset(18 * scale, -4 * scale), 5 * scale, const Color(0xFFf472b6));
    canvas.restore();
  }

  void _paintAncientTree(Canvas canvas, double cx, double cy, double scale, double sway) {
    canvas.save();
    canvas.translate(cx, cy - 2 * scale);
    _groundShadow(canvas, scale, 28 * scale);

    final lean = sway * 4 * scale;
    _trunk(canvas, scale,
        topY: -56 * scale,
        topX: lean,
        baseHalf: 7 * scale,
        topHalf: 3.5 * scale,
        light: const Color(0xFF6b4520),
        dark: const Color(0xFF3a230f));

    canvas.translate(lean, -56 * scale);
    _blob(canvas, Offset(-22 * scale, -8 * scale), 21 * scale, const Color(0xFFb45309));
    _blob(canvas, Offset(22 * scale, -6 * scale), 19 * scale, const Color(0xFFc2680b));
    _blob(canvas, Offset(-11 * scale, -26 * scale), 22 * scale, const Color(0xFFd97706));
    _blob(canvas, Offset(13 * scale, -22 * scale), 20 * scale, const Color(0xFFea8a0c));
    _blob(canvas, Offset(0, -40 * scale), 24 * scale, const Color(0xFFf59e0b));
    canvas.restore();
  }

  void _paintLegendaryTree(Canvas canvas, double cx, double cy, double scale, double sway) {
    canvas.save();
    canvas.translate(cx, cy - 2 * scale);
    _groundShadow(canvas, scale, 30 * scale);

    final lean = sway * 4 * scale;
    _trunk(canvas, scale,
        topY: -58 * scale,
        topX: lean,
        baseHalf: 7.5 * scale,
        topHalf: 4 * scale,
        light: const Color(0xFF4a1f63),
        dark: const Color(0xFF2a0e3a));

    canvas.translate(lean, -58 * scale);
    _glow(canvas, Offset(0, -28 * scale), 34 * scale,
        const Color(0xFF7c3aed).withOpacity(0.35));
    _blob(canvas, Offset(-24 * scale, -8 * scale), 22 * scale, const Color(0xFF6d28d9));
    _blob(canvas, Offset(24 * scale, -6 * scale), 20 * scale, const Color(0xFF7c3aed));
    _blob(canvas, Offset(-14 * scale, -30 * scale), 24 * scale, const Color(0xFF8b5cf6));
    _blob(canvas, Offset(15 * scale, -26 * scale), 22 * scale, const Color(0xFFa855f7));
    _blob(canvas, Offset(0, -46 * scale), 25 * scale, const Color(0xFFec4899));
    canvas.restore();
  }

  /// 365+ "Eternal" tree: an obsidian trunk crowned with a golden canopy, a
  /// warm halo and a luminous core — distinct from the violet legendary tree.
  void _paintEternalTree(Canvas canvas, double cx, double cy, double scale, double sway) {
    canvas.save();
    canvas.translate(cx, cy - 2 * scale);
    _groundShadow(canvas, scale, 32 * scale);

    final lean = sway * 3 * scale;
    _trunk(canvas, scale,
        topY: -62 * scale,
        topX: lean,
        baseHalf: 8 * scale,
        topHalf: 4.5 * scale,
        light: const Color(0xFF243044),
        dark: const Color(0xFF070b14));

    canvas.translate(lean, -62 * scale);
    _glow(canvas, Offset(0, -32 * scale), 40 * scale,
        const Color(0xFFF59E0B).withOpacity(0.40));

    // Dark obsidian under-canopy for depth.
    _blob(canvas, Offset(-26 * scale, -6 * scale), 24 * scale, const Color(0xFF1F2937));
    _blob(canvas, Offset(26 * scale, -4 * scale), 22 * scale, const Color(0xFF1F2937));
    // Golden crown.
    _blob(canvas, Offset(-24 * scale, -10 * scale), 20 * scale, const Color(0xFFB45309));
    _blob(canvas, Offset(24 * scale, -8 * scale), 18 * scale, const Color(0xFFc2680b));
    _blob(canvas, Offset(-14 * scale, -32 * scale), 23 * scale, const Color(0xFFF59E0B));
    _blob(canvas, Offset(15 * scale, -28 * scale), 21 * scale, const Color(0xFFf0a020));
    _blob(canvas, Offset(0, -48 * scale), 25 * scale, const Color(0xFFFCD34D),
        highlight: Colors.white);
    // Luminous crown core.
    _glow(canvas, Offset(0, -48 * scale), 10 * scale,
        Colors.white.withOpacity(0.95));
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant TreePainter oldDelegate) {
    return oldDelegate.animValue != animValue || oldDelegate.stage != stage;
  }
}

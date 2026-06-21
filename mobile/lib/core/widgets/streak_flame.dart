import 'package:flutter/material.dart';

/// Colour tiers for the streak flame — it grows hotter and then "legendary" as
/// the streak lengthens: amber → orange → red → crimson → violet → pink → ice →
/// obsidian (365+). Thresholds exposed via [streakFlameTiers] for the legend.
List<Color> streakFlameGradient(int streak) {
  if (streak <= 0) return const [Color(0xFFB0B7C3), Color(0xFF8A93A3)];
  if (streak < 3) return const [Color(0xFFFDE047), Color(0xFFFBBF24)]; // amber
  if (streak < 7) return const [Color(0xFFFBBF24), Color(0xFFF59E0B)]; // orange
  if (streak < 14) return const [Color(0xFFFB923C), Color(0xFFF97316)]; // deep orange
  if (streak < 30) return const [Color(0xFFF87171), Color(0xFFEF4444)]; // red
  if (streak < 60) return const [Color(0xFFEF4444), Color(0xFFB91C1C)]; // crimson
  if (streak < 100) return const [Color(0xFFA78BFA), Color(0xFF7C3AED)]; // violet
  if (streak < 200) return const [Color(0xFFF472B6), Color(0xFFDB2777)]; // pink
  if (streak < 365) return const [Color(0xFF67E8F9), Color(0xFF0891B2)]; // ice
  return const [Color(0xFF4B5563), Color(0xFF0B1220)]; // obsidian — 365+
}

Color streakFlameColor(int streak) => streakFlameGradient(streak).last;

/// (minStreakDays) for each colour tier — used by the legend on the streak page.
const List<int> streakFlameTiers = [1, 3, 7, 14, 30, 60, 100, 200, 365];

/// A custom-drawn flame (not the stock Material glyph): a layered teardrop with
/// an inner highlight, painted with the streak's colour gradient. The 365+
/// obsidian tier reads as a dark "eternal" flame with a golden core.
class StreakFlame extends StatelessWidget {
  const StreakFlame({
    super.key,
    required this.streak,
    required this.size,
    this.active = true,
    this.inactiveColor,
  });

  final int streak;
  final double size;
  final bool active;
  final Color? inactiveColor;

  @override
  Widget build(BuildContext context) {
    final colors = (!active || streak <= 0)
        ? [inactiveColor ?? const Color(0xFFB0B7C3), inactiveColor ?? const Color(0xFF8A93A3)]
        : streakFlameGradient(streak);
    final legendary = active && streak >= 365;
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _FlamePainter(colors: colors, coreGold: legendary),
      ),
    );
  }
}

class _FlamePainter extends CustomPainter {
  _FlamePainter({required this.colors, this.coreGold = false});

  final List<Color> colors;
  final bool coreGold;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final outer = Path()
      ..moveTo(w * 0.50, h * 0.02)
      ..cubicTo(w * 0.62, h * 0.22, w * 0.92, h * 0.30, w * 0.88, h * 0.58)
      ..cubicTo(w * 0.85, h * 0.85, w * 0.66, h * 1.00, w * 0.50, h * 1.00)
      ..cubicTo(w * 0.34, h * 1.00, w * 0.15, h * 0.85, w * 0.12, h * 0.58)
      ..cubicTo(w * 0.09, h * 0.34, w * 0.30, h * 0.30, w * 0.36, h * 0.16)
      ..cubicTo(w * 0.41, h * 0.06, w * 0.44, h * 0.04, w * 0.50, h * 0.02)
      ..close();

    final fill = Paint()
      ..shader = LinearGradient(
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
        colors: colors,
      ).createShader(Offset.zero & size);
    canvas.drawPath(outer, fill);

    // Inner flame highlight.
    final inner = Path()
      ..moveTo(w * 0.50, h * 0.40)
      ..cubicTo(w * 0.58, h * 0.55, w * 0.70, h * 0.62, w * 0.66, h * 0.78)
      ..cubicTo(w * 0.63, h * 0.92, w * 0.56, h * 0.96, w * 0.50, h * 0.96)
      ..cubicTo(w * 0.44, h * 0.96, w * 0.37, h * 0.92, w * 0.34, h * 0.78)
      ..cubicTo(w * 0.30, h * 0.62, w * 0.42, h * 0.55, w * 0.50, h * 0.40)
      ..close();
    final innerPaint = Paint()
      ..color = coreGold
          ? const Color(0xFFFCD34D)
          : Colors.white.withValues(alpha: 0.5);
    canvas.drawPath(inner, innerPaint);
  }

  @override
  bool shouldRepaint(covariant _FlamePainter old) =>
      old.colors != colors || old.coreGold != coreGold;
}

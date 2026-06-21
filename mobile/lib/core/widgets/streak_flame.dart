import 'package:flutter/material.dart';

/// A streak flame whose colour intensifies with the streak length, so the icon
/// itself signals momentum: amber → orange → deep-orange → red → crimson →
/// violet (legendary). Thresholds are exposed via [streakFlameTiers] so a
/// legend can show the progression.
List<Color> streakFlameGradient(int streak) {
  if (streak <= 0) return const [Color(0xFF9CA3AF), Color(0xFF6B7280)];
  if (streak < 3) return const [Color(0xFFFCD34D), Color(0xFFFBBF24)];
  if (streak < 7) return const [Color(0xFFFBBF24), Color(0xFFF59E0B)];
  if (streak < 14) return const [Color(0xFFFB923C), Color(0xFFF97316)];
  if (streak < 30) return const [Color(0xFFF87171), Color(0xFFEF4444)];
  if (streak < 60) return const [Color(0xFFEF4444), Color(0xFFDC2626)];
  return const [Color(0xFFA78BFA), Color(0xFF7C3AED)];
}

Color streakFlameColor(int streak) => streakFlameGradient(streak).last;

/// (minStreakDays) for each colour tier — used by the legend on the streak page.
const List<int> streakFlameTiers = [1, 3, 7, 14, 30, 60];

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
    if (!active || streak <= 0) {
      return Icon(
        Icons.local_fire_department_outlined,
        size: size,
        color: inactiveColor ?? const Color(0xFF9CA3AF),
      );
    }
    final colors = streakFlameGradient(streak);
    return ShaderMask(
      shaderCallback: (rect) => LinearGradient(
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
        colors: colors,
      ).createShader(rect),
      blendMode: BlendMode.srcIn,
      child: Icon(Icons.local_fire_department_rounded,
          size: size, color: Colors.white),
    );
  }
}

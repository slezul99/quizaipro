import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:quizaipro_mobile/l10n/app_localizations.dart';

class LevelUpCelebrationDialog extends StatefulWidget {
  const LevelUpCelebrationDialog({
    super.key,
    required this.oldLevel,
    required this.newLevel,
  });

  final int oldLevel;
  final int newLevel;

  @override
  State<LevelUpCelebrationDialog> createState() => _LevelUpCelebrationDialogState();
}

class _LevelUpCelebrationDialogState extends State<LevelUpCelebrationDialog>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  final List<_ConfettiParticle> _particles = [];
  final Random _random = Random();
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    // Trigger lightweight tactile haptic feedback
    HapticFeedback.lightImpact();
    Timer(const Duration(milliseconds: 150), () => HapticFeedback.mediumImpact());

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..addListener(() {
        _updateParticles();
      });
    _controller.repeat();
  }

  void _initParticles(double width, double height) {
    if (_initialized) return;
    _initialized = true;
    for (int i = 0; i < 90; i++) {
      _particles.add(_ConfettiParticle(
        x: _random.nextDouble() * width,
        y: -_random.nextDouble() * height,
        color: Colors.primaries[_random.nextInt(Colors.primaries.length)],
        speedY: 2.0 + _random.nextDouble() * 3.5,
        speedX: -1.2 + _random.nextDouble() * 2.4,
        size: 6.0 + _random.nextDouble() * 6.0,
        rotationSpeed: -0.1 + _random.nextDouble() * 0.2,
      ));
    }
  }

  void _updateParticles() {
    if (!mounted || !_initialized) return;
    setState(() {
      for (final p in _particles) {
        p.y += p.speedY;
        p.x += p.speedX;
        p.rotation += p.rotationSpeed;
        if (p.y > MediaQuery.of(context).size.height) {
          p.y = -20;
          p.x = _random.nextDouble() * MediaQuery.of(context).size.width;
        }
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color _getTierColor(int level) {
    if (level <= 5) return const Color(0xFFCD7F32); // Bronze
    if (level <= 15) return const Color(0xFFC0C0C0); // Silver
    if (level <= 30) return const Color(0xFFFFD700); // Gold
    if (level <= 50) return const Color(0xFF14B8A6); // Teal (Sage)
    if (level <= 100) return const Color(0xFF10B981); // Emerald (Grandmaster)
    return const Color(0xFF8B5CF6); // Purple (Legend)
  }

  @override
  Widget build(BuildContext context) {
    final tierColor = _getTierColor(widget.newLevel);
    final l = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.85),
      body: LayoutBuilder(
        builder: (context, constraints) {
          _initParticles(constraints.maxWidth, constraints.maxHeight);

          return Stack(
            children: [
              // Confetti Emitter
              CustomPaint(
                painter: _ConfettiPainter(_particles),
                size: Size(constraints.maxWidth, constraints.maxHeight),
              ),

              // Celebration Content
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.grey[900]?.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: tierColor.withOpacity(0.4),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: tierColor.withOpacity(0.2),
                          blurRadius: 24,
                          spreadRadius: 4,
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Glow icon
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: tierColor.withOpacity(0.15),
                            border: Border.all(color: tierColor, width: 3),
                          ),
                          alignment: Alignment.center,
                          child: const Icon(
                            Icons.emoji_events_rounded,
                            color: Colors.white,
                            size: 44,
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Title
                        Text(
                          l.levelUpNewLevel,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: 2,
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Level numbers
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '${widget.oldLevel}',
                              style: TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(width: 16),
                            Icon(
                              Icons.arrow_forward_rounded,
                              color: tierColor,
                              size: 28,
                            ),
                            const SizedBox(width: 16),
                            Text(
                              '${widget.newLevel}',
                              style: const TextStyle(
                                fontSize: 48,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Subtext
                        Text(
                          l.levelUpEncouragement,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[400],
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 24),

                        // OK Button
                        ElevatedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: tierColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 36,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 4,
                          ),
                          child: Text(
                            l.levelUpGreat,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.1,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ConfettiParticle {
  double x;
  double y;
  final Color color;
  final double speedY;
  final double speedX;
  final double size;
  final double rotationSpeed;
  double rotation = 0.0;

  _ConfettiParticle({
    required this.x,
    required this.y,
    required this.color,
    required this.speedY,
    required this.speedX,
    required this.size,
    required this.rotationSpeed,
  });
}

class _ConfettiPainter extends CustomPainter {
  final List<_ConfettiParticle> particles;

  _ConfettiPainter(this.particles);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    for (final p in particles) {
      paint.color = p.color;
      canvas.save();
      canvas.translate(p.x, p.y);
      canvas.rotate(p.rotation);
      canvas.drawRect(
        Rect.fromCenter(center: Offset.zero, width: p.size, height: p.size),
        paint,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

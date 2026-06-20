import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:quizaipro_mobile/core/router/app_routes.dart';
import 'package:quizaipro_mobile/core/theme/aurora_tokens.dart';
import 'package:quizaipro_mobile/features/dashboard/domain/entities/xp_summary.dart';

class LevelCard extends StatefulWidget {
  const LevelCard({
    super.key,
    required this.xp,
    required this.tokens,
  });

  final XpSummary xp;
  final AuroraTokens tokens;

  @override
  State<LevelCard> createState() => _LevelCardState();
}

class _LevelCardState extends State<LevelCard> with SingleTickerProviderStateMixin {
  late int _lastXp;
  int _xpBuffer = 0;
  Timer? _throttleTimer;
  
  late final AnimationController _floatController;
  late final Animation<double> _floatOpacity;
  late final Animation<double> _floatSlide;
  int _displayXpGain = 0;

  @override
  void initState() {
    super.initState();
    _lastXp = widget.xp.currentXp;

    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _floatOpacity = TweenSequence<double>([
      TweenSequenceItem(tween: Tween<double>(begin: 0.0, end: 1.0), weight: 20),
      TweenSequenceItem(tween: ConstantTween<double>(1.0), weight: 50),
      TweenSequenceItem(tween: Tween<double>(begin: 1.0, end: 0.0), weight: 30),
    ]).animate(_floatController);

    _floatSlide = Tween<double>(begin: 20.0, end: -40.0).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeOut),
    );
  }

  @override
  void didUpdateWidget(covariant LevelCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.xp.currentXp > _lastXp) {
      final diff = widget.xp.currentXp - _lastXp;
      _lastXp = widget.xp.currentXp;
      _onXpGained(diff);
    } else if (widget.xp.currentXp < _lastXp) {
      // XP reset or decreased, just sync
      _lastXp = widget.xp.currentXp;
    }
  }

  void _onXpGained(int amount) {
    _xpBuffer += amount;
    _throttleTimer?.cancel();
    _throttleTimer = Timer(const Duration(milliseconds: 1500), () {
      if (!mounted) return;
      setState(() {
        _displayXpGain = _xpBuffer;
        _xpBuffer = 0;
      });
      _floatController.forward(from: 0.0);
    });
  }

  @override
  void dispose() {
    _throttleTimer?.cancel();
    _floatController.dispose();
    super.dispose();
  }

  // Determine tier colors for border glow and backgrounds
  // Novice: 1-5, Scholar: 6-15, Master: 16-30, Sage: 31-50, Grandmaster: 51-100, Legend: 101+
  Color _getTierColor() {
    final lvl = widget.xp.level;
    if (lvl <= 5) return const Color(0xFFCD7F32); // Bronze
    if (lvl <= 15) return const Color(0xFFC0C0C0); // Silver
    if (lvl <= 30) return const Color(0xFFFFD700); // Gold
    if (lvl <= 50) return const Color(0xFF14B8A6); // Teal (Sage)
    if (lvl <= 100) return const Color(0xFF10B981); // Emerald (Grandmaster)
    return const Color(0xFF8B5CF6); // Purple (Legend)
  }

  String _getTierName() {
    final lvl = widget.xp.level;
    if (lvl <= 5) return 'Novice';
    if (lvl <= 15) return 'Scholar';
    if (lvl <= 30) return 'Master';
    if (lvl <= 50) return 'Sage';
    if (lvl <= 100) return 'Grandmaster';
    return 'Legend';
  }

  @override
  Widget build(BuildContext context) {
    final tierColor = _getTierColor();
    final tierName = _getTierName();

    return GestureDetector(
      onTap: () => context.pushNamed(AppRoutes.levelJourneyName),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Glassmorphic Card Container
          Container(
            padding: EdgeInsets.all(widget.tokens.space16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(widget.tokens.radiusL),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  widget.tokens.surfaceCard.withOpacity(0.85),
                  widget.tokens.surfaceCard.withOpacity(0.65),
                ],
              ),
              border: Border.all(
                color: tierColor.withOpacity(0.3),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: tierColor.withOpacity(0.08),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
                ...widget.tokens.shadowCard,
              ],
            ),
            child: Row(
              children: [
                // Avatar Badge and Glow
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: tierColor.withOpacity(0.4),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                    ),
                    // Inner Circular Level Badge
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            tierColor,
                            tierColor.withOpacity(0.7),
                          ],
                        ),
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '${widget.xp.level}',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 16),
                
                // Info Section
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            tierName.toUpperCase(),
                            style: widget.tokens.titleSmall.copyWith(
                              fontWeight: FontWeight.w800,
                              color: tierColor,
                              letterSpacing: 1.2,
                            ),
                          ),
                          Text(
                            '${widget.xp.currentXp} XP',
                            style: widget.tokens.bodyMedium.copyWith(
                              color: widget.tokens.textSecondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      
                      // Progress Bar
                      SizedBox(
                        height: 12,
                        width: double.infinity,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(widget.tokens.radiusS),
                          child: Stack(
                            children: [
                              Container(
                                color: widget.tokens.surfaceSubtle,
                              ),
                              FractionallySizedBox(
                                widthFactor: widget.xp.levelProgress,
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 500),
                                  curve: Curves.easeOut,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        tierColor,
                                        tierColor.withOpacity(0.8),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      
                      // Bottom label
                      Text(
                        '${widget.xp.xpToNextLevel} XP до уровня ${widget.xp.level + 1}',
                        style: widget.tokens.bodySmall.copyWith(
                          color: widget.tokens.textTertiary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Floating XP Animation
          AnimatedBuilder(
            animation: _floatController,
            builder: (context, child) {
              return Positioned(
                left: 28,
                top: _floatSlide.value,
                child: Opacity(
                  opacity: _floatOpacity.value,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: tierColor,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: tierColor.withOpacity(0.4),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                    child: Text(
                      '+$_displayXpGain XP',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

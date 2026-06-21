import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:quizaipro_mobile/features/dashboard/domain/entities/evolution_stage.dart';
import 'package:quizaipro_mobile/features/dashboard/presentation/widgets/evolution_tree_animation.dart';
import 'package:quizaipro_mobile/l10n/app_localizations.dart';

/// Full-screen celebration shown when the user's streak crosses into a new
/// evolution stage — the tree literally "grew". Renders the new stage's tree
/// art front and centre so the reward is tangible.
class TreeGrowthCelebrationDialog extends StatefulWidget {
  const TreeGrowthCelebrationDialog({super.key, required this.stage});

  final EvolutionStage stage;

  @override
  State<TreeGrowthCelebrationDialog> createState() =>
      _TreeGrowthCelebrationDialogState();
}

class _TreeGrowthCelebrationDialogState
    extends State<TreeGrowthCelebrationDialog>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    HapticFeedback.mediumImpact();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final accent = widget.stage.palette.primary;
    final stageName = widget.stage.getLocalizedName(l);

    return Scaffold(
      backgroundColor: Colors.black.withValues(alpha: 0.85),
      body: Center(
        child: ScaleTransition(
          scale: CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF14181F),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: accent.withValues(alpha: 0.45), width: 2),
                boxShadow: [
                  BoxShadow(
                    color: accent.withValues(alpha: 0.30),
                    blurRadius: 30,
                    spreadRadius: 4,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 150,
                    height: 150,
                    child: EvolutionTreeAnimation(stage: widget.stage, size: 150),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    l.streakTreeGrewTitle,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    l.streakTreeGrewBody(stageName),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.4,
                      color: Colors.white.withValues(alpha: 0.75),
                    ),
                  ),
                  const SizedBox(height: 22),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accent,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        l.levelUpGreat,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

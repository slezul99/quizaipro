import 'package:flutter/material.dart';

import 'package:quizaipro_mobile/core/theme/aurora_tokens.dart';
import 'package:quizaipro_mobile/features/ai_generation/domain/entities/generation_status.dart';
import 'package:quizaipro_mobile/l10n/app_localizations.dart';

class GenerationProgressWidget extends StatefulWidget {
  const GenerationProgressWidget({
    super.key,
    required this.status,
    required this.progress,
  });

  final GenerationStatus status;
  final int progress;

  @override
  State<GenerationProgressWidget> createState() =>
      _GenerationProgressWidgetState();
}

class _GenerationProgressWidgetState extends State<GenerationProgressWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _statusLabel(AppLocalizations l10n) => switch (widget.status) {
        GenerationStatus.pending => l10n.aiStudioStatusPending,
        GenerationStatus.processing => l10n.aiStudioStatusProcessing,
        GenerationStatus.completed => l10n.dashboardStreakDone,
        GenerationStatus.failed => l10n.aiStudioStatusFailed,
        GenerationStatus.cancelled => l10n.aiStudioStatusCancelled,
      };

  @override
  Widget build(BuildContext context) {
    final aurora = context.aurora;
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final isActive = widget.status.isActive;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 120,
          height: 120,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Rotating gradient ring
              if (isActive)
                AnimatedBuilder(
                  animation: _controller,
                  builder: (_, child) => Transform.rotate(
                    angle: _controller.value * 2 * 3.14159,
                    child: child,
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: SweepGradient(
                        colors: [
                          aurora.brandGradientStart,
                          aurora.brandGradientEnd,
                          aurora.backgroundSurface,
                        ],
                      ),
                    ),
                  ),
                )
              else
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: widget.status == GenerationStatus.completed
                        ? aurora.stateSuccessSurface
                        : aurora.stateErrorSurface,
                  ),
                ),
              // Inner circle
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: aurora.backgroundCanvas,
                ),
                child: Center(
                  child: widget.status.isTerminal
                      ? Icon(
                          widget.status == GenerationStatus.completed
                              ? Icons.check_rounded
                              : Icons.close_rounded,
                          size: 36,
                          color: widget.status == GenerationStatus.completed
                              ? aurora.stateSuccess
                              : aurora.stateError,
                        )
                      : Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '${widget.progress}%',
                              style: theme.textTheme.titleLarge?.copyWith(
                                color: aurora.textPrimary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: aurora.space20),
        Text(
          _statusLabel(l10n),
          style: theme.textTheme.titleMedium?.copyWith(
            color: aurora.textPrimary,
          ),
        ),
      ],
    );
  }
}

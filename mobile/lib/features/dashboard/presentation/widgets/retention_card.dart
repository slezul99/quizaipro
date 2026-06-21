import 'package:flutter/material.dart';

import 'package:quizaipro_mobile/core/theme/aurora_tokens.dart';
import 'package:quizaipro_mobile/features/dashboard/domain/entities/retention_summary.dart';

/// Dashboard card surfacing the FSRS retention summary: how much the user
/// remembers now, the one-week forecast, and how many cards are fading.
class RetentionCard extends StatelessWidget {
  const RetentionCard({
    super.key,
    required this.retention,
    required this.tokens,
    required this.title,
    required this.forecastLabel,
    required this.fadingLabel,
    this.explanation,
    this.onReviewFading,
  });

  final RetentionSummary retention;
  final AuroraTokens tokens;
  final String title;
  final String forecastLabel;
  final String fadingLabel;

  /// Plain-language explanation shown when the "?" is tapped.
  final String? explanation;

  /// Tapping the card (when something is fading) starts a focused review.
  final VoidCallback? onReviewFading;

  static const _amber = Color(0xFFf59e0b);

  Color get _accent {
    final now = retention.now ?? 0;
    if (now >= 80) return tokens.stateSuccess;
    if (now >= 50) return _amber;
    return tokens.stateError;
  }

  @override
  Widget build(BuildContext context) {
    final now = retention.now ?? 0;
    final tappable = onReviewFading != null && retention.fading > 0;
    return Material(
      color: tokens.surfaceCard,
      borderRadius: BorderRadius.circular(tokens.radiusL),
      child: InkWell(
        onTap: tappable ? onReviewFading : null,
        borderRadius: BorderRadius.circular(tokens.radiusL),
        child: _content(context, now),
      ),
    );
  }

  void _showInfo(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: tokens.backgroundSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(tokens.radiusL)),
      ),
      builder: (ctx) {
        final tt = Theme.of(ctx).textTheme;
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.all(tokens.space24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text('🧠', style: TextStyle(fontSize: 22)),
                    SizedBox(width: tokens.space8),
                    Text(title,
                        style: tt.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
                  ],
                ),
                SizedBox(height: tokens.space12),
                Text(explanation ?? '',
                    style: tt.bodyMedium?.copyWith(
                        color: tokens.textSecondary, height: 1.5)),
                SizedBox(height: tokens.space8),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _content(BuildContext context, int now) {
    return Container(
      padding: EdgeInsets.all(tokens.space16),
      decoration: BoxDecoration(
        color: tokens.surfaceCard,
        borderRadius: BorderRadius.circular(tokens.radiusL),
        boxShadow: tokens.shadowCard,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('🧠', style: TextStyle(fontSize: 20)),
              SizedBox(width: tokens.space8),
              Expanded(
                child: Text(
                  title,
                  style: tokens.titleMedium.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              if (explanation != null)
                GestureDetector(
                  onTap: () => _showInfo(context),
                  behavior: HitTestBehavior.opaque,
                  child: Padding(
                    padding: EdgeInsets.only(right: tokens.space8),
                    child: Icon(Icons.help_outline_rounded,
                        size: 18, color: tokens.textTertiary),
                  ),
                ),
              Text(
                '$now%',
                style: tokens.headlineSmall.copyWith(
                  fontWeight: FontWeight.w800,
                  color: _accent,
                ),
              ),
            ],
          ),
          SizedBox(height: tokens.space12),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: (now / 100).clamp(0.0, 1.0),
              minHeight: 8,
              backgroundColor: tokens.surfaceSubtle,
              valueColor: AlwaysStoppedAnimation<Color>(_accent),
            ),
          ),
          SizedBox(height: tokens.space12),
          Row(
            children: [
              Text(
                '$forecastLabel ${retention.forecast ?? now}%',
                style: tokens.bodySmall.copyWith(color: tokens.textSecondary),
              ),
              if (retention.fading > 0) ...[
                const Spacer(),
                Text(
                  '${retention.fading} $fadingLabel',
                  style: tokens.bodySmall.copyWith(
                    color: _amber,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (onReviewFading != null)
                  Icon(Icons.chevron_right_rounded, size: 18, color: _amber),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

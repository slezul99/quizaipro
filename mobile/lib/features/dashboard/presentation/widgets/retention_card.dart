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
  });

  final RetentionSummary retention;
  final AuroraTokens tokens;
  final String title;
  final String forecastLabel;
  final String fadingLabel;

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
              ],
            ],
          ),
        ],
      ),
    );
  }
}

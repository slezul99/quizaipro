import 'package:freezed_annotation/freezed_annotation.dart';

part 'xp_summary.freezed.dart';

@freezed
class XpSummary with _$XpSummary {
  const XpSummary._();

  const factory XpSummary({
    required int currentXp,
    required int level,
    required int xpInCurrentLevel,
    required int xpForNextLevel,
  }) = _XpSummary;

  double get levelProgress =>
      xpForNextLevel > 0 ? (xpInCurrentLevel / xpForNextLevel).clamp(0.0, 1.0) : 0.0;

  int get xpToNextLevel => (xpForNextLevel - xpInCurrentLevel).clamp(0, xpForNextLevel);
}

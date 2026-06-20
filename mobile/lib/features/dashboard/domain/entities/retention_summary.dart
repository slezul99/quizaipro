import 'package:freezed_annotation/freezed_annotation.dart';

part 'retention_summary.freezed.dart';

/// FSRS memory summary across all of the user's studied cards, computed by the
/// backend (single source of truth) and shown on the dashboard so invisible
/// forgetting becomes visible: "you remember 78% now, 60% by next week".
@freezed
class RetentionSummary with _$RetentionSummary {
  const factory RetentionSummary({
    int? now,
    int? forecast,
    @Default(0) int fading,
    @Default(0) int studied,
  }) = _RetentionSummary;

  const RetentionSummary._();

  /// True once at least one card has been studied and a percentage is known.
  bool get hasData => studied > 0 && now != null;
}

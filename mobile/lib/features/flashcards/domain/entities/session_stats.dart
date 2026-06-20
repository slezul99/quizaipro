import 'package:freezed_annotation/freezed_annotation.dart';

part 'session_stats.freezed.dart';

@freezed
class SessionStats with _$SessionStats {
  const factory SessionStats({
    required int total,
    @Default(0) int reviewed,
    @Default(0) int againCount,
    @Default(0) int hardCount,
    @Default(0) int goodCount,
    @Default(0) int easyCount,
    @Default(0) int newCount,
    @Default(0) int reviewCount,
    required DateTime startedAt,
  }) = _SessionStats;

  const SessionStats._();

  double get retentionRate =>
      reviewed == 0 ? 0 : (goodCount + easyCount) / reviewed;

  Duration get elapsed => DateTime.now().difference(startedAt);
}

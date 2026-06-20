import 'package:freezed_annotation/freezed_annotation.dart';

part 'due_reviews_summary.freezed.dart';

@freezed
class DueReviewsSummary with _$DueReviewsSummary {
  const DueReviewsSummary._();

  const factory DueReviewsSummary({
    required int totalDue,
    required int overdue,
    required int dueToday,
  }) = _DueReviewsSummary;

  bool get hasOverdue => overdue > 0;
  bool get hasDue => totalDue > 0;
}

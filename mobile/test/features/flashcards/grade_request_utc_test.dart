// Guards the sync timezone fix: request DTOs must serialize timestamps as UTC,
// otherwise a device east of UTC sends wall-clock times the backend rejects as
// "in the future" (the bug that stopped tests/flashcards from syncing).

import 'package:flutter_test/flutter_test.dart';
import 'package:quizaipro_mobile/features/flashcards/data/dto/grade_request_dto.dart';

void main() {
  test('GradeRequestDto serializes timestamps as UTC', () {
    final local = DateTime(2026, 1, 1, 12, 0); // local wall-clock (isUtc == false)
    final dto = GradeRequestDto(
      cardId: '1',
      deckId: '2',
      grade: 3,
      newEaseFactor: 2.5,
      newStability: 3.173,
      newDifficulty: 5.0,
      newInterval: 3,
      newRepetitions: 1,
      nextReviewAt: local,
      gradedAt: local,
    );

    final json = dto.toJson();
    final gradedAt = json['graded_at'] as String;

    // Marked UTC and preserves the exact instant (not the wall-clock digits).
    expect(gradedAt.endsWith('Z'), isTrue, reason: 'must be a UTC ISO string');
    expect(DateTime.parse(gradedAt).isAtSameMomentAs(local), isTrue);
    expect(json['next_review_at'], gradedAt);
  });

  test('dtoUtcIso keeps an already-UTC instant unchanged', () {
    final utc = DateTime.utc(2026, 1, 1, 12, 0);
    expect(dtoUtcIso(utc), '2026-01-01T12:00:00.000Z');
  });
}

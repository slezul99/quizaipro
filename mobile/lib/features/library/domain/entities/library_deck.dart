import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:quizaipro_mobile/features/library/domain/entities/library_filter.dart';

part 'library_deck.freezed.dart';

@freezed
class LibraryDeck with _$LibraryDeck {
  const factory LibraryDeck({
    required String id,
    required String title,
    @Default('📚') String icon,
    required String description,
    required int cardCount,
    required int dueCount,
    required bool hasTests,
    required bool hasFlashcards,
    required String coverColorHex,
    String? coverUrl,
    required bool isPro,
    required bool isPublic,
    required bool isFavorite,
    required bool isArchived,
    required List<String> tags,
    required DateTime createdAt,
    required DateTime updatedAt,
    LibraryDifficulty? difficulty,
    DateTime? lastStudiedAt,
    String? subjectName,
  }) = _LibraryDeck;
}

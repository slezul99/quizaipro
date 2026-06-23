import 'package:quizaipro_mobile/features/library/data/dto/library_collection_dto.dart';
import 'package:quizaipro_mobile/features/library/data/dto/library_deck_dto.dart';
import 'package:quizaipro_mobile/features/library/domain/entities/library_collection.dart';
import 'package:quizaipro_mobile/features/library/domain/entities/library_deck.dart';
import 'package:quizaipro_mobile/features/library/domain/entities/library_filter.dart';

abstract final class LibraryMapper {
  static LibraryDeck deckFromDto(LibraryDeckDto dto) => LibraryDeck(
        id: dto.id,
        title: dto.title,
        icon: dto.icon,
        description: dto.description,
        cardCount: dto.cardCount,
        dueCount: dto.dueCount,
        hasTests: dto.hasTests,
        hasFlashcards: dto.hasFlashcards,
        coverColorHex: dto.coverColorHex,
        coverUrl: dto.coverUrl,
        isPro: dto.isPro,
        isPublic: dto.isPublic,
        isFavorite: dto.isFavorite,
        isArchived: dto.isArchived,
        tags: dto.tags,
        createdAt: DateTime.parse(dto.createdAt),
        updatedAt: DateTime.parse(dto.updatedAt),
        difficulty: _difficultyFromString(dto.difficulty),
        lastStudiedAt: dto.lastStudiedAt != null
            ? DateTime.parse(dto.lastStudiedAt!)
            : null,
        subjectName: dto.subjectName,
      );

  static LibraryCollection collectionFromDto(LibraryCollectionDto dto) =>
      LibraryCollection(
        id: dto.id,
        name: dto.name,
        description: dto.description,
        coverColorHex: dto.coverColorHex,
        deckCount: dto.deckCount,
        createdAt: DateTime.parse(dto.createdAt),
      );

  static LibraryDifficulty? _difficultyFromString(String? value) =>
      switch (value) {
        'beginner' => LibraryDifficulty.beginner,
        'intermediate' => LibraryDifficulty.intermediate,
        'advanced' => LibraryDifficulty.advanced,
        _ => null,
      };
}

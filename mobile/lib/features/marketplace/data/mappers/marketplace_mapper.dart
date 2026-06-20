import 'package:quizaipro_mobile/features/marketplace/data/dto/collection_dto.dart';
import 'package:quizaipro_mobile/features/marketplace/data/dto/deck_card_preview_dto.dart';
import 'package:quizaipro_mobile/features/marketplace/data/dto/deck_detail_dto.dart';
import 'package:quizaipro_mobile/features/marketplace/data/dto/deck_summary_dto.dart';
import 'package:quizaipro_mobile/features/marketplace/data/dto/learning_path_dto.dart';
import 'package:quizaipro_mobile/features/marketplace/data/dto/paginated_dto.dart';
import 'package:quizaipro_mobile/features/marketplace/data/dto/subject_dto.dart';
import 'package:quizaipro_mobile/features/marketplace/domain/entities/collection.dart';
import 'package:quizaipro_mobile/features/marketplace/domain/entities/deck_card_preview.dart';
import 'package:quizaipro_mobile/features/marketplace/domain/entities/deck_detail.dart';
import 'package:quizaipro_mobile/features/marketplace/domain/entities/deck_summary.dart';
import 'package:quizaipro_mobile/features/marketplace/domain/entities/learning_path.dart';
import 'package:quizaipro_mobile/features/marketplace/domain/entities/paginated_result.dart';
import 'package:quizaipro_mobile/features/marketplace/domain/entities/subject.dart';

abstract final class MarketplaceMapper {
  // ── Subjects ──────────────────────────────────────────────────────────────

  static Subject subjectFromDto(SubjectDto dto) => Subject(
        id: dto.id,
        name: dto.name,
        iconCode: dto.iconCode,
        deckCount: dto.deckCount,
        colorHex: dto.colorHex,
      );

  // ── Deck summary ──────────────────────────────────────────────────────────

  static DeckSummary deckSummaryFromDto(DeckSummaryDto dto) => DeckSummary(
        id: dto.id,
        title: dto.title,
        description: dto.description,
        authorName: dto.authorName,
        coverColorHex: dto.coverColorHex,
        cardCount: dto.cardCount,
        rating: dto.rating,
        ratingCount: dto.ratingCount,
        cloneCount: dto.cloneCount,
        tags: dto.tags,
        language: dto.language,
        subjectId: dto.subjectId,
        isPro: dto.isPro,
      );

  // ── Deck detail ───────────────────────────────────────────────────────────

  static DeckDetail deckDetailFromDto(DeckDetailDto dto) => DeckDetail(
        id: dto.id,
        title: dto.title,
        description: dto.description,
        fullDescription: dto.fullDescription,
        authorName: dto.authorName,
        authorUsername: dto.authorUsername,
        authorAvatarUrl: dto.authorAvatarUrl,
        coverColorHex: dto.coverColorHex,
        cardCount: dto.cardCount,
        rating: dto.rating,
        ratingCount: dto.ratingCount,
        cloneCount: dto.cloneCount,
        likeCount: dto.likeCount,
        tags: dto.tags,
        language: dto.language,
        subjectId: dto.subjectId,
        isPro: dto.isPro,
        previewCardsCount: dto.previewCardsCount,
        isClonedByUser: dto.isClonedByUser,
        createdAt: DateTime.tryParse(dto.createdAt) ?? DateTime.now(),
        updatedAt: DateTime.tryParse(dto.updatedAt) ?? DateTime.now(),
      );

  // ── Card preview ──────────────────────────────────────────────────────────

  static DeckCardPreview cardPreviewFromDto(DeckCardPreviewDto dto) =>
      DeckCardPreview(
        id: dto.id,
        front: dto.front,
        back: dto.back,
        hint: dto.hint,
      );

  // ── Collection ────────────────────────────────────────────────────────────

  static Collection collectionFromDto(CollectionDto dto) => Collection(
        id: dto.id,
        name: dto.name,
        description: dto.description,
        coverUrl: dto.coverUrl,
        coverColorHex: dto.coverColorHex,
        deckCount: dto.deckCount,
        subjectId: dto.subjectId,
        curatorName: dto.curatorName,
      );

  // ── Learning path ─────────────────────────────────────────────────────────

  static LearningPath learningPathFromDto(LearningPathDto dto) => LearningPath(
        id: dto.id,
        title: dto.title,
        description: dto.description,
        coverUrl: dto.coverUrl,
        coverColorHex: dto.coverColorHex,
        deckCount: dto.deckCount,
        estimatedHours: dto.estimatedHours,
        difficulty: _difficultyFromString(dto.difficulty),
        enrolledCount: dto.enrolledCount,
      );

  // ── Pagination wrappers ───────────────────────────────────────────────────

  static PaginatedResult<DeckSummary> paginatedDecksFromDto(
    PaginatedDto<DeckSummaryDto> dto,
  ) =>
      PaginatedResult(
        items: dto.items.map(deckSummaryFromDto).toList(),
        page: dto.page,
        totalPages: dto.totalPages,
        totalCount: dto.totalCount,
      );

  static PaginatedResult<Collection> paginatedCollectionsFromDto(
    PaginatedDto<CollectionDto> dto,
  ) =>
      PaginatedResult(
        items: dto.items.map(collectionFromDto).toList(),
        page: dto.page,
        totalPages: dto.totalPages,
        totalCount: dto.totalCount,
      );

  static PaginatedResult<LearningPath> paginatedLearningPathsFromDto(
    PaginatedDto<LearningPathDto> dto,
  ) =>
      PaginatedResult(
        items: dto.items.map(learningPathFromDto).toList(),
        page: dto.page,
        totalPages: dto.totalPages,
        totalCount: dto.totalCount,
      );

  // ── Private helpers ───────────────────────────────────────────────────────

  static PathDifficulty _difficultyFromString(String s) => switch (s) {
        'intermediate' => PathDifficulty.intermediate,
        'advanced' => PathDifficulty.advanced,
        _ => PathDifficulty.beginner,
      };
}

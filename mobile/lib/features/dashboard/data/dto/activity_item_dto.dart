import 'package:json_annotation/json_annotation.dart';

part 'activity_item_dto.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class StudyCardReviewDetailDto {
  const StudyCardReviewDetailDto({
    required this.cardId,
    required this.front,
    required this.back,
    this.explanation,
    required this.grade,
    required this.xpEarned,
  });

  final String cardId;
  final String front;
  final String back;
  final String? explanation;
  final int grade;
  final int xpEarned;

  factory StudyCardReviewDetailDto.fromJson(Map<String, dynamic> json) =>
      _$StudyCardReviewDetailDtoFromJson(json);

  Map<String, dynamic> toJson() => _$StudyCardReviewDetailDtoToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class TestQuestionAttemptDetailDto {
  const TestQuestionAttemptDetailDto({
    required this.front,
    required this.isCorrect,
    required this.correctAnswer,
    this.selectedAnswer,
    required this.xpEarned,
  });

  final String front;
  final bool isCorrect;
  final String correctAnswer;
  final String? selectedAnswer;
  final int xpEarned;

  factory TestQuestionAttemptDetailDto.fromJson(Map<String, dynamic> json) =>
      _$TestQuestionAttemptDetailDtoFromJson(json);

  Map<String, dynamic> toJson() => _$TestQuestionAttemptDetailDtoToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class ActivityItemDto {
  const ActivityItemDto({
    required this.id,
    required this.type,
    required this.title,
    required this.cardsReviewed,
    required this.xpEarned,
    required this.createdAt,
    this.details,
  });

  final String id;
  final String type;
  final String title;
  final int cardsReviewed;
  final int xpEarned;
  final String createdAt;
  final List<dynamic>? details; // Direct JSON array from SQLite json_group_array

  factory ActivityItemDto.fromJson(Map<String, dynamic> json) =>
      _$ActivityItemDtoFromJson(json);

  Map<String, dynamic> toJson() => _$ActivityItemDtoToJson(this);
}

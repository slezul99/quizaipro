import 'package:freezed_annotation/freezed_annotation.dart';

part 'learning_path.freezed.dart';

enum PathDifficulty { beginner, intermediate, advanced }

@freezed
class LearningPath with _$LearningPath {
  const factory LearningPath({
    required String id,
    required String title,
    required String description,
    String? coverUrl,
    required String coverColorHex,
    required int deckCount,
    required int estimatedHours,
    required PathDifficulty difficulty,
    required int enrolledCount,
  }) = _LearningPath;
}

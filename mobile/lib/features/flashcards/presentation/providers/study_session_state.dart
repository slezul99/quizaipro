import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:quizaipro_mobile/features/flashcards/domain/entities/session_stats.dart';
import 'package:quizaipro_mobile/features/flashcards/domain/entities/study_card.dart';
import 'package:quizaipro_mobile/features/flashcards/domain/entities/study_mode.dart';

part 'study_session_state.freezed.dart';

@freezed
class StudySessionState with _$StudySessionState {
  const factory StudySessionState({
    required List<StudyCard> queue,
    required int currentIndex,
    required bool isCardFlipped,
    required SessionStats stats,
    required StudyMode mode,
    required String deckId,
    required String deckTitle,
    @Default(false) bool isComplete,
    @Default(false) bool isSavingSession,
    String? saveError,
  }) = _StudySessionState;

  const StudySessionState._();

  StudyCard? get currentCard =>
      currentIndex < queue.length ? queue[currentIndex] : null;

  int get totalInQueue => queue.length;

  double get progress =>
      totalInQueue == 0 ? 0 : currentIndex / totalInQueue;
}

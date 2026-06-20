import 'package:fpdart/fpdart.dart';

import 'package:quizaipro_mobile/core/error/failures.dart';
import 'package:quizaipro_mobile/features/ai_generation/domain/entities/deck_summary.dart';
import 'package:quizaipro_mobile/features/ai_generation/domain/entities/find_answers_result.dart';
import 'package:quizaipro_mobile/features/ai_generation/domain/entities/generated_card.dart';
import 'package:quizaipro_mobile/features/ai_generation/domain/entities/generation_job.dart';
import 'package:quizaipro_mobile/features/ai_generation/domain/entities/quality_mode.dart';

abstract interface class AiGenerationRepository {
  Future<Either<Failure, GenerationJob>> generateFromTopic({
    required String topic,
    required int cardCount,
    required QualityMode qualityMode,
  });

  Future<Either<Failure, GenerationJob>> generateFromText({
    required String text,
    required int cardCount,
    required QualityMode qualityMode,
  });

  Future<Either<Failure, GenerationJob>> generateFromPdf({
    required String filePath,
    required String fileName,
    required int cardCount,
    required QualityMode qualityMode,
  });

  Future<Either<Failure, GenerationJob>> getJobStatus(String jobId);

  Future<Either<Failure, List<GenerationJob>>> getHistory();

  Future<Either<Failure, Unit>> saveGeneratedCards({
    required String deckId,
    required List<GeneratedCard> cards,
  });

  Future<Either<Failure, DeckSummary>> createDeck(String title);

  Future<Either<Failure, FindAnswersResult>> findAnswers({
    required String question,
    String? deckId,
  });

  Future<Either<Failure, String>> explainCard({
    required String question,
    required String answer,
    String? deckId,
  });

  Future<Either<Failure, List<DeckSummary>>> getUserDecks();
}

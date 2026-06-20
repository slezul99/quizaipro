import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:quizaipro_mobile/core/error/failures.dart';
import 'package:quizaipro_mobile/features/ai_generation/domain/entities/generation_source.dart';
import 'package:quizaipro_mobile/features/ai_generation/domain/entities/quality_mode.dart';
import 'package:quizaipro_mobile/features/ai_generation/domain/usecases/generate_from_pdf_use_case.dart';
import 'package:quizaipro_mobile/features/ai_generation/domain/usecases/generate_from_text_use_case.dart';
import 'package:quizaipro_mobile/features/ai_generation/domain/usecases/generate_from_topic_use_case.dart';
import 'package:quizaipro_mobile/features/ai_generation/presentation/providers/ai_generation_providers.dart';
import 'package:quizaipro_mobile/features/ai_generation/presentation/providers/studio_state.dart';

part 'studio_notifier.g.dart';

@Riverpod(keepAlive: true)
class StudioNotifier extends _$StudioNotifier {
  @override
  StudioState build() => const StudioState();

  void setSource(GenerationSource source) =>
      state = state.copyWith(source: source, errorMessage: null);

  void setTopic(String value) => state = state.copyWith(topic: value);

  void setBodyText(String value) => state = state.copyWith(bodyText: value);

  void setPdf(String filePath, String fileName) =>
      state = state.copyWith(pdfFilePath: filePath, pdfFileName: fileName);

  void clearPdf() =>
      state = state.copyWith(pdfFilePath: null, pdfFileName: null);

  void setCardCount(int count) => state = state.copyWith(cardCount: count);

  void setQualityMode(QualityMode mode) =>
      state = state.copyWith(qualityMode: mode);

  void clearSubmittedJob() =>
      state = state.copyWith(submittedJobId: null);

  void reset() => state = const StudioState();

  Future<void> generate() async {
    if (!state.canGenerate) return;

    state = state.copyWith(isSubmitting: true, errorMessage: null);

    final result = switch (state.source) {
      GenerationSource.topic => await ref
          .read(generateFromTopicUseCaseProvider)
          .call(GenerateFromTopicParams(
            topic: state.topic.trim(),
            cardCount: state.cardCount,
            qualityMode: state.qualityMode,
          )),
      GenerationSource.text => await ref
          .read(generateFromTextUseCaseProvider)
          .call(GenerateFromTextParams(
            text: state.bodyText.trim(),
            cardCount: state.cardCount,
            qualityMode: state.qualityMode,
          )),
      GenerationSource.pdf => await ref
          .read(generateFromPdfUseCaseProvider)
          .call(GenerateFromPdfParams(
            filePath: state.pdfFilePath!,
            fileName: state.pdfFileName!,
            cardCount: state.cardCount,
            qualityMode: state.qualityMode,
          )),
    };

    result.fold(
      (failure) => state = state.copyWith(
        isSubmitting: false,
        errorMessage: failure.userMessage,
      ),
      (job) => state = state.copyWith(
        isSubmitting: false,
        submittedJobId: job.id,
      ),
    );
  }
}

import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:quizaipro_mobile/core/config/app_constants.dart';
import 'package:quizaipro_mobile/features/ai_generation/domain/entities/generation_source.dart';
import 'package:quizaipro_mobile/features/ai_generation/domain/entities/quality_mode.dart';

part 'studio_state.freezed.dart';

@freezed
class StudioState with _$StudioState {
  const factory StudioState({
    @Default(GenerationSource.topic) GenerationSource source,
    @Default('') String topic,
    @Default('') String bodyText,
    @Default(null) String? pdfFilePath,
    @Default(null) String? pdfFileName,
    @Default(AppConstants.aiGenerationDefaultCards) int cardCount,
    @Default(QualityMode.balanced) QualityMode qualityMode,
    @Default(false) bool isSubmitting,
    String? errorMessage,
    String? submittedJobId,
  }) = _StudioState;

  const StudioState._();

  bool get canGenerate => switch (source) {
        GenerationSource.topic => topic.trim().isNotEmpty && !isSubmitting,
        GenerationSource.text =>
          bodyText.trim().length >= 50 && !isSubmitting,
        GenerationSource.pdf => pdfFilePath != null && !isSubmitting,
      };
}

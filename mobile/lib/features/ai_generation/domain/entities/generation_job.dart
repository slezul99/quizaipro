import 'package:freezed_annotation/freezed_annotation.dart';

import 'generated_card.dart';
import 'generation_source.dart';
import 'generation_status.dart';
import 'quality_mode.dart';

part 'generation_job.freezed.dart';

@freezed
class GenerationJob with _$GenerationJob {
  const factory GenerationJob({
    required String id,
    required GenerationSource source,
    required GenerationStatus status,
    @Default(0) int progress,
    String? topic,
    String? inputText,
    String? pdfFileName,
    required QualityMode qualityMode,
    required int requestedCardCount,
    @Default([]) List<GeneratedCard> cards,
    String? errorMessage,
    required DateTime createdAt,
    DateTime? completedAt,
  }) = _GenerationJob;

  const GenerationJob._();

  bool get isTerminal => status.isTerminal;
  bool get isCompleted => status == GenerationStatus.completed;

  String get sourceLabel => switch (source) {
        GenerationSource.topic => topic ?? 'Topic',
        GenerationSource.text => 'Text input',
        GenerationSource.pdf => pdfFileName ?? 'PDF file',
      };
}

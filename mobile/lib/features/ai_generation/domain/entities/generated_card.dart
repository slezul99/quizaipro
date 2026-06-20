import 'package:freezed_annotation/freezed_annotation.dart';

part 'generated_card.freezed.dart';
part 'generated_card.g.dart';

@freezed
class GeneratedCard with _$GeneratedCard {
  const factory GeneratedCard({
    required String question,
    required String answer,
    @Default('') String topic,
    @Default('medium') String difficulty,
  }) = _GeneratedCard;

  factory GeneratedCard.fromJson(Map<String, dynamic> json) =>
      _$GeneratedCardFromJson(json);
}

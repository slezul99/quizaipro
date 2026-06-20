// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'find_answers_result_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FindAnswersResultDto _$FindAnswersResultDtoFromJson(
        Map<String, dynamic> json) =>
    FindAnswersResultDto(
      question: json['question'] as String,
      explanation: json['explanation'] as String,
      keyPoints: (json['key_points'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$FindAnswersResultDtoToJson(
        FindAnswersResultDto instance) =>
    <String, dynamic>{
      'question': instance.question,
      'explanation': instance.explanation,
      'key_points': instance.keyPoints,
    };

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'find_answers_result.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$FindAnswersResultImpl _$$FindAnswersResultImplFromJson(
        Map<String, dynamic> json) =>
    _$FindAnswersResultImpl(
      question: json['question'] as String,
      explanation: json['explanation'] as String,
      keyPoints: (json['keyPoints'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
    );

Map<String, dynamic> _$$FindAnswersResultImplToJson(
        _$FindAnswersResultImpl instance) =>
    <String, dynamic>{
      'question': instance.question,
      'explanation': instance.explanation,
      'keyPoints': instance.keyPoints,
    };

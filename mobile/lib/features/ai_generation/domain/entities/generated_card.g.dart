// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'generated_card.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$GeneratedCardImpl _$$GeneratedCardImplFromJson(Map<String, dynamic> json) =>
    _$GeneratedCardImpl(
      question: json['question'] as String,
      answer: json['answer'] as String,
      topic: json['topic'] as String? ?? '',
      difficulty: json['difficulty'] as String? ?? 'medium',
    );

Map<String, dynamic> _$$GeneratedCardImplToJson(_$GeneratedCardImpl instance) =>
    <String, dynamic>{
      'question': instance.question,
      'answer': instance.answer,
      'topic': instance.topic,
      'difficulty': instance.difficulty,
    };

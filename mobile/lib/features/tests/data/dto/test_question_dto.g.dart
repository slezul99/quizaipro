// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'test_question_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TestOptionDto _$TestOptionDtoFromJson(Map<String, dynamic> json) =>
    TestOptionDto(
      id: json['id'] as String,
      text: json['text'] as String,
      isCorrect: json['is_correct'] as bool,
    );

Map<String, dynamic> _$TestOptionDtoToJson(TestOptionDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'text': instance.text,
      'is_correct': instance.isCorrect,
    };

TestQuestionDto _$TestQuestionDtoFromJson(Map<String, dynamic> json) =>
    TestQuestionDto(
      id: json['id'] as String,
      deckId: json['deck_id'] as String,
      question: json['question'] as String,
      correctAnswer: json['correct_answer'] as String,
      options: (json['options'] as List<dynamic>)
          .map((e) => TestOptionDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      topic: json['topic'] as String?,
    );

Map<String, dynamic> _$TestQuestionDtoToJson(TestQuestionDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'deck_id': instance.deckId,
      'question': instance.question,
      'correct_answer': instance.correctAnswer,
      'options': instance.options,
      'topic': instance.topic,
    };

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tutor_message_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TutorMessageDto _$TutorMessageDtoFromJson(Map<String, dynamic> json) =>
    TutorMessageDto(
      id: json['id'] as String,
      conversationId: json['conversation_id'] as String,
      role: json['role'] as String,
      content: json['content'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$TutorMessageDtoToJson(TutorMessageDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'conversation_id': instance.conversationId,
      'role': instance.role,
      'content': instance.content,
      'created_at': instance.createdAt.toIso8601String(),
    };

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'conversation_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ConversationDto _$ConversationDtoFromJson(Map<String, dynamic> json) =>
    ConversationDto(
      id: json['id'] as String,
      title: json['title'] as String,
      deckId: json['deck_id'] as String?,
      deckTitle: json['deck_title'] as String?,
      isPinned: json['is_pinned'] as bool,
      messageCount: (json['message_count'] as num).toInt(),
      lastMessagePreview: json['last_message_preview'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$ConversationDtoToJson(ConversationDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'deck_id': instance.deckId,
      'deck_title': instance.deckTitle,
      'is_pinned': instance.isPinned,
      'message_count': instance.messageCount,
      'last_message_preview': instance.lastMessagePreview,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
    };

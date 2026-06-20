// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'send_message_request_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SendMessageRequestDto _$SendMessageRequestDtoFromJson(
        Map<String, dynamic> json) =>
    SendMessageRequestDto(
      conversationId: json['conversation_id'] as String,
      content: json['content'] as String,
      deckId: json['deck_id'] as String?,
    );

Map<String, dynamic> _$SendMessageRequestDtoToJson(
        SendMessageRequestDto instance) =>
    <String, dynamic>{
      'conversation_id': instance.conversationId,
      'content': instance.content,
      'deck_id': instance.deckId,
    };

import 'package:json_annotation/json_annotation.dart';

part 'send_message_request_dto.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class SendMessageRequestDto {
  const SendMessageRequestDto({
    required this.conversationId,
    required this.content,
    this.deckId,
  });

  final String conversationId;
  final String content;
  final String? deckId;

  factory SendMessageRequestDto.fromJson(Map<String, dynamic> json) =>
      _$SendMessageRequestDtoFromJson(json);

  Map<String, dynamic> toJson() => _$SendMessageRequestDtoToJson(this);
}

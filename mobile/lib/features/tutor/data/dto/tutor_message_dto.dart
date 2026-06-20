import 'package:json_annotation/json_annotation.dart';

part 'tutor_message_dto.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class TutorMessageDto {
  const TutorMessageDto({
    required this.id,
    required this.conversationId,
    required this.role,
    required this.content,
    required this.createdAt,
  });

  final String id;
  final String conversationId;
  final String role;
  final String content;
  final DateTime createdAt;

  factory TutorMessageDto.fromJson(Map<String, dynamic> json) =>
      _$TutorMessageDtoFromJson(json);

  Map<String, dynamic> toJson() => _$TutorMessageDtoToJson(this);
}

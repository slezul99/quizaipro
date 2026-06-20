import 'package:json_annotation/json_annotation.dart';

part 'google_auth_request_dto.g.dart';

@JsonSerializable(includeIfNull: false)
class GoogleAuthRequestDto {
  const GoogleAuthRequestDto({
    required this.idToken,
    this.deviceToken,
  });

  @JsonKey(name: 'id_token')
  final String idToken;
  @JsonKey(name: 'device_token')
  final String? deviceToken;

  Map<String, dynamic> toJson() => _$GoogleAuthRequestDtoToJson(this);
}

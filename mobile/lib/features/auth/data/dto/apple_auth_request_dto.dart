import 'package:json_annotation/json_annotation.dart';

part 'apple_auth_request_dto.g.dart';

@JsonSerializable(includeIfNull: false)
class AppleAuthRequestDto {
  const AppleAuthRequestDto({
    required this.identityToken,
    required this.authorizationCode,
    this.fullName,
    this.deviceToken,
  });

  @JsonKey(name: 'identity_token')
  final String identityToken;
  @JsonKey(name: 'authorization_code')
  final String authorizationCode;
  @JsonKey(name: 'full_name')
  final String? fullName;
  @JsonKey(name: 'device_token')
  final String? deviceToken;

  Map<String, dynamic> toJson() => _$AppleAuthRequestDtoToJson(this);
}

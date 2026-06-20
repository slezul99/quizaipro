import 'package:json_annotation/json_annotation.dart';

part 'register_request_dto.g.dart';

@JsonSerializable(includeIfNull: false)
class RegisterRequestDto {
  const RegisterRequestDto({
    required this.email,
    required this.password,
    required this.username,
    this.displayName,
    this.deviceToken,
  });

  final String email;
  final String password;
  final String username;
  @JsonKey(name: 'display_name')
  final String? displayName;
  @JsonKey(name: 'device_token')
  final String? deviceToken;

  Map<String, dynamic> toJson() => _$RegisterRequestDtoToJson(this);
}

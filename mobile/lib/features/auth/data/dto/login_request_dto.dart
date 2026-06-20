import 'package:json_annotation/json_annotation.dart';

part 'login_request_dto.g.dart';

@JsonSerializable(includeIfNull: false)
class LoginRequestDto {
  const LoginRequestDto({
    required this.email,
    required this.password,
    this.deviceToken,
  });

  final String email;
  final String password;
  @JsonKey(name: 'device_token')
  final String? deviceToken;

  Map<String, dynamic> toJson() => _$LoginRequestDtoToJson(this);
}

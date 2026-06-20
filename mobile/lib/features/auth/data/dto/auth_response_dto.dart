import 'package:json_annotation/json_annotation.dart';

import 'package:quizaipro_mobile/features/auth/data/dto/user_dto.dart';

part 'auth_response_dto.g.dart';

@JsonSerializable()
class AuthResponseDto {
  const AuthResponseDto({
    required this.accessToken,
    required this.refreshToken,
    required this.user,
  });

  @JsonKey(name: 'access_token')
  final String accessToken;
  @JsonKey(name: 'refresh_token')
  final String refreshToken;
  final UserDto user;

  factory AuthResponseDto.fromJson(Map<String, dynamic> json) =>
      _$AuthResponseDtoFromJson(json);

  Map<String, dynamic> toJson() => _$AuthResponseDtoToJson(this);
}

import 'package:json_annotation/json_annotation.dart';

part 'user_dto.g.dart';

@JsonSerializable()
class UserDto {
  const UserDto({
    required this.id,
    required this.email,
    this.username,
    this.displayName,
    this.avatarUrl,
    required this.emailVerified,
    required this.xp,
    required this.streakDays,
    required this.role,
    required this.createdAt,
  });

  final String id;
  final String email;
  final String? username;
  @JsonKey(name: 'display_name')
  final String? displayName;
  @JsonKey(name: 'avatar_url')
  final String? avatarUrl;
  @JsonKey(name: 'email_verified')
  final bool emailVerified;
  final int xp;
  @JsonKey(name: 'streak_days')
  final int streakDays;
  final String role;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  factory UserDto.fromJson(Map<String, dynamic> json) =>
      _$UserDtoFromJson(json);

  Map<String, dynamic> toJson() => _$UserDtoToJson(this);
}

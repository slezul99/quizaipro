// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserDto _$UserDtoFromJson(Map<String, dynamic> json) => UserDto(
      id: json['id'] as String,
      email: json['email'] as String,
      username: json['username'] as String?,
      displayName: json['display_name'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      emailVerified: json['email_verified'] as bool,
      xp: (json['xp'] as num).toInt(),
      streakDays: (json['streak_days'] as num).toInt(),
      role: json['role'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$UserDtoToJson(UserDto instance) => <String, dynamic>{
      'id': instance.id,
      'email': instance.email,
      'username': instance.username,
      'display_name': instance.displayName,
      'avatar_url': instance.avatarUrl,
      'email_verified': instance.emailVerified,
      'xp': instance.xp,
      'streak_days': instance.streakDays,
      'role': instance.role,
      'created_at': instance.createdAt.toIso8601String(),
    };

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'register_request_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RegisterRequestDto _$RegisterRequestDtoFromJson(Map<String, dynamic> json) =>
    RegisterRequestDto(
      email: json['email'] as String,
      password: json['password'] as String,
      username: json['username'] as String,
      displayName: json['display_name'] as String?,
      deviceToken: json['device_token'] as String?,
    );

Map<String, dynamic> _$RegisterRequestDtoToJson(RegisterRequestDto instance) =>
    <String, dynamic>{
      'email': instance.email,
      'password': instance.password,
      'username': instance.username,
      if (instance.displayName case final value?) 'display_name': value,
      if (instance.deviceToken case final value?) 'device_token': value,
    };

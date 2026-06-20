// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'apple_auth_request_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AppleAuthRequestDto _$AppleAuthRequestDtoFromJson(Map<String, dynamic> json) =>
    AppleAuthRequestDto(
      identityToken: json['identity_token'] as String,
      authorizationCode: json['authorization_code'] as String,
      fullName: json['full_name'] as String?,
      deviceToken: json['device_token'] as String?,
    );

Map<String, dynamic> _$AppleAuthRequestDtoToJson(
        AppleAuthRequestDto instance) =>
    <String, dynamic>{
      'identity_token': instance.identityToken,
      'authorization_code': instance.authorizationCode,
      if (instance.fullName case final value?) 'full_name': value,
      if (instance.deviceToken case final value?) 'device_token': value,
    };

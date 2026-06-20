// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'google_auth_request_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GoogleAuthRequestDto _$GoogleAuthRequestDtoFromJson(
        Map<String, dynamic> json) =>
    GoogleAuthRequestDto(
      idToken: json['id_token'] as String,
      deviceToken: json['device_token'] as String?,
    );

Map<String, dynamic> _$GoogleAuthRequestDtoToJson(
        GoogleAuthRequestDto instance) =>
    <String, dynamic>{
      'id_token': instance.idToken,
      if (instance.deviceToken case final value?) 'device_token': value,
    };

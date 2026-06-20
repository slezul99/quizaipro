import 'package:quizaipro_mobile/core/config/app_constants.dart';
import 'package:quizaipro_mobile/core/storage/hive_service.dart';
import 'package:quizaipro_mobile/features/auth/data/dto/user_dto.dart';

abstract interface class AuthLocalDataSource {
  Future<void> cacheUser(UserDto user);

  UserDto? getCachedUser();

  Future<void> clearUser();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  const AuthLocalDataSourceImpl(this._hiveService);

  final HiveService _hiveService;

  @override
  Future<void> cacheUser(UserDto user) =>
      _hiveService.settings.put(AppConstants.authCachedUserKey, user.toJson());

  @override
  UserDto? getCachedUser() {
    final raw = _hiveService.settings.get(AppConstants.authCachedUserKey);
    if (raw == null) return null;
    return UserDto.fromJson(Map<String, dynamic>.from(raw as Map));
  }

  @override
  Future<void> clearUser() =>
      _hiveService.settings.delete(AppConstants.authCachedUserKey);
}

import 'package:quizaipro_mobile/features/auth/data/dto/user_dto.dart';
import 'package:quizaipro_mobile/features/auth/domain/entities/user.dart';

abstract final class UserMapper {
  static User fromDto(UserDto dto) => User(
        id: dto.id,
        email: dto.email,
        username: dto.username,
        displayName: dto.displayName,
        avatarUrl: dto.avatarUrl,
        emailVerified: dto.emailVerified,
        xp: dto.xp,
        streakDays: dto.streakDays,
        role: dto.role,
        createdAt: dto.createdAt,
      );

  static UserDto toDto(User user) => UserDto(
        id: user.id,
        email: user.email,
        username: user.username,
        displayName: user.displayName,
        avatarUrl: user.avatarUrl,
        emailVerified: user.emailVerified,
        xp: user.xp,
        streakDays: user.streakDays,
        role: user.role,
        createdAt: user.createdAt,
      );
}

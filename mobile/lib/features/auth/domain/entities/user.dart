import 'package:freezed_annotation/freezed_annotation.dart';

part 'user.freezed.dart';

@freezed
class User with _$User {
  const User._();

  const factory User({
    required String id,
    required String email,
    String? username,
    String? displayName,
    String? avatarUrl,
    required bool emailVerified,
    required int xp,
    required int streakDays,
    required String role,
    required DateTime createdAt,
  }) = _User;

  bool get isAdmin => role == 'admin';

  String get displayNameOrUsername =>
      displayName?.isNotEmpty == true
          ? displayName!
          : username?.isNotEmpty == true
              ? username!
              : email.split('@').first;

  String get initials {
    final name = displayName ?? username ?? email;
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }
}

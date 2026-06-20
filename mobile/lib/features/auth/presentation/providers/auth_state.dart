import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:quizaipro_mobile/features/auth/domain/entities/user.dart';

part 'auth_state.freezed.dart';

/// The canonical auth state stored in [AuthNotifier].
///
/// Only two final states exist — [AuthAuthenticated] and [AuthUnauthenticated].
/// Loading and error during login/register are managed locally by the form
/// widgets, keeping router redirect logic simple and deterministic.
@freezed
sealed class AuthState with _$AuthState {
  /// Resolved: no valid session.
  const factory AuthState.unauthenticated() = AuthUnauthenticated;

  /// Resolved: valid session with hydrated [User].
  const factory AuthState.authenticated({required User user}) =
      AuthAuthenticated;
}

extension AuthStateX on AuthState {
  bool get isAuthenticated => this is AuthAuthenticated;

  User? get user => switch (this) {
        AuthAuthenticated(:final user) => user,
        _ => null,
      };
}

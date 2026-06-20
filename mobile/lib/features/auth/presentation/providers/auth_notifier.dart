import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import 'package:quizaipro_mobile/core/di/providers.dart';
import 'package:quizaipro_mobile/core/error/failures.dart';
import 'package:quizaipro_mobile/core/usecase/usecase.dart';
import 'package:quizaipro_mobile/features/auth/domain/entities/user.dart';
import 'package:quizaipro_mobile/features/auth/domain/usecases/login_use_case.dart';
import 'package:quizaipro_mobile/features/auth/domain/usecases/register_use_case.dart';
import 'package:quizaipro_mobile/features/auth/domain/usecases/sign_in_with_apple_use_case.dart';
import 'package:quizaipro_mobile/features/auth/domain/usecases/sign_in_with_google_use_case.dart';
import 'package:quizaipro_mobile/features/auth/presentation/providers/auth_providers.dart';
import 'package:quizaipro_mobile/features/auth/presentation/providers/auth_state.dart';

export 'auth_state.dart';

part 'auth_notifier.g.dart';

/// Single source of truth for authentication state.
///
/// State lifecycle:
///   build()      → AsyncValue.loading() → token check → authenticated | unauthenticated
///   login()      → throws [Failure] on error; updates state on success
///   register()   → same contract as login()
///   signInWith*  → manages state directly (loading → success | error)
///   logout()     → always succeeds; clears all local data
@Riverpod(keepAlive: true)
class AuthNotifier extends _$AuthNotifier {
  @override
  Future<AuthState> build() async {
    debugPrint('[STARTUP-DIAG] 08 authNotifierProvider.build: started');
    // SecureStorage is a core L0 provider — direct import is intentional.
    final storage = ref.read(secureStorageProvider);
    debugPrint('[STARTUP-DIAG] 09 storage.readAccessToken: calling...');
    final token = await storage.readAccessToken();
    debugPrint('[STARTUP-DIAG] 10 storage.readAccessToken: returned '
        '(token=${token == null ? 'null' : 'present, len=${token.length}'})');

    if (token == null || token.isEmpty) {
      debugPrint('[STARTUP-DIAG] 11 build: no token -> unauthenticated (END)');
      return const AuthState.unauthenticated();
    }

    debugPrint('[STARTUP-DIAG] 12 getCurrentUserUseCase: calling...');
    final result = await ref
        .read(getCurrentUserUseCaseProvider)
        .call(const NoParams());
    debugPrint('[STARTUP-DIAG] 13 getCurrentUserUseCase: returned');

    return result.fold(
      (failure) {
        debugPrint('[STARTUP-DIAG] 14 getCurrentUser: failure=$failure');
        if (failure is UnauthorizedFailure) {
          debugPrint('[STARTUP-DIAG] 15 build: unauthorized -> unauthenticated (END)');
          return const AuthState.unauthenticated();
        }
        // On network/server error: return cached user if available so the app
        // stays functional offline on first launch.
        final cached = ref.read(authRepositoryProvider).cachedUser;
        debugPrint('[STARTUP-DIAG] 16 build: network/server error, '
            'cachedUser=${cached == null ? 'null' : cached.id} (END)');
        return cached != null
            ? AuthState.authenticated(user: cached)
            : const AuthState.unauthenticated();
      },
      (user) {
        debugPrint('[STARTUP-DIAG] 17 build: getCurrentUser success, '
            'user=${user.id} -> authenticated (END)');
        return AuthState.authenticated(user: user);
      },
    );
  }

  // ── Email / Password login ────────────────────────────────────────────────

  /// Returns [User] on success. Throws [Failure] on error so the
  /// login form can display field-level validation messages.
  Future<User> login({
    required String email,
    required String password,
  }) async {
    final result = await ref
        .read(loginUseCaseProvider)
        .call(LoginParams(email: email, password: password));
    return result.fold(
      (failure) => throw failure,
      (user) {
        state = AsyncValue.data(AuthState.authenticated(user: user));
        return user;
      },
    );
  }

  // ── Email / Password register ─────────────────────────────────────────────

  /// Returns [User] on success. Throws [Failure] on error.
  Future<User> register({
    required String email,
    required String password,
    required String username,
    String? displayName,
  }) async {
    final result = await ref.read(registerUseCaseProvider).call(
          RegisterParams(
            email: email,
            password: password,
            username: username,
            displayName: displayName,
          ),
        );
    return result.fold(
      (failure) => throw failure,
      (user) {
        state = AsyncValue.data(AuthState.authenticated(user: user));
        return user;
      },
    );
  }

  // ── Google Sign In ────────────────────────────────────────────────────────

  Future<void> signInWithGoogle() async {
    state = const AsyncValue.loading();
    try {
      // serverClientId = Firebase project's "Web client" OAuth id (public, not
      // a secret). Required for google_sign_in to return an idToken whose
      // audience the backend (/auth/google) can verify. The Android OAuth
      // client is matched automatically by package name + registered SHA-1.
      final googleSignIn = GoogleSignIn(
        scopes: const ['email', 'profile'],
        serverClientId:
            '740504504650-kcsehujnb3jogs73au0a6qlbuaf28l13.apps.googleusercontent.com',
      );
      final account = await googleSignIn.signIn();

      if (account == null) {
        // User cancelled the picker.
        state = const AsyncValue.data(AuthState.unauthenticated());
        return;
      }

      final auth = await account.authentication;
      final idToken = auth.idToken;
      if (idToken == null) {
        state = AsyncValue.error(
          const UnknownFailure(message: 'Google did not return an ID token.'),
          StackTrace.current,
        );
        return;
      }

      final result = await ref
          .read(signInWithGoogleUseCaseProvider)
          .call(GoogleSignInParams(idToken: idToken));
      state = result.fold(
        (f) => AsyncValue.error(f, StackTrace.current),
        (user) => AsyncValue.data(AuthState.authenticated(user: user)),
      );
    } catch (e, st) {
      state = AsyncValue.error(UnknownFailure(message: e.toString()), st);
    }
  }

  // ── Apple Sign In (iOS / macOS) ───────────────────────────────────────────

  Future<void> signInWithApple() async {
    state = const AsyncValue.loading();
    try {
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      final identityToken = credential.identityToken;
      if (identityToken == null) {
        state = AsyncValue.error(
          const UnknownFailure(message: 'Apple did not return an identity token.'),
          StackTrace.current,
        );
        return;
      }

      final fullName = [credential.givenName, credential.familyName]
          .where((s) => s != null && s.isNotEmpty)
          .join(' ')
          .trim();

      final result = await ref.read(signInWithAppleUseCaseProvider).call(
            AppleSignInParams(
              identityToken: identityToken,
              authorizationCode: credential.authorizationCode,
              fullName: fullName.isNotEmpty ? fullName : null,
            ),
          );
      state = result.fold(
        (f) => AsyncValue.error(f, StackTrace.current),
        (user) => AsyncValue.data(AuthState.authenticated(user: user)),
      );
    } on SignInWithAppleAuthorizationException catch (e) {
      if (e.code == AuthorizationErrorCode.canceled) {
        state = const AsyncValue.data(AuthState.unauthenticated());
      } else {
        state = AsyncValue.error(
          UnknownFailure(message: e.message),
          StackTrace.current,
        );
      }
    } catch (e, st) {
      state = AsyncValue.error(UnknownFailure(message: e.toString()), st);
    }
  }

  // ── Logout ────────────────────────────────────────────────────────────────

  Future<void> logout() async {
    await ref.read(authRepositoryProvider).logout();
    state = const AsyncValue.data(AuthState.unauthenticated());
    // Disconnect Google silently — errors are irrelevant after local logout.
    GoogleSignIn().signOut().catchError((_) {});
  }

  // ── Profile patch (called by profile / settings feature) ─────────────────

  void updateUser(User updated) {
    state = AsyncValue.data(AuthState.authenticated(user: updated));
  }
}

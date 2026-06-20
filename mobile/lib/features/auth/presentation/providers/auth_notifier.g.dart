// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$authNotifierHash() => r'ab89d953dc9dd7804e95e89eeda87d76545b4850';

/// Single source of truth for authentication state.
///
/// State lifecycle:
///   build()      → AsyncValue.loading() → token check → authenticated | unauthenticated
///   login()      → throws [Failure] on error; updates state on success
///   register()   → same contract as login()
///   signInWith*  → manages state directly (loading → success | error)
///   logout()     → always succeeds; clears all local data
///
/// Copied from [AuthNotifier].
@ProviderFor(AuthNotifier)
final authNotifierProvider =
    AsyncNotifierProvider<AuthNotifier, AuthState>.internal(
  AuthNotifier.new,
  name: r'authNotifierProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$authNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$AuthNotifier = AsyncNotifier<AuthState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package

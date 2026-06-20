// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'router_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$routerNotifierHash() => r'7d958d90049f5b2c0a43b397b774b0b06b45db5d';

/// Bridges Riverpod state changes to GoRouter's [refreshListenable].
///
/// Watches [authNotifierProvider] and notifies the router whenever auth state
/// changes so the redirect guard is re-evaluated automatically.
/// Intentional cross-layer import: router is the coordinator and is
/// allowed to depend on the auth feature's notifier.
///
/// Copied from [RouterNotifier].
@ProviderFor(RouterNotifier)
final routerNotifierProvider =
    AutoDisposeAsyncNotifierProvider<RouterNotifier, void>.internal(
  RouterNotifier.new,
  name: r'routerNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$routerNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$RouterNotifier = AutoDisposeAsyncNotifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package

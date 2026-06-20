import 'package:flutter/widgets.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:quizaipro_mobile/features/auth/presentation/providers/auth_notifier.dart';

part 'router_notifier.g.dart';

/// Bridges Riverpod state changes to GoRouter's [refreshListenable].
///
/// Watches [authNotifierProvider] and notifies the router whenever auth state
/// changes so the redirect guard is re-evaluated automatically.
/// Intentional cross-layer import: router is the coordinator and is
/// allowed to depend on the auth feature's notifier.
@riverpod
class RouterNotifier extends _$RouterNotifier implements Listenable {
  VoidCallback? _routerListener;

  @override
  Future<void> build() async {
    ref.listen(authNotifierProvider, (_, __) {
      _routerListener?.call();
    });
  }

  @override
  void addListener(VoidCallback listener) {
    _routerListener = listener;
  }

  @override
  void removeListener(VoidCallback listener) {
    if (_routerListener == listener) _routerListener = null;
  }
}

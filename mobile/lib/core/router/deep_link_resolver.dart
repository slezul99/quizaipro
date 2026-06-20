import 'package:quizaipro_mobile/core/router/app_routes.dart';

/// Resolves deep-links from three sources to GoRouter named routes:
///   1. Push notification payload  (link: "/decks/abc123")
///   2. Universal / App Links      (https://quizaipro.com/...)
///   3. Custom scheme              (quizaipro://...)
///
/// Returns the GoRouter location string (e.g. "/library") or null if
/// the link cannot be resolved (caller falls back to home).
abstract final class DeepLinkResolver {
  static String? resolve(String? rawLink) {
    if (rawLink == null || rawLink.isEmpty) return null;

    final uri = Uri.tryParse(rawLink);
    if (uri == null) return null;

    final path = uri.path.replaceAll(RegExp(r'^/+'), '');
    final segments = path.split('/').where((s) => s.isNotEmpty).toList();

    if (segments.isEmpty) return AppRoutes.home;

    return switch (segments[0]) {
      'decks' when segments.length >= 2 =>
        '${AppRoutes.library}/${AppRoutes.libraryDeck}?id=${segments[1]}',
      'discover' when segments.length >= 2 =>
        '${AppRoutes.discover}/${AppRoutes.discoverDeck}?id=${segments[1]}',
      'duel' when segments.length >= 2 =>
        '/duel/${segments[1]}',
      'live' when segments.length >= 2 =>
        '/live/${segments[1]}',
      'tutor' => AppRoutes.tutor,
      'u' when segments.length >= 2 =>
        '/u/${segments[1]}',
      'notifications' => AppRoutes.notifications,
      _ => null,
    };
  }

  /// Synthesises a back-stack so pressing back after a deep-link
  /// navigates to the parent tab rather than exiting the app.
  static String backStackRootFor(String location) {
    if (location.startsWith('/library')) return AppRoutes.library;
    if (location.startsWith('/discover')) return AppRoutes.discover;
    if (location.startsWith('/duel') || location.startsWith('/arena')) {
      return AppRoutes.arena;
    }
    return AppRoutes.home;
  }
}

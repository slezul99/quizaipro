import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:quizaipro_mobile/core/router/app_routes.dart';
import 'package:quizaipro_mobile/core/theme/aurora_tokens.dart';
import 'package:quizaipro_mobile/l10n/app_localizations.dart';

/// 5-tab persistent shell using [StatefulShellRoute.indexedStack].
///
/// Immersive screens (study/test/duel/live/tutor) are pushed on the root
/// navigator (above this shell) so they render without the bottom bar.
class AppShell extends StatelessWidget {
  const AppShell({required this.shell, super.key});

  final StatefulNavigationShell shell;

  List<_Destination> _getDestinations(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return [
      _Destination(
        label: l10n.navHome,
        icon: Icons.home_outlined,
        activeIcon: Icons.home_rounded,
        route: AppRoutes.homeName,
      ),
      _Destination(
        label: l10n.navLibrary,
        icon: Icons.library_books_outlined,
        activeIcon: Icons.library_books_rounded,
        route: AppRoutes.libraryName,
      ),
      _Destination(
        label: l10n.navDiscover,
        icon: Icons.explore_outlined,
        activeIcon: Icons.explore_rounded,
        route: AppRoutes.discoverName,
      ),
      _Destination(
        label: l10n.navArena,
        icon: Icons.sports_esports_outlined,
        activeIcon: Icons.sports_esports_rounded,
        route: AppRoutes.arenaName,
      ),
      _Destination(
        label: l10n.navProfile,
        icon: Icons.person_outline_rounded,
        activeIcon: Icons.person_rounded,
        route: AppRoutes.profileName,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.aurora;

    return PopScope(
      canPop: shell.currentIndex == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (shell.currentIndex != 0) {
          shell.goBranch(0);
        }
      },
      child: Scaffold(
      // AI Tutor FAB — cross-cutting, not a tab. Previously a center-bottom
      // `Positioned` overlay stacked above the shell body, which intercepted
      // taps on full-width content beneath it (the Dashboard "Начать
      // повторение" button resolved to AI Tutor instead of the Study Session).
      // Hosting it as the Scaffold FAB at endFloat keeps it clear of centered
      // content and lets the framework manage safe-area / nav-bar insets. (P0-2)
      body: shell,
      floatingActionButton: _TutorFab(tokens: tokens),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      bottomNavigationBar: NavigationBar(
        selectedIndex: shell.currentIndex,
        onDestinationSelected: (index) => shell.goBranch(
          index,
          initialLocation: index == shell.currentIndex,
        ),
        backgroundColor: tokens.backgroundSurface,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.transparent,
        indicatorColor: tokens.brandGradientStart.withAlpha(26),
        destinations: _getDestinations(context)
            .map(
              (d) => NavigationDestination(
                icon: Icon(d.icon),
                selectedIcon: Icon(d.activeIcon),
                label: d.label,
              ),
            )
            .toList(),
      ),
    ),
    );
  }
}

class _TutorFab extends StatelessWidget {
  const _TutorFab({required this.tokens});

  final AuroraTokens tokens;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.pushNamed(AppRoutes.tutorName),
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          gradient: tokens.brandGradient,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: tokens.brandGradientStart.withAlpha(77),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Icon(
          Icons.auto_awesome_rounded,
          color: Colors.white,
          size: 24,
        ),
      ),
    );
  }
}

class _Destination {
  const _Destination({
    required this.label,
    required this.icon,
    required this.activeIcon,
    required this.route,
  });

  final String label;
  final IconData icon;
  final IconData activeIcon;
  final String route;
}

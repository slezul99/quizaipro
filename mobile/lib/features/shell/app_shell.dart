import 'dart:async';

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

/// AssistiveTouch-style AI button: a small, semi-transparent bubble that stays
/// out of the way until tapped, then fades in fully and reveals a little menu
/// of AI actions (Tutor / Generator). Auto-collapses after a few idle seconds.
class _TutorFab extends StatefulWidget {
  const _TutorFab({required this.tokens});

  final AuroraTokens tokens;

  @override
  State<_TutorFab> createState() => _TutorFabState();
}

class _TutorFabState extends State<_TutorFab> {
  bool _expanded = false;
  Timer? _collapseTimer;

  @override
  void dispose() {
    _collapseTimer?.cancel();
    super.dispose();
  }

  void _toggle() {
    setState(() => _expanded = !_expanded);
    _collapseTimer?.cancel();
    if (_expanded) {
      _collapseTimer = Timer(const Duration(seconds: 4), () {
        if (mounted) setState(() => _expanded = false);
      });
    }
  }

  void _go(String routeName) {
    _collapseTimer?.cancel();
    setState(() => _expanded = false);
    context.pushNamed(routeName);
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.tokens;
    final l = AppLocalizations.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedSize(
          duration: const Duration(milliseconds: 160),
          alignment: Alignment.bottomLeft,
          curve: Curves.easeOut,
          child: _expanded
              ? Padding(
                  padding: EdgeInsets.only(bottom: t.space12),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _action(t, Icons.auto_awesome_rounded,
                          l.dashboardActionAiTutor,
                          () => _go(AppRoutes.tutorName)),
                      SizedBox(height: t.space8),
                      _action(t, Icons.auto_fix_high_rounded,
                          l.dashboardActionAiStudio,
                          () => _go(AppRoutes.aiGenerationStudioName)),
                    ],
                  ),
                )
              : const SizedBox.shrink(),
        ),
        AnimatedOpacity(
          duration: const Duration(milliseconds: 180),
          opacity: _expanded ? 1.0 : 0.42,
          child: GestureDetector(
            onTap: _toggle,
            child: Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                gradient: t.brandGradient,
                shape: BoxShape.circle,
                boxShadow: _expanded
                    ? [
                        BoxShadow(
                          color: t.brandGradientStart.withAlpha(77),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : null,
              ),
              child: Icon(
                _expanded ? Icons.close_rounded : Icons.auto_awesome_rounded,
                color: Colors.white,
                size: 22,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _action(
      AuroraTokens t, IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: t.space12, vertical: t.space8),
        decoration: BoxDecoration(
          color: t.surfaceCard,
          borderRadius: BorderRadius.circular(t.radiusFull),
          boxShadow: t.shadowCard,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: t.brandGradientStart),
            SizedBox(width: t.space8),
            Text(label,
                style: Theme.of(context)
                    .textTheme
                    .labelLarge
                    ?.copyWith(fontWeight: FontWeight.w700)),
          ],
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

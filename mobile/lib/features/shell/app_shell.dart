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
      // AI button — cross-cutting, not a tab. Rendered as a slim handle glued
      // flush to the left edge (a `Positioned.fill` + `Align`, so the empty
      // area around it stays transparent to taps and centered content beneath
      // remains tappable). Tapping the handle slides out the AI actions panel.
      body: Stack(
        children: [
          shell,
          _TutorSideTab(tokens: tokens),
        ],
      ),
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

/// AI button as a slim handle glued to the left edge. Collapsed it's a
/// semi-transparent rounded tab that protrudes from the side; tapping it slides
/// out a panel with the AI actions (Tutor / Studio). Auto-collapses after a few
/// idle seconds.
class _TutorSideTab extends StatefulWidget {
  const _TutorSideTab({required this.tokens});

  final AuroraTokens tokens;

  @override
  State<_TutorSideTab> createState() => _TutorSideTabState();
}

class _TutorSideTabState extends State<_TutorSideTab> {
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
      _collapseTimer = Timer(const Duration(seconds: 5), () {
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
    // Sits a little below vertical centre, flush to the left edge. The
    // surrounding Align area is transparent to taps.
    return Positioned.fill(
      child: Align(
        alignment: const Alignment(-1.0, 0.30),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          switchInCurve: Curves.easeOutBack,
          switchOutCurve: Curves.easeIn,
          transitionBuilder: (child, anim) => SizeTransition(
            axis: Axis.horizontal,
            axisAlignment: -1,
            sizeFactor: anim,
            child: FadeTransition(opacity: anim, child: child),
          ),
          child: _expanded ? _buildPanel(context) : _buildHandle(context),
        ),
      ),
    );
  }

  Widget _buildHandle(BuildContext context) {
    final t = widget.tokens;
    return GestureDetector(
      key: const ValueKey('handle'),
      onTap: _toggle,
      child: Opacity(
        opacity: 0.55,
        child: Container(
          width: 34,
          height: 60,
          decoration: BoxDecoration(
            gradient: t.brandGradient,
            borderRadius: const BorderRadius.only(
              topRight: Radius.circular(18),
              bottomRight: Radius.circular(18),
            ),
            boxShadow: [
              BoxShadow(
                color: t.brandGradientStart.withAlpha(60),
                blurRadius: 10,
                offset: const Offset(2, 3),
              ),
            ],
          ),
          child: const Icon(Icons.auto_awesome_rounded,
              color: Colors.white, size: 20),
        ),
      ),
    );
  }

  Widget _buildPanel(BuildContext context) {
    final t = widget.tokens;
    final l = AppLocalizations.of(context);
    return Material(
      key: const ValueKey('panel'),
      color: t.surfaceCard,
      elevation: 8,
      shadowColor: Colors.black.withAlpha(60),
      borderRadius: const BorderRadius.only(
        topRight: Radius.circular(20),
        bottomRight: Radius.circular(20),
      ),
      child: Container(
        width: 196,
        padding: EdgeInsets.fromLTRB(
            t.space12, t.space10, t.space12, t.space12),
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.only(
            topRight: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
          border: Border(
            top: BorderSide(color: t.borderSubtle),
            right: BorderSide(color: t.borderSubtle),
            bottom: BorderSide(color: t.borderSubtle),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.auto_awesome_rounded,
                    size: 16, color: t.brandGradientStart),
                SizedBox(width: t.space4),
                Text('AI',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: t.brandGradientStart)),
                const Spacer(),
                GestureDetector(
                  onTap: _toggle,
                  child: Icon(Icons.chevron_left_rounded,
                      size: 20, color: t.textTertiary),
                ),
              ],
            ),
            SizedBox(height: t.space8),
            _action(t, Icons.school_rounded, l.dashboardActionAiTutor,
                () => _go(AppRoutes.tutorName)),
            SizedBox(height: t.space8),
            _action(t, Icons.auto_fix_high_rounded, l.dashboardActionAiStudio,
                () => _go(AppRoutes.aiGenerationStudioName)),
          ],
        ),
      ),
    );
  }

  Widget _action(
      AuroraTokens t, IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding:
            EdgeInsets.symmetric(horizontal: t.space12, vertical: t.space10),
        decoration: BoxDecoration(
          color: t.brandGradientStart.withAlpha(20),
          borderRadius: BorderRadius.circular(t.radiusMd),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: t.brandGradientStart),
            SizedBox(width: t.space8),
            Flexible(
              child: Text(label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context)
                      .textTheme
                      .labelLarge
                      ?.copyWith(fontWeight: FontWeight.w700)),
            ),
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

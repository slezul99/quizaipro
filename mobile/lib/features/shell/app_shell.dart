import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:quizaipro_mobile/core/router/app_routes.dart';
import 'package:quizaipro_mobile/core/theme/aurora_tokens.dart';
import 'package:quizaipro_mobile/features/library/domain/entities/library_deck.dart';
import 'package:quizaipro_mobile/features/library/presentation/providers/library_decks_notifier.dart';
import 'package:quizaipro_mobile/l10n/app_localizations.dart';

/// 5-tab persistent shell using [StatefulShellRoute.indexedStack].
///
/// Immersive screens (study/test/duel/live/tutor) are pushed on the root
/// navigator (above this shell) so they render without the bottom bar.
class AppShell extends StatelessWidget {
  const AppShell({required this.shell, super.key});

  final StatefulNavigationShell shell;

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
      extendBody: true,
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
      // Centre launcher — a quick way into Study / Test from anywhere.
      floatingActionButton: _CenterLauncher(
        tokens: tokens,
        onTap: () => _showQuickStartSheet(context, tokens),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: _BottomBar(shell: shell, tokens: tokens),
    ),
    );
  }
}

/// Custom bottom bar — four tabs (Arena is temporarily hidden) with a notch
/// for the centre launcher FAB.
class _BottomBar extends StatelessWidget {
  const _BottomBar({required this.shell, required this.tokens});

  final StatefulNavigationShell shell;
  final AuroraTokens tokens;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return BottomAppBar(
      color: tokens.backgroundSurface,
      surfaceTintColor: Colors.transparent,
      shadowColor: Colors.black.withAlpha(20),
      elevation: 10,
      shape: const CircularNotchedRectangle(),
      notchMargin: 7,
      height: 62,
      padding: EdgeInsets.zero,
      child: Row(
        children: [
          _BottomBarItem(
            shell: shell,
            tokens: tokens,
            branch: 0,
            icon: Icons.home_outlined,
            activeIcon: Icons.home_rounded,
            label: l.navHome,
          ),
          _BottomBarItem(
            shell: shell,
            tokens: tokens,
            branch: 1,
            icon: Icons.library_books_outlined,
            activeIcon: Icons.library_books_rounded,
            label: l.navLibrary,
          ),
          const SizedBox(width: 64), // notch gap for the centre FAB
          _BottomBarItem(
            shell: shell,
            tokens: tokens,
            branch: 2,
            icon: Icons.explore_outlined,
            activeIcon: Icons.explore_rounded,
            label: l.navDiscover,
          ),
          _BottomBarItem(
            shell: shell,
            tokens: tokens,
            branch: 4,
            icon: Icons.person_outline_rounded,
            activeIcon: Icons.person_rounded,
            label: l.navProfile,
          ),
        ],
      ),
    );
  }
}

class _BottomBarItem extends StatelessWidget {
  const _BottomBarItem({
    required this.shell,
    required this.tokens,
    required this.branch,
    required this.icon,
    required this.activeIcon,
    required this.label,
  });

  final StatefulNavigationShell shell;
  final AuroraTokens tokens;
  final int branch;
  final IconData icon;
  final IconData activeIcon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final selected = shell.currentIndex == branch;
    final color = selected ? tokens.brandGradientStart : tokens.textTertiary;
    return Expanded(
      child: InkWell(
        onTap: () => shell.goBranch(branch, initialLocation: branch == shell.currentIndex),
        customBorder: const StadiumBorder(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(selected ? activeIcon : icon, color: color, size: 24),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The raised centre button that launches the quick-start (Study / Test) sheet.
class _CenterLauncher extends StatelessWidget {
  const _CenterLauncher({required this.tokens, required this.onTap});

  final AuroraTokens tokens;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 58,
        height: 58,
        decoration: BoxDecoration(
          gradient: tokens.brandGradient,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: tokens.brandGradientStart.withAlpha(110),
              blurRadius: 16,
              spreadRadius: 1,
              offset: const Offset(0, 6),
            ),
          ],
          border: Border.all(color: Colors.white.withAlpha(60), width: 1.5),
        ),
        child: const Icon(Icons.bolt_rounded, color: Colors.white, size: 30),
      ),
    );
  }
}

void _showQuickStartSheet(BuildContext rootContext, AuroraTokens tokens) {
  showModalBottomSheet<void>(
    context: rootContext,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _QuickStartSheet(rootContext: rootContext, tokens: tokens),
  );
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
        opacity: 0.5,
        child: Container(
          width: 20,
          height: 42,
          decoration: BoxDecoration(
            gradient: t.brandGradient,
            borderRadius: const BorderRadius.only(
              topRight: Radius.circular(12),
              bottomRight: Radius.circular(12),
            ),
            boxShadow: [
              BoxShadow(
                color: t.brandGradientStart.withAlpha(50),
                blurRadius: 8,
                offset: const Offset(1, 2),
              ),
            ],
          ),
          child: const Icon(Icons.auto_awesome_rounded,
              color: Colors.white, size: 14),
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

/// Quick-start sheet: pick a mode (Study / Test) then a deck, and jump straight
/// into it — fewer taps than going Library → deck → button.
class _QuickStartSheet extends ConsumerStatefulWidget {
  const _QuickStartSheet({required this.rootContext, required this.tokens});

  final BuildContext rootContext;
  final AuroraTokens tokens;

  @override
  ConsumerState<_QuickStartSheet> createState() => _QuickStartSheetState();
}

class _QuickStartSheetState extends ConsumerState<_QuickStartSheet> {
  bool _testMode = false;

  void _launch(LibraryDeck deck) {
    Navigator.of(context).pop();
    final params = {'deckId': deck.id, 'deckTitle': deck.title};
    widget.rootContext.pushNamed(
      _testMode ? AppRoutes.testSetupName : AppRoutes.studySessionName,
      queryParameters: params,
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.tokens;
    final l = AppLocalizations.of(context);
    final decksAsync = ref.watch(libraryDecksNotifierProvider);

    return Container(
      decoration: BoxDecoration(
        color: t.backgroundSurface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(t.space20, t.space12, t.space20, t.space16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: t.surfaceSubtle,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              SizedBox(height: t.space16),
              // Mode toggle.
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: t.surfaceSubtle,
                  borderRadius: BorderRadius.circular(t.radiusFull),
                ),
                child: Row(
                  children: [
                    _ModeTab(
                      tokens: t,
                      icon: Icons.school_rounded,
                      label: l.libraryActionStudy,
                      selected: !_testMode,
                      onTap: () => setState(() => _testMode = false),
                    ),
                    _ModeTab(
                      tokens: t,
                      icon: Icons.fact_check_rounded,
                      label: l.libraryDeckDetailTest,
                      selected: _testMode,
                      onTap: () => setState(() => _testMode = true),
                    ),
                  ],
                ),
              ),
              SizedBox(height: t.space16),
              Text(
                l.libraryTabDecks,
                style: t.labelMedium.copyWith(color: t.textSecondary),
              ),
              SizedBox(height: t.space8),
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.42,
                ),
                child: decksAsync.when(
                  loading: () => const Padding(
                    padding: EdgeInsets.all(24),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  error: (_, __) => Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(l.errorNetwork,
                        style: TextStyle(color: t.textSecondary)),
                  ),
                  data: (state) {
                    final decks = state.items
                        .where((d) => _testMode ? d.hasTests : d.hasFlashcards)
                        .toList();
                    if (decks.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 24),
                        child: Text(
                          l.libraryNoDecks,
                          style: TextStyle(color: t.textSecondary),
                          textAlign: TextAlign.center,
                        ),
                      );
                    }
                    return ListView.separated(
                      shrinkWrap: true,
                      itemCount: decks.length,
                      separatorBuilder: (_, __) => SizedBox(height: t.space8),
                      itemBuilder: (_, i) => _QuickDeckRow(
                        tokens: t,
                        deck: decks[i],
                        cardsLabel: l.marketplaceCardCount(decks[i].cardCount),
                        onTap: () => _launch(decks[i]),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ModeTab extends StatelessWidget {
  const _ModeTab({
    required this.tokens,
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final AuroraTokens tokens;
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            gradient: selected ? tokens.brandGradient : null,
            borderRadius: BorderRadius.circular(tokens.radiusFull),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon,
                  size: 18,
                  color: selected ? Colors.white : tokens.textSecondary),
              SizedBox(width: tokens.space8),
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  color: selected ? Colors.white : tokens.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickDeckRow extends StatelessWidget {
  const _QuickDeckRow({
    required this.tokens,
    required this.deck,
    required this.cardsLabel,
    required this.onTap,
  });

  final AuroraTokens tokens;
  final LibraryDeck deck;
  final String cardsLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cover = _hexToColor(deck.coverColorHex);
    final initial =
        deck.title.trim().isNotEmpty ? deck.title.trim()[0].toUpperCase() : '?';
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: EdgeInsets.all(tokens.space12),
        decoration: BoxDecoration(
          color: tokens.backgroundSurface,
          borderRadius: BorderRadius.circular(tokens.radiusMd),
          border: Border.all(color: tokens.borderSubtle),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: cover.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(tokens.radiusSm),
              ),
              child: Text(
                initial,
                style: TextStyle(color: cover, fontWeight: FontWeight.w900),
              ),
            ),
            SizedBox(width: tokens.space12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    deck.title,
                    style: tokens.titleSmall.copyWith(fontWeight: FontWeight.w700),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(cardsLabel,
                      style: tokens.labelSmall.copyWith(color: tokens.textTertiary)),
                ],
              ),
            ),
            Icon(Icons.play_circle_fill_rounded,
                color: tokens.brandGradientStart, size: 28),
          ],
        ),
      ),
    );
  }

  Color _hexToColor(String hex) {
    final clean = hex.replaceAll('#', '');
    try {
      return Color(int.parse('FF$clean', radix: 16));
    } catch (_) {
      return const Color(0xFF6366F1);
    }
  }
}

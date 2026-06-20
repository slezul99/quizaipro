import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:quizaipro_mobile/core/error/failures.dart';
import 'package:quizaipro_mobile/core/router/app_routes.dart';
import 'package:quizaipro_mobile/core/theme/aurora_tokens.dart';
import 'package:quizaipro_mobile/features/auth/presentation/providers/auth_notifier.dart';
import 'package:quizaipro_mobile/features/auth/presentation/widgets/auth_gradient_header.dart';
import 'package:quizaipro_mobile/features/auth/presentation/widgets/welcome_action_card.dart';
import 'package:quizaipro_mobile/l10n/app_localizations.dart';

class WelcomeScreen extends ConsumerStatefulWidget {
  const WelcomeScreen({super.key});

  @override
  ConsumerState<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends ConsumerState<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeIn;
  late final Animation<Offset> _slideUp;
  bool _socialLoading = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _fadeIn = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _slideUp = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.aurora;

    ref.listen(authNotifierProvider, (_, next) {
      next.whenOrNull(
        error: (err, _) {
          if (!mounted) return;
          setState(() => _socialLoading = false);
          final message = err is Failure ? err.userMessage : err.toString();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message), backgroundColor: tokens.stateError),
          );
        },
        data: (_) {
          if (mounted) setState(() => _socialLoading = false);
        },
      );
    });

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          AuthGradientHeader(tokens: tokens, fullScreen: true),
          SafeArea(
            child: FadeTransition(
              opacity: _fadeIn,
              child: SlideTransition(
                position: _slideUp,
                child: Column(
                  children: [
                    const Spacer(flex: 3),
                    _WelcomeHero(tokens: tokens),
                    const Spacer(flex: 4),
                    WelcomeActionCard(
                      tokens: tokens,
                      socialLoading: _socialLoading,
                      onGetStarted: () => context.pushNamed(AppRoutes.registerName),
                      onLogin: () => context.pushNamed(AppRoutes.loginName),
                      onGoogle: _onGoogle,
                      onApple: _onApple,
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _onGoogle() async {
    setState(() => _socialLoading = true);
    await ref.read(authNotifierProvider.notifier).signInWithGoogle();
  }

  Future<void> _onApple() async {
    setState(() => _socialLoading = true);
    await ref.read(authNotifierProvider.notifier).signInWithApple();
  }
}

class _WelcomeHero extends StatelessWidget {
  const _WelcomeHero({required this.tokens});

  final AuroraTokens tokens;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: tokens.space32),
      child: Column(
        children: [
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(tokens.radiusXl),
              boxShadow: tokens.shadowCard,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(tokens.radiusXl),
              child: Image.asset('assets/images/app_icon.png', fit: BoxFit.cover),
            ),
          ),
          SizedBox(height: tokens.space24),
          Text(
            l10n.authWelcomeTitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'SpaceGrotesk',
              fontSize: 40,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              height: 1.15,
              letterSpacing: -1,
            ),
          ),
          SizedBox(height: tokens.space12),
          Text(
            l10n.authWelcomeSubtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 16,
              color: Colors.white.withAlpha(204),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

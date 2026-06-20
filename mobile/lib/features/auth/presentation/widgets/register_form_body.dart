import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:quizaipro_mobile/core/error/failures.dart';
import 'package:quizaipro_mobile/core/router/app_routes.dart';
import 'package:quizaipro_mobile/core/theme/aurora_tokens.dart';
import 'package:quizaipro_mobile/features/auth/presentation/providers/auth_notifier.dart';
import 'package:quizaipro_mobile/features/auth/presentation/widgets/aurora_text_field.dart';
import 'package:quizaipro_mobile/features/auth/presentation/widgets/auth_error_banner.dart';
import 'package:quizaipro_mobile/features/auth/presentation/widgets/auth_gradient_button.dart';
import 'package:quizaipro_mobile/features/auth/presentation/widgets/password_strength_bar.dart';
import 'package:quizaipro_mobile/l10n/app_localizations.dart';

/// Self-contained register form. Manages its own controllers and error state.
/// Calls [AuthNotifier] directly; navigation on success is handled by the
/// router redirect reacting to auth state change — no explicit push needed.
class RegisterFormBody extends ConsumerStatefulWidget {
  const RegisterFormBody({super.key});

  @override
  ConsumerState<RegisterFormBody> createState() => _RegisterFormBodyState();
}

class _RegisterFormBodyState extends ConsumerState<RegisterFormBody> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _usernameFocus = FocusNode();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();
  final _confirmFocus = FocusNode();

  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;
  String? _usernameServerError;
  String? _emailServerError;
  String? _passwordServerError;
  String? _generalError;
  PasswordStrength _passwordStrength = PasswordStrength.empty;

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(() {
      setState(
        () => _passwordStrength = PasswordStrength.evaluate(_passwordController.text),
      );
    });
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _usernameFocus.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    _confirmFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.aurora;
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_generalError != null) ...[
          AuthErrorBanner(
            message: _generalError!,
            tokens: tokens,
            onDismiss: () => setState(() => _generalError = null),
          ),
          SizedBox(height: tokens.space16),
        ],
        Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AuroraTextField(
                controller: _usernameController,
                focusNode: _usernameFocus,
                label: l10n.authUsername,
                hint: l10n.authUsernamePlaceholder,
                textInputAction: TextInputAction.next,
                serverError: _usernameServerError,
                tokens: tokens,
                onChanged: (_) => setState(() => _usernameServerError = null),
                onSubmitted: (_) => _emailFocus.requestFocus(),
                validator: _validateUsername,
              ),
              SizedBox(height: tokens.space16),
              AuroraTextField(
                controller: _emailController,
                focusNode: _emailFocus,
                label: l10n.authEmail,
                hint: l10n.authEmailPlaceholder,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                serverError: _emailServerError,
                tokens: tokens,
                onChanged: (_) => setState(() => _emailServerError = null),
                onSubmitted: (_) => _passwordFocus.requestFocus(),
                validator: _validateEmail,
              ),
              SizedBox(height: tokens.space16),
              AuroraTextField(
                controller: _passwordController,
                focusNode: _passwordFocus,
                label: l10n.authPassword,
                hint: l10n.authPasswordPlaceholder,
                obscureText: _obscurePassword,
                textInputAction: TextInputAction.next,
                serverError: _passwordServerError,
                tokens: tokens,
                onChanged: (_) => setState(() => _passwordServerError = null),
                onSubmitted: (_) => _confirmFocus.requestFocus(),
                validator: _validatePassword,
                suffix: IconButton(
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: tokens.textTertiary,
                    size: 20,
                  ),
                  onPressed: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                ),
              ),
              if (_passwordController.text.isNotEmpty) ...[
                SizedBox(height: tokens.space8),
                PasswordStrengthBar(
                  strength: _passwordStrength,
                  tokens: tokens,
                ),
              ],
              SizedBox(height: tokens.space16),
              AuroraTextField(
                controller: _confirmPasswordController,
                focusNode: _confirmFocus,
                label: l10n.authConfirmPassword,
                hint: l10n.authConfirmPasswordPlaceholder,
                obscureText: _obscureConfirm,
                textInputAction: TextInputAction.done,
                tokens: tokens,
                onSubmitted: (_) => _onRegister(),
                validator: _validateConfirmPassword,
                suffix: IconButton(
                  icon: Icon(
                    _obscureConfirm
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: tokens.textTertiary,
                    size: 20,
                  ),
                  onPressed: () =>
                      setState(() => _obscureConfirm = !_obscureConfirm),
                ),
              ),
              SizedBox(height: tokens.space32),
              AuthGradientButton(
                label: l10n.authCreateAccount,
                isLoading: _isLoading,
                tokens: tokens,
                onTap: _onRegister,
              ),
              SizedBox(height: tokens.space24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    l10n.authHaveAccount,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14,
                      color: tokens.textSecondary,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => context.goNamed(AppRoutes.loginName),
                    child: Text(
                      l10n.authSignInLink,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: tokens.brandGradientStart,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: tokens.space16),
              Text(
                l10n.authTermsNotice,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12,
                  color: tokens.textTertiary,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _onRegister() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isLoading = true;
      _generalError = null;
      _usernameServerError = null;
      _emailServerError = null;
      _passwordServerError = null;
    });
    try {
      await ref.read(authNotifierProvider.notifier).register(
            email: _emailController.text.trim(),
            password: _passwordController.text,
            username: _usernameController.text.trim().toLowerCase(),
          );
    } on ValidationFailure catch (f) {
      setState(() {
        _usernameServerError = f.fields?['username']?.first;
        _emailServerError = f.fields?['email']?.first;
        _passwordServerError = f.fields?['password']?.first;
        final hasFieldErrors = _usernameServerError != null ||
            _emailServerError != null ||
            _passwordServerError != null;
        if (!hasFieldErrors) _generalError = f.message;
      });
    } on Failure catch (f) {
      setState(() => _generalError = f.userMessage);
    } catch (e) {
      setState(() => _generalError = AppLocalizations.of(context)!.errorUnexpected);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String? _validateUsername(String? value) {
    final l10n = AppLocalizations.of(context)!;
    if (value == null || value.trim().isEmpty) {
      return l10n.validationRequired(l10n.authUsername);
    }
    final t = value.trim();
    if (t.length < 3) return l10n.validationUsernameMin;
    if (t.length > 20) return l10n.validationUsernameMax;
    if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(t)) {
      return l10n.validationUsernameChars;
    }
    return _usernameServerError;
  }

  String? _validateEmail(String? value) {
    final l10n = AppLocalizations.of(context)!;
    if (value == null || value.trim().isEmpty) {
      return l10n.validationRequired(l10n.authEmail);
    }
    if (!RegExp(r'^[\w.+-]+@[\w-]+\.[\w.-]+$').hasMatch(value.trim())) {
      return l10n.validationEmail;
    }
    return _emailServerError;
  }

  String? _validatePassword(String? value) {
    final l10n = AppLocalizations.of(context)!;
    if (value == null || value.isEmpty) {
      return l10n.validationRequired(l10n.authPassword);
    }
    if (value.length < 8) return l10n.validationPasswordMin;
    return _passwordServerError;
  }

  String? _validateConfirmPassword(String? value) {
    final l10n = AppLocalizations.of(context)!;
    if (value == null || value.isEmpty) return l10n.authConfirmPasswordRequired;
    if (value != _passwordController.text) return l10n.validationPasswordsNoMatch;
    return null;
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:quizaipro_mobile/core/error/failures.dart';
import 'package:quizaipro_mobile/core/router/app_routes.dart';
import 'package:quizaipro_mobile/features/auth/presentation/providers/auth_notifier.dart';
import 'package:quizaipro_mobile/l10n/app_localizations.dart';

class LoginFormBody extends ConsumerStatefulWidget {
  const LoginFormBody({super.key});

  @override
  ConsumerState<LoginFormBody> createState() => _LoginFormBodyState();
}

class _LoginFormBodyState extends ConsumerState<LoginFormBody> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();

  bool _obscurePassword = true;
  bool _isLoading = false;
  bool _socialLoading = false;
  String? _emailServerError;
  String? _passwordServerError;
  String? _generalError;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    ref.listen(authNotifierProvider, (_, next) {
      next.whenOrNull(
        error: (err, _) {
          if (!mounted) return;
          setState(() {
            _socialLoading = false;
            final message = err is Failure ? err.userMessage : err.toString();
            _generalError = message;
          });
        },
        data: (_) {
          if (mounted) setState(() => _socialLoading = false);
        },
      );
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_generalError != null) ...[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.redAccent.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.redAccent.withOpacity(0.5)),
            ),
            child: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.redAccent),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(_generalError!, style: const TextStyle(color: Colors.white)),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white54, size: 20),
                  onPressed: () => setState(() => _generalError = null),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
        Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildTextField(
                controller: _emailController,
                focusNode: _emailFocus,
                label: l10n.authIdentifier,
                hint: l10n.authIdentifierPlaceholder,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                onSubmitted: (_) => _passwordFocus.requestFocus(),
                errorText: _emailServerError,
                validator: _validateIdentifier,
                onChanged: (_) => setState(() => _emailServerError = null),
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _passwordController,
                focusNode: _passwordFocus,
                label: l10n.authPassword,
                hint: l10n.authPasswordHintLogin,
                obscureText: _obscurePassword,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _onLogin(),
                errorText: _passwordServerError,
                validator: _validatePassword,
                onChanged: (_) => setState(() => _passwordServerError = null),
                suffix: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                    color: Colors.white54,
                  ),
                  onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                ),
              ),
              const SizedBox(height: 32),
              
              // Sign In Button
              Container(
                width: double.infinity,
                height: 56,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(28),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF9333EA), Color(0xFFD946EF)], // Purple to pink
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFD946EF).withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _onLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                  ),
                  child: _isLoading 
                    ? const SizedBox(
                        width: 24, height: 24, 
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5)
                      )
                    : Text(l10n.authSignIn, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    l10n.authNoAccount,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(width: 4),
                  GestureDetector(
                    onTap: () => context.goNamed(AppRoutes.registerName),
                    child: Text(
                      l10n.authSignUp,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFD946EF),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(child: Divider(color: Colors.white.withOpacity(0.2))),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text('OR', style: TextStyle(color: Colors.white.withOpacity(0.5))),
                  ),
                  Expanded(child: Divider(color: Colors.white.withOpacity(0.2))),
                ],
              ),
              const SizedBox(height: 24),
              
              // Google Button
              ElevatedButton.icon(
                onPressed: _socialLoading ? null : _onGoogle,
                icon: const Icon(Icons.g_mobiledata_rounded, color: Colors.black, size: 36),
                label: Text(l10n.authContinueWithGoogle, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w600, fontSize: 16)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                  elevation: 0,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String label,
    required String hint,
    required String? Function(String?) validator,
    required void Function(String) onChanged,
    bool obscureText = false,
    Widget? suffix,
    TextInputType? keyboardType,
    TextInputAction? textInputAction,
    Function(String)? onSubmitted,
    String? errorText,
  }) {
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      obscureText: obscureText,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      onFieldSubmitted: onSubmitted,
      onChanged: onChanged,
      validator: validator,
      style: const TextStyle(color: Colors.white, fontSize: 16),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        floatingLabelStyle: const TextStyle(color: Color(0xFFD946EF), fontWeight: FontWeight.bold),
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white38),
        errorText: errorText,
        filled: true,
        fillColor: Colors.white.withOpacity(0.08),
        suffixIcon: suffix,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFD946EF), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.redAccent, width: 2),
        ),
      ),
    );
  }

  Future<void> _onGoogle() async {
    FocusScope.of(context).unfocus();
    setState(() {
      _socialLoading = true;
      _generalError = null;
    });
    await ref.read(authNotifierProvider.notifier).signInWithGoogle();
  }

  Future<void> _onLogin() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isLoading = true;
      _generalError = null;
      _emailServerError = null;
      _passwordServerError = null;
    });
    try {
      await ref.read(authNotifierProvider.notifier).login(
            email: _emailController.text.trim(),
            password: _passwordController.text,
          );
    } on ValidationFailure catch (f) {
      setState(() {
        _emailServerError = f.fields?['email']?.first;
        _passwordServerError = f.fields?['password']?.first;
        if (_emailServerError == null && _passwordServerError == null) {
          _generalError = f.message;
        }
      });
    } on Failure catch (f) {
      setState(() => _generalError = f.userMessage);
    } catch (e) {
      setState(() => _generalError = AppLocalizations.of(context)!.errorUnexpected);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String? _validateIdentifier(String? value) {
    final l10n = AppLocalizations.of(context)!;
    if (value == null || value.trim().isEmpty) {
      return l10n.validationRequired(l10n.authIdentifier);
    }
    return _emailServerError;
  }

  String? _validatePassword(String? value) {
    final l10n = AppLocalizations.of(context)!;
    if (value == null || value.isEmpty) {
      return l10n.validationRequired(l10n.authPassword);
    }
    return _passwordServerError;
  }
}


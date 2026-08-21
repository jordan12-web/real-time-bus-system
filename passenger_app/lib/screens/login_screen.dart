import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../controllers/auth_controller.dart';
import '../routes/app_routes.dart';
import '../theme/design_tokens.dart';
import '../widgets/gradient_background.dart';
import '../widgets/guzo_logo.dart';
import '../widgets/polished_button.dart';
import '../widgets/polished_card.dart';

/// Login Screen with centered card and Guzo branding.
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_formKey.currentState?.validate() ?? false) {
      final success = await ref
          .read(authControllerProvider.notifier)
          .login(_emailController.text.trim(), _passwordController.text);
      if (success && mounted) {
        AppRoutes.navigateToTripList(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = isDark ? DesignTokens.darkPrimary : DesignTokens.primary;

    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(DesignTokens.spaceLg),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Guzo branding
                    const GuzoLogo(size: 38),
                    const SizedBox(height: DesignTokens.spaceLg),

                    // Centered Form Card
                    PolishedCard(
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              'Welcome Back',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: isDark
                                    ? Colors.white
                                    : const Color(0xFF0F172A),
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: DesignTokens.spaceXs),
                            Text(
                              'Log in to book trips & manage tickets',
                              style: TextStyle(
                                fontSize: 13,
                                color: isDark
                                    ? Colors.white60
                                    : const Color(0xFF64748B),
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: DesignTokens.spaceLg),

                            // Email input
                            Semantics(
                              label: 'Email input field',
                              child: TextFormField(
                                key: const Key('login_email'),
                                controller: _emailController,
                                keyboardType: TextInputType.emailAddress,
                                decoration: const InputDecoration(
                                  labelText: 'Email address',
                                  prefixIcon:
                                      Icon(Icons.email_outlined, size: 20),
                                ),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Please enter your email';
                                  }
                                  if (!value.contains('@')) {
                                    return 'Please enter a valid email';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(height: DesignTokens.spaceMd),

                            // Password input with visibility toggle
                            Semantics(
                              label: 'Password input field',
                              child: TextFormField(
                                key: const Key('login_password'),
                                controller: _passwordController,
                                obscureText: _obscurePassword,
                                decoration: InputDecoration(
                                  labelText: 'Password',
                                  prefixIcon:
                                      const Icon(Icons.lock_outline, size: 20),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscurePassword
                                          ? Icons.visibility_off_outlined
                                          : Icons.visibility_outlined,
                                      size: 20,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _obscurePassword = !_obscurePassword;
                                      });
                                    },
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your password';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(height: DesignTokens.spaceLg),

                            // Error message
                            if (authState.errorMessage != null) ...[
                              Container(
                                padding: const EdgeInsets.all(
                                    DesignTokens.spaceSm),
                                decoration: BoxDecoration(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .error
                                      .withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(
                                      DesignTokens.radiusGlobal),
                                  border: Border.all(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .error
                                        .withValues(alpha: 0.3),
                                  ),
                                ),
                                child: Text(
                                  authState.errorMessage!,
                                  style: TextStyle(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .error,
                                    fontSize: 13,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              const SizedBox(height: DesignTokens.spaceMd),
                            ],

                            // Login Button
                            PolishedButton(
                              key: const Key('login_button'),
                              label: 'Log In',
                              icon: Icons.login_rounded,
                              isLoading: authState.isLoading,
                              onPressed: _handleLogin,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: DesignTokens.spaceLg),

                    // Signup link
                    Wrap(
                      alignment: WrapAlignment.center,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          "Don't have an account? ",
                          style: TextStyle(
                            color: isDark
                                ? Colors.white60
                                : const Color(0xFF64748B),
                            fontSize: 14,
                          ),
                        ),
                        GestureDetector(
                          onTap: () =>
                              AppRoutes.navigateToSignup(context),
                          child: Text(
                            'Sign Up',
                            style: TextStyle(
                              color: primary,
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

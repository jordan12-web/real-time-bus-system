import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../controllers/auth_controller.dart';
import '../theme/design_tokens.dart';
import '../theme/theme_provider.dart';
import '../widgets/gradient_background.dart';
import '../widgets/guzo_logo.dart';
import '../widgets/polished_button.dart';
import '../widgets/polished_card.dart';

/// Driver Login Screen with keyboard-aware scrolling, focus traversal, and polished Guzo design.
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();

  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    FocusScope.of(context).unfocus();

    if (_formKey.currentState?.validate() ?? false) {
      final success = await ref
          .read(authControllerProvider.notifier)
          .login(_emailController.text.trim(), _passwordController.text);
      if (success && mounted) {
        Navigator.of(context).pushReplacementNamed('/dashboard');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final themeNotifier = ref.watch(themeProviderInstance);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: GradientBackground(
        child: SafeArea(
          child: Stack(
            children: [
              // Theme mode toggle in top-right corner
              Positioned(
                top: DesignTokens.spaceSm,
                right: DesignTokens.spaceSm,
                child: ThemeModeToggle(
                  isDark: isDark,
                  onToggle: () => themeNotifier.toggle(),
                ),
              ),
              Center(
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(
                    DesignTokens.spaceLg,
                    DesignTokens.spaceLg,
                    DesignTokens.spaceLg,
                    MediaQuery.of(context).viewInsets.bottom + DesignTokens.spaceLg,
                  ),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 420),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Guzo Driver Branding
                        const GuzoLogo(
                          size: 38,
                          tagline: 'Driver Portal & Operations',
                        ),
                        const SizedBox(height: DesignTokens.spaceLg),

                        // Centered Form Card
                        PolishedCard(
                          child: AutofillGroup(
                            child: Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Text(
                                    'Welcome Back, Driver',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w700,
                                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: DesignTokens.spaceXs),
                                  Text(
                                    'Sign in to manage trips & broadcast live GPS',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: isDark ? Colors.white60 : const Color(0xFF64748B),
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: DesignTokens.spaceLg),

                                  // Email input field
                                  Semantics(
                                    label: 'Driver email address input',
                                    child: TextFormField(
                                      key: const Key('email_field'),
                                      controller: _emailController,
                                      focusNode: _emailFocus,
                                      keyboardType: TextInputType.emailAddress,
                                      textInputAction: TextInputAction.next,
                                      autofillHints: const [AutofillHints.email],
                                      decoration: const InputDecoration(
                                        labelText: 'Email address',
                                        hintText: 'driver@guzo.com',
                                        prefixIcon: Icon(Icons.email_outlined, size: 20),
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
                                      onFieldSubmitted: (_) {
                                        FocusScope.of(context).requestFocus(_passwordFocus);
                                      },
                                    ),
                                  ),
                                  const SizedBox(height: DesignTokens.spaceMd),

                                  // Password input field
                                  Semantics(
                                    label: 'Driver password input',
                                    child: TextFormField(
                                      key: const Key('password_field'),
                                      controller: _passwordController,
                                      focusNode: _passwordFocus,
                                      obscureText: _obscurePassword,
                                      textInputAction: TextInputAction.done,
                                      autofillHints: const [AutofillHints.password],
                                      decoration: InputDecoration(
                                        labelText: 'Password',
                                        prefixIcon: const Icon(Icons.lock_outline, size: 20),
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
                                      onFieldSubmitted: (_) => _handleLogin(),
                                    ),
                                  ),
                                  const SizedBox(height: DesignTokens.spaceLg),

                                  // Error Banner
                                  if (authState.errorMessage != null) ...[
                                    Container(
                                      padding: const EdgeInsets.all(DesignTokens.spaceSm),
                                      decoration: BoxDecoration(
                                        color: Theme.of(context).colorScheme.error.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(DesignTokens.radiusGlobal),
                                        border: Border.all(
                                          color: Theme.of(context).colorScheme.error.withValues(alpha: 0.3),
                                        ),
                                      ),
                                      child: Text(
                                        authState.errorMessage!,
                                        style: TextStyle(
                                          color: Theme.of(context).colorScheme.error,
                                          fontSize: 13,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                    const SizedBox(height: DesignTokens.spaceMd),
                                  ],

                                  // Login Button
                                  PolishedButton(
                                    buttonKey: const Key('login_button'),
                                    label: 'Log In',
                                    icon: Icons.login_rounded,
                                    isLoading: authState.isLoading,
                                    onPressed: authState.isLoading ? null : _handleLogin,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
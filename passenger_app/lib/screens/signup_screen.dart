import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../controllers/auth_controller.dart';
import '../routes/app_routes.dart';
import '../theme/design_tokens.dart';
import '../widgets/gradient_background.dart';
import '../widgets/guzo_logo.dart';
import '../widgets/polished_button.dart';
import '../widgets/polished_card.dart';

/// Signup Screen with keyboard-aware scrolling and focus traversal.
class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullnameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phonenumberController = TextEditingController();
  final _passwordController = TextEditingController();

  // Focus nodes for deterministic focus traversal
  final _fullnameFocus = FocusNode();
  final _emailFocus = FocusNode();
  final _phoneFocus = FocusNode();
  final _passwordFocus = FocusNode();

  bool _obscurePassword = true;

  @override
  void dispose() {
    _fullnameController.dispose();
    _emailController.dispose();
    _phonenumberController.dispose();
    _passwordController.dispose();
    _fullnameFocus.dispose();
    _emailFocus.dispose();
    _phoneFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  Future<void> _handleSignup() async {
    // Dismiss keyboard before validating/submitting
    FocusScope.of(context).unfocus();

    if (_formKey.currentState?.validate() ?? false) {
      final success = await ref
          .read(authControllerProvider.notifier)
          .signup(
            _fullnameController.text.trim(),
            _emailController.text.trim(),
            _passwordController.text,
            _phonenumberController.text.trim(),
          );
      if (success && mounted) {
        AppRoutes.navigateToLogin(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = isDark ? DesignTokens.darkPrimary : DesignTokens.primary;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: GradientBackground(
        child: SafeArea(
          child: Center(
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
                    // Guzo logo branding
                    const GuzoLogo(size: 38),
                    const SizedBox(height: DesignTokens.spaceLg),

                    // Centered Registration Card
                    PolishedCard(
                      child: AutofillGroup(
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                'Create an Account',
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
                                'Join Guzo for easy intercity bus booking',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: isDark
                                      ? Colors.white60
                                      : const Color(0xFF64748B),
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: DesignTokens.spaceLg),

                              // Full name input
                              Semantics(
                                label: 'Full name input field',
                                child: TextFormField(
                                  key: const Key('full_name'),
                                  controller: _fullnameController,
                                  focusNode: _fullnameFocus,
                                  keyboardType: TextInputType.name,
                                  textInputAction: TextInputAction.next,
                                  autofillHints: const [AutofillHints.name],
                                  decoration: const InputDecoration(
                                    labelText: 'Full name',
                                    prefixIcon: Icon(
                                      Icons.person_outline_rounded,
                                      size: 20,
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return 'Please enter your full name';
                                    }
                                    return null;
                                  },
                                  onFieldSubmitted: (_) {
                                    FocusScope.of(
                                      context,
                                    ).requestFocus(_emailFocus);
                                  },
                                ),
                              ),
                              const SizedBox(height: DesignTokens.spaceMd),

                              // Email input
                              Semantics(
                                label: 'Email input field',
                                child: TextFormField(
                                  key: const Key('signup_email'),
                                  controller: _emailController,
                                  focusNode: _emailFocus,
                                  keyboardType: TextInputType.emailAddress,
                                  textInputAction: TextInputAction.next,
                                  autofillHints: const [AutofillHints.email],
                                  decoration: const InputDecoration(
                                    labelText: 'Email address',
                                    prefixIcon: Icon(
                                      Icons.email_outlined,
                                      size: 20,
                                    ),
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
                                    FocusScope.of(
                                      context,
                                    ).requestFocus(_phoneFocus);
                                  },
                                ),
                              ),
                              const SizedBox(height: DesignTokens.spaceMd),

                              // Phone number input (optional)
                              Semantics(
                                label: 'Phone number input field',
                                child: TextFormField(
                                  key: const Key('phone_number'),
                                  controller: _phonenumberController,
                                  focusNode: _phoneFocus,
                                  keyboardType: TextInputType.phone,
                                  textInputAction: TextInputAction.next,
                                  autofillHints: const [
                                    AutofillHints.telephoneNumber,
                                  ],
                                  decoration: const InputDecoration(
                                    labelText: 'Phone number (optional)',
                                    prefixIcon: Icon(
                                      Icons.phone_outlined,
                                      size: 20,
                                    ),
                                  ),
                                  onFieldSubmitted: (_) {
                                    FocusScope.of(
                                      context,
                                    ).requestFocus(_passwordFocus);
                                  },
                                ),
                              ),
                              const SizedBox(height: DesignTokens.spaceMd),

                              // Password input with toggle
                              Semantics(
                                label: 'Password input field',
                                child: TextFormField(
                                  key: const Key('signup_password'),
                                  controller: _passwordController,
                                  focusNode: _passwordFocus,
                                  obscureText: _obscurePassword,
                                  textInputAction: TextInputAction.done,
                                  autofillHints: const [
                                    AutofillHints.newPassword,
                                  ],
                                  decoration: InputDecoration(
                                    labelText: 'Password',
                                    prefixIcon: const Icon(
                                      Icons.lock_outline,
                                      size: 20,
                                    ),
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
                                    if (value.length < 6) {
                                      return 'Password must be at least 6 characters';
                                    }
                                    return null;
                                  },
                                  onFieldSubmitted: (_) {
                                    _handleSignup();
                                  },
                                ),
                              ),
                              const SizedBox(height: DesignTokens.spaceLg),

                              // Error message
                              if (authState.errorMessage != null) ...[
                                Container(
                                  padding: const EdgeInsets.all(
                                    DesignTokens.spaceSm,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.error.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(
                                      DesignTokens.radiusGlobal,
                                    ),
                                    border: Border.all(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.error.withOpacity(0.3),
                                    ),
                                  ),
                                  child: Text(
                                    authState.errorMessage!,
                                    style: TextStyle(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.error,
                                      fontSize: 13,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                const SizedBox(height: DesignTokens.spaceMd),
                              ],

                              // Signup Button
                              PolishedButton(
                                key: const Key('signup_button'),
                                label: 'Sign Up',
                                icon: Icons.person_add_rounded,
                                isLoading: authState.isLoading,
                                onPressed: authState.isLoading
                                    ? null
                                    : _handleSignup,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: DesignTokens.spaceLg),

                    // Login Link
                    Wrap(
                      alignment: WrapAlignment.center,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          'Already have an account? ',
                          style: TextStyle(
                            color: isDark
                                ? Colors.white60
                                : const Color(0xFF64748B),
                            fontSize: 14,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => AppRoutes.navigateToLogin(context),
                          child: Text(
                            'Log In',
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

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../controllers/auth_controller.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/primary_button.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final success = await ref
        .read(authControllerProvider.notifier)
        .login(_emailController.text.trim(), _passwordController.text);
    if (success && mounted) {
      Navigator.of(context).pushReplacementNamed('/dashboard');
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);

    return AppScaffold(
      title: 'Driver Login',
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Icon(Icons.directions_bus, size: 64),
          const SizedBox(height: 24),
          TextField(
            key: const Key('email_field'),
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(labelText: 'Email'),
          ),
          const SizedBox(height: 12),
          TextField(
            key: const Key('password_field'),
            controller: _passwordController,
            obscureText: true,
            decoration: const InputDecoration(labelText: 'Password'),
          ),
          const SizedBox(height: 20),
          if (authState.errorMessage != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: Text(
                authState.errorMessage!,
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
            ),
          PrimaryButton(
            buttonKey: const Key('login_button'),
            text: 'Log In',
            isLoading: authState.isLoading,
            onPressed: _handleLogin,
          ),
          const SizedBox(height: 16),
          const Text(
            'Only accounts with role "driver" or "admin" can sign in here. '
            'See migration/README.md if you need to promote an account.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
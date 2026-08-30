import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/api_client.dart';
import '../repositories/auth_repository.dart';

final apiClientProvider = Provider<ApiClient>((ref) => ApiClient());

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(ref.watch(apiClientProvider));
});

class AuthState {
  final bool isLoading;
  final DriverUser? user;
  final String? errorMessage;

  const AuthState({this.isLoading = false, this.user, this.errorMessage});

  bool get isLoggedIn => user != null;

  AuthState copyWith({
    bool? isLoading,
    DriverUser? user,
    String? errorMessage,
    bool clearError = false,
    bool clearUser = false,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      user: clearUser ? null : (user ?? this.user),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class AuthController extends StateNotifier<AuthState> {
  final AuthRepository _repository;

  AuthController(this._repository) : super(const AuthState()) {
    _restoreSession();
  }

  Future<void> _restoreSession() async {
    final user = await _repository.getCurrentUser();
    if (user != null) {
      state = state.copyWith(user: user);
    }
  }

  Future<bool> login(String email, String password) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final user = await _repository.login(email, password);
      state = state.copyWith(isLoading: false, user: user);
      return true;
    } on AuthException catch (error) {
      state = state.copyWith(isLoading: false, errorMessage: error.message);
      return false;
    } catch (error) {
      state = state.copyWith(isLoading: false, errorMessage: error.toString());
      return false;
    }
  }

  Future<void> logout() async {
    await _repository.logout();
    state = const AuthState();
  }
}

final authControllerProvider =
    StateNotifierProvider<AuthController, AuthState>((ref) {
  return AuthController(ref.watch(authRepositoryProvider));
});
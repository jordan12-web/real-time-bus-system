import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/api/dio_client.dart';
import '../core/exceptions.dart';
import '../models/user.dart';
import '../repositories/auth_repository.dart';
import '../services/auth_service.dart';
import '../services/booking_service.dart';
import '../services/payment_service.dart';
import '../services/ticket_service.dart';
import '../services/tracking_service.dart';
import '../services/trip_service.dart';
import '../repositories/booking_repository.dart';
import '../repositories/payment_repository.dart';
import '../repositories/ticket_repository.dart';
import '../repositories/tracking_repository.dart';
import '../repositories/trip_repository.dart';

final dioClientProvider = Provider<DioClient>((ref) => DioClient());

final authServiceProvider = Provider<AuthService>(
  (ref) => AuthService(ref.watch(dioClientProvider)),
);

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  final authService = ref.watch(authServiceProvider);
  final repository = AuthRepository(
    authService,
    dioClient: dioClient,
  );
  dioClient.getAccessToken = repository.getAccessToken;
  dioClient.onTokenRefresh = repository.refresh;
  return repository;
});

final tripServiceProvider = Provider<TripService>(
  (ref) => TripService(ref.watch(dioClientProvider)),
);

final tripRepositoryProvider = Provider<TripRepository>(
  (ref) => TripRepository(ref.watch(tripServiceProvider)),
);

final bookingServiceProvider = Provider<BookingService>(
  (ref) => BookingService(ref.watch(dioClientProvider)),
);

final bookingRepositoryProvider = Provider<BookingRepository>(
  (ref) => BookingRepository(
    ref.watch(bookingServiceProvider),
    ref.watch(tripServiceProvider),
  ),
);

final paymentServiceProvider = Provider<PaymentService>(
  (ref) => PaymentService(ref.watch(dioClientProvider)),
);

final paymentRepositoryProvider = Provider<PaymentRepository>(
  (ref) => PaymentRepository(ref.watch(paymentServiceProvider)),
);

final ticketServiceProvider = Provider<TicketService>(
  (ref) => TicketService(ref.watch(dioClientProvider)),
);

final ticketRepositoryProvider = Provider<TicketRepository>(
  (ref) => TicketRepository(ref.watch(ticketServiceProvider)),
);

final trackingServiceProvider = Provider<TrackingService>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return TrackingService(
    ref.watch(dioClientProvider),
    accessTokenProvider: authRepository.getAccessToken,
  );
});

final trackingRepositoryProvider = Provider<TrackingRepository>(
  (ref) => TrackingRepository(ref.watch(trackingServiceProvider)),
);

class AuthState {
  final bool isLoading;
  final User? user;
  final String? errorMessage;

  const AuthState({
    this.isLoading = false,
    this.user,
    this.errorMessage,
  });

  AuthState copyWith({
    bool? isLoading,
    User? user,
    String? errorMessage,
    bool clearUser = false,
    bool clearError = false,
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
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final token = await _repository.getAccessToken();
      if (token != null && token.isNotEmpty) {
        final user = await _repository.me();
        state = state.copyWith(isLoading: false, user: user);
      } else {
        state = state.copyWith(isLoading: false);
      }
    } on ApiException catch (error) {
      if (error.statusCode == 401) {
        final refreshed = await _repository.refresh();
        if (refreshed) {
          final user = await _repository.me();
          state = state.copyWith(isLoading: false, user: user);
          return;
        }
      }
      state = state.copyWith(isLoading: false, clearUser: true);
    } catch (_) {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<bool> login(String email, String password) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final user = await _repository.login(email: email, password: password);
      state = state.copyWith(isLoading: false, user: user);
      return true;
    } on ApiException catch (error) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: error.message,
      );
      return false;
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: error.toString(),
      );
      return false;
    }
  }

  Future<void> logout() async {
    await _repository.logout();
    state = const AuthState();
  }

  Future<bool> refreshSession() async {
    final refreshed = await _repository.refresh();
    if (!refreshed) {
      state = state.copyWith(
        clearUser: true,
        errorMessage: 'Session expired. Please log in again.',
      );
      return false;
    }
    try {
      final user = await _repository.me();
      state = state.copyWith(user: user, clearError: true);
      return true;
    } on ApiException catch (error) {
      state = state.copyWith(errorMessage: error.message, clearUser: true);
      return false;
    }
  }
}

final authControllerProvider =
    StateNotifierProvider<AuthController, AuthState>((ref) {
  return AuthController(ref.watch(authRepositoryProvider));
});

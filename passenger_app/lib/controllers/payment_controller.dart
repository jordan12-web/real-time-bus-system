import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/exceptions.dart';
import '../models/payment.dart';
import '../repositories/payment_repository.dart';
import 'auth_controller.dart' show paymentRepositoryProvider;

class PaymentState {
  final bool isLoading;
  final bool isPolling;
  final PaymentInitiationResult? initiation;
  final Payment? payment;
  final String? errorMessage;

  const PaymentState({
    this.isLoading = false,
    this.isPolling = false,
    this.initiation,
    this.payment,
    this.errorMessage,
  });

  PaymentState copyWith({
    bool? isLoading,
    bool? isPolling,
    PaymentInitiationResult? initiation,
    Payment? payment,
    String? errorMessage,
    bool clearError = false,
  }) {
    return PaymentState(
      isLoading: isLoading ?? this.isLoading,
      isPolling: isPolling ?? this.isPolling,
      initiation: initiation ?? this.initiation,
      payment: payment ?? this.payment,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class PaymentController extends StateNotifier<PaymentState> {
  final PaymentRepository _repository;
  bool _stopPollingRequested = false;

  PaymentController(this._repository) : super(const PaymentState());

  /// Idempotency itself lives in PaymentRepository.initiatePayment — calling
  /// this twice for the same bookingId returns the cached pending result
  /// instead of opening a second Chapa checkout.
  Future<PaymentInitiationResult?> initiatePayment({
    required String bookingId,
    String? returnUrl,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final result = await _repository.initiatePayment(
        bookingId: bookingId,
        returnUrl: returnUrl,
      );
      state = state.copyWith(
        isLoading: false,
        initiation: result,
        payment: result.payment,
      );
      return result;
    } on ApiException catch (error) {
      state = state.copyWith(isLoading: false, errorMessage: error.message);
      return null;
    } catch (error) {
      state = state.copyWith(isLoading: false, errorMessage: error.toString());
      return null;
    }
  }

  /// Polls GET /payments/{id} until status leaves 'pending' or attempts run
  /// out. Call after the user completes checkout in the browser/WebView
  /// opened from initiatePayment's checkoutUrl.
  Future<Payment?> pollPaymentStatus(
    String paymentId, {
    Duration interval = const Duration(seconds: 3),
    int maxAttempts = 20,
  }) async {
    _stopPollingRequested = false;
    state = state.copyWith(isPolling: true, clearError: true);

    for (var attempt = 0; attempt < maxAttempts; attempt++) {
      if (_stopPollingRequested) break;
      try {
        final payment = await _repository.getPayment(paymentId);
        state = state.copyWith(payment: payment);
        if (payment.status != 'pending') {
          state = state.copyWith(isPolling: false);
          if (payment.status == 'success') {
            _repository.clearPendingCache(payment.bookingId);
          }
          return payment;
        }
      } on ApiException catch (error) {
        state = state.copyWith(isPolling: false, errorMessage: error.message);
        return null;
      }
      await Future<void>.delayed(interval);
    }

    state = state.copyWith(isPolling: false);
    return state.payment;
  }

  void stopPolling() => _stopPollingRequested = true;
}

final paymentControllerProvider =
    StateNotifierProvider<PaymentController, PaymentState>((ref) {
  return PaymentController(ref.watch(paymentRepositoryProvider));
});
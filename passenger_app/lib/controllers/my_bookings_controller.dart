import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/exceptions.dart';
import '../models/booking.dart';
import '../repositories/booking_repository.dart';
import 'auth_controller.dart' show bookingRepositoryProvider;

class MyBookingsState {
  final bool isLoading;
  final List<Booking> bookings;
  final String? errorMessage;

  const MyBookingsState({
    this.isLoading = false,
    this.bookings = const [],
    this.errorMessage,
  });

  MyBookingsState copyWith({
    bool? isLoading,
    List<Booking>? bookings,
    String? errorMessage,
    bool clearError = false,
  }) {
    return MyBookingsState(
      isLoading: isLoading ?? this.isLoading,
      bookings: bookings ?? this.bookings,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class MyBookingsController extends StateNotifier<MyBookingsState> {
  final BookingRepository _repository;

  MyBookingsController(this._repository) : super(const MyBookingsState());

  Future<void> loadMyBookings() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final bookings = await _repository.listMyBookings();
      state = state.copyWith(isLoading: false, bookings: bookings);
    } on ApiException catch (error) {
      state = state.copyWith(isLoading: false, errorMessage: error.message);
    } catch (error) {
      state = state.copyWith(isLoading: false, errorMessage: error.toString());
    }
  }
}

final myBookingsControllerProvider =
    StateNotifierProvider<MyBookingsController, MyBookingsState>((ref) {
  return MyBookingsController(ref.watch(bookingRepositoryProvider));
});
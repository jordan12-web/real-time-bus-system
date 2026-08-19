import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/exceptions.dart';
import '../models/booking.dart';
import '../repositories/booking_repository.dart';
import 'auth_controller.dart' show bookingRepositoryProvider;

class BookingState {
  final bool isLoading;
  final Booking? booking;
  final String? selectedSeatNumber;
  final String? errorMessage;

  const BookingState({
    this.isLoading = false,
    this.booking,
    this.selectedSeatNumber,
    this.errorMessage,
  });

  BookingState copyWith({
    bool? isLoading,
    Booking? booking,
    String? selectedSeatNumber,
    String? errorMessage,
    bool clearError = false,
    bool clearSelectedSeat = false,
  }) {
    return BookingState(
      isLoading: isLoading ?? this.isLoading,
      booking: booking ?? this.booking,
      selectedSeatNumber: clearSelectedSeat ? null : (selectedSeatNumber ?? this.selectedSeatNumber),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class BookingController extends StateNotifier<BookingState> {
  final BookingRepository _repository;

  BookingController(this._repository) : super(const BookingState());

  void selectSeat(String seatNumber) {
    state = state.copyWith(selectedSeatNumber: seatNumber, clearError: true);
  }

  void clearSeatSelection() {
    state = state.copyWith(clearSelectedSeat: true);
  }

  Future<bool> createBooking(String tripId, {String? seatNumber}) async {
    final seatToBook = seatNumber ?? state.selectedSeatNumber;
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final booking = await _repository.createBooking(tripId, seatNumber: seatToBook);
      state = state.copyWith(isLoading: false, booking: booking);
      return true;
    } on ApiException catch (error) {
      state = state.copyWith(isLoading: false, errorMessage: error.message);
      return false;
    } catch (error) {
      state = state.copyWith(isLoading: false, errorMessage: error.toString());
      return false;
    }
  }

  Future<void> refreshBooking(String id) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final booking = await _repository.getBooking(id);
      state = state.copyWith(isLoading: false, booking: booking);
    } on ApiException catch (error) {
      state = state.copyWith(isLoading: false, errorMessage: error.message);
    }
  }

  Future<bool> cancelBooking(String id) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final booking = await _repository.cancelBooking(id);
      state = state.copyWith(isLoading: false, booking: booking);
      return true;
    } on ApiException catch (error) {
      state = state.copyWith(isLoading: false, errorMessage: error.message);
      return false;
    }
  }
}

final bookingControllerProvider =
    StateNotifierProvider<BookingController, BookingState>((ref) {
  return BookingController(ref.watch(bookingRepositoryProvider));
});
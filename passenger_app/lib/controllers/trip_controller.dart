import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/exceptions.dart';
import '../models/trip.dart';
import '../repositories/trip_repository.dart';
import 'auth_controller.dart' show tripRepositoryProvider;

class TripListState {
  final bool isLoading;
  final List<Trip> trips;
  final String? errorMessage;

  const TripListState({
    this.isLoading = false,
    this.trips = const [],
    this.errorMessage,
  });

  TripListState copyWith({
    bool? isLoading,
    List<Trip>? trips,
    String? errorMessage,
    bool clearError = false,
  }) {
    return TripListState(
      isLoading: isLoading ?? this.isLoading,
      trips: trips ?? this.trips,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class TripController extends StateNotifier<TripListState> {
  final TripRepository _repository;

  TripController(this._repository) : super(const TripListState());

  Future<void> loadTrips({bool forceRefresh = false}) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final trips = await _repository.listTrips(forceRefresh: forceRefresh);
      state = state.copyWith(isLoading: false, trips: trips);
    } on ApiException catch (error) {
      state = state.copyWith(isLoading: false, errorMessage: error.message);
    } catch (error) {
      state = state.copyWith(isLoading: false, errorMessage: error.toString());
    }
  }

  /// Fetches a single trip without mutating the shared list state.
  Future<Trip> getTrip(String id) => _repository.getTrip(id);
}

final tripControllerProvider =
    StateNotifierProvider<TripController, TripListState>((ref) {
  return TripController(ref.watch(tripRepositoryProvider));
});
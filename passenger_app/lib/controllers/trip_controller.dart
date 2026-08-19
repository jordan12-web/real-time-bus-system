import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/exceptions.dart';
import '../models/trip.dart';
import '../repositories/trip_repository.dart';
import 'auth_controller.dart' show tripRepositoryProvider;

class TripListState {
  final bool isLoading;
  final List<Trip> trips;
  final String? originFilter;
  final String? destinationFilter;
  final DateTime? timeFilter;
  final String? errorMessage;

  const TripListState({
    this.isLoading = false,
    this.trips = const [],
    this.originFilter,
    this.destinationFilter,
    this.timeFilter,
    this.errorMessage,
  });

  TripListState copyWith({
    bool? isLoading,
    List<Trip>? trips,
    String? originFilter,
    String? destinationFilter,
    DateTime? timeFilter,
    String? errorMessage,
    bool clearError = false,
    bool clearFilters = false,
  }) {
    return TripListState(
      isLoading: isLoading ?? this.isLoading,
      trips: trips ?? this.trips,
      originFilter: clearFilters ? null : (originFilter ?? this.originFilter),
      destinationFilter: clearFilters ? null : (destinationFilter ?? this.destinationFilter),
      timeFilter: clearFilters ? null : (timeFilter ?? this.timeFilter),
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

  Future<void> searchTrips({
    String? origin,
    String? destination,
    DateTime? time,
  }) async {
    state = state.copyWith(
      isLoading: true,
      clearError: true,
      originFilter: origin,
      destinationFilter: destination,
      timeFilter: time,
    );
    try {
      final trips = await _repository.searchTrips(
        origin: origin,
        destination: destination,
        time: time,
      );
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
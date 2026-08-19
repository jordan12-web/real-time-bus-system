import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/exceptions.dart';
import '../models/trip_location.dart';
import '../repositories/tracking_repository.dart';
import 'auth_controller.dart' show trackingRepositoryProvider;

class TrackingState {
  final bool isLoading;
  final bool isStreaming;
  final List<TripLocation> recentLocations;
  final TripLocation? latestLocation;
  final String? errorMessage;

  const TrackingState({
    this.isLoading = false,
    this.isStreaming = false,
    this.recentLocations = const [],
    this.latestLocation,
    this.errorMessage,
  });

  TrackingState copyWith({
    bool? isLoading,
    bool? isStreaming,
    List<TripLocation>? recentLocations,
    TripLocation? latestLocation,
    String? errorMessage,
    bool clearError = false,
  }) {
    return TrackingState(
      isLoading: isLoading ?? this.isLoading,
      isStreaming: isStreaming ?? this.isStreaming,
      recentLocations: recentLocations ?? this.recentLocations,
      latestLocation: latestLocation ?? this.latestLocation,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class TrackingController extends StateNotifier<TrackingState> {
  final TrackingRepository _repository;
  StreamSubscription<TripLocation>? _sseSubscription;

  TrackingController(this._repository) : super(const TrackingState());

  Future<void> loadRecentLocations(String tripId, {int limit = 50}) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final locations = await _repository.getRecentLocations(tripId, limit: limit);
      final latest = locations.isNotEmpty ? locations.first : null;
      state = state.copyWith(
        isLoading: false,
        recentLocations: locations,
        latestLocation: latest,
      );
    } on ApiException catch (error) {
      state = state.copyWith(isLoading: false, errorMessage: error.message);
    } catch (error) {
      state = state.copyWith(isLoading: false, errorMessage: error.toString());
    }
  }

  void subscribeLiveTracking(String tripId) {
    _sseSubscription?.cancel();
    state = state.copyWith(isStreaming: true, clearError: true);

    _sseSubscription = _repository.subscribeSse(tripId).listen(
      (location) {
        final updatedList = [location, ...state.recentLocations];
        state = state.copyWith(
          latestLocation: location,
          recentLocations: updatedList,
        );
      },
      onError: (error) {
        state = state.copyWith(
          isStreaming: false,
          errorMessage: error.toString(),
        );
      },
      onDone: () {
        state = state.copyWith(isStreaming: false);
      },
    );
  }

  void unsubscribeLiveTracking() {
    _sseSubscription?.cancel();
    _sseSubscription = null;
    state = state.copyWith(isStreaming: false);
  }

  @override
  void dispose() {
    _sseSubscription?.cancel();
    super.dispose();
  }
}

final trackingControllerProvider =
    StateNotifierProvider<TrackingController, TrackingState>((ref) {
  return TrackingController(ref.watch(trackingRepositoryProvider));
});

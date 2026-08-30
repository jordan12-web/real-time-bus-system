import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

import '../core/permissions.dart';
import '../models/trip.dart';
import '../models/ticket_validation_result.dart';
import '../repositories/driver_trip_repository.dart';
import '../services/driver_service.dart';
import 'auth_controller.dart' show apiClientProvider;

final driverServiceProvider = Provider<DriverService>((ref) {
  return DriverService(ref.watch(apiClientProvider));
});

final driverTripRepositoryProvider = Provider<DriverTripRepository>((ref) {
  return DriverTripRepository(ref.watch(driverServiceProvider));
});

class DriverTripState {
  final bool isLoading;
  final List<Trip> trips;
  final Trip? lastCreatedTrip;
  final bool isBroadcasting;
  final String? lastLocationStatus;
  final TicketValidationResult? lastValidation;
  final String? errorMessage;

  const DriverTripState({
    this.isLoading = false,
    this.trips = const [],
    this.lastCreatedTrip,
    this.isBroadcasting = false,
    this.lastLocationStatus,
    this.lastValidation,
    this.errorMessage,
  });

  DriverTripState copyWith({
    bool? isLoading,
    List<Trip>? trips,
    Trip? lastCreatedTrip,
    bool? isBroadcasting,
    String? lastLocationStatus,
    TicketValidationResult? lastValidation,
    String? errorMessage,
    bool clearError = false,
  }) {
    return DriverTripState(
      isLoading: isLoading ?? this.isLoading,
      trips: trips ?? this.trips,
      lastCreatedTrip: lastCreatedTrip ?? this.lastCreatedTrip,
      isBroadcasting: isBroadcasting ?? this.isBroadcasting,
      lastLocationStatus: lastLocationStatus ?? this.lastLocationStatus,
      lastValidation: lastValidation ?? this.lastValidation,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class DriverTripController extends StateNotifier<DriverTripState> {
  final DriverTripRepository _repository;
  StreamSubscription<Position>? _positionSubscription;
  Timer? _broadcastTimer;

  DriverTripController(this._repository) : super(const DriverTripState());

  Future<void> loadMyTrips(String driverId) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final trips = await _repository.listMyTrips(driverId);
      state = state.copyWith(isLoading: false, trips: trips);
    } on DriverApiException catch (error) {
      state = state.copyWith(isLoading: false, errorMessage: error.message);
    }
  }

  Future<bool> createTrip({
    required String routeId,
    required String vehicleId,
    required String driverId,
    required String origin,
    required String destination,
    required DateTime departureTime,
    required DateTime arrivalTime,
    required double pricePerSeat,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final trip = await _repository.createTrip(
        routeId: routeId,
        vehicleId: vehicleId,
        driverId: driverId,
        origin: origin,
        destination: destination,
        departureTime: departureTime,
        arrivalTime: arrivalTime,
        pricePerSeat: pricePerSeat,
      );
      state = state.copyWith(
        isLoading: false,
        lastCreatedTrip: trip,
        trips: [...state.trips, trip],
      );
      return true;
    } on DriverApiException catch (error) {
      state = state.copyWith(isLoading: false, errorMessage: error.message);
      return false;
    }
  }

  /// Manual, single-shot location emit — the reliable path for a live demo:
  /// no permission dialogs, no dependency on GPS signal indoors, deterministic.
  Future<void> emitLocation({
    required String tripId,
    required double latitude,
    required double longitude,
    double? speedKmh,
    double? heading,
  }) async {
    try {
      await _repository.reportLocation(
        tripId: tripId,
        latitude: latitude,
        longitude: longitude,
        speedKmh: speedKmh,
        heading: heading,
      );
      state = state.copyWith(
        lastLocationStatus: 'Sent ($latitude, $longitude) at ${DateTime.now().toLocal()}',
        clearError: true,
      );
    } on DriverApiException catch (error) {
      state = state.copyWith(errorMessage: error.message);
    }
  }

  /// Real-GPS auto-broadcast, best-effort. Falls back silently (does nothing
  /// but flip isBroadcasting back off) if permission is denied or location
  /// services are off — [emitLocation] above remains available regardless,
  /// so a permission failure here never blocks the demo.
  Future<void> startBroadcast(String tripId, {Duration interval = const Duration(seconds: 5)}) async {
    final granted = await AppPermissions.requestLocation();
    if (!granted) {
      state = state.copyWith(
        errorMessage: 'Location permission denied — use Emit Location manually instead.',
      );
      return;
    }

    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      state = state.copyWith(
        errorMessage: 'Location services are off — use Emit Location manually instead.',
      );
      return;
    }

    state = state.copyWith(isBroadcasting: true, clearError: true);

    _positionSubscription = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high, distanceFilter: 5),
    ).listen((position) {
      emitLocation(
        tripId: tripId,
        latitude: position.latitude,
        longitude: position.longitude,
        speedKmh: position.speed * 3.6,
        heading: position.heading,
      );
    });
  }

  void stopBroadcast() {
    _positionSubscription?.cancel();
    _positionSubscription = null;
    _broadcastTimer?.cancel();
    _broadcastTimer = null;
    state = state.copyWith(isBroadcasting: false);
  }

  Future<void> validateTicket(String qrCodeData) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final result = await _repository.validateTicket(qrCodeData);
      state = state.copyWith(isLoading: false, lastValidation: result);
    } on DriverApiException catch (error) {
      state = state.copyWith(isLoading: false, errorMessage: error.message);
    }
  }

  @override
  void dispose() {
    _positionSubscription?.cancel();
    _broadcastTimer?.cancel();
    super.dispose();
  }
}

final driverTripControllerProvider =
    StateNotifierProvider<DriverTripController, DriverTripState>((ref) {
  return DriverTripController(ref.watch(driverTripRepositoryProvider));
});
# Guzo Real-Time Bus System — Passenger App Technical Guide

---

## 1. System Overview & Architecture

The **Passenger App** (`passenger_app`) is a high-performance cross-platform Flutter application (iOS, Android, Web, Windows) designed for intercity bus discovery, interactive seat booking, Chapa mobile payment checkout, QR ticket rendering, and real-time SSE bus position tracking.

### Architecture & Layering Pattern
The application follows the **Clean Layered Architecture with Repository & Riverpod State Management**:

```
┌─────────────────────────────────────────────────────────┐
│                    Presentation Layer                   │
│   Screens (trip_list, my_trips, tracking, ticket, etc.) │
│   Widgets (polished_card, polished_button, status_badge)│
└────────────────────────────┬────────────────────────────┘
                             │ (ref.watch / ref.read)
                             ▼
┌─────────────────────────────────────────────────────────┐
│                 State Management Layer                  │
│  Riverpod StateNotifiers & ChangeNotifier (ThemeProvider)│
└────────────────────────────┬────────────────────────────┘
                             │
                             ▼
┌─────────────────────────────────────────────────────────┐
│                    Repository Layer                     │
│  (auth_repository, booking_repository, tracking_repo)   │
└────────────────────────────┬────────────────────────────┘
                             │
                             ▼
┌─────────────────────────────────────────────────────────┐
│                  Data / Network Layer                   │
│  DioClient (HTTP + Retry Interceptor) & SSE EventSource │
└────────────────────────────┴────────────────────────────┘
```

---

## 2. Technical Need-to-Knows & Code Snippets

### A. Reactive State Management (Riverpod)
The app utilizes **Flutter Riverpod (`flutter_riverpod: ^2.6.1`)** for immutable, compile-time safe state management:

```dart
// controllers/trip_controller.dart
class TripState {
  final bool isLoading;
  final List<Trip> trips;
  final String? errorMessage;

  const TripState({this.isLoading = false, this.trips = const [], this.errorMessage});

  TripState copyWith({bool? isLoading, List<Trip>? trips, String? errorMessage}) {
    return TripState(
      isLoading: isLoading ?? this.isLoading,
      trips: trips ?? this.trips,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class TripController extends StateNotifier<TripState> {
  final TripRepository _repository;
  TripController(this._repository) : super(const TripState());

  Future<void> loadTrips({bool forceRefresh = false}) async {
    state = state.copyWith(isLoading: true);
    try {
      final trips = await _repository.getTrips();
      state = state.copyWith(isLoading: false, trips: trips);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }
}

final tripControllerProvider = StateNotifierProvider<TripController, TripState>((ref) {
  return TripController(ref.watch(tripRepositoryProvider));
});
```

---

### B. M3 Bottom Navigation Shell
To avoid top app bar clutter, the app employs a `MainNavigationShell` with a Material 3 `NavigationBar`:

```dart
// widgets/main_navigation_shell.dart
class _MainNavigationShellState extends State<MainNavigationShell> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    TripListScreen(),   // Tab 0: Search & Discovery
    MyTripsScreen(),    // Tab 1: Bookings & Tickets
    TrackingScreen(),   // Tab 2: Real-time Live Tracking
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) => setState(() => _currentIndex = index),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.directions_bus_outlined), label: 'Search Trips'),
          NavigationDestination(icon: Icon(Icons.confirmation_number_outlined), label: 'My Tickets'),
          NavigationDestination(icon: Icon(Icons.radar_outlined), label: 'Live Track'),
        ],
      ),
    );
  }
}
```

---

### C. Live Bus Tracking via SSE (Server-Sent Events)
Live bus coordinate updates arrive asynchronously over SSE HTTP streams and update the `FlutterMap` marker position seamlessly:

```dart
// services/tracking_service.dart
Stream<TripLocation> streamTripLocation(String tripId) {
  final url = '${Config.apiBaseUrl}/tracking/stream/$tripId';
  final client = http.Client();
  final request = http.Request('GET', Uri.parse(url));
  request.headers['Accept'] = 'text/event-stream';

  final controller = StreamController<TripLocation>();
  client.send(request).then((response) {
    response.stream
        .transform(utf8.decoder)
        .transform(const LineSplitter())
        .listen((line) {
      if (line.startsWith('data: ')) {
        final jsonStr = line.substring(6).trim();
        final data = json.decode(jsonStr);
        if (data is Map<String, dynamic> && data.containsKey('latitude')) {
          controller.add(TripLocation.fromJson(data));
        }
      }
    });
  });
  return controller.stream;
}
```

---

## 3. End-to-End Traced User Workflows

### Traced Workflow: Search ➔ Seat Selection ➔ Chapa Checkout ➔ QR Ticket
```
Passenger               Passenger App                        Backend Service             Chapa Gateway
    │                         │                                     │                         │
    │── 1. Enters Origin ────>│                                     │                         │
    │    & Destination        │── 2. GET /trips?origin=... ────────>│                         │
    │                         │<── 3. List of Available Trips ──────│                         │
    │                         │                                     │                         │
    │── 4. Selects Seat #12 ─>│                                     │                         │
    │    & Taps Book          │── 5. POST /bookings ───────────────>│                         │
    │                         │<── 6. Booking Created (pending) ────│                         │
    │                         │                                     │                         │
    │── 7. Taps "Pay Now" ───>│── 8. POST /payments/checkout ────────>│                         │
    │                         │                                     │── 9. Init Chapa ───────>│
    │                         │<── 10. Chapa Checkout URL ──────────│<── 11. Return URL ──────│
    │                         │                                     │                         │
    │<── 12. Opens Chapa WebView (Completes Telebirr/Card Payment) ───────────────────────────│
    │                         │                                     │                         │
    │                         │<── 13. Webhook Callback updates Booking to "confirmed" ───────│
    │                         │                                     │                         │
    │── 14. Views Ticket ────>│── 15. GET /tickets/booking/:id ─────>│                         │
    │                         │<── 16. Returns Signed QR Image ─────│                         │
```

---

## 4. Anticipated Instructor Defense Q&A

> **Q1: Why did you use Riverpod instead of Provider or BLoC for state management?**  
> **A:** Riverpod is compile-time safe, does not depend on the Flutter `BuildContext` tree (allowing state controllers to be tested in isolation), automatically disposes unused state, and supports dependency overrides cleanly in `ProviderScope`.

> **Q2: How does the passenger app handle network dropouts during payment checkout?**  
> **A:** The custom `DioClient` uses `axios-retry` / exponential backoff interceptors for API calls. For Chapa checkout, payment verification is asynchronous: even if the mobile app disconnects during payment, Chapa sends a server-to-server webhook directly to our backend to confirm the booking independently.

> **Q3: How is dark mode persistence managed across app restarts?**  
> **A:** `ThemeProvider` reads the saved theme key (`driver_theme_mode` / `theme_mode`) asynchronously from hardware-encrypted secure storage (`FlutterSecureStorage`) during initialization before building `MaterialApp`.

---

## 5. Future Improvements & Roadmap
1. **OSRM Route Polyline Snapping:** Render exact road geometry polyline vectors between Ethiopian cities rather than straight-line distance segments.
2. **Offline Local Ticket Storage:** Cache encrypted QR codes locally in SQLite / Hive so passengers can access boarding passes without internet connectivity at terminal gates.
3. **Push Notifications:** Integrate Firebase Cloud Messaging (FCM) to notify passengers when their bus is 10 minutes away.

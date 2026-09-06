# Guzo Real-Time Bus System — Driver App Technical Guide

---

## 1. System Overview & Architecture

The **Driver App** (`driver_app`) is a dedicated operational Flutter application designed for bus drivers and terminal operators. It focuses strictly on two core operational workflows:
1. **Real-Time GPS Location Broadcasting:** Continuous background/foreground location streaming to update passengers on bus position.
2. **Passenger Boarding & QR Ticket Scanning:** Camera-based QR verification to admit passengers onto the bus and mark tickets as `used`.

> **Note on Separation of Concerns:** In accordance with operational requirements, the **Create Trip** functionality is exclusively hosted on the **Admin Web** platform. Drivers are strictly assigned scheduled trips created by administrators, eliminating data duplication and authorization conflicts.

---

## 2. Technical Need-to-Knows & Code Snippets

### A. Real-Time GPS Location Broadcasting
The driver app captures device GPS positions via `geolocator` and streams updates to the backend:

```dart
// controllers/driver_trip_controller.dart - Live GPS Stream Listener
Future<void> startBroadcast(String tripId) async {
  final granted = await AppPermissions.requestLocation();
  if (!granted) return;

  state = state.copyWith(isBroadcasting: true);

  _positionSubscription = Geolocator.getPositionStream(
    locationSettings: const LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 5, // Triggers every 5 meters moved
    ),
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
```

#### Deterministic Fallback for Live Demos
For indoor presentations or environments without GPS signal, the app features a **Manual Location Emission Form** with city coordinate presets (e.g. Addis Ababa, Bahir Dar):
```dart
Future<void> emitLocation({
  required String tripId,
  required double latitude,
  required double longitude,
  double? speedKmh,
  double? heading,
}) async {
  await _repository.reportLocation(
    tripId: tripId,
    latitude: latitude,
    longitude: longitude,
    speedKmh: speedKmh,
    heading: heading,
  );
  state = state.copyWith(
    lastLocationStatus: 'Sent ($latitude, $longitude) at ${DateTime.now().toLocal()}',
  );
}
```

---

### B. Mobile Scanner & QR Ticket Validation
The app uses `mobile_scanner` to detect QR codes via the device camera, passing the raw Base64 string to the backend for HMAC verification:

```dart
// screens/qr_scanner_screen.dart - Barcode Detection Handler
Future<void> _handleDetection(BarcodeCapture capture) async {
  if (_isProcessing || _awaitingNextScan) return;
  final barcode = capture.barcodes.firstOrNull;
  final rawValue = barcode?.rawValue;
  if (rawValue == null || rawValue.isEmpty) return;

  setState(() => _isProcessing = true);
  await ref.read(driverTripControllerProvider.notifier).validateTicket(rawValue);
  await _controller.stop();
  if (mounted) {
    setState(() {
      _isProcessing = false;
      _awaitingNextScan = true; // Shows "Scan Next Ticket" button
    });
  }
}
```

---

## 3. End-to-End Traced Driver Workflows

### Traced Workflow 1: QR Ticket Scanning & Admittance
```
Passenger Boarding          Driver App Scanner                    Backend Service             MongoDB Database
       │                            │                                    │                           │
       │── 1. Presents QR Code ────>│                                    │                           │
       │    on Mobile Device        │── 2. Camera captures raw string ──>│                           │
       │                            │── 3. POST /tickets/validate ──────>│                           │
       │                            │                                    │── 4. Decode Base64 ──────>│
       │                            │                                    │── 5. Verify HMAC Sig ─────│
       │                            │                                    │── 6. Query Ticket record ─>│
       │                            │                                    │<── 7. Returns Ticket ─────│
       │                            │                                    │                           │
       │                            │                                    │── 8. Check Status:        │
       │                            │                                    │      If status == 'issued':
       │                            │                                    │      Set status = 'used'  │
       │                            │                                    │── 9. Save Ticket ────────>│
       │                            │<── 10. Return { valid: true } ─────│                           │
       │                            │                                                                │
       │<── 11. Visual Green Card ──│                                                                │
       │    "Passenger Admitted"                                                                     │
```

---

## 4. Anticipated Instructor Defense Q&A

> **Q1: Why was the "Create Trip" screen removed from the Driver App?**  
> **A:** Trip creation is an administrative management responsibility (route allocation, fleet scheduling, seat pricing). Keeping trip creation on the **Admin Web** platform enforces role separation of concerns, prevents unauthorized trip creation by individual drivers, and avoids data fragmentation.

> **Q2: How does the driver app prevent duplicate boarding scans if a passenger presents the same QR code twice?**  
> **A:** When a QR code is scanned for the first time, the backend transitions the ticket's database status from `issued` to `used`. If the same QR code is scanned again, the backend returns `{ valid: false, reason: "Ticket has already been used" }`, and the driver app displays a prominent red warning card.

> **Q3: What happens if a driver enters a tunnel or loses GPS connectivity during a trip?**  
> **A:** The `Geolocator` stream automatically pauses updates when signal is lost and resumes seamlessly when connection is re-established. Drivers can also tap preset demo coordinate chips to broadcast point updates manually if required.

---

## 5. Future Improvements & Roadmap
1. **Android Foreground Service:** Run GPS location reporting inside a persistent Android Foreground Service with a ongoing notification bar, ensuring background location updates continue even when the screen is turned off.
2. **Offline Public Key QR Verification:** Store the backend's RSA public key inside the app so ticket signatures can be verified offline locally without cellular connectivity at remote bus terminals.

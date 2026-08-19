# Backend Schema & OpenAPI Migration Runbook

This runbook documents the required backend schema extensions and OpenAPI updates for **Trip Origin/Destination Search** and **Seat Selection**.

---

## 1. OpenAPI Specification Updates (`docs/openapi.yaml`)

### Trip Schema (`/components/schemas/Trip`)
Add required string fields:
```yaml
Trip:
  type: object
  properties:
    id:
      type: string
    route_id:
      type: string
    origin:
      type: string
      example: "Addis Ababa"
    destination:
      type: string
      example: "Hawassa"
    vehicle_id:
      type: string
    driver_id:
      type: string
    departure_time:
      type: string
      format: date-time
    arrival_time:
      type: string
      format: date-time
    price_per_seat:
      type: number
    status:
      type: string
      enum: [scheduled, in_transit, completed, cancelled]
```

### Trips Query Parameters (`GET /trips`)
Add optional query parameters for search:
```yaml
parameters:
  - name: origin
    in: query
    schema:
      type: string
    description: Filter by origin city/station
  - name: destination
    in: query
    schema:
      type: string
    description: Filter by destination city/station
  - name: time
    in: query
    schema:
      type: string
      format: date-time
    description: Filter trips departing on or after given timestamp
```

### Booking Schema (`/components/schemas/Booking`)
Add optional string field:
```yaml
Booking:
  type: object
  properties:
    id:
      type: string
    user_id:
      type: string
    trip_id:
      type: string
    seat_number:
      type: string
      example: "Seat 12"
    status:
      type: string
      enum: [pending, confirmed, cancelled, expired]
    total_amount:
      type: number
    currency:
      type: string
    hold_expires_at:
      type: string
      format: date-time
```

---

## 2. Database Schema Migration (MongoDB Mongoose)

1. **Trip Collection (`backend/src/models/Trip.js`)**:
   - Added `origin` (String, required, default: "Addis Ababa").
   - Added `destination` (String, required, default: "Hawassa").
   - MongoDB automatically accommodates new fields on existing documents via default values.

2. **Booking Collection (`backend/src/models/Booking.js`)**:
   - Added `seat_number` (String, optional).
   - Compound check added in `bookingService.js` preventing duplicate active bookings for the same seat on a trip (`{ trip_id, seat_number, status: { $in: ['pending', 'confirmed'] } }`).

---

## 3. Verification Checklist

1. **Backend Verification**:
   - [ ] Run backend `npm start` in `backend/`.
   - [ ] Call `GET /trips?origin=Addis&destination=Hawassa` and verify filtered results.
   - [ ] Call `POST /bookings` with payload `{ "trip_id": "<id>", "seat_number": "Seat 5" }` and verify `seat_number` returned in JSON.
   - [ ] Attempt duplicate seat booking and verify `400 Bad Request` with error message `"Seat Seat 5 is already reserved for this trip"`.

2. **Frontend Verification**:
   - [ ] Run `flutter analyze` in `passenger_app/` — verify 0 errors.
   - [ ] Run unit tests: `flutter test` in `passenger_app/`.

# API Changelog & Versioning Policy

## Versioning Policy
This API follows [Semantic Versioning (SemVer 2.0.0)](https://semver.org/).
- **MAJOR** (`v1.0.0` → `v2.0.0`): Breaking changes to request/response schemas or endpoint removals.
- **MINOR** (`v1.0.0` → `v1.1.0`): Backward-compatible new features, new endpoints, or optional query params.
- **PATCH** (`v1.0.0` → `v1.0.1`): Backward-compatible bug fixes or performance updates.

---

## [v1.0.0] - 2026-08-14

### Initial Release (MVP Backend)
Initial release of the Real-Time Bus Reservation System backend API built with Node.js, Express, and MongoDB.

#### Implemented Endpoints:

- **Health Check**:
  - `GET /health` — Check server operational status.

- **Authentication (`/auth`)**:
  - `POST /auth/signup` — User registration.
  - `POST /auth/login` — User authentication and JWT token issuance.
  - `POST /auth/refresh` — Stateless JWT refresh token endpoint.
  - `GET /auth/me` — Protected profile endpoint.

- **Trips (`/trips`)**:
  - `GET /trips` — List all scheduled trips.
  - `POST /trips` — Create new trip (Admin/Driver only).
  - `GET /trips/:id` — Get trip details.

- **Bookings (`/bookings`)**:
  - `POST /bookings` — Reserve seat on a trip.
  - `GET /bookings/:id` — Retrieve booking details.
  - `DELETE /bookings/:id` — Cancel booking.

- **Payments (`/payments`)**:
  - `POST /payments/initiate` — Initiate Chapa checkout.
  - `POST /payments/webhook` — Public Chapa webhook receiver with API transaction verification.
  - `GET /payments/:id` — Retrieve payment status.

- **Tickets (`/tickets`)**:
  - `POST /tickets/:bookingId/generate` — Generate HMAC-signed QR ticket.
  - `POST /tickets/validate` — Validate QR ticket and mark as used (Driver/Admin only).
  - `POST /tickets/:id/revoke` — Revoke ticket (Admin only).

- **GPS Tracking (`/tracking`)**:
  - `POST /tracking/report` — Report driver GPS coordinates (Driver/Admin only).
  - `GET /tracking/:tripId/recent` — Fetch recent location history.
  - `GET /tracking/:tripId/stream` — Real-time location stream via Server-Sent Events (SSE).

---

## Migration & Deprecation Guidelines (Future Major Releases)
1. Breaking changes will be introduced under a new version prefix (e.g. `/api/v2/`).
2. Deprecated endpoints will be marked in OpenAPI specifications with `deprecated: true` for a minimum of 90 days before removal.

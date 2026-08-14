# Project Decisions

## 2026-08-08
- **Decision**: Backend framework switched from Java/Spring Boot to Node.js/Express.
- **Reason**: Faster iteration, team familiarity, easier AI scaffolding.
- **Impact**: Database changed from MySQL to MongoDB.

## 2026-08-08
- **Decision**: Authentication via JWT + refresh tokens.
- **Reason**: Industry standard, scalable, secure.
- **Impact**: Requires token middleware and refresh endpoint.

## 2026-08-08
- **Decision**: Stateless refresh tokens signed with `JWT_REFRESH_SECRET`.
- **Reason**: Lean Phase 1/2 setup without additional redis/database session management.
- **Impact**: Refresh tokens will need persistent token rotation/revocation list in a future phase if revocation on logout is required.

## 2026-08-10
- **Decision**: Chapa Payment Webhook Verification Strategy.
- **Reason**: Security requirement — webhooks payloads must not be trusted blindly.
- **Impact**: The `POST /payments/webhook` endpoint extracts `tx_ref` and explicitly invokes Chapa's transaction verification API (`GET /v1/transaction/verify/:tx_ref`) using `CHAPA_SECRET_KEY` before updating Payment status to `success`/`failed` and Booking status to `confirmed`/`cancelled`. Secrets are managed via `CHAPA_SECRET_KEY` and `CHAPA_PUBLIC_KEY` in environment variables.

## 2026-08-11
- **Decision**: QR Ticket HMAC Signature & Local File Storage.
- **Reason**: Ensure tamper-proof QR tickets without heavy external dependencies.
- **Impact**: QR payload `{ t, b, u, r, iat }` is signed using HMAC-SHA256 with `JWT_SECRET`. The payload and signature are base64-encoded and generated as a PNG using `qrcode` library stored in `uploads/tickets/` served statically via `/uploads`.

## 2026-08-11
- **Decision**: Real-Time GPS Tracking via Server-Sent Events (SSE).
- **Reason**: Minimal, lightweight, native HTTP streaming protocol without needing WebSocket infrastructure or external socket libraries for MVP.
- **Impact**: Drivers post locations via `POST /tracking/report`, emitting events on Node.js EventEmitter. Passengers subscribe via `GET /tracking/:tripId/stream` to receive real-time location stream.

## 2026-08-12
- **Decision**: Backend Stabilization, Input Validation & Idempotency Strategy.
- **Reason**: Ensure backend reliability, prevent double-bookings, avoid duplicate payment creation, and maintain clean error formatting under high load.
- **Impact**: 
  1. Standardized JSON error response format `{ "error": "message" }` with global Express error handler.
  2. Input validation for email format, password strength, dates, and geographic coordinate bounds (-90 to 90 lat, -180 to 180 lng).
  3. Double-booking prevention per user/trip for active bookings.
  4. Payment initiation idempotency (returns existing pending payment checkout URL if present).
  5. Process crash safety via `uncaughtException` and `unhandledRejection` handlers in `server.js`.

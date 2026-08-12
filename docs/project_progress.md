# Project Progress

## Phase 1 — Setup
[Done] MongoDB cluster
[Done] Repo initialized
[Done] Scaffold Node.js project

## Phase 2 — Authentication
[Done] User model
[Done] Signup endpoint
[Done] Login endpoint
[Done] Me endpoint
[Done] JWT + refresh tokens
* Note: Refresh tokens are stateless and signed with JWT_REFRESH_SECRET. They must be rotated in a future task if persistent revocation is required.

## Phase 3 — Booking & Trips
[Done] Trip model
[Done] Booking model
[Done] Trip endpoints (`GET /trips`, `POST /trips`, `GET /trips/:id`)
[Done] Booking endpoints (`POST /bookings`, `GET /bookings/:id`, `DELETE /bookings/:id`)
[Done] Role-based access control middleware

## Phase 4 — Payment (Chapa Sandbox)
[Done] Payment model (`src/models/Payment.js`)
[Done] Payment service (`src/services/paymentService.js`)
[Done] Initiate checkout endpoint (`POST /payments/initiate`)
[Done] Public webhook endpoint (`POST /payments/webhook` with Chapa API verification)
[Done] Get payment status endpoint (`GET /payments/:id`)
[Done] Automatic Booking status update on payment verification (`confirmed` on success, `cancelled` on failure)

## Phase 5 — Tickets & Tracking
[Done] Ticket model (`src/models/Ticket.js`)
[Done] QR payload signing & HMAC-SHA256 verification
[Done] QR PNG generation using `qrcode` library (saved under `uploads/tickets/`)
[Done] Generate ticket endpoint (`POST /tickets/:bookingId/generate`)
[Done] Validate ticket endpoint (`POST /tickets/validate`)
[Done] Revoke ticket endpoint (`POST /tickets/:id/revoke`)
[Done] TripLocation model (`src/models/TripLocation.js`)
[Done] GPS location reporting endpoint (`POST /tracking/report`)
[Done] Recent locations query endpoint (`GET /tracking/:tripId/recent`)
[Done] Real-time tracking stream via Server-Sent Events (`GET /tracking/:tripId/stream`)

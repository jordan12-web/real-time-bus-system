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
[Todo] QR ticket generation
[Todo] QR validation
[Todo] GPS tracking

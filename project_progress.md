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

## Phase 6 — Stabilization & Hardening
[Done] Standardized JSON error response handling (`{ "error": "message" }`) across all services & controllers
[Done] Process stability handlers (`uncaughtException`, `unhandledRejection`) in `server.js`
[Done] Strict request input validation (email format, password length, date sanity, numeric ranges)
[Done] Double-booking prevention check per passenger/trip in `bookingService.js`
[Done] Idempotent payment initiation handling in `paymentService.js`
[Done] Gateway & unexpected error logging

## Task 3 — Documentation & API Contract
[Done] OpenAPI 3.0.3 Specification (`docs/openapi.yaml`)
[Done] Postman Collection v2.1 (`docs/postman_collection.json`)
[Done] Postman Environment (`docs/postman_environment.json`)
[Done] API Runbook & Testing Guide (`docs/README_API.md`)
[Done] API Changelog & Versioning Policy (`docs/API_CHANGELOG.md`)
[Done] CI Pipeline Newman Contract Verification (`infra/ci.yml`)

## Task 4 — Deployment, Staging, and Monitoring
[Done] Staging deployment guide for Render & webhook integration (`docs/deploy_staging.md`)
[Done] GitHub Actions CI/CD Pipeline (`.github/workflows/ci.yml`)
[Done] Staging environment template (`docs/staging_env.example`)
[Done] Monitoring, logging & alerting architecture (`docs/monitoring.md`)
[Done] Sentry configuration snippet (`backend/src/config/sentry.js`)
[Done] Emergency code rollback & database restoration runbook (`docs/rollback.md`)

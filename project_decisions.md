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

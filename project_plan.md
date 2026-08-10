# Real-Time Bus Reservation System Backend

## Project Overview
- **What**: Backend for passenger app MVP (auth, booking, payment, QR, tracking).
- **Why**: Enable real-time reservations and tracking for bus passengers.
- **Who**: Passengers, drivers, admins.
- **Problem Solved**: Manual booking inefficiency, lack of real-time updates.

## Goals
- **MVP**: Auth, booking, payment, QR ticketing, GPS tracking.
- **Long-term**: Full multi-role system with notifications, refunds, advanced analytics.
- **Success Criteria**: Working backend connected to frontend by Sunday.
- **Out-of-Scope**: Push notifications, advanced refunds, multiple payment providers.

## Features
- **Auth**: Signup, login, JWT + refresh tokens.
- **Booking**: Search trips, reserve seats, cancel.
- **Payment**: Chapa sandbox integration.
- **Tickets**: QR generation + validation.
- **Tracking**: GPS updates for trips.

## User Flows
- Passenger signup/login → search trips → book seat → pay → get QR ticket → track bus.
- Admin login → manage routes/trips → view bookings.
- Driver login → update GPS location.

## Technical Architecture
- **Backend**: Node.js + Express.
- **Database**: MongoDB (Atlas).
- **Auth**: JWT + refresh tokens.
- **Services**: Auth, booking, payment, ticket, tracking.
- **Frontend**: Flutter (passenger), React (admin).

## Tech Stack
- **Framework**: Express.
- **Database**: MongoDB + Mongoose.
- **Auth**: JWT, bcrypt.
- **Hosting**: TBD (Heroku/Render).
- **CI/CD**: GitHub Actions.
- **Monitoring**: TBD.

## Project Structure
backend/
src/
controllers/
services/
models/
routes/
utils/
config/
app.js
server.js
docs/
project_plan.md
project_progress.md
project_decisions.md


## Database Design
- **User**: email, passwordHash, role.
- **Trip**: route, schedule, seats.
- **Booking**: userId, tripId, seat, status.
- **Payment**: bookingId, amount, status.
- **Ticket**: bookingId, QRCode.
- **Location**: tripId, coordinates, timestamp.

## API Design
- `/auth/signup`, `/auth/login`, `/auth/me`
- `/trips`, `/bookings`, `/payments`, `/tickets`, `/tracking`

## Coding Standards
- Snake_case for DB fields.
- Consistent error handling.
- JWT middleware for protected routes.
- Unit tests for services.

## Non-Functional Requirements
- **Performance**: Handle 1000 concurrent users.
- **Security**: Hash passwords, secure JWT.
- **Reliability**: Fail gracefully.
- **Scalability**: Modular services.

## Future Ideas
- Push notifications.
- Refunds.
- Multi-payment providers.

## Decision Log
- 2026-08-08: Switched backend from Java/Spring Boot to Node.js/MongoDB.
- Reason: Faster iteration, easier AI scaffolding.

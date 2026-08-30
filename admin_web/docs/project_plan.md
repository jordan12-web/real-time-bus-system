# Admin Web Dashboard — Project Plan

> Read this file first, every session. It is the single source of truth for
> this sub-project. If code conflicts with what's written here, that's a bug
> in one of the two — point it out before changing anything.

## Overview

**What:** A web dashboard for admins/dispatchers to manage the Real-Time Bus
Reservation & Tracking System — create and monitor trips, view who's booked
on each trip, and manage user roles (most importantly, promoting a user to
`driver`, since there's currently no way to do that except editing MongoDB
directly).

**Why:** The passenger app and driver app both assume trips, routes, and
driver assignments already exist. Nothing currently creates them except
manual `POST /trips` calls via Postman, and nothing lets you turn a
passenger account into a driver account except a raw MongoDB edit. This
dashboard is the missing piece that makes the whole system usable without
a database GUI open.

**Who:** The project owner, acting as admin, for demo purposes. Not
building for multiple concurrent admin users or a permissions hierarchy —
one `admin`-role account is enough for this project's scope.

**Problem it solves:** Every "who does this?" gap we found while building
the driver app (trip creation, driver promotion) belongs here instead.

## Goals

**MVP goals (Tier 1):**
- Admin can log in with an existing `admin`-role account
- Admin can view and create trips
- Admin can view who's booked on a given trip (manifest) — origin,
  destination, seat, payment status
- Admin can view and promote users to `driver` role
- Admin can see basic dashboard stats (trip count, booking count, revenue)

**Long-term vision (Tier 2 — not MVP, only if time remains):**
- Cancel / update trip status
- View all payments (a table; today only single-payment lookup exists)
- Revoke a ticket from the dashboard (backend endpoint already exists,
  `POST /tickets/:id/revoke`, admin-only — just needs a UI)

**Success criteria:** Can demo, live, in front of an instructor: log in →
create a trip → (separately, in the passenger app) book and pay for a seat
on it → come back to the dashboard and see that booking in the trip's
manifest.

**Out of scope:** Multi-admin permissions, audit logging, anything
resembling a full CRM. This is an internship MVP, not a product.

## Features (Tier 1 detail)

### Admin login
- **Purpose:** Gate the whole dashboard behind an authenticated admin session.
- **Requirements:** Reuses `POST /auth/login` — same backend, same JWT, same
  pattern as the passenger and driver apps. No new backend work.
- **Edge cases:** A `passenger`/`driver`-role account logging in here should
  be rejected client-side with a clear message, same pattern used in the
  driver app's `AuthRepository`.
- **Dependencies:** None — endpoint exists.

### Trip list + create trip
- **Purpose:** Replace manual Postman calls for trip creation.
- **Requirements:** `GET /trips` (exists, public/unfiltered), `POST /trips`
  (exists, `driver`/`admin` role). `route_id`/`vehicle_id` are free-text
  strings on the real schema — no separate Route/Vehicle collections to
  manage (confirmed against `backend/src/models/Trip.js`).
- **Edge cases:** Departure must be before arrival (client-side validation,
  mirrors what the driver app's create-trip screen already does).
- **Dependencies:** None — endpoints exist.

### Trip manifest (who's booked on a trip)
- **Purpose:** See passengers, seats, and payment status for a specific trip.
- **Requirements:** **Needs a new backend endpoint** —
  `GET /trips/:id/bookings` (admin/driver-scoped). Nothing like it exists
  today; the only booking-list endpoint (`GET /bookings`) is scoped to "my
  bookings" for the calling user.
- **Edge cases:** Empty manifest (no bookings yet) should read as normal,
  not an error state.
- **Dependencies:** New backend endpoint (Phase 3 of progress tracker).

### User management (list + promote role)
- **Purpose:** Directly replaces the "manually edit MongoDB" step from
  `driver_app/migration/README.md`.
- **Requirements:** **Needs two new backend endpoints** — `GET /users`
  (admin-only, list) and `PATCH /users/:id/role` (admin-only, updates the
  `role` enum field on `User`).
- **Edge cases:** Don't let an admin demote themselves by accident (client-
  side confirmation at minimum; a backend guard is nice-to-have, not
  required for MVP).
- **Dependencies:** Two new backend endpoints (Phase 4).

### Dashboard stats
- **Purpose:** At-a-glance numbers for the demo — trip count, booking count,
  total revenue.
- **Requirements:** **Needs a new backend endpoint** — `GET /admin/stats`
  (admin-only), a small aggregate query over existing `Trip`, `Booking`,
  `Payment` collections. Revenue = sum of `Payment` docs with
  `status: 'success'`.
- **Dependencies:** New backend endpoint (Phase 5).

## User Flows

1. **Login:** Open dashboard → enter admin credentials → land on trip list.
2. **Create a trip:** Trip list → "Create Trip" → fill form → submit → see
   it appear in the list.
3. **View manifest:** Trip list → click a trip → see passenger table.
4. **Promote a driver:** Users page → find a passenger account → "Promote
   to Driver" → confirm → role updates.
5. **Check stats:** Dashboard home shows trip/booking/revenue counts on load.

## Technical Architecture

Same separation-of-concerns discipline as the Flutter apps, translated to
React idioms rather than forced into literal MVC classes:

| Flutter layer | React equivalent | Role |
|---|---|---|
| `services/` | `src/api/` | Axios calls, one function per endpoint, zero business logic |
| `repositories/` + `controllers/` | `src/hooks/` (TanStack Query) | Caching, loading/error state, refetching |
| `models/` | `src/types/` | TypeScript interfaces matching real JSON shapes |
| `widgets/` | `src/components/` | Reusable UI |
| `screens/` | `src/pages/` | Route-level views |
| `routes/app_routes.dart` | `src/routes/` | React Router config |

## Tech Stack (decided, see `project_decisions.md` for the "why")

- **React 18 + TypeScript** — matches the original plan once "React Native"
  is corrected to plain React; most transferable skill for future work.
- **Vite** — not Create React App (deprecated).
- **React Router** — navigation.
- **TanStack Query + Axios** — server state, caching, loading/error handling.
- **Ant Design** — component library; purpose-built for admin dashboards
  (tables, forms, layout out of the box), prioritizing build speed given
  this project has already run long.

## Project Structure

```
admin_web/
├── docs/
│   ├── project_plan.md
│   ├── project_progress.md
│   └── project_decisions.md
├── src/
│   ├── api/            # axios calls, one file per resource
│   ├── hooks/           # TanStack Query hooks wrapping api/
│   ├── types/            # TS interfaces matching real backend JSON
│   ├── components/       # reusable UI
│   ├── pages/             # route-level views
│   ├── routes/            # router config + auth guard
│   ├── App.tsx
│   └── main.tsx
├── .env.example
├── package.json
├── tsconfig.json
└── vite.config.ts
```

## Database Design

No new database — reuses the existing MongoDB collections
(`User`, `Trip`, `Booking`, `Payment`, `Ticket`, `TripLocation`). See the
root `docs/openapi.yaml` for the authoritative shapes. This dashboard adds
no new collections, only new *read* (and one *write* — role promotion)
endpoints over existing data.

## API Design

Existing endpoints (see root `docs/openapi.yaml` and
`docs/api_key_format.md` for exact casing per field — same conventions
apply here, no new casing rules invented):
- `POST /auth/login`
- `GET /trips`, `POST /trips`

New endpoints this project adds (document here until they're added to the
root `openapi.yaml`):
- `GET /trips/:id/bookings` — admin/driver — returns bookings for one trip
- `GET /users` — admin only — list users
- `PATCH /users/:id/role` — admin only — body `{ role: 'passenger' | 'driver' | 'admin' }`
- `GET /admin/stats` — admin only — returns `{ tripCount, bookingCount, totalRevenue, currency }`

## Coding Standards

- Components: PascalCase, one per file, file name matches component name.
- Hooks: `useXxx.ts`, one TanStack Query hook per resource operation
  (e.g. `useTrips`, `useCreateTrip`).
- API functions: camelCase, mirror the Dart services' naming
  (`listTrips`, `createTrip`) for cross-codebase consistency.
- Types mirror the wire format exactly (snake_case fields where the backend
  sends snake_case) — no normalization layer, matching the conclusion we
  already reached on the Flutter side: response bodies are consistently
  snake_case, so there's nothing to normalize.
- No default exports except page components (React Router convention);
  everything else is a named export.

## Non-Functional Requirements

Kept deliberately light — this is an internship MVP dashboard, not a
product:
- Desktop-only layout is fine; no mobile responsiveness requirement (this
  is an admin tool, not something demoed on a phone).
- JWT stored in memory or `sessionStorage`, not `localStorage` — closing
  the tab ends the admin session, which is an acceptable and simple
  security default for this scope.
- Basic error states (failed request shows a message) — no need for retry/
  backoff logic like the passenger app's `DioClient` has; an admin can just
  click again.

## Future Ideas (not being built now)

- Tier 2 features listed above (cancel trip, payments table, ticket revoke UI)
- Dark mode
- CSV export of manifests/stats

## Decision Log

**2026-08-29 — Chose React + TypeScript over Flutter Web or Vue.**
Reasoning: matches the original plan once "React Native" (mobile-only,
can't build a website) is corrected to plain React; most transferable
skill for the person's future internships/jobs; avoids writing a third
Dart codebase instead of learning something new.

**2026-08-29 — Chose Ant Design over shadcn/ui or Mantine.**
Reasoning: no strong preference given by the project owner; Ant Design is
purpose-built for admin dashboards specifically (tables/forms/layout ready
out of the box), prioritizing build speed given the project has already
run long past its original 3-week estimate.

**2026-08-29 — Trip creation moved from driver app to admin dashboard.**
Reasoning: trip creation requires assigning `route_id`, `vehicle_id`, and
`driver_id` together — a dispatch decision ("which driver takes which
vehicle on which route"), not something an individual driver should
self-serve. Originally implemented in the driver app per an external spec
that didn't reflect this; corrected before that code was ever committed.

**2026-08-29 — Adopted a docs-first workflow (this file + progress +
decisions logs) for this sub-project and future ones.**
Reasoning: Claude has no persistent memory of a specific codebase across
separate conversations. Maintaining these three files as the source of
truth (not chat history) means any future session — with Claude or another
AI — can resume this project correctly by reading them first.

# Admin Web Dashboard — Progress

> Tracks implementation, not ideas. See `project_plan.md` for the "what and
> why"; this file is only "what's actually done."

## Phase 1 — Project Setup
- [x] Scaffold Vite + React + TypeScript project
- [x] Install and configure Ant Design
- [x] Install React Router, TanStack Query, Axios
- [x] Set up `src/api`, `src/hooks`, `src/types`, `src/components`, `src/pages`, `src/routes` folders
- [x] `.env.example` with `VITE_API_BASE_URL`
- [ ] ESLint + Prettier configuration (deferred — not blocking demo work)

## Phase 2 — Auth
- [x] `types/auth.ts` — matches real `AuthResponse`/`User` shapes
- [x] `api/authApi.ts` — `login()`
- [x] Axios client with token attached from memory (`api/client.ts`)
- [x] `hooks/useAuth.tsx` — auth context + `useAuth()` hook
- [x] `pages/LoginPage.tsx` — working login form
- [x] `routes/ProtectedRoute.tsx` — redirects to `/login` if not authenticated, rejects non-admin roles
- [x] `App.tsx` wired with router + protected shell

## Phase 3 — Trips
- [ ] Backend: `GET /trips/:id/bookings` (new endpoint)
- [ ] `types/trip.ts`
- [ ] `api/tripsApi.ts` — `listTrips`, `createTrip`, `getTripBookings`
- [ ] `hooks/useTrips.ts`, `hooks/useCreateTrip.ts`, `hooks/useTripBookings.ts`
- [ ] `pages/TripsPage.tsx` — table + "Create Trip" button
- [ ] `pages/CreateTripPage.tsx` or modal — form
- [ ] `pages/TripDetailPage.tsx` — manifest table

## Phase 4 — Users
- [ ] Backend: `GET /users`, `PATCH /users/:id/role` (new endpoints)
- [ ] `types/user.ts`
- [ ] `api/usersApi.ts`
- [ ] `hooks/useUsers.ts`, `hooks/usePromoteUser.ts`
- [ ] `pages/UsersPage.tsx` — table + role-promote action

## Phase 5 — Dashboard Stats
- [ ] Backend: `GET /admin/stats` (new endpoint)
- [ ] `types/stats.ts`
- [ ] `api/statsApi.ts`
- [ ] `hooks/useStats.ts`
- [ ] `pages/DashboardPage.tsx` — stat cards, set as the post-login landing page

## Phase 6 — Tier 2 (only if time remains)
- [ ] Cancel/update trip status
- [ ] Payments table
- [ ] Ticket revoke UI

---

**Current state as of this session:** Phase 1 and Phase 2 complete — the
skeleton scaffolded this session includes a fully working login flow
against the real backend, a protected route shell, and empty placeholder
pages for Trips/Users/Dashboard ready for Phase 3-5 to fill in. **Next
unfinished task: Phase 3, starting with the new backend endpoint
`GET /trips/:id/bookings`.**

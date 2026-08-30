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
- [x] Backend: `GET /trips/:id/bookings` (new endpoint, admin/driver-scoped)
- [x] `types/trip.ts`
- [x] `api/tripsApi.ts` — `listTrips`, `createTrip`, `getTrip`, `getTripBookings`
- [x] `hooks/useTrips.ts`, `hooks/useCreateTrip.ts`, `hooks/useTripBookings.ts` (also exports `useTrip`)
- [x] `pages/TripsPage.tsx` — table + "Create Trip" modal (driver field is a dropdown fed by Users, not a raw ObjectId input)
- [x] `pages/TripDetailPage.tsx` — manifest table, route `/trips/:id`

## Phase 4 — Users
- [x] Backend: `GET /users`, `PATCH /users/:id/role` (new files: `userService.js`, `userController.js`, `userRoutes.js`; self-demotion guarded against server-side)
- [x] `types/user.ts` (reuses `UserRole` from `types/auth.ts`)
- [x] `api/usersApi.ts`
- [x] `hooks/useUsers.ts`, `hooks/usePromoteUser.ts` (exports `useUpdateUserRole`)
- [x] `pages/UsersPage.tsx` — table + inline role-change `Select` per row

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

**Current state as of this session:** Phases 1-4 complete. Trips can be
listed and created (driver assignment via a searchable dropdown, not a raw
ID field), each trip has a manifest view showing passengers/seats/payment
status, and users can be listed and promoted/demoted by role directly from
the dashboard — replacing the manual MongoDB edit documented in
`driver_app/migration/README.md`. All new backend files syntax-validated
(`node --check`); all new frontend code type-checked (`tsc -b`) and
production-built (`vite build`) successfully before delivery. **Next
unfinished task: Phase 5, starting with the new backend endpoint
`GET /admin/stats`.**

**Important — not yet pushed:** none of this (Phases 1-4) is in the GitHub
repo yet as of this session. The `admin_web/` folder needs to be added and
committed, and the backend changes (`app.js`, `src/routes/tripRoutes.js`,
`src/routes/userRoutes.js` [new], `src/controllers/tripController.js`,
`src/controllers/userController.js` [new], `src/services/tripService.js`,
`src/services/userService.js` [new]) need to be merged into `backend/` and
redeployed to Render before any of this works against the live site.
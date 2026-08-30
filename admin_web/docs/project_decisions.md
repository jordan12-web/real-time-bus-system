# Admin Web Dashboard — Decision Log

Format per entry: date, what changed, why, alternatives considered,
consequences. Newest first.

---

**2026-08-30 — Create Trip's driver field is a dropdown, not a text input.**
- **What:** `TripsPage.tsx`'s create-trip form fetches `useUsers()`,
  filters to `role === 'driver'`, and shows a searchable `Select` for
  `driver_id` instead of asking the admin to paste a raw MongoDB
  ObjectId.
- **Why:** Phase 3 and Phase 4 were built in the same session — this was
  a natural place to make them reinforce each other rather than ship
  Phase 3 with a UX gap Phase 4 was about to make easy to fix.
- **Consequences:** If no `driver`-role accounts exist yet, the dropdown
  is disabled with a message pointing at the Users page. Trip creation
  is soft-blocked until at least one driver exists — intentional, since
  a trip with no valid driver assigned isn't useful anyway.

---

**2026-08-30 — Self-demotion guarded server-side, not just client-side.**
- **What:** `PATCH /users/:id/role` rejects a request where the
  authenticated admin tries to change their own role away from `admin`.
- **Why:** A client-side-only guard is trivially bypassed with a direct
  API call; this is cheap to enforce server-side and prevents an admin
  from locking themselves out of the only account that can undo it.
- **Alternatives considered:** No guard at all (rejected — one wrong
  click and the demo has no working admin account left).

---

**2026-08-29 — Adopted a docs-first workflow for this sub-project.**
- **What:** Created `project_plan.md`, `project_progress.md`, and this file,
  following a documentation-first AI-assisted development workflow.
- **Why:** Claude has no persistent memory of a specific codebase across
  separate conversations. These three files, kept accurate and current,
  let any future session (with Claude or otherwise) resume correctly by
  reading them first, instead of requiring the project owner to
  re-explain context every time.
- **Alternatives considered:** Relying on chat history / re-explaining
  context each session (status quo for the rest of this monorepo so far).
- **Consequences:** These files must be kept in sync going forward —
  update `project_progress.md` after every completed task, and log any
  significant architectural decision here, not just in chat.

---

**2026-08-29 — Trip creation belongs on the admin dashboard, not the
driver app.**
- **What:** `POST /trips` will be called from `admin_web`, not from
  `driver_app`. The driver app's create-trip screen (built in an earlier
  session, never committed) is being abandoned.
- **Why:** Creating a trip requires assigning `route_id`, `vehicle_id`,
  and `driver_id` together — a dispatch decision, not something an
  individual driver should self-serve.
- **Alternatives considered:** Keeping trip creation in the driver app
  (original spec from an external prompt assumed this).
- **Consequences:** The driver app's scope shrinks to: view assigned
  trips, report location, validate tickets. Simpler, and matches how a
  real bus operator's driver role would actually work.

---

**2026-08-29 — React + TypeScript, not Flutter Web or Vue.**
- **What:** The admin dashboard is a new React + TypeScript codebase,
  not a third Flutter target.
- **Why:** The original project plan specified a web admin dashboard in
  React; "React Native" (mentioned to the instructor) was a mobile-only
  framework mix-up, corrected here rather than discovered later. React
  is also the most transferable skill for the project owner's future
  internships, versus reusing Flutter (already comfortable) or adopting
  Vue (smaller job-market share).
- **Alternatives considered:** Flutter Web (reuse existing skills, but
  no new learning; historically weaker web ergonomics), Vue (smaller
  ecosystem for this person's stated career goals).
- **Consequences:** A second language/ecosystem (TypeScript/npm) now
  exists in this monorepo alongside Dart and JavaScript(Node). Some
  duplicated concepts (e.g., a `Trip` type in three places: Dart model,
  Node model, TS type) — acceptable for this project's scope; not worth
  a shared-schema code-generation setup for an internship MVP.

---

**2026-08-29 — Ant Design as the component library.**
- **What:** Using Ant Design for tables, forms, and layout.
- **Why:** No strong preference expressed by the project owner between
  Ant Design, shadcn/ui, and Mantine; Ant Design was chosen because it's
  purpose-built for admin-dashboard UI specifically, minimizing custom
  component-building time on a project that's already run long past its
  original 3-week estimate.
- **Alternatives considered:** shadcn/ui + Tailwind (currently more
  in-demand skill, more manual assembly required), Mantine (middle
  ground).
- **Consequences:** Bundle size is larger than a hand-assembled
  Tailwind setup, but irrelevant for an internally-used admin tool with
  no performance requirement.

---

**2026-08-29 — Three new backend endpoints required, none yet built.**
- **What:** `GET /trips/:id/bookings`, `GET /users`, `PATCH /users/:id/role`,
  `GET /admin/stats` are all new — confirmed none of them exist by
  reading the actual route files (`backend/src/routes/`), not assumed.
- **Why:** No admin-scoped reads exist today for bookings-by-trip or
  users; no way to change a user's role via the API at all (today it's a
  raw MongoDB edit, as documented in `driver_app/migration/README.md`).
- **Consequences:** Frontend work on Phases 3-5 is blocked on these
  endpoints landing first — see `project_progress.md` for the task order.
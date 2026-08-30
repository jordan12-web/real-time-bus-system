# Admin Web Dashboard — Decision Log

Format per entry: date, what changed, why, alternatives considered,
consequences. Newest first.

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

# Guzo Real-Time Bus System — Admin Web Technical Guide

---

## 1. System Overview & Architecture

The **Admin Web Portal** (`admin_web`) is a modern React web application built with **Vite**, **TypeScript**, **Ant Design (`antd: ^5.22.5`)**, and **TanStack React Query (`@tanstack/react-query: ^5.62.0`)**. It provides system administrators with centralized fleet management, intercity trip scheduling, passenger role promotion, revenue analytics, and transaction auditing.

### Tech Stack & Architecture Pattern
```
┌─────────────────────────────────────────────────────────┐
│                    React 18 Components                  │
│       Pages: DashboardPage, TripsPage, UsersPage...      │
│       Shell: DashboardShell (Fixed Sidebar Layout)      │
└────────────────────────────┬────────────────────────────┘
                             │
                             ▼
┌─────────────────────────────────────────────────────────┐
│               Data Fetching & Cache Layer               │
│      TanStack React Query (useQuery, useMutation)       │
└────────────────────────────┬────────────────────────────┘
                             │
                             ▼
┌─────────────────────────────────────────────────────────┐
│                  Network & Auth Layer                   │
│         Axios Client + JWT Interceptors & AuthContext   │
└────────────────────────────┴────────────────────────────┘
```

---

## 2. Technical Need-to-Knows & Code Snippets

### A. Fixed-Sidebar Layout Engineering (`DashboardShell.tsx`)
To ensure that long scrollable data tables (e.g. 50+ users or trips) never cause the left navigation menu to scroll out of view, the layout uses a **pinned fixed-sidebar CSS architecture**:

```tsx
// components/DashboardShell.tsx
export default function DashboardShell({ children }: { children: ReactNode }) {
  const navigate = useNavigate();
  const location = useLocation();
  const { user, logout } = useAuth();

  return (
    <Layout style={{ height: '100vh', overflow: 'hidden' }}>
      {/* Fixed Left Navigation Sider */}
      <Sider
        width={220}
        style={{
          overflow: 'auto',
          height: '100vh',
          position: 'fixed',
          left: 0,
          top: 0,
          bottom: 0,
          backgroundColor: '#0B1220',
          zIndex: 100,
        }}
      >
        <div style={{ padding: '20px 16px', textAlign: 'center' }}>
          <span style={{ background: 'linear-gradient(135deg, #10B981, #6366F1)', color: 'white', borderRadius: 8, padding: '4px 10px', fontWeight: 800 }}>
            Guzo
          </span>
          <span style={{ color: 'white', fontSize: 17, fontWeight: 700, marginLeft: 8 }}>Admin</span>
        </div>
        <Menu theme="dark" mode="inline" selectedKeys={[location.pathname]} items={NAV_ITEMS} onClick={({ key }) => navigate(key)} />
      </Sider>

      {/* Main Right Content Pane (Scrolls Independently) */}
      <Layout style={{ marginLeft: 220, height: '100vh', display: 'flex', flexDirection: 'column' }}>
        <Header style={{ background: '#fff', display: 'flex', alignItems: 'center', justifyContent: 'space-between', padding: '0 28px', flexShrink: 0, height: 64 }}>
          <Typography.Title level={4} style={{ margin: 0 }}>System Administration</Typography.Title>
          <Button icon={<LogoutOutlined />} onClick={logout} danger>Log Out</Button>
        </Header>
        <Content style={{ padding: '24px 28px', overflowY: 'auto', flex: 1, backgroundColor: '#F8FAFC' }}>
          {children}
        </Content>
      </Layout>
    </Layout>
  );
}
```

---

### B. React Query Data Caching & Mutation Invalidation
Server state management is decoupled from React UI components using **TanStack React Query**. Creating a trip automatically invalidates the `trips` query cache, triggering a background refetch without page reloads:

```tsx
// hooks/useCreateTrip.ts
export function useCreateTrip() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: (newTrip: CreateTripInput) => tripsApi.createTrip(newTrip),
    onSuccess: () => {
      // Invalidate and refetch trips list instantly
      queryClient.invalidateQueries({ queryKey: ['trips'] });
    },
  });
}
```

---

### C. Unified System Branding (`App.tsx`)
The Admin Web portal adopts the exact same Emerald Green (`#10B981`) color scheme used across the passenger and driver mobile apps via Ant Design's `ConfigProvider`:

```tsx
// App.tsx
export default function App() {
  return (
    <ConfigProvider theme={{ token: { colorPrimary: "#10B981" } }}>
      <QueryClientProvider client={queryClient}>
        <AuthProvider>
          <BrowserRouter>
            <Routes>
              <Route path="/login" element={<LoginPage />} />
              <Route path="/dashboard" element={<ProtectedRoute><DashboardPage /></ProtectedRoute>} />
              <Route path="/trips" element={<ProtectedRoute><TripsPage /></ProtectedRoute>} />
              <Route path="/users" element={<ProtectedRoute><UsersPage /></ProtectedRoute>} />
              <Route path="/payments" element={<ProtectedRoute><PaymentsPage /></ProtectedRoute>} />
            </Routes>
          </BrowserRouter>
        </AuthProvider>
      </QueryClientProvider>
    </ConfigProvider>
  );
}
```

---

## 3. End-to-End Traced Technical Workflows

### Traced Workflow: Admin Trip Creation & Fleet Allocation
```
Administrator               Admin Web (TripsPage)            Backend (tripController)         MongoDB Database
      │                              │                                  │                            │
      │── 1. Fills Trip Form ───────>│                                  │                            │
      │    (Origin, Dest, Price)     │                                  │                            │
      │── 2. Clicks "Create Trip" ──>│── 3. useCreateTrip() Mutation ──>│                            │
      │                              │    POST /api/trips               │                            │
      │                              │    (Headers: Bearer JWT)         │── 4. Verify Admin Role ───>│
      │                              │                                  │── 5. Insert Trip Record ──>│
      │                              │                                  │<── 6. Saved Trip Object ───│
      │                              │<── 7. Returns 201 Created ───────│                            │
      │                              │                                                               │
      │                              │── 8. invalidateQueries(['trips'])                             │
      │                              │── 9. Auto refetch GET /api/trips                             │
      │<── 10. Table Updates Live ───│                                                               │
```

---

## 4. Anticipated Instructor Defense Q&A

> **Q1: Why did you use TanStack React Query instead of Redux for web state management?**  
> **A:** Server state (trips, users, payments) is fundamentally different from client UI state. React Query handles query caching, background polling, automatic retries, deduplication, and cache invalidation out-of-the-box with 90% less boilerplate code than Redux.

> **Q2: How did you fix the sidebar scrolling defect when viewing long tables on the admin portal?**  
> **A:** Originally, the outer `<Layout>` handled body scrolling, causing the `<Sider>` to scroll out of view when tables expanded vertically. We fixed this by pinning the `<Sider>` with `position: fixed`, `height: 100vh`, giving the main content container `marginLeft: 220px`, and setting `overflowY: auto` on `<Content>`. Now only the data table pane scrolls.

> **Q3: How does the admin web portal prevent unauthorized access to administrative endpoints?**  
> **A:** Access control occurs at two levels:  
> 1. **Client-side:** `ProtectedRoute` checks `useAuth().user?.role === 'admin'`. Non-admin users are redirected to `/login`.  
> 2. **Server-side:** Backend routes use `authorize(['admin'])` middleware to inspect the JWT signature and role claims. Any attempted direct API manipulation by passengers or drivers returns HTTP 403 Forbidden.

---

## 5. Future Improvements & Roadmap
1. **Live Admin Fleet Overlay Map:** Integrate Mapbox / Leaflet on `DashboardPage` to visualize all active bus locations concurrently.
2. **CSV / Excel Report Exporting:** Add one-click CSV export functionality to `PaymentsPage` and `UsersPage` for financial reporting.

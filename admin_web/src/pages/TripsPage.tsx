import { Typography } from 'antd';
import DashboardShell from '../components/DashboardShell';

// TODO(Phase 3, project_progress.md): trip list + create trip, fed by
// GET/POST /trips (both already exist). Manifest view needs a new backend
// endpoint, GET /trips/:id/bookings.
export default function TripsPage() {
  return (
    <DashboardShell>
      <Typography.Title level={3}>Trips</Typography.Title>
      <Typography.Text type="secondary">
        Trip list and creation coming in Phase 3 — see docs/project_progress.md.
      </Typography.Text>
    </DashboardShell>
  );
}

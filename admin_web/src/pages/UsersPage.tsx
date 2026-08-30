import { Typography } from 'antd';
import DashboardShell from '../components/DashboardShell';

// TODO(Phase 4, project_progress.md): user list + role promotion, fed by
// two new backend endpoints: GET /users, PATCH /users/:id/role. This is
// the one that directly replaces the manual MongoDB role edit documented
// in driver_app/migration/README.md.
export default function UsersPage() {
  return (
    <DashboardShell>
      <Typography.Title level={3}>Users</Typography.Title>
      <Typography.Text type="secondary">
        User list and role promotion coming in Phase 4 — see docs/project_progress.md.
      </Typography.Text>
    </DashboardShell>
  );
}

import { Typography } from 'antd';
import DashboardShell from '../components/DashboardShell';

// TODO(Phase 5, project_progress.md): stat cards fed by GET /admin/stats
// once that backend endpoint exists.
export default function DashboardPage() {
  return (
    <DashboardShell>
      <Typography.Title level={3}>Dashboard</Typography.Title>
      <Typography.Text type="secondary">
        Stats coming in Phase 5 — see docs/project_progress.md.
      </Typography.Text>
    </DashboardShell>
  );
}

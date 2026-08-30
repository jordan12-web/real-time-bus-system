import { Table, Tag, Select, Typography, Alert } from 'antd';
import { useUsers } from '../hooks/useUsers';
import { useUpdateUserRole } from '../hooks/usePromoteUser';
import type { AdminUser, UserRole } from '../types/user';
import DashboardShell from '../components/DashboardShell';
import { extractErrorMessage } from '../api';

const ROLE_COLORS: Record<UserRole, string> = {
  admin: 'purple',
  driver: 'blue',
  passenger: 'default',
};

const ROLE_OPTIONS: { value: UserRole; label: string }[] = [
  { value: 'passenger', label: 'Passenger' },
  { value: 'driver', label: 'Driver' },
  { value: 'admin', label: 'Admin' },
];

export default function UsersPage() {
  const { data: users, isLoading, error } = useUsers();
  const updateRole = useUpdateUserRole();

  return (
    <DashboardShell>
      <Typography.Title level={3}>Users</Typography.Title>

      {error && (
        <Alert type="error" message={extractErrorMessage(error)} style={{ marginBottom: 16 }} />
      )}
      {updateRole.isError && (
        <Alert
          type="error"
          message={extractErrorMessage(updateRole.error)}
          style={{ marginBottom: 16 }}
          closable
        />
      )}

      <Table<AdminUser>
        rowKey="id"
        loading={isLoading}
        dataSource={users}
        columns={[
          { title: 'Name', dataIndex: 'full_name' },
          { title: 'Email', dataIndex: 'email' },
          { title: 'Phone', dataIndex: 'phone_number', render: (v) => v ?? '—' },
          {
            title: 'Role',
            dataIndex: 'role',
            render: (role: UserRole) => <Tag color={ROLE_COLORS[role]}>{role}</Tag>,
          },
          {
            title: 'Change Role',
            key: 'action',
            render: (_, user) => (
              <Select<UserRole>
                value={user.role}
                options={ROLE_OPTIONS}
                style={{ width: 140 }}
                loading={updateRole.isPending && updateRole.variables?.userId === user.id}
                onChange={(newRole) => updateRole.mutate({ userId: user.id, role: newRole })}
              />
            ),
          },
        ]}
      />
    </DashboardShell>
  );
}
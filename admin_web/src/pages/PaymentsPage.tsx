import { Table, Tag, Typography, Alert } from 'antd';
import dayjs from 'dayjs';
import { usePayments } from '../hooks/usePayments';
import type { Payment, PaymentStatus } from '../types/payment';
import DashboardShell from '../components/DashboardShell';
import { extractErrorMessage } from '../api';

const STATUS_COLORS: Record<PaymentStatus, string> = {
  pending: 'orange',
  success: 'green',
  failed: 'red',
};

export default function PaymentsPage() {
  const { data: payments, isLoading, error } = usePayments();

  return (
    <DashboardShell>
      <Typography.Title level={3}>Payments</Typography.Title>

      {error && <Alert type="error" message={extractErrorMessage(error)} style={{ marginBottom: 16 }} />}

      <Table<Payment>
        rowKey="id"
        loading={isLoading}
        dataSource={payments}
        columns={[
          {
            title: 'Amount',
            dataIndex: 'amount',
            render: (v: number, p) => `${v} ${p.currency}`,
          },
          {
            title: 'Status',
            dataIndex: 'status',
            render: (status: PaymentStatus) => <Tag color={STATUS_COLORS[status]}>{status}</Tag>,
          },
          { title: 'Chapa Tx Ref', dataIndex: 'chapa_tx_ref' },
          {
            title: 'Seat',
            key: 'seat',
            render: (_, p) => p.booking?.seat_number ?? '—',
          },
          {
            title: 'Date',
            dataIndex: 'created_at',
            render: (v: string) => dayjs(v).format('YYYY-MM-DD HH:mm'),
          },
        ]}
      />
    </DashboardShell>
  );
}
import { Row, Col, Card, Statistic, Typography, Alert } from 'antd';
import { CarOutlined, BookOutlined, DollarOutlined } from '@ant-design/icons';
import { useStats } from '../hooks/useStats';
import DashboardShell from '../components/DashboardShell';
import { extractErrorMessage } from '../api';

export default function DashboardPage() {
  const { data: stats, isLoading, error } = useStats();

  return (
    <DashboardShell>
      <Typography.Title level={3}>Dashboard</Typography.Title>

      {error && <Alert type="error" message={extractErrorMessage(error)} style={{ marginBottom: 16 }} />}

      <Row gutter={16}>
        <Col span={8}>
          <Card loading={isLoading}>
            <Statistic
              title="Total Trips"
              value={stats?.tripCount}
              prefix={<CarOutlined />}
            />
          </Card>
        </Col>
        <Col span={8}>
          <Card loading={isLoading}>
            <Statistic
              title="Total Bookings"
              value={stats?.bookingCount}
              prefix={<BookOutlined />}
            />
          </Card>
        </Col>
        <Col span={8}>
          <Card loading={isLoading}>
            <Statistic
              title="Total Revenue"
              value={stats?.totalRevenue}
              precision={2}
              prefix={<DollarOutlined />}
              suffix={stats?.currency}
            />
          </Card>
        </Col>
      </Row>
    </DashboardShell>
  );
}
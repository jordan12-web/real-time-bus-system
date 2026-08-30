import { useParams, useNavigate } from 'react-router-dom';
import { Table, Tag, Typography, Alert, Button, Descriptions } from 'antd';
import { ArrowLeftOutlined } from '@ant-design/icons';
import dayjs from 'dayjs';
import { useTrip, useTripBookings } from '../hooks/useTripBookings';
import type { TripBooking, BookingStatus } from '../types/trip';
import DashboardShell from '../components/DashboardShell';
import { extractErrorMessage } from '../api';

const BOOKING_STATUS_COLORS: Record<BookingStatus, string> = {
  pending: 'orange',
  confirmed: 'green',
  cancelled: 'default',
  expired: 'red',
};

export default function TripDetailPage() {
  const { id } = useParams<{ id: string }>();
  const navigate = useNavigate();
  const { data: trip } = useTrip(id);
  const { data: bookings, isLoading, error } = useTripBookings(id);

  return (
    <DashboardShell>
      <Button
        icon={<ArrowLeftOutlined />}
        onClick={() => navigate('/trips')}
        style={{ marginBottom: 16 }}
      >
        Back to Trips
      </Button>

      <Typography.Title level={3}>
        {trip ? `${trip.origin} → ${trip.destination}` : 'Trip Manifest'}
      </Typography.Title>

      {trip && (
        <Descriptions bordered size="small" column={2} style={{ marginBottom: 24 }}>
          <Descriptions.Item label="Departure">
            {dayjs(trip.departure_time).format('YYYY-MM-DD HH:mm')}
          </Descriptions.Item>
          <Descriptions.Item label="Arrival">
            {dayjs(trip.arrival_time).format('YYYY-MM-DD HH:mm')}
          </Descriptions.Item>
          <Descriptions.Item label="Price/Seat">{trip.price_per_seat} ETB</Descriptions.Item>
          <Descriptions.Item label="Status">{trip.status}</Descriptions.Item>
        </Descriptions>
      )}

      {error && <Alert type="error" message={extractErrorMessage(error)} style={{ marginBottom: 16 }} />}

      <Table<TripBooking>
        rowKey="id"
        loading={isLoading}
        dataSource={bookings}
        locale={{ emptyText: 'No bookings on this trip yet.' }}
        columns={[
          {
            title: 'Passenger',
            key: 'passenger',
            render: (_, booking) =>
              booking.passenger
                ? `${booking.passenger.full_name} (${booking.passenger.email})`
                : booking.user_id,
          },
          { title: 'Seat', dataIndex: 'seat_number', render: (v) => v ?? '—' },
          {
            title: 'Payment Status',
            dataIndex: 'status',
            render: (status: BookingStatus) => (
              <Tag color={BOOKING_STATUS_COLORS[status]}>{status}</Tag>
            ),
          },
          {
            title: 'Amount',
            dataIndex: 'total_amount',
            render: (v: number, booking) => `${v} ${booking.currency}`,
          },
          {
            title: 'Booked At',
            dataIndex: 'created_at',
            render: (v: string) => dayjs(v).format('YYYY-MM-DD HH:mm'),
          },
        ]}
      />
    </DashboardShell>
  );
}
import { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import {
  Table,
  Tag,
  Typography,
  Alert,
  Button,
  Modal,
  Form,
  Input,
  InputNumber,
  Select,
  DatePicker,
} from 'antd';
import { PlusOutlined } from '@ant-design/icons';
import dayjs, { type Dayjs } from 'dayjs';
import { useTrips } from '../hooks/useTrips';
import { useCreateTrip } from '../hooks/useCreateTrip';
import { useUsers } from '../hooks/useUsers';
import type { Trip, TripStatus } from '../types/trip';
import DashboardShell from '../components/DashboardShell';
import { extractErrorMessage } from '../api';

const STATUS_COLORS: Record<TripStatus, string> = {
  scheduled: 'blue',
  in_transit: 'processing',
  completed: 'green',
  cancelled: 'red',
};

interface CreateTripFormValues {
  route_id: string;
  vehicle_id: string;
  driver_id: string;
  origin: string;
  destination: string;
  price_per_seat: number;
  departure_time: Dayjs;
  arrival_time: Dayjs;
}

export default function TripsPage() {
  const navigate = useNavigate();
  const { data: trips, isLoading, error } = useTrips();
  const { data: users } = useUsers();
  const createTrip = useCreateTrip();
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [form] = Form.useForm<CreateTripFormValues>();

  const driverOptions = (users ?? [])
    .filter((u) => u.role === 'driver')
    .map((u) => ({ value: u.id, label: `${u.full_name} (${u.email})` }));

  async function handleCreate(values: CreateTripFormValues) {
    if (!values.departure_time.isBefore(values.arrival_time)) {
      form.setFields([{ name: 'arrival_time', errors: ['Arrival must be after departure.'] }]);
      return;
    }
    await createTrip.mutateAsync({
      route_id: values.route_id,
      vehicle_id: values.vehicle_id,
      driver_id: values.driver_id,
      origin: values.origin,
      destination: values.destination,
      price_per_seat: values.price_per_seat,
      departure_time: values.departure_time.toISOString(),
      arrival_time: values.arrival_time.toISOString(),
    });
    setIsModalOpen(false);
    form.resetFields();
  }

  return (
    <DashboardShell>
      <div
        style={{
          display: 'flex',
          justifyContent: 'space-between',
          alignItems: 'center',
          marginBottom: 16,
        }}
      >
        <Typography.Title level={3} style={{ margin: 0 }}>
          Trips
        </Typography.Title>
        <Button type="primary" icon={<PlusOutlined />} onClick={() => setIsModalOpen(true)}>
          Create Trip
        </Button>
      </div>

      {error && <Alert type="error" message={extractErrorMessage(error)} style={{ marginBottom: 16 }} />}

      <Table<Trip>
        rowKey="id"
        loading={isLoading}
        dataSource={trips}
        onRow={(trip) => ({ onClick: () => navigate(`/trips/${trip.id}`), style: { cursor: 'pointer' } })}
        columns={[
          { title: 'Origin', dataIndex: 'origin' },
          { title: 'Destination', dataIndex: 'destination' },
          {
            title: 'Departure',
            dataIndex: 'departure_time',
            render: (v: string) => dayjs(v).format('YYYY-MM-DD HH:mm'),
          },
          { title: 'Price/Seat', dataIndex: 'price_per_seat', render: (v: number) => `${v} ETB` },
          {
            title: 'Status',
            dataIndex: 'status',
            render: (status: TripStatus) => <Tag color={STATUS_COLORS[status]}>{status}</Tag>,
          },
        ]}
      />

      <Modal
        title="Create Trip"
        open={isModalOpen}
        onCancel={() => setIsModalOpen(false)}
        onOk={() => form.submit()}
        confirmLoading={createTrip.isPending}
        okText="Create"
      >
        {createTrip.isError && (
          <Alert
            type="error"
            message={extractErrorMessage(createTrip.error)}
            style={{ marginBottom: 16 }}
          />
        )}
        <Form<CreateTripFormValues>
          form={form}
          layout="vertical"
          onFinish={handleCreate}
          initialValues={{ route_id: 'route-bdr-add-01', vehicle_id: 'bus-01' }}
        >
          <Form.Item
            name="route_id"
            label="Route ID"
            extra="Free text — no separate Route records exist, any non-empty string works."
            rules={[{ required: true }]}
          >
            <Input />
          </Form.Item>
          <Form.Item name="vehicle_id" label="Vehicle ID" rules={[{ required: true }]}>
            <Input />
          </Form.Item>
          <Form.Item
            name="driver_id"
            label="Driver"
            rules={[{ required: true, message: 'Select a driver' }]}
          >
            <Select
              options={driverOptions}
              placeholder={
                driverOptions.length === 0 ? 'No driver-role accounts yet — promote one on the Users page' : 'Select a driver'
              }
              disabled={driverOptions.length === 0}
              showSearch
              optionFilterProp="label"
            />
          </Form.Item>
          <Form.Item name="origin" label="Origin" rules={[{ required: true }]}>
            <Input />
          </Form.Item>
          <Form.Item name="destination" label="Destination" rules={[{ required: true }]}>
            <Input />
          </Form.Item>
          <Form.Item name="price_per_seat" label="Price per seat (ETB)" rules={[{ required: true }]}>
            <InputNumber min={1} style={{ width: '100%' }} />
          </Form.Item>
          <Form.Item
            name="departure_time"
            label="Departure"
            initialValue={dayjs().add(1, 'hour')}
            rules={[{ required: true }]}
          >
            <DatePicker showTime style={{ width: '100%' }} />
          </Form.Item>
          <Form.Item
            name="arrival_time"
            label="Arrival"
            initialValue={dayjs().add(7, 'hour')}
            rules={[{ required: true }]}
          >
            <DatePicker showTime style={{ width: '100%' }} />
          </Form.Item>
        </Form>
      </Modal>
    </DashboardShell>
  );
}
import type { ReactNode } from 'react';
import { Layout, Menu, Button, Typography } from 'antd';
import {
  DashboardOutlined,
  CarOutlined,
  UserOutlined,
  LogoutOutlined,
} from '@ant-design/icons';
import { useNavigate, useLocation } from 'react-router-dom';
import { useAuth } from '../hooks/useAuth';

const { Header, Sider, Content } = Layout;

const NAV_ITEMS = [
  { key: '/dashboard', icon: <DashboardOutlined />, label: 'Dashboard' },
  { key: '/trips', icon: <CarOutlined />, label: 'Trips' },
  { key: '/users', icon: <UserOutlined />, label: 'Users' },
];

export default function DashboardShell({ children }: { children: ReactNode }) {
  const navigate = useNavigate();
  const location = useLocation();
  const { user, logout } = useAuth();

  return (
    <Layout style={{ minHeight: '100vh' }}>
      <Sider>
        <div
          style={{
            color: 'white',
            fontWeight: 700,
            fontSize: 18,
            padding: '16px',
            textAlign: 'center',
          }}
        >
          Guzo Bus
        </div>
        <Menu
          theme="dark"
          mode="inline"
          selectedKeys={[location.pathname]}
          items={NAV_ITEMS}
          onClick={({ key }) => navigate(key)}
        />
      </Sider>
      <Layout>
        <Header
          style={{
            background: '#fff',
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'flex-end',
            gap: 12,
            padding: '0 24px',
          }}
        >
          <Typography.Text>{user?.full_name ?? user?.email}</Typography.Text>
          <Button icon={<LogoutOutlined />} onClick={logout}>
            Log Out
          </Button>
        </Header>
        <Content style={{ margin: 24 }}>{children}</Content>
      </Layout>
    </Layout>
  );
}

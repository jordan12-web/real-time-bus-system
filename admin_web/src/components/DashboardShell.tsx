import type { ReactNode } from 'react';
import { Layout, Menu, Button, Typography } from 'antd';
import {
  DashboardOutlined,
  CarOutlined,
  UserOutlined,
  LogoutOutlined,
  CreditCardOutlined,
} from '@ant-design/icons';
import { useNavigate, useLocation } from 'react-router-dom';
import { useAuth } from '../hooks/useAuth';

const { Header, Sider, Content } = Layout;

const NAV_ITEMS = [
  { key: '/dashboard', icon: <DashboardOutlined />, label: 'Dashboard' },
  { key: '/trips', icon: <CarOutlined />, label: 'Trips' },
  { key: '/users', icon: <UserOutlined />, label: 'Users' },
  { key: '/payments', icon: <CreditCardOutlined />, label: 'Payments' },
];

export default function DashboardShell({ children }: { children: ReactNode }) {
  const navigate = useNavigate();
  const location = useLocation();
  const { user, logout } = useAuth();

  return (
    <Layout style={{ height: '100vh', overflow: 'hidden' }}>
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
          borderRight: '1px solid rgba(255, 255, 255, 0.08)',
          zIndex: 100,
        }}
      >
        <div
          style={{
            padding: '20px 16px',
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center',
            gap: 8,
          }}
        >
          <span
            style={{
              background: 'linear-gradient(135deg, #10B981, #6366F1)',
              color: 'white',
              borderRadius: '8px',
              padding: '4px 10px',
              fontSize: '14px',
              fontWeight: 800,
              letterSpacing: '-0.3px',
            }}
          >
            Guzo
          </span>
          <span style={{ color: 'white', fontSize: '17px', fontWeight: 700 }}>
            Admin Portal
          </span>
        </div>
        <Menu
          theme="dark"
          mode="inline"
          style={{ backgroundColor: 'transparent', borderRight: 'none' }}
          selectedKeys={[location.pathname]}
          items={NAV_ITEMS}
          onClick={({ key }) => navigate(key)}
        />
      </Sider>

      <Layout style={{ marginLeft: 220, height: '100vh', display: 'flex', flexDirection: 'column' }}>
        <Header
          style={{
            background: '#ffffff',
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'space-between',
            padding: '0 28px',
            boxShadow: '0 1px 3px rgba(0,0,0,0.05)',
            zIndex: 10,
            flexShrink: 0,
            height: 64,
          }}
        >
          <Typography.Title level={4} style={{ margin: 0, color: '#0F172A', fontWeight: 700 }}>
            System Administration
          </Typography.Title>
          <div style={{ display: 'flex', alignItems: 'center', gap: 16 }}>
            <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'flex-end' }}>
              <Typography.Text style={{ fontWeight: 600, color: '#0F172A', fontSize: 14 }}>
                {user?.full_name ?? user?.email ?? 'System Administrator'}
              </Typography.Text>
              <Typography.Text type="secondary" style={{ fontSize: 12 }}>
                Role: Super Admin
              </Typography.Text>
            </div>
            <Button
              type="default"
              icon={<LogoutOutlined />}
              onClick={logout}
              danger
              style={{ borderRadius: 6 }}
            >
              Log Out
            </Button>
          </div>
        </Header>

        <Content
          style={{
            padding: '24px 28px',
            overflowY: 'auto',
            flex: 1,
            backgroundColor: '#F8FAFC',
          }}
        >
          {children}
        </Content>
      </Layout>
    </Layout>
  );
}
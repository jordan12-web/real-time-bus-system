import { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { Button, Card, Form, Input, Typography, Alert } from 'antd';
import { useAuth } from '../hooks/useAuth';

interface LoginFormValues {
  email: string;
  password: string;
}

export default function LoginPage() {
  const { login, isLoading, errorMessage } = useAuth();
  const navigate = useNavigate();
  const [localError, setLocalError] = useState<string | null>(null);

  async function handleFinish(values: LoginFormValues) {
    setLocalError(null);
    const success = await login(values.email, values.password);
    if (success) {
      navigate('/dashboard');
    }
  }

  return (
    <div
      style={{
        display: 'flex',
        alignItems: 'center',
        justifyContent: 'center',
        minHeight: '100vh',
        background: '#f0f2f5',
      }}
    >
      <Card style={{ width: 360 }}>
        <Typography.Title level={3} style={{ textAlign: 'center' }}>
          Guzo Bus — Admin
        </Typography.Title>
        <Typography.Text
          type="secondary"
          style={{ display: 'block', textAlign: 'center', marginBottom: 24 }}
        >
          Sign in with an admin account
        </Typography.Text>

        {(errorMessage ?? localError) && (
          <Alert
            type="error"
            message={errorMessage ?? localError}
            style={{ marginBottom: 16 }}
          />
        )}

        <Form layout="vertical" onFinish={handleFinish} onFinishFailed={() => setLocalError(null)}>
          <Form.Item
            name="email"
            label="Email"
            rules={[{ required: true, message: 'Email is required' }]}
          >
            <Input type="email" autoComplete="username" />
          </Form.Item>
          <Form.Item
            name="password"
            label="Password"
            rules={[{ required: true, message: 'Password is required' }]}
          >
            <Input.Password autoComplete="current-password" />
          </Form.Item>
          <Form.Item style={{ marginBottom: 0 }}>
            <Button type="primary" htmlType="submit" loading={isLoading} block>
              Log In
            </Button>
          </Form.Item>
        </Form>
      </Card>
    </div>
  );
}

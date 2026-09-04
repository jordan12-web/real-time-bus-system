import { Component, type ErrorInfo, type ReactNode } from 'react';
import { Result, Button, Typography } from 'antd';

interface Props {
  children: ReactNode;
}

interface State {
  error: Error | null;
}


export default class ErrorBoundary extends Component<Props, State> {
  state: State = { error: null };

  static getDerivedStateFromError(error: Error): State {
    return { error };
  }

  componentDidCatch(error: Error, errorInfo: ErrorInfo) {
    // eslint-disable-next-line no-console
    console.error('Uncaught render error:', error, errorInfo);
  }

  render() {
    if (this.state.error) {
      return (
        <div style={{ padding: 48 }}>
          <Result
            status="error"
            title="Something went wrong"
            subTitle="An unexpected error occurred while rendering the dashboard."
            extra={[
              <Button key="reload" type="primary" onClick={() => window.location.reload()}>
                Reload
              </Button>,
            ]}
          >
            <Typography.Paragraph code style={{ whiteSpace: 'pre-wrap', textAlign: 'left' }}>
              {this.state.error.message}
              {'\n\n'}
              {this.state.error.stack}
            </Typography.Paragraph>
          </Result>
        </div>
      );
    }
    return this.props.children;
  }
}
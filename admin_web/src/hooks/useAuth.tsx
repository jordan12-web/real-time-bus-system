import { createContext, useContext, useState, type ReactNode } from 'react';
import { login as loginApi, extractErrorMessage } from '../api';
import { setAuthToken } from '../api/client';
import type { AuthUser } from '../types/auth';

interface AuthContextValue {
  user: AuthUser | null;
  isLoading: boolean;
  errorMessage: string | null;
  login: (email: string, password: string) => Promise<boolean>;
  logout: () => void;
}

const AuthContext = createContext<AuthContextValue | undefined>(undefined);

export function AuthProvider({ children }: { children: ReactNode }) {
  const [user, setUser] = useState<AuthUser | null>(null);
  const [isLoading, setIsLoading] = useState(false);
  const [errorMessage, setErrorMessage] = useState<string | null>(null);

  async function login(email: string, password: string): Promise<boolean> {
    setIsLoading(true);
    setErrorMessage(null);
    try {
      const result = await loginApi(email, password);
      if (result.user.role !== 'admin') {
        setErrorMessage(
          `This account has role "${result.user.role}", not "admin". ` +
            'Only admin accounts can access this dashboard.',
        );
        return false;
      }
      setAuthToken(result.accessToken);
      setUser(result.user);
      return true;
    } catch (error) {
      setErrorMessage(extractErrorMessage(error));
      return false;
    } finally {
      setIsLoading(false);
    }
  }

  function logout() {
    setAuthToken(null);
    setUser(null);
  }

  return (
    <AuthContext.Provider value={{ user, isLoading, errorMessage, login, logout }}>
      {children}
    </AuthContext.Provider>
  );
}

export function useAuth(): AuthContextValue {
  const context = useContext(AuthContext);
  if (!context) {
    throw new Error('useAuth must be used within an AuthProvider');
  }
  return context;
}

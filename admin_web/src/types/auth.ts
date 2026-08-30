
export type UserRole = 'passenger' | 'driver' | 'admin';

export interface AuthUser {
  id: string;
  full_name: string;
  email: string;
  role: UserRole;
}

export interface LoginResponse {
  accessToken: string;
  refreshToken: string;
  user: AuthUser;
}

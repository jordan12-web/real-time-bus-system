/** Matches backend/src/models/User.js's role enum exactly. */
export type UserRole = 'passenger' | 'driver' | 'admin';

/** Matches the real /auth/login and /auth/me response shape (snake_case
 * fields — verified against docs/api_key_format.md, no normalization). */
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

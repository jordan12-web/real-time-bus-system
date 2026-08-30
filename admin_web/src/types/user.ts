import type { UserRole } from './auth';

export type { UserRole };


export interface AdminUser {
  id: string;
  full_name: string;
  email: string;
  phone_number: string | null;
  role: UserRole;
  created_at: string;
}
import { apiClient } from './client';
import type { AdminUser, UserRole } from '../types/user';

export async function listUsers(): Promise<AdminUser[]> {
  const response = await apiClient.get<AdminUser[]>('/users');
  return response.data;
}

export async function updateUserRole(userId: string, role: UserRole): Promise<AdminUser> {
  const response = await apiClient.patch<AdminUser>(`/users/${userId}/role`, { role });
  return response.data;
}
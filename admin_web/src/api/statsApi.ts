import { apiClient } from './client';
import type { AdminStats } from '../types/stats';

export async function getStats(): Promise<AdminStats> {
  const response = await apiClient.get<AdminStats>('/admin/stats');
  return response.data;
}
import { apiClient } from './client';
import type { Payment } from '../types/payment';

export async function listPayments(): Promise<Payment[]> {
  const response = await apiClient.get<Payment[]>('/payments');
  return response.data;
}
import { apiClient } from './client';

export async function revokeTicket(ticketId: string): Promise<void> {
  await apiClient.post(`/tickets/${ticketId}/revoke`);
}